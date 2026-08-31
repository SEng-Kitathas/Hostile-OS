from __future__ import annotations
import argparse,hashlib,json,sys
from pathlib import Path
LOG_BASE_LBA=256; LOG_SECTORS=128; SECTOR=512; MAGIC=b'H1LG'; VERSION=1

def decode_region(region:bytes):
 if len(region)<LOG_SECTORS*SECTOR: raise ValueError('journal region too short')
 records=[]; session=None; expected_seq=0
 for i in range(LOG_SECTORS):
  s=region[i*SECTOR:(i+1)*SECTOR]
  if s[:4]!=MAGIC: break
  ver=int.from_bytes(s[4:6],'little'); ses=int.from_bytes(s[6:8],'little'); seq=int.from_bytes(s[8:10],'little'); n=int.from_bytes(s[10:12],'little')
  if ver!=VERSION or n>500: break
  if session is None: session=ses
  if ses!=session or seq!=expected_seq: break
  payload=s[12:12+n]
  records.append({'lba':LOG_BASE_LBA+i,'version':ver,'session':ses,'sequence':seq,'length':n,'payload':payload})
  expected_seq+=1
 text=b''.join(r['payload'] for r in records)
 return {'session':session,'record_count':len(records),'text_bytes':text,'text':text.decode('ascii',errors='replace'),'text_sha256':hashlib.sha256(text).hexdigest()}

def decode_image_bytes(b:bytes):
 a=LOG_BASE_LBA*SECTOR; z=a+LOG_SECTORS*SECTOR
 if len(b)<z: raise ValueError('image/device capture too short')
 return decode_region(b[a:z])

def self_test():
 reg=bytearray(LOG_SECTORS*SECTOR)
 def put(i,ses,seq,payload):
  o=i*SECTOR; reg[o:o+4]=MAGIC; reg[o+4:o+6]=(1).to_bytes(2,'little'); reg[o+6:o+8]=ses.to_bytes(2,'little'); reg[o+8:o+10]=seq.to_bytes(2,'little'); reg[o+10:o+12]=len(payload).to_bytes(2,'little'); reg[o+12:o+12+len(payload)]=payload
 put(0,0x1234,0,b'A\n'); put(1,0x1234,1,b'B\n'); put(2,0x7777,2,b'STALE\n')
 d=decode_region(bytes(reg))
 return d['record_count']==2 and d['text_bytes']==b'A\nB\n'

def main():
 ap=argparse.ArgumentParser(); ap.add_argument('source',nargs='?'); ap.add_argument('--self-test',action='store_true'); ap.add_argument('--json',action='store_true'); ns=ap.parse_args()
 if ns.self_test:
  ok=self_test(); print('SELF_TEST='+('PASS' if ok else 'FAIL')); return 0 if ok else 1
 if not ns.source: ap.error('source required unless --self-test')
 p=ns.source
 with open(p,'rb',buffering=0) as f:
  f.seek(LOG_BASE_LBA*SECTOR); region=f.read(LOG_SECTORS*SECTOR)
 d=decode_region(region)
 if ns.json:
  out={k:v for k,v in d.items() if k not in ('text_bytes',)}; print(json.dumps(out,indent=2,sort_keys=True))
 else:
  print(f"H1LOG session={d['session']} records={d['record_count']} sha256={d['text_sha256']}")
  print(d['text'],end='' if d['text'].endswith('\n') or not d['text'] else '\n')
 return 0
if __name__=='__main__': raise SystemExit(main())
