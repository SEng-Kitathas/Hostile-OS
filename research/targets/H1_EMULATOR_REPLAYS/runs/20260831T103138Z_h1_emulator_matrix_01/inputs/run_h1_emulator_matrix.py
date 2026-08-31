from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BODY = ROOT / 'os/research_only/d64_reference_v3'
BUILD = BODY / 'build'
PROFILE = ROOT / 'research/targets/H1_HP_PAVILION_P2_1120_EMULATOR_MATRIX_V2.json'
POLICY = ROOT / 'research/targets/H1_EMULATOR_QUALIFICATION_POLICY_2026-08-31.md'
RUNS = ROOT / 'research/targets/H1_EMULATOR_REPLAYS/runs'
SECTOR = 512

CORE_TRACE = [
    'S1_8K_OK','TEST=D64_V2_CORE','ACT_FILLED=40','ACT_OVER=F','ROW_FILLED=14','ROW_OVER=F',
    'SHARE_LIVE=0002','STALE_BIND=R','FRESH_BIND=W','FRESH_BIND_VAL=7E','MISSING_BIND=M',
    'RELEASE_BOUND=B','DETACH_ONE_LIVE=0001','DETACH_LAST_LIVE=0000','OLD_RES=R','NEW_RES=W',
    'NEW_RES_VAL=55','DONE','TEST=D64_V2_IRQ','IRQ1_EVENT=01','IRQ1_REL=1','IRQ1_WAKE=1',
    'IRQ1_PROG=02','IRQ2_EVENT=02','IRQ2_REL=1','IRQ2_WAKE=1','IRQ2_PROG=02','IRQBAD_EVENT=02',
    'IRQBAD_REL=0','IRQBAD_WAKE=0','IRQBAD_PROG=00','IRQ_DONE'
]
RESTART_WRITE_TRACE = ['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=R','PHASE=WRITE','WRITE=A','PERSIST_DONE']
RESTART_RECOVER_TRACE = [
    'S1_8K_OK','TEST=D64_V2_PERSIST','MODE=R','PHASE=RECOVER','SELECT=A','DUR_VAL=71',
    'OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=71','PERSIST_DONE'
]
FAULT_TRACES = {
    'old_empty':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=A','DUR_VAL=71','OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=71','PERSIST_DONE'],
    'newer_valid':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=B','DUR_VAL=72','OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=72','PERSIST_DONE'],
    'newer_corrupt':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=A','DUR_VAL=71','OLD_BIND=R','OLD_RES=R','FRESH_BIND=W','FRESH_BIND_VAL=71','PERSIST_DONE'],
    'equal_conflict':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=X','DUR_VAL=00','OLD_BIND=-','OLD_RES=-','FRESH_BIND=-','FRESH_BIND_VAL=00','PERSIST_DONE'],
    'both_invalid':['S1_8K_OK','TEST=D64_V2_PERSIST','MODE=F','PHASE=RECOVER','SELECT=N','DUR_VAL=00','OLD_BIND=-','OLD_RES=-','FRESH_BIND=-','FRESH_BIND_VAL=00','PERSIST_DONE'],
}

def sha_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()

def git(*args: str) -> str:
    return subprocess.check_output(['git', *args], cwd=ROOT, text=True).strip()

def find_bochs() -> Path:
    explicit = os.environ.get('HOSTILE_BOCHS')
    if explicit:
        p = Path(explicit).expanduser()
        if p.is_file(): return p
        raise SystemExit(f'HOSTILE_BOCHS missing: {p}')
    q = shutil.which('bochs.exe') or shutil.which('bochs')
    if q: return Path(q)
    p = Path(r'C:\Program Files\Bochs-3.1\bochs.exe')
    if p.is_file(): return p
    raise SystemExit('Bochs not found')

def crc16(data: bytes) -> int:
    c = 0xffff
    for b in data:
        c ^= b << 8
        for _ in range(8):
            c = ((c << 1) ^ 0x1021) & 0xffff if c & 0x8000 else (c << 1) & 0xffff
    return c

def record(seq: int, val: int, ae: int, re: int) -> bytes:
    p = bytearray(24)
    p[:4] = b'H4F1'; p[4] = 0x51; p[5] = val; p[6] = ae; p[7] = re; p[8] = 0; p[9] = 1
    p[10] = ae; p[11] = 0; p[12] = 1; p[13] = 0; p[14] = 1; p[15] = re; p[16:18] = b'4\x12'
    p[18] = 1; p[19] = 0; p[20:24] = seq.to_bytes(4, 'little')
    q = bytes(p) + crc16(bytes(p)).to_bytes(2, 'little') + b'CMIT'
    return q + bytes(SECTOR - len(q))

def corrupt(r: bytes) -> bytes:
    x = bytearray(r); x[5] ^= 1; return bytes(x)

def control(mode: str) -> bytes:
    b = bytearray(SECTOR); b[:4] = b'V2MD'; b[4] = ord(mode); return bytes(b)

def make_image(base: bytes, path: Path, mode: str, a: bytes | None = None, b: bytes | None = None) -> None:
    im = bytearray(base); im[19*SECTOR:20*SECTOR] = control(mode)
    if a is not None: im[17*SECTOR:18*SECTOR] = a
    if b is not None: im[18*SECTOR:19*SECTOR] = b
    path.write_bytes(im)

def sector(path: Path, lba: int) -> bytes:
    with path.open('rb') as f:
        f.seek(lba * SECTOR); return f.read(SECTOR)

def extract_trace(lines: list[str], marker: str) -> list[str]:
    try: start = lines.index('S1_8K_OK')
    except ValueError: return []
    out = []
    for line in lines[start:]:
        out.append(line)
        if line == marker: break
    return out

def bochs_config(bochs: Path, disk: Path, work: Path, readonly: bool) -> Path:
    install = bochs.parent
    cfg = work / 'bochsrc.txt'
    cfg.write_text(
        f'romimage: file="{(install / "BIOS-bochs-latest").as_posix()}", options=fastboot\n'
        f'vgaromimage: file="{(install / "VGABIOS-lgpl-latest.bin").as_posix()}"\n'
        'cpu: model=phenom_8650_toliman, count=1, ips=50000000, reset_on_triple_fault=1, ignore_bad_msrs=1\n'
        'memory: guest=4096, host=256\n'
        f'floppya: 1_44="{disk.as_posix()}", status=inserted, write_protected={1 if readonly else 0}\n'
        'boot: floppy\nport_e9_hack: enabled=1, all_rings=1\ndisplay_library: nogui\n'
        f'log: "{(work / "bochs.log").as_posix()}"\n'
        'panic: action=fatal\nerror: action=report\ninfo: action=report\ndebug: action=ignore\nclock: sync=none\n',
        encoding='utf-8', newline='\n')
    return cfg

def bochs_boot(bochs: Path, disk: Path, work: Path, readonly: bool, marker: str, expected: list[str], timeout: float) -> dict:
    work.mkdir(parents=True, exist_ok=True)
    stdout_path = work / 'stdout.txt'; stderr_path = work / 'stderr.txt'
    cfg = bochs_config(bochs, disk, work, readonly)
    before = sha(disk)
    fo = stdout_path.open('wb', buffering=0); fe = stderr_path.open('wb', buffering=0)
    argv = [str(bochs), '-q', '-f', str(cfg)]
    started = time.perf_counter()
    proc = subprocess.Popen(argv, cwd=ROOT, stdin=subprocess.DEVNULL, stdout=fo, stderr=fe)
    deadline = time.time() + timeout; marker_seen = False; natural_exit = False
    marker_bytes = marker.encode('ascii')
    while time.time() < deadline:
        if stdout_path.exists() and marker_bytes in stdout_path.read_bytes():
            marker_seen = True; break
        if proc.poll() is not None:
            natural_exit = True; break
        time.sleep(0.05)
    if marker_seen:
        # Give BIOS-backed write paths a bounded flush interval before host termination.
        time.sleep(0.20)
        if proc.poll() is None:
            proc.terminate()
            try: proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                proc.kill(); proc.wait()
        status = 'TRACE_COMPLETE_HOST_TERMINATED'
    elif natural_exit:
        status = 'PROCESS_EXITED_BEFORE_MARKER'
    else:
        if proc.poll() is None:
            proc.kill(); proc.wait()
        status = 'UNKNOWN_TIMEOUT'
    fo.close(); fe.close()
    lines = stdout_path.read_text(encoding='ascii', errors='replace').splitlines() if stdout_path.exists() else []
    trace = extract_trace(lines, marker)
    after = sha(disk)
    return {
        'status': status,
        'passed': marker_seen and trace == expected,
        'marker_seen': marker_seen,
        'trace_exact': trace == expected,
        'trace': trace,
        'expected_trace': expected,
        'wall_ms': (time.perf_counter() - started) * 1000,
        'process_return_code_after_host_action': proc.returncode,
        'readonly': readonly,
        'disk_sha256_before': before,
        'disk_sha256_after': after,
        'disk_unchanged': before == after,
        'argv': argv,
        'config_path': str(cfg.relative_to(ROOT)).replace('\\','/'),
        'stdout_path': str(stdout_path.relative_to(ROOT)).replace('\\','/'),
        'stderr_path': str(stderr_path.relative_to(ROOT)).replace('\\','/'),
        'stderr': stderr_path.read_text(encoding='utf-8', errors='replace') if stderr_path.exists() else '',
        'termination_contract': 'terminal trace marker first; host termination second'
    }

def run_qemu_h1() -> dict:
    cp = subprocess.run(['python', str(ROOT/'tools/run_h1_hp_p2_1120_vm.py')], cwd=ROOT, text=True, capture_output=True, timeout=45)
    if cp.returncode != 0:
        return {'passed':False,'status':'RUNNER_FAILED','return_code':cp.returncode,'stdout':cp.stdout,'stderr':cp.stderr}
    try: receipt = json.loads(cp.stdout)
    except json.JSONDecodeError:
        return {'passed':False,'status':'RECEIPT_PARSE_FAILED','stdout':cp.stdout,'stderr':cp.stderr}
    receipt['trace_exact_current_core'] = receipt.get('trace') == CORE_TRACE
    receipt['passed'] = bool(receipt.get('passed')) and receipt['trace_exact_current_core']
    return receipt

def run_bochs_all(base: bytes, bochs: Path, out: Path, timeout: float) -> dict:
    result: dict = {'backend_role':'INDEPENDENT_X86_BOOT_AND_SEMANTIC_REPLAY','cpu_count':1,'memory_mib':4096}
    core_dir = out/'core'; core_dir.mkdir(parents=True, exist_ok=True); core_disk = core_dir/'core.img'; make_image(base, core_disk, 'C')
    result['core'] = bochs_boot(bochs, core_disk, core_dir, True, 'IRQ_DONE', CORE_TRACE, timeout)

    restart_dir = out/'restart'; restart_dir.mkdir(parents=True, exist_ok=True); restart_disk = restart_dir/'restart.img'; make_image(base, restart_disk, 'R', bytes(SECTOR), bytes(SECTOR))
    initial = sha(restart_disk)
    boot1 = bochs_boot(bochs, restart_disk, restart_dir/'boot1', False, 'PERSIST_DONE', RESTART_WRITE_TRACE, timeout)
    a1 = sector(restart_disk,17); b1 = sector(restart_disk,18); expected_a = record(1,0x71,1,1); after1 = sha(restart_disk)
    boot2_before = sha(restart_disk)
    boot2 = bochs_boot(bochs, restart_disk, restart_dir/'boot2', True, 'PERSIST_DONE', RESTART_RECOVER_TRACE, timeout)
    result['restart'] = {
        'initial_disk_sha256':initial,'boot1':boot1,'a_after_boot1_exact_expected':a1==expected_a,
        'a_after_boot1_sha256':sha_bytes(a1),'b_after_boot1_zero':b1==bytes(SECTOR),
        'disk_sha256_after_boot1':after1,'no_host_write_between_boots':boot2_before==after1,
        'boot2':boot2,'disk_unchanged_during_recovery_boot':boot2_before==sha(restart_disk),
        'disk_sha256_after_boot2':sha(restart_disk)
    }

    a1r = record(1,0x71,1,1); b2r = record(2,0x72,2,2)
    fixtures = {
        'old_empty':(a1r,bytes(SECTOR)),
        'newer_valid':(a1r,b2r),
        'newer_corrupt':(a1r,corrupt(b2r)),
        'equal_conflict':(record(2,0x72,2,2),record(2,0x73,2,2)),
        'both_invalid':(corrupt(a1r),corrupt(b2r)),
    }
    faults = {}
    for name,(a,b) in fixtures.items():
        d = out/'faulted_media'/name; d.mkdir(parents=True, exist_ok=True); disk=d/f'{name}.img'; make_image(base,disk,'F',a,b)
        br = bochs_boot(bochs,disk,d,True,'PERSIST_DONE',FAULT_TRACES[name],timeout)
        faults[name]={'boot':br,'disk_unchanged':br['disk_unchanged'],'a_sha256':sha_bytes(a),'b_sha256':sha_bytes(b)}
    result['faulted_media'] = faults

    restart_ok = all([
        result['restart']['boot1']['passed'], result['restart']['boot2']['passed'], result['restart']['a_after_boot1_exact_expected'],
        result['restart']['b_after_boot1_zero'], result['restart']['no_host_write_between_boots'], result['restart']['disk_unchanged_during_recovery_boot']
    ])
    faults_ok = all(v['boot']['passed'] and v['disk_unchanged'] for v in faults.values())
    result['checks'] = {'core_exact':result['core']['passed'],'restart_exact_and_invariants':restart_ok,'five_fault_cases_exact_and_readonly':faults_ok}
    result['passed'] = all(result['checks'].values())
    return result

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--rebuild', action='store_true')
    ap.add_argument('--timeout', type=float, default=12.0)
    args = ap.parse_args()
    if args.rebuild or not (BUILD/'d64_v3.img').is_file():
        subprocess.run(['python',str(BODY/'build.py')],cwd=BODY,check=True)
    base_path=BUILD/'d64_v3.img'; base=base_path.read_bytes(); bochs=find_bochs()
    stamp=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    run=RUNS/f'{stamp}_h1_emulator_matrix_01'; run.mkdir(parents=True,exist_ok=False)
    source_head=git('rev-parse','HEAD'); body_tree=git('rev-parse','HEAD:os/research_only/d64_reference_v3')
    inputs=run/'inputs'; inputs.mkdir()
    for src in [PROFILE,POLICY,Path(__file__).resolve()]:
        dst=inputs/src.name; shutil.copy2(src,dst)
    input_manifest=[]
    for f in sorted(inputs.iterdir()): input_manifest.append({'path':f.name,'bytes':f.stat().st_size,'sha256':sha(f)})
    (run/'inputs_manifest.json').write_text(json.dumps({'format':'H1_MATRIX_INPUTS_V1','source_git_head':source_head,'body_git_tree':body_tree,'base_image_sha256':sha(base_path),'inputs':input_manifest},indent=2)+'\n',encoding='utf-8',newline='\n')
    qemu=run_qemu_h1()
    bochs_result=run_bochs_all(base,bochs,run/'bochs',args.timeout)
    receipt={
        'format':'HOSTILE_OS_H1_EMULATOR_MATRIX_RUN_V2','status':'COMPLETED','passed':bool(qemu.get('passed')) and bochs_result['passed'],
        'source_git_head':source_head,'body_git_tree':body_tree,'base_image_sha256':sha(base_path),
        'profile_sha256':sha(PROFILE),'policy_sha256':sha(POLICY),'runner_sha256':sha(Path(__file__).resolve()),
        'qemu_h1_proxy':qemu,
        'bochs_independent_replay':bochs_result,
        'bochs_path':str(bochs),'bochs_sha256':sha(bochs),
        'backend_authority':{
            'qemu_h1_proxy':'two-vCPU coarse H1 constraint proxy, not A45/E2-1800 identity',
            'bochs_independent_replay':'one-CPU independent x86 semantic replay; installed package cannot represent H1 dual-core topology',
            'physical_h1':'hardware-specific authority remains unearned'
        }
    }
    (run/'matrix_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'run':str(run.relative_to(ROOT)).replace('\\','/'),'passed':receipt['passed'],'source_git_head':source_head,'base_image_sha256':receipt['base_image_sha256'],'qemu_passed':qemu.get('passed',False),'bochs_passed':bochs_result['passed'],'bochs_checks':bochs_result['checks']},indent=2))
    return 0 if receipt['passed'] else 2

if __name__ == '__main__':
    raise SystemExit(main())
