from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def run_cmd(argv: list[str], cwd: Path, timeout: int) -> dict:
    try:
        p = subprocess.run(argv, cwd=cwd, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                           text=True, encoding="utf-8", errors="replace", timeout=timeout)
        return {"argv": argv, "return_code": p.returncode, "stdout_tail": p.stdout[-8000:], "stderr_tail": p.stderr[-8000:]}
    except subprocess.TimeoutExpired as e:
        return {"argv": argv, "return_code": None, "timeout": True,
                "stdout_tail": (e.stdout or "")[-8000:] if isinstance(e.stdout, str) else "",
                "stderr_tail": (e.stderr or "")[-8000:] if isinstance(e.stderr, str) else ""}


def scan_pr01(root: Path) -> dict:
    runs = root / "research/persistence/D64_PR01/runs"
    completed = 0
    passed = 0
    failed = 0
    unknown = 0
    problems: list[dict] = []
    if not runs.exists():
        return {"completed": 0, "passed": 0, "failed": 0, "unknown": 0, "problems": [{"reason": "runs_missing"}]}
    for d in sorted(p for p in runs.iterdir() if p.is_dir()):
        receipt = d / "receipt.json"
        audit = d / "13_independent_audit.json"
        if not receipt.exists() or not audit.exists():
            unknown += 1
            continue
        completed += 1
        try:
            r = json.loads(receipt.read_text(encoding="utf-8"))
            a = json.loads(audit.read_text(encoding="utf-8"))
            ok = (
                r.get("scientific_status") == "COMPLETED"
                and r.get("boot1", {}).get("exit_code") == 33
                and r.get("boot2", {}).get("exit_code") == 33
                and r.get("process_contract", {}).get("distinct_pids") is True
                and r.get("process_contract", {}).get("boot2_started_after_boot1_ended") is True
                and r.get("process_contract", {}).get("no_host_disk_write_between_boots") is True
                and a.get("passed") is True
            )
            if ok:
                passed += 1
            else:
                failed += 1
                problems.append({"run": d.name, "reason": "closure_not_pass"})
        except Exception as exc:
            failed += 1
            problems.append({"run": d.name, "reason": "parse_error", "detail": repr(exc)})
    return {"completed": completed, "passed": passed, "failed": failed, "unknown": unknown, "problems": problems[:50]}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--hours", type=float, default=8.0)
    ap.add_argument("--interval-seconds", type=float, default=1800.0)
    ap.add_argument("--journal-dir", default=".pcmmad_sync_runs/overnight_2026-08-30")
    ns = ap.parse_args()

    root = Path(__file__).resolve().parents[1]
    journal_dir = root / ns.journal_dir
    journal_dir.mkdir(parents=True, exist_ok=True)
    journal = journal_dir / "integrity.journal.jsonl"
    state = journal_dir / "integrity.state.json"
    deadline = time.monotonic() + max(0.0, ns.hours) * 3600.0
    cycle = 0
    hard_failure = False
    baseline_scan = scan_pr01(root)
    baseline_failed = {x.get("run") for x in baseline_scan.get("problems", []) if x.get("run")}

    def emit(event: dict) -> None:
        event = {"time_utc": utc_now(), **event}
        with journal.open("a", encoding="utf-8", newline="\n") as f:
            f.write(json.dumps(event, sort_keys=True) + "\n")
        state.write_text(json.dumps({"pid": os.getpid(), "cycle": cycle, "hard_failure": hard_failure,
                                     "last_update_utc": event["time_utc"], "last_event": event}, indent=2) + "\n", encoding="utf-8")

    emit({"event": "START", "hours": ns.hours, "interval_seconds": ns.interval_seconds, "baseline_pr01_scan": baseline_scan})
    while time.monotonic() < deadline:
        cycle += 1
        git_fsck = run_cmd(["git", "fsck", "--full"], root, 600)
        lfs = None
        if shutil.which("git"):
            probe = run_cmd(["git", "lfs", "version"], root, 30)
            if probe.get("return_code") == 0:
                lfs = run_cmd(["git", "lfs", "fsck"], root, 600)
        scan = scan_pr01(root)
        current_failed = {x.get("run") for x in scan.get("problems", []) if x.get("run")}
        new_failed = sorted(x for x in current_failed if x not in baseline_failed)
        cycle_fail = git_fsck.get("return_code") not in (0,) or (lfs is not None and lfs.get("return_code") not in (0,)) or bool(new_failed)
        hard_failure = hard_failure or cycle_fail
        emit({"event": "CYCLE", "cycle": cycle, "git_fsck": git_fsck, "git_lfs_fsck": lfs, "pr01_scan": scan, "baseline_failed_runs": sorted(baseline_failed), "new_failed_runs": new_failed, "cycle_failure": cycle_fail})
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            break
        time.sleep(min(ns.interval_seconds, remaining))

    emit({"event": "COMPLETED", "cycles": cycle, "hard_failure": hard_failure})
    return 1 if hard_failure else 0


if __name__ == "__main__":
    raise SystemExit(main())
