from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
from pathlib import Path


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def crlf(data: bytes) -> bytes:
    return data.replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")


def lf(data: bytes) -> bytes:
    return data.replace(b"\r\n", b"\n")


def main() -> int:
    ap=argparse.ArgumentParser(description='Verify historical run input hashes across Git line-ending normalization')
    ap.add_argument('run_dir',help='run directory containing inputs_manifest.json')
    args=ap.parse_args()
    run=Path(args.run_dir).resolve(); repo=Path(__file__).resolve().parents[1]
    manifest=json.loads((run/'inputs_manifest.json').read_text(encoding='utf-8'))
    rows=[]; failed=[]
    for item in manifest['inputs']:
        rel=item['source_project_relative']; expected=item['sha256']; snap=run/item['snapshot_path']
        snap_bytes=snap.read_bytes()
        try:
            blob=subprocess.check_output(['git','show','HEAD:'+rel],cwd=repo)
        except subprocess.CalledProcessError:
            blob=b''
        direct=digest(blob)==expected if blob else False
        as_crlf=digest(crlf(blob))==expected if blob else False
        as_lf=digest(lf(blob))==expected if blob else False
        snap_match=digest(snap_bytes)==expected
        status='DIRECT' if direct else ('CRLF_NORMALIZED' if as_crlf else ('LF_NORMALIZED' if as_lf else 'MISMATCH'))
        row={'key':item['key'],'path':rel,'expected':expected,'snapshot_matches':snap_match,'git_blob_status':status,'git_blob_sha256':digest(blob) if blob else None}
        rows.append(row)
        if not snap_match or status=='MISMATCH': failed.append(item['key'])
    report={'format':'HOSTILE_OS_HISTORICAL_INPUT_HASH_CHECK_V1','run_dir':str(run),'passed':not failed,'failures':failed,'inputs':rows,'note':'normalization classifications explain historical checkout hashes; sealed receipt hashes are not rewritten'}
    print(json.dumps(report,indent=2))
    return 0 if report['passed'] else 1

if __name__=='__main__': raise SystemExit(main())
