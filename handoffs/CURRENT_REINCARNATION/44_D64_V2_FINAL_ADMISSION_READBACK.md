# D64 reference v2 final admitted-state readback — 2026-08-30

Status: **PASS**
Admitted canonical commit: `9332d34ac7cf0043a5851632aab698fe61967eef`
V2 tree at admitted commit: `e7e9c08458bd9573ff4bcd60b9193d88adb26b21`
I001 tree: `bd641bcd658fbf558f15a9226f96058351d5794c`
I001 pre-v2 anchor tree: `bd641bcd658fbf558f15a9226f96058351d5794c`

After `CURRENT_RESEARCH_REFERENCE` metadata was committed, an exact `git archive HEAD os` export was created from commit `9332d34ac7cf0043a5851632aab698fe61967eef`.

The isolated export contained no `research/`, `continuity/`, `authority/`, or `handoffs/` root.

From `os/research_only/d64_reference_v2/` inside that export, the following completed successfully:

```text
python build.py
python run.py --mode all
python verify.py
```

Readback:
- body status: `CURRENT_RESEARCH_REFERENCE`;
- stage1: 512 bytes + `55 aa`;
- stage2 raw: 3845 bytes;
- total linked stage2 memory: 7440 bytes;
- named state: 3467 bytes;
- core+IRQ reviewer boot: PASS;
- restart two-boot reviewer: PASS, no host write between boots;
- five faulted-media reviewer boots: PASS;
- verifier: 17/17 PASS;
- historical I001 tree unchanged from pre-v2 anchor: `true`.

This closes the gap between the pre-label admission audit and the exact admitted Git commit. It is an engineering/reproducibility readback, not new science.
