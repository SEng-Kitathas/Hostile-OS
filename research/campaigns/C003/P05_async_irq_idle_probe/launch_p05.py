from __future__ import annotations

import datetime as dt
import hashlib
import json
import subprocess
import sys
from pathlib import Path

QEMU_TIMEOUT_SECONDS = 8
LLVM = Path(r"E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin")
CLANG = LLVM / "clang.exe"
LLD = LLVM / "ld.lld.exe"
OBJCOPY = LLVM / "llvm-objcopy.exe"
QEMU = Path(r"C:\Program Files\qemu\qemu-system-i386.exe")
PYTHON = Path(r"C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe")


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def run_capture(argv: list[str], stdout_path: Path, stderr_path: Path, timeout: int = 30) -> int:
    with stdout_path.open("wb") as so, stderr_path.open("wb") as se:
        cp = subprocess.run(argv, stdout=so, stderr=se, timeout=timeout, check=False)
    return cp.returncode


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: launch_p05.py RUN_ID", file=sys.stderr)
        return 64

    run_id = sys.argv[1]
    src = Path(__file__).resolve().parent
    repo = src.parents[3]
    run = repo / "research" / "campaigns" / "C003" / "runs" / run_id
    if run.exists():
        print(f"run directory already exists: {run}", file=sys.stderr)
        return 65
    run.mkdir(parents=True)

    mechanism = src / "mechanism.S"
    fixture = src / "fixture.S"
    linker = src / "linker.ld"
    evaluator = src / "evaluate_p05.py"
    launcher = Path(__file__).resolve()

    mechanism_o = run / "mechanism.o"
    fixture_o = run / "fixture.o"
    probe_elf = run / "probe.elf"
    probe = run / "probe.bin"

    build_steps = [
        ("01_clang_mechanism", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(mechanism), "-o", str(mechanism_o)]),
        ("02_clang_fixture", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(fixture), "-o", str(fixture_o)]),
        ("03_link", [str(LLD), "-m", "elf_i386", "-T", str(linker), str(mechanism_o), str(fixture_o), "-o", str(probe_elf)]),
        ("04_objcopy", [str(OBJCOPY), "-O", "binary", str(probe_elf), str(probe)]),
    ]
    for name, argv in build_steps:
        rc = run_capture(argv, run / f"{name}.stdout.txt", run / f"{name}.stderr.txt")
        if rc != 0:
            print(f"{name} failed exit={rc}", file=sys.stderr)
            return 2

    boot = probe.read_bytes()
    if len(boot) != 512 or boot[510:512] != b"\x55\xaa":
        print(f"boot contract failed bytes={len(boot)} sig={boot[510:512].hex() if len(boot) >= 512 else 'short'}", file=sys.stderr)
        return 2

    debugcon = run / "debugcon.txt"
    qstdout = run / "05_qemu.stdout.txt"
    qstderr = run / "05_qemu.stderr.txt"
    qargv = [
        str(QEMU),
        "-accel", "tcg",
        "-display", "none",
        "-monitor", "none",
        "-serial", "none",
        "-no-reboot",
        "-drive", f"file={probe.as_posix()},format=raw,if=floppy",
        "-device", "isa-debug-exit,iobase=0xf4,iosize=0x04",
        "-debugcon", f"file:{debugcon.as_posix()}",
        "-global", "isa-debugcon.iobase=0xe9",
    ]

    started = now()
    with qstdout.open("wb") as so, qstderr.open("wb") as se:
        proc = subprocess.Popen(qargv, stdout=so, stderr=se)
        pid = proc.pid
        try:
            qexit = proc.wait(timeout=QEMU_TIMEOUT_SECONDS)
            qstatus = "COMPLETED"
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=5)
            qexit = None
            qstatus = "UNKNOWN_TIMEOUT"
    ended = now()

    evaluation = run / "evaluation.json"
    eval_stdout = run / "06_evaluator.stdout.txt"
    eval_stderr = run / "06_evaluator.stderr.txt"
    eval_exit = None
    if debugcon.exists():
        eval_exit = run_capture(
            [str(PYTHON), str(evaluator), str(debugcon), str(evaluation)],
            eval_stdout,
            eval_stderr,
        )
    else:
        eval_stdout.write_bytes(b"")
        eval_stderr.write_text("debugcon missing; evaluator not run\n", encoding="utf-8")

    receipt = {
        "run_id": run_id,
        "run_class": "C003_P05_ASYNC_IRQ_IDLE_WAKE_DISCRIMINATOR",
        "scientific_status": qstatus,
        "authority_ceiling": "QEMU virtual PIT/PIC real-mode evidence only",
        "cwd": str(repo),
        "qemu": {
            "pid": pid,
            "argv": qargv,
            "started_utc": started,
            "ended_utc": ended,
            "status": qstatus,
            "exit_code": qexit,
            "timeout_seconds": QEMU_TIMEOUT_SECONDS,
        },
        "tools": {
            "clang": {"path": str(CLANG), "sha256": sha256(CLANG)},
            "lld": {"path": str(LLD), "sha256": sha256(LLD)},
            "objcopy": {"path": str(OBJCOPY), "sha256": sha256(OBJCOPY)},
            "qemu": {"path": str(QEMU), "sha256": sha256(QEMU)},
            "python": {"path": str(PYTHON), "sha256": sha256(PYTHON)},
        },
        "source_sha256": {
            "mechanism": sha256(mechanism),
            "fixture": sha256(fixture),
            "linker": sha256(linker),
            "evaluator": sha256(evaluator),
            "launcher": sha256(launcher),
        },
        "artifacts": {
            "probe_bin": {"path": str(probe), "bytes": len(boot), "sha256": sha256(probe), "boot_signature": "55aa"},
            "debugcon": {"path": str(debugcon), "sha256": sha256(debugcon) if debugcon.exists() else None},
            "evaluation": {"path": str(evaluation), "sha256": sha256(evaluation) if evaluation.exists() else None, "evaluator_exit": eval_exit},
            "qemu_stdout": {"path": str(qstdout), "sha256": sha256(qstdout)},
            "qemu_stderr": {"path": str(qstderr), "sha256": sha256(qstderr)},
            "evaluator_stdout": {"path": str(eval_stdout), "sha256": sha256(eval_stdout)},
            "evaluator_stderr": {"path": str(eval_stderr), "sha256": sha256(eval_stderr)},
        },
    }
    receipt_path = run / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")

    print(f"RUN_DIR={run}")
    print(f"QEMU_STATUS={qstatus}")
    print(f"QEMU_PID={pid} EXIT={qexit} START={started} END={ended}")
    print(f"PROBE_SHA256={sha256(probe)}")
    if debugcon.exists():
        print("DEBUGCON=" + debugcon.read_text(encoding="ascii").replace("\n", r"\n"))
    print(f"EVALUATOR_EXIT={eval_exit}")
    print(f"RECEIPT_SHA256={sha256(receipt_path)}")

    if qstatus == "UNKNOWN_TIMEOUT":
        return 3
    if qexit == 33 and eval_exit == 0:
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
