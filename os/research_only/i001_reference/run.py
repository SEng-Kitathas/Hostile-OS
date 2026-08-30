from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def find_qemu() -> Path:
    explicit = os.environ.get("HOSTILE_QEMU")
    if explicit:
        p = Path(explicit).expanduser()
        if p.is_file():
            return p
        raise SystemExit(f"HOSTILE_QEMU points to missing file: {p}")
    for name in ["qemu-system-i386", "qemu-system-i386.exe"]:
        found = shutil.which(name)
        if found:
            return Path(found)
    if os.name == "nt":
        common = Path(r"C:\Program Files\qemu\qemu-system-i386.exe")
        if common.is_file():
            return common
    raise SystemExit("qemu-system-i386 not found; set HOSTILE_QEMU or put it on PATH")


def resolved_identity_path(path: Path) -> Path:
    try:
        return path.resolve(strict=True)
    except (OSError, RuntimeError):
        return path.absolute()


def qemu_environment(qemu: Path) -> tuple[dict[str, str], str | None]:
    env = os.environ.copy()
    explicit = os.environ.get("HOSTILE_QEMU_MODULE_DIR") or os.environ.get("QEMU_MODULE_DIR")
    if explicit:
        env["QEMU_MODULE_DIR"] = explicit
        return env, explicit
    # Transplanted layouts supported:
    #   runtime/qemu/bin/qemu-system-i386 -> ../modules
    #   runtime/qemu/run-qemu-i386.sh    -> ./modules
    for candidate in (qemu.parent / "modules", qemu.parent.parent / "modules"):
        if candidate.is_dir():
            env["QEMU_MODULE_DIR"] = str(candidate)
            return env, str(candidate)
    return env, None


def first_line(argv: list[str]) -> str:
    cp = subprocess.run(argv, text=True, capture_output=True, timeout=10, check=False)
    lines = (cp.stdout + cp.stderr).strip().splitlines()
    return lines[0] if lines else "<no version output>"


def boot(qemu: Path, disk: Path, debug: Path, timeout: int) -> dict:
    env, module_dir = qemu_environment(qemu)
    argv = [
        str(qemu), "-accel", "tcg", "-display", "none", "-monitor", "none", "-serial", "none",
        "-nic", "none", "-no-reboot", "-boot", "a",
        "-drive", f"file={disk.as_posix()},format=raw,if=floppy",
        "-device", "isa-debug-exit,iobase=0xf4,iosize=0x04",
        "-debugcon", f"file:{debug.as_posix()}",
        "-global", "isa-debugcon.iobase=0xe9",
    ]
    started = utc_now(); t0 = time.perf_counter()
    proc = subprocess.Popen(argv, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, env=env)
    try:
        _, stderr = proc.communicate(timeout=timeout)
        status = "COMPLETED"; exit_code = proc.returncode
    except subprocess.TimeoutExpired:
        proc.kill(); _, stderr = proc.communicate(); status = "UNKNOWN_TIMEOUT"; exit_code = None
    return {
        "pid": proc.pid, "argv": argv, "started_utc": started, "ended_utc": utc_now(),
        "wall_ms": (time.perf_counter() - t0) * 1000.0, "status": status, "exit_code": exit_code,
        "stderr": stderr.decode("utf-8", errors="replace") if stderr else "", "timeout_seconds": timeout,
        "qemu_module_dir": module_dir,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description="Boot the HOSTILE-OS I001 research-only embodiment twice")
    ap.add_argument("--build-dir", default="build")
    ap.add_argument("--timeout", type=int, default=10)
    args = ap.parse_args()
    here = Path(__file__).resolve().parent
    build = Path(args.build_dir)
    if not build.is_absolute():
        build = here / build
    initial = build / "hostile-research-os.img"
    if not initial.exists():
        cp = subprocess.run([sys.executable, str(here / "build.py"), "--out", str(build)], check=False)
        if cp.returncode != 0:
            return cp.returncode
    qemu = find_qemu()
    disk = build / "hostile-research-os.run.img"
    shutil.copyfile(initial, disk)
    boot1_debug = build / "boot1.debugcon.txt"
    boot2_debug = build / "boot2.debugcon.txt"
    for p in [boot1_debug, boot2_debug]:
        p.unlink(missing_ok=True)
    b1 = boot(qemu, disk, boot1_debug, args.timeout)
    if b1["status"] != "COMPLETED" or b1["exit_code"] != 33:
        print(json.dumps(b1, indent=2)); return 3 if b1["status"] == "UNKNOWN_TIMEOUT" else 1
    # No host disk write occurs between boots. Boot 2 observes Boot 1's durable write.
    b2 = boot(qemu, disk, boot2_debug, args.timeout)
    receipt = {
        "format": "HOSTILE_OS_RESEARCH_ONLY_RUN_V1",
        "warning": "RESEARCH PURPOSES ONLY; this is not the sealed historical I001 science run",
        "qemu": {"invocation_path": str(qemu), "identity_path": str(resolved_identity_path(qemu)), "version": first_line([str(qemu), "--version"]), "sha256": sha256(resolved_identity_path(qemu))},
        "boot1": b1, "boot2": b2,
        "boot1_trace": boot1_debug.read_text(encoding="ascii", errors="replace").splitlines() if boot1_debug.exists() else [],
        "boot2_trace": boot2_debug.read_text(encoding="ascii", errors="replace").splitlines() if boot2_debug.exists() else [],
        "no_host_disk_write_between_boots": True,
    }
    (build / "run_receipt.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps({"boot1": {"pid": b1["pid"], "status": b1["status"], "exit": b1["exit_code"]}, "boot2": {"pid": b2["pid"], "status": b2["status"], "exit": b2["exit_code"]}}, indent=2))
    return 0 if b2["status"] == "COMPLETED" and b2["exit_code"] == 33 else (3 if b2["status"] == "UNKNOWN_TIMEOUT" else 1)


if __name__ == "__main__":
    raise SystemExit(main())
