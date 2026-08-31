# D64 reference v2 OS-only admission audit — 2026-08-30

Status: **PASS / ADMISSION GATE SATISFIED**
Audit source commit: `aafc78eccf9611c815fcefa560847e425c50a548`
V2 Git tree object: `800bf1a727786dab6c90ab0b2469c2bd406a9b9c`
Historical I001 tree object: `bd641bcd658fbf558f15a9226f96058351d5794c`
Pre-v2 I001 anchor tree: `bd641bcd658fbf558f15a9226f96058351d5794c`

## Isolation method

An exact `git archive HEAD os` export was extracted into scratch. The export root contained `os/` and **did not contain**:
- `research/`;
- `continuity/`;
- `authority/`;
- `handoffs/`.

The isolated v2 directory was then used as its own working directory for:

```text
python build.py
python run.py --mode all
python verify.py
```

No full-repository path was used by those scripts.

Static token inspection of `build.py`, `run.py`, and `verify.py` found no references to the forbidden R&D/history dependency roots above.

## Isolated build/run result

PASS:
- stage1 512 bytes + `55 aa`;
- stage2 raw 3845 bytes;
- total linked memory 7440 bytes <= 8192;
- named state exactly 3467 bytes;
- core+IRQ reviewer boot exit33;
- restart Boot1/Boot2 exit33 with no host write between boots and exact durable A record;
- five faulted-media reviewer boots exit33;
- integrated verifier PASS 17/17.

The isolated build reproduced the same stage1/stage2/disk hashes as the canonical full-tree embodiment check.

## Historical-reference preservation

Current I001 tree object:
`bd641bcd658fbf558f15a9226f96058351d5794c`

Pre-v2 convergence anchor (`c407449`) I001 tree object:
`bd641bcd658fbf558f15a9226f96058351d5794c`

Exact equality: **true**.

The new v2 body therefore did not rewrite the historical I001 reference generation.

## Admission decision

The planned admission gates are satisfied:
- self-contained build from `os/` only;
- all reviewer modes pass;
- verifier passes;
- architecture/evidence map is present;
- no hidden R&D-tree build/run dependency found;
- historical I001 reference unchanged.

Therefore `os/research_only/d64_reference_v2/` may now be labeled:

**CURRENT_RESEARCH_REFERENCE**

Authority ceiling remains unchanged:
- RESEARCH PURPOSES ONLY;
- FINAL_ARCHITECTURE=false;
- PRODUCTION_READY=false;
- GENERAL_PURPOSE_RELEASE=false.
