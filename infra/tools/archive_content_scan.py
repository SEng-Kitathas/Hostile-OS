from __future__ import annotations
import os, sys, time, zipfile, tarfile, json
from pathlib import Path

NEEDLES=(
    b"18/72", b"72/72", b"completion-before-wait", b"already complete",
    b"notification wakes waiting parent", b"current completion condition",
    b"one-shot completion", b"generation-scoped", b"wait forever",
    b"c002/p17", b"c002_p17", b"c002 p17", b"c002/p18", b"c002_p18", b"c002 p18",
    b"c002/p19", b"c002_p19", b"c002 p19"
)
TEXT_EXTS=(".py",".md",".txt",".json",".log",".csv",".tsv",".yaml",".yml",".toml",".ps1",".c",".h",".asm",".s",".rst")
MAX_MEMBER=8*1024*1024

def is_reparse(path: str) -> bool:
    try:
        st=os.lstat(path); return bool(getattr(st,"st_file_attributes",0)&0x400)
    except OSError: return False

def kind(name: str):
    n=name.lower()
    if n.endswith((".zip",".whl",".jar")): return "zip"
    if n.endswith((".tar",".tgz",".tar.gz")): return "tar"
    return None

def likely_text(name: str) -> bool:
    n=name.lower()
    return n.endswith(TEXT_EXTS) or "." not in os.path.basename(n)

def main() -> int:
    if len(sys.argv)!=3:
        print("usage: archive_content_scan.py ROOT OUTPUT", file=sys.stderr); return 64
    root, out=sys.argv[1], Path(sys.argv[2]); out.parent.mkdir(parents=True,exist_ok=True)
    archives=members=read_members=bytes_read=0; hits=[]; errors=[]; start=time.time(); stack=[root]
    while stack:
        d=stack.pop()
        try:
            with os.scandir(d) as it:
                for e in it:
                    try:
                        if e.is_dir(follow_symlinks=False):
                            if not is_reparse(e.path): stack.append(e.path)
                            continue
                        if not e.is_file(follow_symlinks=False): continue
                        k=kind(e.name)
                        if not k: continue
                        archives+=1
                        try:
                            if k=="zip":
                                with zipfile.ZipFile(e.path) as z:
                                    for info in z.infolist():
                                        members+=1
                                        if info.is_dir() or info.file_size>MAX_MEMBER or not likely_text(info.filename): continue
                                        try: data=z.read(info)
                                        except Exception as ex:
                                            if len(errors)<1000: errors.append((e.path,info.filename,type(ex).__name__,str(ex)[:200])); continue
                                        read_members+=1; bytes_read+=len(data); low=data.lower()
                                        matched=[n.decode('ascii') for n in NEEDLES if n in low]
                                        if matched: hits.append((e.path,info.filename,matched,len(data)))
                            else:
                                with tarfile.open(e.path,"r:*") as t:
                                    for m in t:
                                        members+=1
                                        if not m.isfile() or m.size>MAX_MEMBER or not likely_text(m.name): continue
                                        try:
                                            f=t.extractfile(m); data=f.read() if f else b""
                                        except Exception as ex:
                                            if len(errors)<1000: errors.append((e.path,m.name,type(ex).__name__,str(ex)[:200])); continue
                                        read_members+=1; bytes_read+=len(data); low=data.lower()
                                        matched=[n.decode('ascii') for n in NEEDLES if n in low]
                                        if matched: hits.append((e.path,m.name,matched,len(data)))
                        except Exception as ex:
                            if len(errors)<1000: errors.append((e.path,"<archive>",type(ex).__name__,str(ex)[:200]))
                    except Exception as ex:
                        if len(errors)<1000: errors.append((getattr(e,'path',d),"<entry>",type(ex).__name__,str(ex)[:200]))
        except Exception as ex:
            if len(errors)<1000: errors.append((d,"<dir>",type(ex).__name__,str(ex)[:200]))
    result={"root":root,"started_epoch":start,"ended_epoch":time.time(),"archives_examined":archives,"members_examined":members,"text_members_read":read_members,"bytes_read":bytes_read,"hits":len(hits),"errors_captured":len(errors)}
    with out.open("w",encoding="utf-8") as f:
        f.write(json.dumps(result,sort_keys=True)+"\n")
        for a,n,m,s in hits: f.write(f"HIT\t{a}\t{n}\t{s}\t{','.join(m)}\n")
        for a,n,t,m in errors: f.write(f"ERR\t{a}\t{n}\t{t}\t{m}\n")
    print(json.dumps(result,sort_keys=True))
    for a,n,m,s in hits[:250]: print("HIT",a,"::",n,"::",m,"::",s)
    return 0
if __name__=="__main__": raise SystemExit(main())
