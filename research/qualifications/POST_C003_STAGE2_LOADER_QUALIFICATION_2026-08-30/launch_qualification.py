from __future__ import annotations
import datetime as dt
import hashlib
import json
import subprocess
import sys
from pathlib import Path

IMAGE_BYTES = 1474560
SECTOR_BYTES = 512
STAGE2_SECTORS = 8
STAGE2_LOAD_BYTES = STAGE2_SECTORS * SECTOR_BYTES
DURABLE_SECTOR_ZERO_BASED = 9
QEMU_TIMEOUT_SECONDS = 5

LLVM = Path(r'E:\Android\Sdk\ndk\29.0.14206865\toolchains\llvm\prebuilt\windows-x86_64\bin')
CLANG = LLVM / 'clang.exe'
LLD = LLVM / 'ld.lld.exe'
OBJCOPY = LLVM / 'llvm-objcopy.exe'
SIZE = LLVM / 'llvm-size.exe'
QEMU = Path(r'C:\Program Files\qemu\qemu-system-i386.exe')


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def run_capture(argv: list[str], stdout_path: Path, stderr_path: Path, timeout: int = 30) -> int:
    with stdout_path.open('wb') as out, stderr_path.open('wb') as err:
        cp = subprocess.run(argv, stdout=out, stderr=err, timeout=timeout, check=False)
    return cp.returncode


def main() -> int:
    if len(sys.argv) != 2:
        print('usage: launch_qualification.py RUN_ID', file=sys.stderr)
        return 64

    run_id = sys.argv[1]
    src = Path(__file__).resolve().parent
    repo = src.parents[3]
    run = src / 'runs' / run_id
    if run.exists():
        print(f'run directory exists: {run}', file=sys.stderr)
        return 65
    run.mkdir(parents=True)

    stage1_s = src / 'stage1.S'
    stage1_ld = src / 'stage1.ld'
    stage2_s = src / 'stage2.S'
    stage2_ld = src / 'stage2.ld'
    launcher = Path(__file__).resolve()

    s1o = run / 'stage1.o'
    s1elf = run / 'stage1.elf'
    s1bin = run / 'stage1.bin'
    s2o = run / 'stage2.o'
    s2elf = run / 'stage2.elf'
    s2bin_raw = run / 'stage2.raw.bin'
    s2bin_pad = run / 'stage2.padded.bin'
    disk = run / 'disk.img'

    steps = [
        ('01_stage1_clang', [str(CLANG), '-target', 'i386-unknown-none-elf', '-ffreestanding', '-c', str(stage1_s), '-o', str(s1o)]),
        ('02_stage1_link', [str(LLD), '-m', 'elf_i386', '-T', str(stage1_ld), str(s1o), '-o', str(s1elf)]),
        ('03_stage1_objcopy', [str(OBJCOPY), '-O', 'binary', str(s1elf), str(s1bin)]),
        ('04_stage2_clang', [str(CLANG), '-target', 'i386-unknown-none-elf', '-ffreestanding', '-c', str(stage2_s), '-o', str(s2o)]),
        ('05_stage2_link', [str(LLD), '-m', 'elf_i386', '-T', str(stage2_ld), str(s2o), '-o', str(s2elf)]),
        ('06_stage2_objcopy', [str(OBJCOPY), '-O', 'binary', str(s2elf), str(s2bin_raw)]),
    ]
    for name, argv in steps:
        rc = run_capture(argv, run / f'{name}.stdout.txt', run / f'{name}.stderr.txt')
        if rc != 0:
            print(f'{name} failed exit={rc}', file=sys.stderr)
            return 2

    stage1 = s1bin.read_bytes()
    if len(stage1) != 512 or stage1[510:512] != b'\x55\xaa':
        print(f'stage1 boot contract failed size={len(stage1)} sig={stage1[510:512].hex()}', file=sys.stderr)
        return 2

    stage2_raw = s2bin_raw.read_bytes()
    if len(stage2_raw) > STAGE2_LOAD_BYTES:
        print(f'stage2 raw size={len(stage2_raw)} exceeds {STAGE2_LOAD_BYTES}', file=sys.stderr)
        return 2
    stage2_padded = stage2_raw + bytes(STAGE2_LOAD_BYTES - len(stage2_raw))
    s2bin_pad.write_bytes(stage2_padded)

    image = bytearray(IMAGE_BYTES)
    image[0:512] = stage1
    image[512:512 + STAGE2_LOAD_BYTES] = stage2_padded
    disk.write_bytes(image)

    durable_before = image[DURABLE_SECTOR_ZERO_BASED * SECTOR_BYTES:(DURABLE_SECTOR_ZERO_BASED + 1) * SECTOR_BYTES]
    if any(durable_before):
        print('durable sector not zero before boot', file=sys.stderr)
        return 2

    debug = run / 'debugcon.txt'
    qso = run / '07_qemu.stdout.txt'
    qse = run / '07_qemu.stderr.txt'
    qargv = [
        str(QEMU), '-accel', 'tcg', '-display', 'none', '-monitor', 'none', '-serial', 'none', '-no-reboot', '-boot', 'a',
        '-drive', f'file={disk.as_posix()},format=raw,if=floppy',
        '-device', 'isa-debug-exit,iobase=0xf4,iosize=0x04',
        '-debugcon', f'file:{debug.as_posix()}', '-global', 'isa-debugcon.iobase=0xe9'
    ]
    started = dt.datetime.now(dt.timezone.utc).isoformat()
    with qso.open('wb') as out, qse.open('wb') as err:
        proc = subprocess.Popen(qargv, stdout=out, stderr=err)
        pid = proc.pid
        try:
            qexit = proc.wait(timeout=QEMU_TIMEOUT_SECONDS)
            qstatus = 'COMPLETED'
        except subprocess.TimeoutExpired:
            proc.kill()
            proc.wait(timeout=5)
            qexit = None
            qstatus = 'UNKNOWN_TIMEOUT'
    ended = dt.datetime.now(dt.timezone.utc).isoformat()

    observed = debug.read_text(encoding='ascii').splitlines() if debug.exists() else []
    expected = ['S1_OK', 'S2_OK']
    disk_after = disk.read_bytes()
    durable_after = disk_after[DURABLE_SECTOR_ZERO_BASED * SECTOR_BYTES:(DURABLE_SECTOR_ZERO_BASED + 1) * SECTOR_BYTES]

    size_stdout = run / '08_stage2_size.stdout.txt'
    size_stderr = run / '08_stage2_size.stderr.txt'
    size_exit = run_capture([str(SIZE), str(s2elf)], size_stdout, size_stderr)

    checks = {
        'qemu_completed': qstatus == 'COMPLETED',
        'qemu_exit_33': qexit == 33,
        'exact_trace': observed == expected,
        'stage1_512': len(stage1) == 512,
        'stage1_signature_55aa': stage1[510:512] == b'\x55\xaa',
        'stage2_raw_within_4096': len(stage2_raw) <= STAGE2_LOAD_BYTES,
        'stage2_disk_extent_4096': len(stage2_padded) == STAGE2_LOAD_BYTES,
        'durable_sector_zero_after': not any(durable_after),
        'disk_size_1474560': len(disk_after) == IMAGE_BYTES,
        'llvm_size_exit_0': size_exit == 0,
    }
    passed = all(checks.values())

    result = {
        'qualification': 'POST_C003_STAGE2_LOADER_8_SECTOR_V1',
        'run_id': run_id,
        'passed': passed,
        'checks': checks,
        'layout': {
            'image_bytes': IMAGE_BYTES,
            'sector_bytes': SECTOR_BYTES,
            'stage1_zero_based_sector': 0,
            'stage2_zero_based_start_sector': 1,
            'stage2_sector_count': STAGE2_SECTORS,
            'stage2_load_address': '0x8000',
            'durable_zero_based_sector': DURABLE_SECTOR_ZERO_BASED,
            'bios_stage2_chs': {'cylinder': 0, 'head': 0, 'start_sector_1_based': 2, 'count': 8},
        },
        'qemu': {'pid': pid, 'status': qstatus, 'exit_code': qexit, 'started_utc': started, 'ended_utc': ended, 'timeout_seconds': QEMU_TIMEOUT_SECONDS},
        'observed_lines': observed,
        'expected_lines': expected,
        'sizes': {'stage1_bytes': len(stage1), 'stage2_raw_bytes': len(stage2_raw), 'stage2_padded_bytes': len(stage2_padded), 'disk_bytes': len(disk_after)},
        'source_sha256': {
            'stage1_s': sha256(stage1_s), 'stage1_ld': sha256(stage1_ld), 'stage2_s': sha256(stage2_s), 'stage2_ld': sha256(stage2_ld), 'launcher': sha256(launcher)
        },
        'artifact_sha256': {
            'stage1_bin': sha256(s1bin), 'stage2_raw_bin': sha256(s2bin_raw), 'stage2_padded_bin': sha256(s2bin_pad), 'disk_img': sha256(disk), 'debugcon': sha256(debug) if debug.exists() else None,
            'qemu_stdout': sha256(qso), 'qemu_stderr': sha256(qse), 'size_stdout': sha256(size_stdout), 'size_stderr': sha256(size_stderr)
        },
    }
    result_path = run / 'qualification_result.json'
    result_path.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print('RUN_DIR=' + str(run))
    print('QEMU_STATUS=' + qstatus)
    print(f'QEMU_PID={pid} EXIT={qexit}')
    print('TRACE=' + repr(observed))
    print(f'STAGE1_BYTES={len(stage1)} STAGE2_RAW_BYTES={len(stage2_raw)} STAGE2_PADDED_BYTES={len(stage2_padded)}')
    print('PASSED=' + str(passed))
    print('RESULT_SHA256=' + sha256(result_path))
    if qstatus == 'UNKNOWN_TIMEOUT':
        return 3
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
