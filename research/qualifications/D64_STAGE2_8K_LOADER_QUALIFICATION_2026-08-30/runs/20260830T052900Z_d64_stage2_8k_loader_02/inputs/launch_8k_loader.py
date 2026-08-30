from __future__ import annotations

import datetime as dt
import hashlib
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

IMAGE_BYTES = 1474560
STAGE2_EXTENT = 8192
QEMU_TIMEOUT_SECONDS = 8
PREREG_COMMIT = "ca21370643b8526ce2d66b4de1f2aec2c78a008d"
LLVM = Path(r"E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin")
CLANG = LLVM / "clang.exe"
LLD = LLVM / "ld.lld.exe"
OBJCOPY = LLVM / "llvm-objcopy.exe"
SIZE = LLVM / "llvm-size.exe"
QEMU = Path(r"C:\Program Files\qemu\qemu-system-i386.exe")
PYTHON = Path(r"C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe")


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def capture(argv: list[str], stdout_path: Path, stderr_path: Path, timeout: int = 30) -> int:
    with stdout_path.open("wb") as stdout, stderr_path.open("wb") as stderr:
        return subprocess.run(argv, stdout=stdout, stderr=stderr, timeout=timeout, check=False).returncode


def git_head(repo: Path) -> str:
    return subprocess.run(["git", "rev-parse", "HEAD"], cwd=repo, capture_output=True, text=True, check=True).stdout.strip()


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: launch_8k_loader.py RUN_ID", file=sys.stderr)
        return 64

    run_id = sys.argv[1]
    src = Path(__file__).resolve().parent
    repo = src.parents[2]
    run = src / "runs" / run_id
    if run.exists():
        print(f"run exists: {run}", file=sys.stderr)
        return 65
    run.mkdir(parents=True)
    inputs = run / "inputs"
    inputs.mkdir()

    originals = {
        "qualification_spec": src / "QUALIFICATION_SPEC.md",
        "resource_plan": repo / "research/plans/D64_RESOURCE_BINDING_SCALE_PLAN_2026-08-30.md",
        "stage1_s": src / "stage1.S",
        "stage1_ld": src / "stage1.ld",
        "stage2_s": src / "stage2.S",
        "stage2_ld": src / "stage2.ld",
        "launcher": Path(__file__).resolve(),
        "evaluator": src / "evaluate_8k_loader.py",
        "static_checker": src / "static_check_8k_loader.py",
    }
    snapshot_names = {
        "qualification_spec": "qualification_spec.md",
        "resource_plan": "resource_plan.md",
        "stage1_s": "stage1.S",
        "stage1_ld": "stage1.ld",
        "stage2_s": "stage2.S",
        "stage2_ld": "stage2.ld",
        "launcher": "launch_8k_loader.py",
        "evaluator": "evaluate_8k_loader.py",
        "static_checker": "static_check_8k_loader.py",
    }

    head = git_head(repo)
    original_hashes: dict[str, str] = {}
    items = []
    for key, source in originals.items():
        dest = inputs / snapshot_names[key]
        shutil.copyfile(source, dest)
        h = sha256(dest)
        original_hashes[key] = sha256(source)
        items.append({
            "key": key,
            "source_project_relative": source.relative_to(repo).as_posix(),
            "snapshot_path": dest.relative_to(run).as_posix(),
            "bytes": dest.stat().st_size,
            "sha256": h,
        })

    manifest = {
        "run_id": run_id,
        "snapshot_utc": now(),
        "controlling_git_head": head,
        "controlling_preregistration_commit": PREREG_COMMIT,
        "declared_working_directory": str(repo),
        "launcher_path": str(originals["launcher"]),
        "launcher_sha256": original_hashes["launcher"],
        "tools": {k: str(v) for k, v in {
            "clang": CLANG,
            "lld": LLD,
            "objcopy": OBJCOPY,
            "size": SIZE,
            "qemu": QEMU,
            "python": PYTHON,
        }.items()},
        "inputs": items,
    }
    manifest_path = run / "inputs_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    manifest_sha = sha256(manifest_path)

    stage1_s = inputs / "stage1.S"
    stage1_ld = inputs / "stage1.ld"
    stage2_s = inputs / "stage2.S"
    stage2_ld = inputs / "stage2.ld"
    evaluator = inputs / "evaluate_8k_loader.py"
    checker = inputs / "static_check_8k_loader.py"
    launcher_snapshot = inputs / "launch_8k_loader.py"

    stage1_o = run / "stage1.o"
    stage1_elf = run / "stage1.elf"
    stage1_bin = run / "stage1.bin"
    stage2_o = run / "stage2.o"
    stage2_elf = run / "stage2.elf"
    stage2_raw = run / "stage2.raw.bin"
    stage2_padded = run / "stage2.padded.bin"
    disk = run / "disk.img"

    build = [
        ("01_stage1_clang", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(stage1_s), "-o", str(stage1_o)]),
        ("02_stage1_link", [str(LLD), "-m", "elf_i386", "-T", str(stage1_ld), str(stage1_o), "-o", str(stage1_elf)]),
        ("03_stage1_objcopy", [str(OBJCOPY), "-O", "binary", str(stage1_elf), str(stage1_bin)]),
        ("04_stage2_clang", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(stage2_s), "-o", str(stage2_o)]),
        ("05_stage2_link", [str(LLD), "-m", "elf_i386", "-T", str(stage2_ld), str(stage2_o), "-o", str(stage2_elf)]),
        ("06_stage2_objcopy", [str(OBJCOPY), "-O", "binary", str(stage2_elf), str(stage2_raw)]),
    ]
    for name, argv in build:
        rc = capture(argv, run / f"{name}.stdout.txt", run / f"{name}.stderr.txt")
        if rc != 0:
            (run / "failure.json").write_text(json.dumps({"stage": name, "input_manifest_sha256": manifest_sha}, indent=2) + "\n", encoding="utf-8")
            print(f"{name} failed exit={rc}", file=sys.stderr)
            return 2

    changed = [key for key, source in originals.items() if sha256(source) != original_hashes[key]]
    if changed:
        (run / "failure.json").write_text(json.dumps({"stage": "INPUT_CHANGED_AFTER_SNAPSHOT", "changed": changed, "input_manifest_sha256": manifest_sha}, indent=2) + "\n", encoding="utf-8")
        print("INPUT_CHANGED_AFTER_SNAPSHOT " + ",".join(changed), file=sys.stderr)
        return 4

    stage1_bytes = stage1_bin.read_bytes()
    stage2_bytes = stage2_raw.read_bytes()
    if len(stage1_bytes) != 512 or stage1_bytes[-2:] != b"\x55\xaa":
        print(f"stage1 contract failed bytes={len(stage1_bytes)}", file=sys.stderr)
        return 2
    if len(stage2_bytes) > STAGE2_EXTENT or len(stage2_bytes) <= 0x1FF0 or stage2_bytes[0x1FF0] != 0xA5:
        print(f"stage2 contract failed bytes={len(stage2_bytes)} tail={(stage2_bytes[0x1FF0] if len(stage2_bytes)>0x1FF0 else None)}", file=sys.stderr)
        return 2

    stage2_padded.write_bytes(stage2_bytes + bytes(STAGE2_EXTENT - len(stage2_bytes)))
    image = bytearray(IMAGE_BYTES)
    image[:512] = stage1_bytes
    image[512:512 + STAGE2_EXTENT] = stage2_padded.read_bytes()
    disk.write_bytes(image)

    debug = run / "debugcon.txt"
    qemu_stdout = run / "07_qemu.stdout.txt"
    qemu_stderr = run / "07_qemu.stderr.txt"
    qemu_argv = [
        str(QEMU), "-accel", "tcg", "-display", "none", "-monitor", "none", "-serial", "none", "-no-reboot", "-boot", "a",
        "-drive", f"file={disk.as_posix()},format=raw,if=floppy",
        "-device", "isa-debug-exit,iobase=0xf4,iosize=0x04",
        "-debugcon", f"file:{debug.as_posix()}", "-global", "isa-debugcon.iobase=0xe9",
    ]
    started = now()
    t0 = time.perf_counter()
    with qemu_stdout.open("wb") as stdout, qemu_stderr.open("wb") as stderr:
        proc = subprocess.Popen(qemu_argv, stdout=stdout, stderr=stderr)
        pid = proc.pid
        try:
            qemu_exit = proc.wait(timeout=QEMU_TIMEOUT_SECONDS)
            qemu_status = "COMPLETED"
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=5)
            qemu_exit = None
            qemu_status = "UNKNOWN_TIMEOUT"
    wall_ms = (time.perf_counter() - t0) * 1000.0
    ended = now()

    evaluation = run / "evaluation.json"
    eval_stdout = run / "08_evaluator.stdout.txt"
    eval_stderr = run / "08_evaluator.stderr.txt"
    eval_exit = capture([str(PYTHON), str(evaluator), str(debug), str(evaluation)], eval_stdout, eval_stderr) if debug.exists() else None

    size_stdout = run / "09_size.stdout.txt"
    size_stderr = run / "09_size.stderr.txt"
    size_exit = capture([str(SIZE), str(stage2_elf)], size_stdout, size_stderr)

    source_hashes = {item["key"]: item["sha256"] for item in items}
    receipt_pre = {
        "run_id": run_id,
        "run_class": "D64_STAGE2_8K_LOADER_QUALIFICATION",
        "scientific_status": qemu_status,
        "authority_ceiling": "fixed 16-sector/8192-byte first-track stage2 loader qualification only",
        "input_manifest_sha256": manifest_sha,
        "controlling_git_head": head,
        "controlling_preregistration_commit": PREREG_COMMIT,
        "qemu": {
            "pid": pid,
            "argv": qemu_argv,
            "started_utc": started,
            "ended_utc": ended,
            "wall_ms": wall_ms,
            "status": qemu_status,
            "exit_code": qemu_exit,
            "timeout_seconds": QEMU_TIMEOUT_SECONDS,
        },
        "source_sha256": source_hashes,
        "tools": {k: {"path": str(v), "sha256": sha256(v)} for k, v in {
            "clang": CLANG, "lld": LLD, "objcopy": OBJCOPY, "size": SIZE, "qemu": QEMU, "python": PYTHON,
        }.items()},
        "artifacts": {
            "stage1_bin": {"bytes": len(stage1_bytes), "sha256": sha256(stage1_bin), "boot_signature": "55aa"},
            "stage2_raw": {"bytes": len(stage2_bytes), "sha256": sha256(stage2_raw), "tail_offset": 0x1FF0, "tail_value": stage2_bytes[0x1FF0]},
            "stage2_padded": {"bytes": stage2_padded.stat().st_size, "sha256": sha256(stage2_padded)},
            "disk": {"bytes": disk.stat().st_size, "sha256": sha256(disk), "sector18_zero": bool(set(disk.read_bytes()[17*512:18*512]) <= {0})},
            "debugcon": {"sha256": sha256(debug) if debug.exists() else None},
            "evaluation": {"sha256": sha256(evaluation) if evaluation.exists() else None, "exit": eval_exit},
            "size": {"sha256": sha256(size_stdout), "exit": size_exit},
        },
        "measurements": {"stage2_extent_bytes": STAGE2_EXTENT, "stage2_sector_count": 16, "stage2_load_start": "0x8000", "stage2_load_end_inclusive": "0x9fff"},
    }
    receipt_pre_path = run / "receipt_pre_static.json"
    receipt_pre_path.write_text(json.dumps(receipt_pre, indent=2) + "\n", encoding="utf-8")

    static = run / "static_closure.json"
    static_stdout = run / "10_static.stdout.txt"
    static_stderr = run / "10_static.stderr.txt"
    static_exit = capture([
        str(PYTHON), str(checker), str(stage1_s), str(stage1_ld), str(stage2_s), str(stage2_ld), str(stage2_raw), str(stage2_padded), str(disk), str(manifest_path), str(receipt_pre_path), str(static)
    ], static_stdout, static_stderr)

    receipt = json.loads(receipt_pre_path.read_text(encoding="utf-8"))
    receipt["artifacts"]["static_closure"] = {"sha256": sha256(static) if static.exists() else None, "exit": static_exit}
    receipt["artifacts"]["receipt_pre_static"] = {"sha256": sha256(receipt_pre_path)}
    receipt_path = run / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")

    print("RUN_DIR=" + str(run))
    print(f"QEMU_PID={pid} STATUS={qemu_status} EXIT={qemu_exit} WALL_MS={wall_ms:.3f}")
    print("TRACE=" + repr(debug.read_text(encoding="ascii").splitlines() if debug.exists() else []))
    print(f"EVALUATOR_EXIT={eval_exit} STATIC_EXIT={static_exit} STAGE2_RAW_BYTES={len(stage2_bytes)}")
    print("INPUT_MANIFEST_SHA256=" + manifest_sha)
    print("RECEIPT_SHA256=" + sha256(receipt_path))

    return 0 if qemu_status == "COMPLETED" and qemu_exit == 33 and eval_exit == 0 and static_exit == 0 and size_exit == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
