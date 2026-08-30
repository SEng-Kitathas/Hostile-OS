from __future__ import annotations
import os, sys, time, zipfile, tarfile, json
from pathlib import Path

NEEDLES=("c002","p17","p18","p19","whole_p01","whole-p01","relation_substrate","hostile_os","hostile-os")

def is_reparse(path: str) -> bool:
    try:
        st=os.lstat(path)
        return bool(getattr(st,"st_file_attributes",0)&0x400)
    except OSError:
        return False

def kind(name: str):
    n=name.lower()
    if n.endswith((".zip",".whl",".jar")): return "zip"
    if n.endswith((".tar",".tgz",".tar.gz")): return "tar"
    return None

def main() -> int:
    if len(sys.argv)!=3:
        print("usage: archive_name_scan.py ROOT OUTPUT", file=sys.stderr); return 64
    root, out=sys.argv[1], Path(sys.argv[2])
    out.parent.mkdir(parents=True,exist_ok=True)
    archives=entries=0; hits=[]; errors=[]; start=time.time(); stack=[root]
    while stack:
        d=stack.pop()
        try:
            with os.scandir(d) as it:
                for e in it:
                    try:
                        if e.is_dir(follow_symlinks=False):
                            if not is_reparse(e.path): stack.append(e.path)
                        elif e.is_file(follow_symlinks=False):
                            k=kind(e.name)
                            if not k: continue
                            archives+=1
                            try:
                                names=[]
                                if k=="zip":
                                    with zipfile.ZipFile(e.path) as z: names=z.namelist()
                                else:
                                    with tarfile.open(e.path,"r:*") as t: names=[m.name for m in t]
                                entries+=len(names)
                                for n in names:
                                    low=n.lower()
                                    if any(x in low for x in NEEDLES): hits.append((e.path,n))
                            except Exception as ex:
                                if len(errors)<1000: errors.append((e.path,type(ex).__name__,str(ex)[:240]))
                    except Exception as ex:
                        if len(errors)<1000: errors.append((getattr(e,'path',d),type(ex).__name__,str(ex)[:240]))
        except Exception as ex:
            if len(errors)<1000: errors.append((d,type(ex).__name__,str(ex)[:240]))
    result={"root":root,"started_epoch":start,"ended_epoch":time.time(),"archives_examined":archives,"entries_examined":entries,"hits":len(hits),"errors_captured":len(errors)}
    with out.open("w",encoding="utf-8") as f:
        f.write(json.dumps(result,sort_keys=True)+"\n")
        for a,n in hits: f.write(f"HIT\t{a}\t{n}\n")
        for a,t,m in errors: f.write(f"ERR\t{a}\t{t}\t{m}\n")
    print(json.dumps(result,sort_keys=True))
    for a,n in hits[:250]: print("HIT",a,"::",n)
    return 0
if __name__=="__main__": raise SystemExit(main())
