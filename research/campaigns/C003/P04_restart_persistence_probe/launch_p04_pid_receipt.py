from __future__ import annotations

import datetime as dt
import hashlib
import json
import subprocess
import sys
from pathlib import Path

RUN_TIMEOUT_SECONDS = 15
LLVM = Path(r"E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin")
CLANG = LLVM / "clang.exe"
LLD = LLVM / "ld.lld.exe"
OBJCOPY = LLVM / "llvm-objcopy.exe"
QEMU = Path(r"C:\Program Files\qemu\qemu-system-i386.exe")
PYTHON = Path(r"C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe")
EXPECTED_QEMU_EXIT = 33


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


def run_qemu(argv: list[str], stdout_path: Path, stderr_path: Path) -> dict:
    started = now()
    with stdout_path.open("wb") as so, stderr_path.open("wb") as se:
        proc = subprocess.Popen(argv, stdout=so, stderr=se)
        pid = proc.pid
        try:
            exit_code = proc.wait(timeout=RUN_TIMEOUT_SECONDS)
            status = "COMPLETED"
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=5)
            exit_code = None
            status = "UNKNOWN_TIMEOUT"
    ended = now()
    return {
        "status": status,
        "pid": pid,
        "argv": argv,
        "started_utc": started,
        "ended_utc": ended,
        "exit_code": exit_code,
        "stdout": str(stdout_path),
        "stderr": str(stderr_path),
    }


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: launch_p04_pid_receipt.py RUN_ID", file=sys.stderr)
        return 64

    run_id = sys.argv[1]
    src = Path(__file__).resolve().parent
    repo = src.parents[3]
    run = repo / "research" / "campaigns" / "C003" / "runs" / run_id
    if run.exists():
        raise SystemExit(f"run directory already exists: {run}")
    run.mkdir(parents=True)

    mechanism = src / "mechanism.S"
    fixture_asm = src / "fixture.S"
    fixture_json = src / "fixture.json"
    linker = src / "linker.ld"
    evaluator = src / "evaluate_p04.py"
    launcher = Path(__file__).resolve()

    build = [
        ("01_clang_mechanism", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(mechanism), "-o", str(run / "mechanism.o")]),
        ("02_clang_fixture", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(fixture_asm), "-o", str(run / "fixture.o")]),
        ("03_link", [str(LLD), "-m", "elf_i386", "-T", str(linker), str(run / "mechanism.o"), str(run / "fixture.o"), "-o", str(run / "probe.elf")]),
        ("04_objcopy", [str(OBJCOPY), "-O", "binary", str(run / "probe.elf"), str(run / "probe.bin")]),
    ]
    for name, argv in build:
        rc = run_capture(argv, run / f"{name}.stdout.txt", run / f"{name}.stderr.txt")
        if rc != 0:
            raise SystemExit(f"{name} failed exit={rc}")

    probe = run / "probe.bin"
    boot = probe.read_bytes()
    if len(boot) != 512 or boot[510:512] != b"\x55\xaa":
        raise SystemExit("boot image size/signature contract failed")

    fixture = json.loads(fixture_json.read_text(encoding="utf-8"))
    image_bytes = int(fixture["image_bytes"])
    sector_bytes = int(fixture["sector_bytes"])
    sector_index = int(fixture["durable_sector_index_zero_based"])
    if image_bytes != 1_474_560 or sector_bytes != 512 or sector_index != 1:
        raise SystemExit("fixture geometry contract failed")

    disk = run / "disk.img"
    image = bytearray(image_bytes)
    image[:512] = boot
    disk.write_bytes(image)
    disk_initial_sha = sha256(disk)

    common = [
        str(QEMU),
        "-display", "none",
        "-monitor", "none",
        "-serial", "none",
        "-no-reboot",
        "-boot", "a",
        "-drive", f"file={disk.as_posix()},format=raw,if=floppy",
        "-device", "isa-debug-exit,iobase=0xf4,iosize=0x04",
    ]

    boot1_debug = run / "boot1.debugcon.txt"
    qemu1_argv = common + ["-debugcon", f"file:{boot1_debug.as_posix()}", "-global", "isa-debugcon.iobase=0xe9"]
    qemu1 = run_qemu(qemu1_argv, run / "05_qemu_boot1.stdout.txt", run / "05_qemu_boot1.stderr.txt")
    if qemu1["status"] != "COMPLETED" or qemu1["exit_code"] != EXPECTED_QEMU_EXIT:
        raise SystemExit(f"boot1 not qualified: {qemu1}")
    if not boot1_debug.exists():
        raise SystemExit("boot1 debug artifact missing")
    disk_after_boot1_sha = sha256(disk)

    # This call occurs only after proc1.wait() returned a terminal exit code.
    boot2_debug = run / "boot2.debugcon.txt"
    qemu2_argv = common + ["-debugcon", f"file:{boot2_debug.as_posix()}", "-global", "isa-debugcon.iobase=0xe9"]
    qemu2 = run_qemu(qemu2_argv, run / "06_qemu_boot2.stdout.txt", run / "06_qemu_boot2.stderr.txt")
    if qemu2["status"] != "COMPLETED" or qemu2["exit_code"] != EXPECTED_QEMU_EXIT:
        raise SystemExit(f"boot2 not qualified: {qemu2}")
    if not boot2_debug.exists():
        raise SystemExit("boot2 debug artifact missing")
    disk_after_boot2_sha = sha256(disk)

    sector_extract = run / "durable_sector.bin"
    final_disk = disk.read_bytes()
    start = sector_index * sector_bytes
    sector_extract.write_bytes(final_disk[start:start + sector_bytes])

    evaluation = run / "evaluation.json"
    eval_argv = [str(PYTHON), str(evaluator), str(boot1_debug), str(boot2_debug), str(disk), str(sector_extract), str(evaluation)]
    eval_rc = run_capture(eval_argv, run / "07_evaluator.stdout.txt", run / "07_evaluator.stderr.txt")
    if eval_rc != 0:
        raise SystemExit(f"evaluator failed exit={eval_rc}")

    receipt = {
        "run_id": run_id,
        "run_class": "C003_P04_RESTART_PERSISTENCE_DISCRIMINATOR_PID_RECEIPT",
        "scientific_p04_completion": True,
        "authority_ceiling": "bounded clean-restart QEMU/raw-floppy/BIOS transport only",
        "cwd": str(repo),
        "launcher_started_utc": qemu1["started_utc"],
        "launcher_ended_utc": now(),
        "process_boundary": {
            "boot1": qemu1,
            "boot2": qemu2,
            "boot1_completed_before_boot2_started": qemu1["ended_utc"] <= qemu2["started_utc"],
            "numeric_pids_distinct": qemu1["pid"] != qemu2["pid"],
        },
        "tools": {
            "clang": {"path": str(CLANG), "sha256": sha256(CLANG)},
            "lld": {"path": str(LLD), "sha256": sha256(LLD)},
            "objcopy": {"path": str(OBJCOPY), "sha256": sha256(OBJCOPY)},
            "qemu": {"path": str(QEMU), "sha256": sha256(QEMU)},
            "python": {"path": str(PYTHON), "sha256": sha256(PYTHON), "observed_eval_exit": eval_rc},
        },
        "source_sha256": {
            "mechanism": sha256(mechanism),
            "fixture_asm": sha256(fixture_asm),
            "fixture_json": sha256(fixture_json),
            "linker": sha256(linker),
            "evaluator": sha256(evaluator),
            "launcher": sha256(launcher),
        },
        "artifacts": {
            "probe_bin": {"path": str(probe), "bytes": len(boot), "sha256": sha256(probe), "boot_signature": "55aa"},
            "disk": {"path": str(disk), "bytes": disk.stat().st_size, "initial_sha256": disk_initial_sha, "after_boot1_sha256": disk_after_boot1_sha, "after_boot2_sha256": disk_after_boot2_sha},
            "boot1_debug": {"path": str(boot1_debug), "sha256": sha256(boot1_debug)},
            "boot2_debug": {"path": str(boot2_debug), "sha256": sha256(boot2_debug)},
            "durable_sector": {"path": str(sector_extract), "bytes": sector_extract.stat().st_size, "sha256": sha256(sector_extract)},
            "evaluation": {"path": str(evaluation), "sha256": sha256(evaluation)},
        },
    }
    receipt_path = run / "receipt_pid.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")

    print(f"RUN_DIR={run}")
    print(f"BOOT1_PID={qemu1['pid']} EXIT={qemu1['exit_code']} START={qemu1['started_utc']} END={qemu1['ended_utc']}")
    print(f"BOOT2_PID={qemu2['pid']} EXIT={qemu2['exit_code']} START={qemu2['started_utc']} END={qemu2['ended_utc']}")
    print(f"BOUNDARY_OK={receipt['process_boundary']['boot1_completed_before_boot2_started']}")
    print(f"PIDS_DISTINCT={receipt['process_boundary']['numeric_pids_distinct']}")
    print(f"BOOT1={boot1_debug.read_text(encoding='ascii').replace(chr(10), r'\n')}")
    print(f"BOOT2={boot2_debug.read_text(encoding='ascii').replace(chr(10), r'\n')}")
    print(f"PROBE_SHA256={sha256(probe)}")
    print(f"DISK_INITIAL_SHA256={disk_initial_sha}")
    print(f"DISK_AFTER_BOOT1_SHA256={disk_after_boot1_sha}")
    print(f"DISK_AFTER_BOOT2_SHA256={disk_after_boot2_sha}")
    print(f"RECEIPT_PID_SHA256={sha256(receipt_path)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
