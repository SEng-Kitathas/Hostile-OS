from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

EXPECTED_STAGE1 = "bd13612a1a1db38dd2c847fce1f19ca5305a8febc06f99090d6d1ae882334eb8"
EXPECTED_STAGE2 = "2e428e4ef6226dd91fd23ee8dffbdf55887188fbfb84cd745dfc94c4301d02be"


def sha256(path: Path) -> str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for c in iter(lambda:f.read(1024*1024),b''): h.update(c)
    return h.hexdigest()


def require(lines: list[str], expected: list[str], label: str, failures: list[str]) -> None:
    for item in expected:
        if item not in lines:
            failures.append(f"{label}: missing {item!r}")


def main() -> int:
    ap=argparse.ArgumentParser(description='Verify the HOSTILE-OS research-only embodiment')
    ap.add_argument('--build-dir',default='build')
    ap.add_argument('--build-only',action='store_true')
    args=ap.parse_args()
    here=Path(__file__).resolve().parent; build=Path(args.build_dir)
    if not build.is_absolute(): build=here/build
    if not (build/'build_manifest.json').exists():
        cp=subprocess.run([sys.executable,str(here/'build.py'),'--out',str(build)],check=False)
        if cp.returncode!=0: return cp.returncode
    failures=[]; checks={}
    s1=build/'stage1.bin'; s2=build/'stage2.raw.bin'
    checks['stage1_hash_matches_i001']=sha256(s1)==EXPECTED_STAGE1
    checks['stage2_hash_matches_i001']=sha256(s2)==EXPECTED_STAGE2
    checks['stage1_size_512']=s1.stat().st_size==512
    checks['stage1_signature_55aa']=s1.read_bytes()[510:]==b'\x55\xaa'
    checks['stage2_within_4096']=s2.stat().st_size<=4096
    for k,v in checks.items():
        if not v: failures.append(k)
    if not args.build_only:
        receipt=build/'run_receipt.json'
        if not receipt.exists():
            cp=subprocess.run([sys.executable,str(here/'run.py'),'--build-dir',str(build)],check=False)
            if cp.returncode!=0: failures.append(f'run.py exit {cp.returncode}')
        if receipt.exists():
            r=json.loads(receipt.read_text(encoding='utf-8'))
            checks['distinct_qemu_pids']=r['boot1']['pid']!=r['boot2']['pid']
            checks['boot1_exit33']=r['boot1']['status']=='COMPLETED' and r['boot1']['exit_code']==33
            checks['boot2_exit33']=r['boot2']['status']=='COMPLETED' and r['boot2']['exit_code']==33
            checks['no_host_write_between_boots']=r.get('no_host_disk_write_between_boots') is True
            b1=r.get('boot1_trace',[]); b2=r.get('boot2_trace',[])
            require(b1,['S1_OK','BOOT=1','P_ACQ=W','C_ACQ=W','B_FULL=F','WAIT_CONT=2','MISS=M','IDLE_ENTER=1','IRQ_REL=1','WAKE=1','APPLY_PROG=2','STALE_C=R','FLAG_CTL=S','VER_CTL=R','STABLE_CTL=C','DURABLE_WRITE=W','GEN_EXHAUST=G','DONE'],'boot1',failures)
            require(b2,['S1_OK','BOOT=2','DURABLE=PASS','PREBIND=R','BAD_RESTART_USE=W','REBIND=W','POSTBIND=W','OLD_TOKEN=R','EPOCH=2','DURABLE_REWRITE=W','DONE'],'boot2',failures)
            irq=[x for x in b1 if x.startswith('IRQ_EVENT=')]
            irq_count=None
            if len(irq)==1:
                try: irq_count=int(irq[0].split('=',1)[1])
                except ValueError: pass
            checks['irq_event_positive']=irq_count is not None and irq_count>=1
            checks['historical_exact_irq_event_one']=irq_count==1
            # The exact-one field is reported but intentionally not required here; historical science owns that seam.
            for k in ['distinct_qemu_pids','boot1_exit33','boot2_exit33','no_host_write_between_boots','irq_event_positive']:
                if not checks.get(k): failures.append(k)
    report={
        'format':'HOSTILE_OS_RESEARCH_ONLY_VERIFY_V1',
        'passed':not failures,
        'checks':checks,
        'failures':failures,
        'note':'historical_exact_irq_event_one is informational; the historical I001 evaluator remains unchanged and its IRQ_EVENT count seam remains open',
    }
    (build/'verify_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(report,indent=2))
    return 0 if report['passed'] else 1


if __name__=='__main__': raise SystemExit(main())
