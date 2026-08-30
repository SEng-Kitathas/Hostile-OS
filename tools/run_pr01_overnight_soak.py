from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--hours", type=float, default=8.0)
    ap.add_argument("--interval-seconds", type=float, default=120.0)
    ap.add_argument("--max-iterations", type=int, default=240)
    ap.add_argument("--journal-dir", default=".pcmmad_sync_runs/overnight_2026-08-30")
    ns = ap.parse_args()

    root = Path(__file__).resolve().parents[1]
    launcher = root / "research/persistence/D64_PR01/probe/launch_pr01.py"
    journal_dir = root / ns.journal_dir
    journal_dir.mkdir(parents=True, exist_ok=True)
    journal = journal_dir / "pr01_soak.journal.jsonl"
    state = journal_dir / "pr01_soak.state.json"

    deadline = time.monotonic() + max(0.0, ns.hours) * 3600.0
    iteration = 0
    failures = 0
    started = utc_now()

    def emit(event: dict) -> None:
        event = {"time_utc": utc_now(), **event}
        with journal.open("a", encoding="utf-8", newline="\n") as f:
            f.write(json.dumps(event, sort_keys=True) + "\n")
        state.write_text(json.dumps({
            "started_utc": started,
            "last_update_utc": event["time_utc"],
            "iteration": iteration,
            "failures": failures,
            "last_event": event,
            "pid": os.getpid(),
        }, indent=2) + "\n", encoding="utf-8")

    emit({"event": "START", "hours": ns.hours, "interval_seconds": ns.interval_seconds, "max_iterations": ns.max_iterations})

    while iteration < ns.max_iterations and time.monotonic() < deadline:
        iteration += 1
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        run_id = f"{stamp}_d64_pr01_overnight_{iteration:04d}"
        t0 = time.monotonic()
        proc = subprocess.run(
            [sys.executable, str(launcher), run_id],
            cwd=root,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=90,
        )
        elapsed = time.monotonic() - t0
        out_tail = proc.stdout[-4000:]
        err_tail = proc.stderr[-4000:]
        emit({
            "event": "ITERATION",
            "run_id": run_id,
            "return_code": proc.returncode,
            "elapsed_seconds": round(elapsed, 3),
            "stdout_tail": out_tail,
            "stderr_tail": err_tail,
        })
        if proc.returncode != 0:
            failures += 1
            emit({"event": "STOP_ON_FAILURE", "run_id": run_id, "return_code": proc.returncode})
            return proc.returncode or 1

        remaining = deadline - time.monotonic()
        if iteration >= ns.max_iterations or remaining <= 0:
            break
        sleep_for = min(max(0.0, ns.interval_seconds - elapsed), remaining)
        if sleep_for > 0:
            time.sleep(sleep_for)

    emit({"event": "COMPLETED", "iterations": iteration, "failures": failures})
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
