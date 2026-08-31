from __future__ import annotations
import argparse, hashlib, json, os, shutil, subprocess, time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
BODY=ROOT/'os/research_only/d64_reference_v2'
BUILD=BODY/'build'
SCRATCH=ROOT/'.pcmmad_sync_runs/h1_hp_p2_1120'
SECTOR=512

def sha(path:Path)->str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''): h.update(chunk)
    return h.hexdigest()

def find_exe(env_name:str,names:list[str],fallbacks:list[Path])->Path:
    v=os.environ.get(env_name)
    if v:
        p=Path(v).expanduser()
        if p.is_file(): return p
        raise SystemExit(f'{env_name} missing: {p}')
    for name in names:
        q=shutil.which(name)
        if q:return Path(q)
    for p in fallbacks:
        if p.is_file():return p
    raise SystemExit(f'missing tool: {env_name}')

def qemu_data_dir(qemu:Path)->Path|None:
    explicit=os.environ.get('HOSTILE_QEMU_DATA_DIR') or os.environ.get('HOSTILE_QEMU_FIRMWARE')
    if explicit:
        p=Path(explicit).expanduser()
        if not (p/'bios-256k.bin').is_file(): raise SystemExit(f'QEMU firmware/data dir lacks bios-256k.bin: {p}')
        return p
    for p in (qemu.parent/'share/qemu',qemu.parent/'share',qemu.parent.parent/'share/qemu',qemu.parent.parent/'share'):
        if (p/'bios-256k.bin').is_file():return p
    return None

def make_core_boot(base:Path,out:Path)->None:
    image=bytearray(base.read_bytes())
    control=bytearray(SECTOR);control[:4]=b'V2MD';control[4]=ord('C')
    image[19*SECTOR:20*SECTOR]=control
    out.write_bytes(image)

def main()->int:
    ap=argparse.ArgumentParser(description='Run current HOSTILE-OS body under the H1 HP Pavilion p2-1120 constraint proxy.')
    ap.add_argument('--rebuild',action='store_true',help='rebuild d64_reference_v2 before launch')
    ap.add_argument('--timeout',type=float,default=15.0)
    ap.add_argument('--machine',default='pc-q35-11.1')
    ap.add_argument('--cpu',default='phenom')
    ap.add_argument('--ram-mib',type=int,default=4096)
    ap.add_argument('--target-disk-gib',type=int,default=500)
    args=ap.parse_args()
    SCRATCH.mkdir(parents=True,exist_ok=True)
    if args.rebuild or not (BUILD/'d64_v2.img').is_file():
        subprocess.run(['python',str(BODY/'build.py')],cwd=BODY,check=True)
    base=BUILD/'d64_v2.img'
    qemu=find_exe('HOSTILE_QEMU_X64',['qemu-system-x86_64','qemu-system-x86_64.exe'],[Path(r'C:\Program Files\qemu\qemu-system-x86_64.exe')])
    qimg=find_exe('HOSTILE_QEMU_IMG',['qemu-img','qemu-img.exe'],[Path(r'C:\Program Files\qemu\qemu-img.exe')])
    data=qemu_data_dir(qemu)
    target=SCRATCH/f'target-{args.target_disk_gib}g.qcow2'
    if not target.is_file():
        subprocess.run([str(qimg),'create','-f','qcow2',str(target),f'{args.target_disk_gib}G'],check=True)
    boot=SCRATCH/'current-core-boot.img';make_core_boot(base,boot)
    debug=SCRATCH/'debugcon.txt';debug.unlink(missing_ok=True)
    argv=[str(qemu)]
    if data:argv+=['-L',str(data)]
    argv += [
      '-accel','tcg','-machine',args.machine,'-cpu',args.cpu,
      '-smp','2,sockets=1,cores=2,threads=1','-m',str(args.ram_mib),
      '-display','none','-monitor','none','-serial','none','-nic','none','-no-reboot','-boot','a',
      '-drive',f'file={boot.as_posix()},format=raw,if=floppy,readonly=on',
      '-drive',f'file={target.as_posix()},format=qcow2,if=ide,index=0,media=disk',
      '-device','isa-debug-exit,iobase=0xf4,iosize=0x04',
      '-debugcon',f'file:{debug.as_posix()}','-global','isa-debugcon.iobase=0xe9'
    ]
    started=time.perf_counter();status='COMPLETED';rc=None;stderr=''
    try:
        cp=subprocess.run(argv,cwd=BODY,capture_output=True,timeout=args.timeout)
        rc=cp.returncode;stderr=cp.stderr.decode('utf-8',errors='replace')
    except subprocess.TimeoutExpired as e:
        status='UNKNOWN_TIMEOUT';stderr=(e.stderr or b'').decode('utf-8',errors='replace') if isinstance(e.stderr,(bytes,bytearray)) else str(e.stderr or '')
    trace=debug.read_text(encoding='ascii',errors='replace').splitlines() if debug.exists() else []
    checks={
      'completed_exit_33':status=='COMPLETED' and rc==33,
      'core_trace_present':'TEST=D64_V2_CORE' in trace,
      'irq_trace_complete':'IRQ_DONE' in trace,
      'two_vcpu_profile':True,
      'ram_profile_4096_default':args.ram_mib==4096,
      'target_disk_present':target.is_file(),
    }
    receipt={
      'format':'HOSTILE_OS_H1_VM_RUN_V1','status':status,'passed':all(checks.values()),'checks':checks,
      'wall_ms':(time.perf_counter()-started)*1000,'exit_code':rc,'machine':args.machine,'cpu_model':args.cpu,
      'smp':'2,sockets=1,cores=2,threads=1','ram_mib':args.ram_mib,'target_disk_gib':args.target_disk_gib,
      'qemu_path':str(qemu),'qemu_data_dir':str(data) if data else None,'base_image_sha256':sha(base),'boot_image_sha256':sha(boot),
      'target_disk_path':str(target.relative_to(ROOT)).replace('\\','/'),'trace':trace,'stderr':stderr,'argv':argv,
      'fidelity_ceiling':['Q35/ICH9 != AMD A45 FCH','phenom CPU model != AMD E2-1800','TCG timing != physical 1.7 GHz','emulated display != Radeon HD 7340']
    }
    (SCRATCH/'run_receipt.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(receipt,indent=2))
    return 0 if receipt['passed'] else 2

if __name__=='__main__':raise SystemExit(main())
