# C003/P01 — non-source-equivalent reconstruction probe result

**Run:** `20260829T205125Z_p01_reconstruction_01`
**Disposition:** QUALIFIED NARROW CONSEQUENCE / SOURCE-GROUNDED P01 REMAINS OPEN
**Scientific P01 completion:** NO
**Architecture promotion:** NONE

## Why this run exists

Exact final C002 Python mechanism / fixture / launcher / evaluator bytes could not be recovered after multiple independent source-recovery paths. The surviving C002/P20 closeout nevertheless carries a qualified semantic scar:

- one-shot completion notification lost an event when completion preceded wait installation;
- bounded current completion condition repaired that ordering;
- the stale evaluator initially failed to recognize `already complete` as a lawful second success path.

Under Adaptive Interpretation Mode, this run tests only whether that surviving distinction can be embodied in a tiny freestanding machine without Python. It is not represented as a translation of the lost C002 source.

## Mechanism / fixture / launcher / evaluator separation

Mechanism:
- `P01_reconstruction_probe/mechanism.S`
- SHA-256 `19155ba00fa37a9ca37edc0d0469183a26da57668d1563be69444aedff596262`

Fixture:
- `P01_reconstruction_probe/fixture.S`
- SHA-256 `d28b181114c2a56a2a27c18235737a5fbd4752a8e68e3cd6f3e500f30183c7bb`
- supplies operation ordering only: wait / completion / end
- supplies no wake/currentness behavior

Linker:
- `P01_reconstruction_probe/linker.ld`
- SHA-256 `535968d750dff301e9652084ab46894f31ad22c5c0e51358a543319c433445b8`

Launcher:
- `P01_reconstruction_probe/launch_reconstruction.ps1`
- SHA-256 `64a7f60d5adff8106e908f098fbce7cd0c0a666c4b76e6a731db40f14d695cab`

Evaluator:
- `P01_reconstruction_probe/evaluate_reconstruction.py`
- version `C003-P01-reconstruction-evaluator-v1`
- SHA-256 `353edd7ca687262b926152803d376f6ed34b7307ce135dfae751dc1066facced`

## Environment

Compiler:
- Clang 21.0.0 from Android NDK
- SHA-256 `f2e1b93d9dd27b847773e7de61b00f1b49ae27eb20ba434297cc020f768a1dfb`

Linker:
- `ld.lld.exe`
- SHA-256 `1260f9d6e0522bd476d040203998fa03406607971c13a9aa74f3f66f1e6d1c5d`

Objcopy:
- `llvm-objcopy.exe`
- SHA-256 `4a7559a17dba5f35eb8d209e4765516b548e83b664278c8640f484c3be70e901`

Machine instantiation:
- `C:\Program Files\qemu\qemu-system-i386.exe`
- QEMU 11.1.0
- SHA-256 `dbbf7242e5b0d295e54336c69034a266ee1cc117d7ac6e3060e38bb61651200b`

Evaluator interpreter:
- Python 3.14.6
- SHA-256 `03168c01b7b7491423350e82c26fee71f35b43694d1319d3c668bda6903a0c38`

## Embodiment

The mechanism uses fixed-capacity explicit bytes for:

- `completion_current`
- `wait_active`
- `parent_runnable`

The repaired path retains terminal completion as current state. A later wait checks that current state before arming a wait. Completion also wakes an already-armed wait.

The negative-control path intentionally uses one-shot behavior: completion only wakes an already-armed wait and is otherwise discarded.

No dynamic allocation, Python objects, dict/list/set containers, exceptions, host scheduling, or interpreter continuation is used by the guest mechanism.

That observation is about **this reconstruction**, not about what the unrecovered Python source relied on.

## Discriminator

The fixture runs three cases:

1. repaired `WAIT -> COMPLETE`
2. repaired `COMPLETE -> WAIT`
3. deliberately broken one-shot `COMPLETE -> WAIT`

Expected durable guest observation:

```text
R_WC=PASS
R_CW=PASS
B_CW=FAIL
DONE
```

## Observed consequence

Raw boot image:
- bytes: 512
- boot signature: `55 aa`
- SHA-256 `962e7cba0ef2452b3d860f7ade7582aaee61f9f5430bf455864481f7c974cc3d`

QEMU:
- expected deterministic exit: 33
- observed exit: 33
- stdout: empty
- stderr: empty

Debug channel:

```text
R_WC=PASS
R_CW=PASS
B_CW=FAIL
DONE
```

- debugcon SHA-256 `68f6cbeb3e444ccf2b56f1c87ee84ae039c17dd2323bc3acf6956c2587fdc1af`

Evaluator:
- observed lines exactly matched expected lines
- evaluator exit: 0
- result: `passed=true`
- evaluation SHA-256 `03ba5604ec90646c5678334d50838a8fe7f1d0b19965ade92065625d4a1693b9`
- evaluator stderr: empty

Run receipt:
- `research/campaigns/C003/runs/20260829T205125Z_p01_reconstruction_01/receipt.json`
- SHA-256 `036ccbcc3a758e74bb13922ffb305a24d1ce9b9aedbe5c721a0749bc1a1da48a`

## Qualified conclusion

**VERIFIED for this reconstruction:** bounded explicit current completion state is sufficient for both tested event orders, while the one-shot negative control reproduces the completion-before-wait loss. The distinction survives translation into a 512-byte freestanding x86 boot image without Python runtime services.

This is useful Pareto pressure: the P17/P18 semantic distinction does not require a large subsystem or a Python runtime to exist.

## What this does not earn

This run does **not** establish:

- that the reconstructed layout matches the lost C002 Python representation;
- which Python host services the C002 source actually relied on;
- that all C002 whole-P01 relations have been translated;
- that C003/P01 is complete;
- any C003/P02 content;
- architecture promotion;
- schedulerlessness, ECS, capability-kernel, or other broad architecture claims.

## Next lawful seam

The source-grounded host-subsidy inventory remains open. If exact C002 source becomes recoverable, bind observed Python dependencies to the preregistered dispositions and compare them against this freestanding reconstruction. Until then, further embodiment may test additional P20-surviving semantics only under the same non-source-equivalent authority ceiling; it may not silently substitute reconstruction for lost source evidence.
