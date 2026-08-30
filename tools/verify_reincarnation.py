from pathlib import Path
import hashlib, json, sys, zipfile
root = Path(__file__).resolve().parents[1]
manifest_path = root / 'MANIFEST_SHA256.json'
manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
errors=[]
expected=set()
for rec in manifest['files']:
    rel=rec['path']; expected.add(rel); p=root/rel
    if not p.is_file(): errors.append(f'MISSING {rel}'); continue
    h=hashlib.sha256(p.read_bytes()).hexdigest()
    if h != rec['sha256']: errors.append(f'HASH {rel} expected={rec["sha256"]} actual={h}')
    if p.stat().st_size != rec['size_bytes']: errors.append(f'SIZE {rel}')
actual={p.relative_to(root).as_posix() for p in root.rglob('*') if p.is_file() and p.relative_to(root).as_posix() != 'MANIFEST_SHA256.json'}
# PACKAGE_VERIFICATION_RECEIPT is intentionally outside manifested payload semantics if added after sealing.
actual.discard('PACKAGE_VERIFICATION_RECEIPT.txt')
extra=sorted(actual-expected); missing=sorted(expected-actual)
if extra: errors.append('EXTRA '+repr(extra))
if missing: errors.append('MEMBERSHIP_MISSING '+repr(missing))
# ZIP CRC smoke for carried payloads.
for p in (root/'08_PAYLOADS').rglob('*.zip'):
    try:
        with zipfile.ZipFile(p) as z:
            bad=z.testzip()
            if bad: errors.append(f'ZIP_CRC {p.relative_to(root)} member={bad}')
    except Exception as e: errors.append(f'ZIP_OPEN {p.relative_to(root)} {e}')
if errors:
    print('FAIL: reincarnation verification')
    for e in errors: print(e)
    sys.exit(1)
print(f'PASS: reincarnation manifest/membership/hash closure files={len(expected)}')
print('ASSURANCE_CEILING=PACKAGE_INTEGRITY_AND_DECLARED_PROVENANCE_NOT_SEMANTIC_OR_ARCHITECTURE_PROOF')
