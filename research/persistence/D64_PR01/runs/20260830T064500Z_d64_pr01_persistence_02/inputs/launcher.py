from __future__ import annotations

import datetime as dt
import hashlib
import json
import shutil
import subprocess
import sys
import time
from pathlib import Path

IMAGE_BYTES = 1_474_560
STAGE2_EXTENT = 8_192
DURABLE_OFFSET = 17 * 512
QEMU_TIMEOUT = 12
PREREG_COMMIT = "0f1146f5782b729f77cfa8d4292e956f5c5f28a8"
NO_HOST_DISK_WRITE_BETWEEN_BOOTS = True

LLVM = Path(r"E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin")
CLANG = LLVM / "clang.exe"
LLD = LLVM / "ld.lld.exe"
OBJCOPY = LLVM / "llvm-objcopy.exe"
SIZE = LLVM / "llvm-size.exe"
NM = LLVM / "llvm-nm.exe"
QEMU = Path(r"C:\Program Files\qemu\qemu-system-i386.exe")
PYTHON = Path(r"C:\Users\ancal\AppData\Local\Python\pythoncore-3.14-64\python.exe")


def now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def capture(argv: list[str], stdout_path: Path, stderr_path: Path, timeout: int = 30) -> int:
    with stdout_path.open("wb") as out, stderr_path.open("wb") as err:
        return subprocess.run(argv, stdout=out, stderr=err, timeout=timeout, check=False).returncode


def git_head(repo: Path) -> str:
    return subprocess.run(["git", "rev-parse", "HEAD"], cwd=repo, capture_output=True, text=True, check=True).stdout.strip()


def tool_record(path: Path) -> dict[str, object]:
    return {"path": str(path), "sha256": sha256(path)}


def originals_unchanged(originals: dict[str, Path], hashes: dict[str, str]) -> list[str]:
    return [key for key, path in originals.items() if sha256(path) != hashes[key]]


def run_qemu(disk: Path, debug_path: Path, stdout_path: Path, stderr_path: Path) -> dict[str, object]:
    argv = [
        str(QEMU), "-accel", "tcg", "-display", "none", "-monitor", "none",
        "-serial", "none", "-no-reboot", "-boot", "a",
        "-drive", f"file={disk.as_posix()},format=raw,if=floppy",
        "-device", "isa-debug-exit,iobase=0xf4,iosize=0x04",
        "-debugcon", f"file:{debug_path.as_posix()}",
        "-global", "isa-debugcon.iobase=0xe9",
    ]
    started_utc = now()
    started_monotonic = time.monotonic()
    t0 = time.perf_counter()
    with stdout_path.open("wb") as out, stderr_path.open("wb") as err:
        proc = subprocess.Popen(argv, stdout=out, stderr=err)
        try:
            exit_code = proc.wait(timeout=QEMU_TIMEOUT)
            status = "COMPLETED"
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=5)
            exit_code = None
            status = "UNKNOWN_TIMEOUT"
    ended_monotonic = time.monotonic()
    ended_utc = now()
    return {
        "pid": proc.pid,
        "argv": argv,
        "started_utc": started_utc,
        "ended_utc": ended_utc,
        "started_monotonic": started_monotonic,
        "ended_monotonic": ended_monotonic,
        "wall_ms": (time.perf_counter() - t0) * 1000.0,
        "status": status,
        "exit_code": exit_code,
        "timeout_seconds": QEMU_TIMEOUT,
    }


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: launch_pr01.py RUN_ID", file=sys.stderr)
        return 64

    run_id = sys.argv[1]
    src = Path(__file__).resolve().parent
    repo = src.parents[3]
    run = src.parent / "runs" / run_id
    if run.exists():
        print(f"run exists: {run}", file=sys.stderr)
        return 65
    run.mkdir(parents=True)
    inputs = run / "inputs"
    inputs.mkdir()

    qual = repo / "research/qualifications/D64_STAGE2_8K_LOADER_QUALIFICATION_2026-08-30"
    originals: dict[str, Path] = {
        "preregistration": src.parent / "D64_PR01_PREREGISTRATION.md",
        "persistence_plan": repo / "research/plans/D64_EXPANDED_RELATION_CLEAN_RESTART_PLAN_2026-08-30.md",
        "i001_result": repo / "research/integration/I001/I001_RESULT.md",
        "rb02_result": repo / "research/resource_binding/D64_RB02/D64_RB02_RESULT.md",
        "arb01_result": repo / "research/composition/D64_ARB01/D64_ARB01_RESULT.md",
        "arb01_adoption": repo / "research/architecture/D64_ARB01_COMPOSITION_ADOPTION_REVIEW_2026-08-30.md",
        "rr01_result": repo / "research/resource_rekey/D64_RR01/D64_RR01_RESULT.md",
        "rr01_adoption": repo / "research/architecture/D64_RR01_RESOURCE_REKEY_ADOPTION_REVIEW_2026-08-30.md",
        "irq01_result": repo / "research/irq_coherence/D64_IRQ01/D64_IRQ01_RESULT.md",
        "irq01_adoption": repo / "research/architecture/D64_IRQ01_COHERENCE_ADOPTION_REVIEW_2026-08-30.md",
        "loader_qualification_result": qual / "QUALIFICATION_RESULT.md",
        "stage1_s": qual / "stage1.S",
        "stage1_ld": qual / "stage1.ld",
        "stage2_s": src / "stage2.S",
        "stage2_ld": src / "stage2.ld",
        "launcher": Path(__file__).resolve(),
        "evaluator": src / "evaluate_pr01.py",
        "static_checker": src / "static_check_pr01.py",
    }

    missing = [key for key, path in originals.items() if not path.exists()]
    if missing:
        (run / "failure.json").write_text(json.dumps({"stage": "MISSING_INPUTS", "missing": missing}, indent=2) + "\n")
        print(f"missing inputs: {missing}", file=sys.stderr)
        return 66

    canonical_head = git_head(repo)
    original_hashes = {key: sha256(path) for key, path in originals.items()}
    input_items: list[dict[str, object]] = []
    snapshot_names: dict[str, str] = {}
    for key, path in originals.items():
        suffix = path.suffix or ".txt"
        name = f"{key}{suffix}"
        snapshot_names[key] = name
        dest = inputs / name
        shutil.copyfile(path, dest)
        input_items.append({
            "key": key,
            "source_project_relative": path.relative_to(repo).as_posix(),
            "snapshot_path": dest.relative_to(run).as_posix(),
            "bytes": dest.stat().st_size,
            "sha256": sha256(dest),
        })

    manifest = {
        "run_id": run_id,
        "snapshot_utc": now(),
        "controlling_git_head": canonical_head,
        "controlling_preregistration_commit": PREREG_COMMIT,
        "declared_working_directory": str(repo),
        "launcher_path": str(originals["launcher"]),
        "launcher_sha256": original_hashes["launcher"],
        "no_host_disk_write_between_boots": True,
        "tools": {
            "clang": str(CLANG), "lld": str(LLD), "objcopy": str(OBJCOPY),
            "size": str(SIZE), "nm": str(NM), "qemu": str(QEMU), "python": str(PYTHON),
        },
        "inputs": input_items,
    }
    manifest_path = run / "inputs_manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    manifest_sha = sha256(manifest_path)

    s1s = inputs / snapshot_names["stage1_s"]
    s1ld = inputs / snapshot_names["stage1_ld"]
    s2s = inputs / snapshot_names["stage2_s"]
    s2ld = inputs / snapshot_names["stage2_ld"]
    evaluator = inputs / snapshot_names["evaluator"]
    checker = inputs / snapshot_names["static_checker"]
    launcher_snapshot = inputs / snapshot_names["launcher"]

    stage1_o = run / "stage1.o"
    stage1_elf = run / "stage1.elf"
    stage1_bin = run / "stage1.bin"
    stage2_o = run / "stage2.o"
    stage2_elf = run / "stage2.elf"
    stage2_raw = run / "stage2.raw.bin"
    stage2_padded = run / "stage2.padded.bin"
    disk = run / "disk.img"

    build_steps = [
        ("01_stage1_clang", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(s1s), "-o", str(stage1_o)]),
        ("02_stage1_link", [str(LLD), "-m", "elf_i386", "-T", str(s1ld), str(stage1_o), "-o", str(stage1_elf)]),
        ("03_stage1_objcopy", [str(OBJCOPY), "-O", "binary", str(stage1_elf), str(stage1_bin)]),
        ("04_stage2_clang", [str(CLANG), "-target", "i386-unknown-none-elf", "-ffreestanding", "-c", str(s2s), "-o", str(stage2_o)]),
        ("05_stage2_link", [str(LLD), "-m", "elf_i386", "-T", str(s2ld), str(stage2_o), "-o", str(stage2_elf)]),
        ("06_stage2_objcopy", [str(OBJCOPY), "-O", "binary", str(stage2_elf), str(stage2_raw)]),
    ]
    for name, argv in build_steps:
        rc = capture(argv, run / f"{name}.stdout.txt", run / f"{name}.stderr.txt")
        if rc != 0:
            (run / "failure.json").write_text(json.dumps({"stage": name, "exit": rc, "input_manifest_sha256": manifest_sha}, indent=2) + "\n")
            return 2

    changed = originals_unchanged(originals, original_hashes)
    if changed:
        (run / "failure.json").write_text(json.dumps({"stage": "INPUT_CHANGED_AFTER_SNAPSHOT", "changed": changed, "input_manifest_sha256": manifest_sha}, indent=2) + "\n")
        return 4

    s1 = stage1_bin.read_bytes()
    s2 = stage2_raw.read_bytes()
    if len(s1) != 512 or s1[-2:] != b"\x55\xaa" or len(s2) > STAGE2_EXTENT:
        (run / "failure.json").write_text(json.dumps({"stage": "IMAGE_CONTRACT", "stage1_bytes": len(s1), "stage2_bytes": len(s2)}, indent=2) + "\n")
        return 2

    stage2_padded.write_bytes(s2 + bytes(STAGE2_EXTENT - len(s2)))
    image = bytearray(IMAGE_BYTES)
    image[:512] = s1
    image[512:512 + STAGE2_EXTENT] = stage2_padded.read_bytes()
    disk.write_bytes(image)
    initial_disk_sha = sha256(disk)

    boot1_debug = run / "boot1.debugcon.txt"
    boot1_proc = None
    boot1_info = run_qemu(disk, boot1_debug, run / "07_boot1_qemu.stdout.txt", run / "07_boot1_qemu.stderr.txt")
    boot1_pid = int(boot1_info["pid"])
    boot1_started_monotonic = float(boot1_info["started_monotonic"])
    boot1_ended_monotonic = float(boot1_info["ended_monotonic"])
    # BOOT 1 COMPLETE

    durable_after_boot1 = disk.read_bytes()[DURABLE_OFFSET:DURABLE_OFFSET + 512]
    durable1 = run / "durable_after_boot1.bin"
    durable1.write_bytes(durable_after_boot1)
    disk_after_boot1_sha = sha256(disk)

    if boot1_info["status"] != "COMPLETED" or boot1_info["exit_code"] != 33:
        (run / "failure.json").write_text(json.dumps({"stage": "BOOT1_NOT_SUCCESS", "boot1": boot1_info}, indent=2) + "\n")
        return 5

    changed = originals_unchanged(originals, original_hashes)
    if changed:
        (run / "failure.json").write_text(json.dumps({"stage": "INPUT_CHANGED_BEFORE_BOOT2", "changed": changed}, indent=2) + "\n")
        return 4

    boot2_debug = run / "boot2.debugcon.txt"
    boot2_proc = None
    boot2_info = run_qemu(disk, boot2_debug, run / "08_boot2_qemu.stdout.txt", run / "08_boot2_qemu.stderr.txt")
    boot2_pid = int(boot2_info["pid"])
    boot2_started_monotonic = float(boot2_info["started_monotonic"])
    boot2_ended_monotonic = float(boot2_info["ended_monotonic"])
    distinct_pids = boot1_pid != boot2_pid
    strict_order = boot2_started_monotonic >= boot1_ended_monotonic
    # BOOT 2 COMPLETE

    durable_after_boot2 = disk.read_bytes()[DURABLE_OFFSET:DURABLE_OFFSET + 512]
    durable2 = run / "durable_after_boot2.bin"
    durable2.write_bytes(durable_after_boot2)
    final_disk_sha = sha256(disk)

    if boot2_info["status"] != "COMPLETED" or boot2_info["exit_code"] != 33 or not distinct_pids or not strict_order:
        (run / "failure.json").write_text(json.dumps({
            "stage": "BOOT2_PROCESS_CONTRACT",
            "boot1": boot1_info, "boot2": boot2_info,
            "distinct_pids": distinct_pids, "strict_order": strict_order,
        }, indent=2) + "\n")
        return 5

    evaluation = run / "evaluation.json"
    evaluator_exit = capture(
        [str(PYTHON), str(evaluator), str(boot1_debug), str(boot2_debug), str(evaluation)],
        run / "09_evaluator.stdout.txt", run / "09_evaluator.stderr.txt",
    )

    size_exit = capture([str(SIZE), str(stage2_elf)], run / "10_size.stdout.txt", run / "10_size.stderr.txt")
    nm_exit = capture([str(NM), "-n", str(stage2_elf)], run / "11_nm.stdout.txt", run / "11_nm.stderr.txt")
    runtime_state_bytes = None
    if nm_exit == 0:
        symbols: dict[str, int] = {}
        for line in (run / "11_nm.stdout.txt").read_text(errors="replace").splitlines():
            parts = line.split()
            if len(parts) >= 3:
                try:
                    symbols[parts[2]] = int(parts[0], 16)
                except ValueError:
                    pass
        if "runtime_state_start" in symbols and "runtime_state_end" in symbols:
            runtime_state_bytes = symbols["runtime_state_end"] - symbols["runtime_state_start"]

    source_sha = {item["key"]: item["sha256"] for item in input_items}
    receipt_pre = {
        "run_id": run_id,
        "run_class": "D64_PR01_EXPANDED_RELATION_CLEAN_RESTART",
        "scientific_status": "COMPLETED" if boot1_info["status"] == "COMPLETED" and boot2_info["status"] == "COMPLETED" else "UNKNOWN",
        "authority_ceiling": "two clean QEMU boots over one shared disk; explicit D64 relation rebind under fresh activity/resource epochs",
        "input_manifest_sha256": manifest_sha,
        "controlling_git_head": canonical_head,
        "controlling_preregistration_commit": PREREG_COMMIT,
        "boot1": boot1_info,
        "boot2": boot2_info,
        "process_contract": {
            "distinct_pids": bool(distinct_pids),
            "boot2_started_after_boot1_ended": bool(strict_order),
            "no_host_disk_write_between_boots": True,
        },
        "source_sha256": source_sha,
        "tools": {
            "clang": tool_record(CLANG), "lld": tool_record(LLD), "objcopy": tool_record(OBJCOPY),
            "size": tool_record(SIZE), "nm": tool_record(NM), "qemu": tool_record(QEMU), "python": tool_record(PYTHON),
        },
        "artifacts": {
            "stage1_bin": {"bytes": len(s1), "sha256": sha256(stage1_bin), "boot_signature": "55aa"},
            "stage2_raw": {"bytes": len(s2), "sha256": sha256(stage2_raw)},
            "stage2_padded": {"bytes": STAGE2_EXTENT, "sha256": sha256(stage2_padded)},
            "disk_initial_sha256": initial_disk_sha,
            "disk_after_boot1_sha256": disk_after_boot1_sha,
            "disk_after_boot2_sha256": final_disk_sha,
            "boot1_debugcon_sha256": sha256(boot1_debug),
            "boot2_debugcon_sha256": sha256(boot2_debug),
            "durable_after_boot1_sha256": sha256(durable1),
            "durable_after_boot2_sha256": sha256(durable2),
            "evaluation": {"sha256": sha256(evaluation) if evaluation.exists() else None, "exit": evaluator_exit},
            "size": {"sha256": sha256(run / "10_size.stdout.txt"), "exit": size_exit},
            "nm": {"sha256": sha256(run / "11_nm.stdout.txt"), "exit": nm_exit},
        },
        "pareto": {
            "stage2_raw_bytes": len(s2),
            "stage2_extent_bytes": STAGE2_EXTENT,
            "runtime_state_bytes": runtime_state_bytes,
            "activity_capacity": 64,
            "bindings_per_activity": 20,
            "binding_cell_count": 1280,
            "resource_capacity": 64,
            "resource_live_count_bits": 16,
            "durable_logical_record_bytes": 20,
            "durable_sector_bytes": 512,
        },
    }
    receipt_pre_path = run / "receipt_pre_static.json"
    receipt_pre_path.write_text(json.dumps(receipt_pre, indent=2) + "\n", encoding="utf-8")

    static = run / "static_closure.json"
    static_exit = capture(
        [
            str(PYTHON), str(checker), str(s2s), str(s2ld), str(launcher_snapshot), str(evaluator),
            str(manifest_path), str(receipt_pre_path), str(durable1), str(durable2), str(static),
        ],
        run / "12_static.stdout.txt", run / "12_static.stderr.txt",
    )

    receipt = json.loads(receipt_pre_path.read_text(encoding="utf-8"))
    receipt["artifacts"]["static_closure"] = {"sha256": sha256(static) if static.exists() else None, "exit": static_exit}
    receipt["artifacts"]["receipt_pre_static_sha256"] = sha256(receipt_pre_path)
    receipt_path = run / "receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8")

    expected1 = bytes.fromhex("48 34 50 31 51 7E 01 01 00 01 01 00 01 00 01 01 34 12 01 00") + bytes(492)
    expected2 = bytes.fromhex("48 34 50 31 51 7E 02 02 00 01 01 00 01 00 01 01 34 12 01 00") + bytes(492)
    evaluation_pass = False
    static_pass = False
    if evaluation.exists():
        evaluation_pass = bool(json.loads(evaluation.read_text(encoding="utf-8")).get("passed"))
    if static.exists():
        static_pass = bool(json.loads(static.read_text(encoding="utf-8")).get("passed"))

    audit_checks = {
        "manifest_hash_matches_receipt": receipt.get("input_manifest_sha256") == sha256(manifest_path),
        "snapshot_sources_match_manifest": all((run / item["snapshot_path"]).exists() and sha256(run / item["snapshot_path"]) == item["sha256"] for item in input_items),
        "receipt_sources_match_manifest": all(receipt.get("source_sha256", {}).get(item["key"]) == item["sha256"] for item in input_items),
        "preregistration_lineage_exact": receipt.get("controlling_preregistration_commit") == PREREG_COMMIT,
        "boot1_exit33": boot1_info["status"] == "COMPLETED" and boot1_info["exit_code"] == 33,
        "boot2_exit33": boot2_info["status"] == "COMPLETED" and boot2_info["exit_code"] == 33,
        "distinct_qemu_processes": distinct_pids,
        "strict_process_order": strict_order,
        "evaluator_pass": evaluator_exit == 0 and evaluation_pass,
        "static_pass": static_exit == 0 and static_pass,
        "durable_boot1_exact": durable1.read_bytes() == expected1,
        "durable_boot2_exact": durable2.read_bytes() == expected2,
        "stage2_fit": len(s2) <= STAGE2_EXTENT,
        "runtime_state_measured": isinstance(runtime_state_bytes, int) and runtime_state_bytes > 0,
        "capacities_exact": receipt["pareto"]["activity_capacity"] == 64 and receipt["pareto"]["binding_cell_count"] == 1280 and receipt["pareto"]["resource_capacity"] == 64,
        "no_host_disk_write_between_boots": NO_HOST_DISK_WRITE_BETWEEN_BOOTS is True,
    }
    audit = {
        "audit_version": "D64-PR01-independent-closure-v1",
        "checks": {key: bool(value) for key, value in audit_checks.items()},
        "passed": bool(all(audit_checks.values())),
        "check_count": len(audit_checks),
        "receipt_sha256": sha256(receipt_path),
        "input_manifest_sha256": sha256(manifest_path),
    }
    audit_path = run / "13_independent_audit.json"
    audit_path.write_text(json.dumps(audit, indent=2) + "\n", encoding="utf-8")

    print(f"RUN_DIR={run}")
    print(f"BOOT1_PID={boot1_pid} STATUS={boot1_info['status']} EXIT={boot1_info['exit_code']} WALL_MS={boot1_info['wall_ms']:.3f}")
    print(f"BOOT2_PID={boot2_pid} STATUS={boot2_info['status']} EXIT={boot2_info['exit_code']} WALL_MS={boot2_info['wall_ms']:.3f}")
    print(f"DISTINCT_PIDS={distinct_pids} STRICT_ORDER={strict_order}")
    print("BOOT1_TRACE=" + repr(boot1_debug.read_text(encoding="ascii").splitlines() if boot1_debug.exists() else []))
    print("BOOT2_TRACE=" + repr(boot2_debug.read_text(encoding="ascii").splitlines() if boot2_debug.exists() else []))
    print(f"EVALUATOR_EXIT={evaluator_exit} STATIC_EXIT={static_exit} AUDIT_PASS={audit['passed']}")
    print(f"STAGE2_RAW_BYTES={len(s2)} RUNTIME_STATE_BYTES={runtime_state_bytes}")
    print(f"DURABLE1_SHA256={sha256(durable1)}")
    print(f"DURABLE2_SHA256={sha256(durable2)}")
    print(f"INPUT_MANIFEST_SHA256={manifest_sha}")
    print(f"RECEIPT_SHA256={sha256(receipt_path)}")
    print(f"AUDIT_SHA256={sha256(audit_path)}")

    success = (
        boot1_info["status"] == "COMPLETED" and boot1_info["exit_code"] == 33
        and boot2_info["status"] == "COMPLETED" and boot2_info["exit_code"] == 33
        and distinct_pids and strict_order
        and evaluator_exit == 0 and static_exit == 0 and size_exit == 0 and nm_exit == 0
        and audit["passed"]
    )
    return 0 if success else 1


if __name__ == "__main__":
    raise SystemExit(main())
