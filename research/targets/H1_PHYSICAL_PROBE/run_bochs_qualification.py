from __future__ import annotations
import datetime as dt
import hashlib
import json
import pathlib
import shutil
import subprocess
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
IMAGE = HERE / "package" / "h1_probe_physical.img"
PREREG = HERE / "H1_PHYSICAL_PROBE_BOCHS_PREREGISTRATION_2026-08-31.md"
BOCHS = pathlib.Path(r"C:\Program Files\Bochs-3.1\bochs.exe")
BIOS = pathlib.Path(r"C:\Program Files\Bochs-3.1\BIOS-bochs-latest")
VGABIOS = pathlib.Path(r"C:\Program Files\Bochs-3.1\VGABIOS-lgpl-latest.bin")
EXPECTED_IMAGE_SHA = "809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead"
REQUIRED = [
    "H1PROBE_BEGIN", "BOOT_DRIVE=", "FW_EBDA=", "IRQ_PIC_MASK=", "IRQ_CAP",
    "E820_BEGIN", "E820_END", "PCI_BEGIN", "PCI_END", "H1PROBE_END",
]

def sha(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def iso_now() -> str:
    return dt.datetime.now(dt.timezone.utc).isoformat()

def main() -> int:
    for p in (IMAGE, PREREG, BOCHS, BIOS, VGABIOS):
        if not p.exists():
            raise SystemExit(f"missing required input: {p}")
    source_sha = sha(IMAGE)
    if source_sha != EXPECTED_IMAGE_SHA:
        raise SystemExit(f"physical image hash mismatch: {source_sha}")
    head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    stamp = dt.datetime.now(dt.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    run = HERE / "runs" / f"{stamp}_h1_physical_probe_bochs_01"
    inputs = run / "inputs"
    inputs.mkdir(parents=True)
    run_image = inputs / "h1_probe_physical.img"
    run_prereg = inputs / PREREG.name
    shutil.copy2(IMAGE, run_image)
    shutil.copy2(PREREG, run_prereg)
    image_before = sha(run_image)
    prereg_sha = sha(run_prereg)
    bochs_sha = sha(BOCHS)
    config = run / "bochsrc.txt"
    log = run / "bochs.log"
    stdout = run / "stdout.txt"
    stderr = run / "stderr.txt"
    cfg = "\n".join([
        f'romimage: file="{BIOS.as_posix()}", options=fastboot',
        f'vgaromimage: file="{VGABIOS.as_posix()}"',
        'cpu: model=phenom_8650_toliman, count=1, ips=50000000, reset_on_triple_fault=1, ignore_bad_msrs=1',
        'memory: guest=4096, host=256',
        f'floppya: 1_44="{run_image.as_posix()}", status=inserted, write_protected=1',
        'boot: floppy',
        'port_e9_hack: enabled=1, all_rings=1',
        'display_library: nogui',
        f'log: "{log.as_posix()}"',
        'panic: action=fatal',
        'error: action=report',
        'info: action=report',
        'debug: action=ignore',
        'clock: sync=none',
        '',
    ])
    config.write_text(cfg, encoding="utf-8", newline="\n")
    argv = [str(BOCHS), "-q", "-f", str(config)]
    start = iso_now()
    with stdout.open("wb") as out, stderr.open("wb") as err:
        proc = subprocess.Popen(argv, cwd=HERE, stdout=out, stderr=err)
        pid = proc.pid
        saw_end = False
        deadline = time.monotonic() + 20.0
        while time.monotonic() < deadline:
            time.sleep(0.10)
            if stdout.exists():
                text = stdout.read_text(encoding="utf-8", errors="replace")
                if "H1PROBE_END" in text:
                    saw_end = True
                    break
            if proc.poll() is not None:
                break
        termination = "natural_exit"
        if proc.poll() is None:
            termination = "harness_terminate_after_end" if saw_end else "harness_terminate_timeout"
            proc.terminate()
            try:
                proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                termination += "_then_kill"
                proc.kill()
                proc.wait(timeout=3)
        exit_code = proc.returncode
    end = iso_now()
    text = stdout.read_text(encoding="utf-8", errors="replace")
    image_after = sha(run_image)
    cpu_ok = ("CPU_VENDOR=" in text) or ("CPU_CPUID=UNAVAILABLE" in text)
    geom_ok = ("BOOT_GEOM" in text) or ("BOOT_GEOM=FAIL" in text)
    rsdp_ok = ("FW_RSDP=" in text) or ("FW_RSDP=NOT_FOUND" in text)
    ordered = True
    last = -1
    for marker in REQUIRED:
        pos = text.find(marker)
        if pos < 0 or pos < last:
            ordered = False
            break
        last = pos
    checks = {
        "source_image_hash_expected": source_sha == EXPECTED_IMAGE_SHA,
        "run_image_hash_before_expected": image_before == EXPECTED_IMAGE_SHA,
        "run_image_unchanged": image_after == image_before,
        "begin_end_and_required_order": ordered,
        "cpu_family": cpu_ok,
        "boot_geometry_family": geom_ok,
        "firmware_rsdp_family": rsdp_ok,
        "collection_end_seen": saw_end,
    }
    passed = all(checks.values())
    status = "COLLECTION_COMPLETE / EMULATOR_TERMINATED_BY_HARNESS" if passed else "FAILED_OR_UNKNOWN"
    receipt = {
        "format": "H1_PHYSICAL_PROBE_BOCHS_RUN_V1",
        "status": status,
        "passed": passed,
        "checks": checks,
        "git_head": head,
        "run": str(run.relative_to(ROOT)).replace("\\", "/"),
        "pid": pid,
        "start": start,
        "end": end,
        "argv": argv,
        "termination": termination,
        "process_return_code_after_harness_action": exit_code,
        "source_image_sha256": source_sha,
        "run_image_sha256_before": image_before,
        "run_image_sha256_after": image_after,
        "preregistration_sha256": prereg_sha,
        "bochs_sha256": bochs_sha,
        "stdout_sha256": sha(stdout),
        "stderr_sha256": sha(stderr),
        "bochs_log_sha256": sha(log) if log.exists() else None,
    }
    (run / "run_receipt.json").write_text(json.dumps(receipt, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(json.dumps(receipt, indent=2))
    return 0 if passed else 1

if __name__ == "__main__":
    raise SystemExit(main())
