# C003 / P18 — explicit two-byte serialization convention

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P18 of 20
**Architecture promotion:** NONE
**P19 earned:** YES

## Controlling preregistration and run

Preregistration was sealed at `60553bfe76566433f2544d3549a470d4341bc12a` before source/execution.

Run `20260830T022300Z_p18_serialization_01`: QEMU PID `14516`, start `2026-08-30T02:22:50.230973+00:00`, end `2026-08-30T02:22:50.423544+00:00`, `COMPLETED`, exit `33`; evaluator exit `0`; stderr empty.

## Exact observation

```text
ENC0=34
ENC1=12
GOOD=1234
BAD=3412
DONE
```

Evaluator `C003-P18-serialization-v1`: passed.

## Exact hashes

Source:
- mechanism `a5eabee7e5bd8ee5f1269cb1c6edb3ec1b5dc8278651a9f3cd9581babce86226`
- fixture `c407ad34323dcd0e052cb5098ee09b3c50ac2bea897531462ee671436fb4f60c`
- linker `29092a54de6afc8ab9d08bd992f80d6e16eebbcb06afdb0af806b37cc01ea405`
- evaluator `842626edb1f666d8a63fe87451f7fb2e9497521430ed774ad8d1de8a1297828b`
- launcher `f66c675974088cea9eeaac689b05235dad6bcdfc8f90afa0c0ffea03f8c2e84b`

Run:
- boot `cdca1968de097101bdf6c84a16fb5af1d8a2545f8be5d2724d3baafe60ca0d5a`
- debugcon `3973640611b318292c85d721abbcea3e199e7736374251dd208469a7dbce04cb`
- evaluation `828685ba7831ddc53b504c1bed4e99ab8d25b0d37dca777b6c8bdd6405a1064a`
- receipt `141ba559e8bccf05c2eb941f4543347347fb9b560f59c389986f67ad8799ca6b`
- evaluator stdout `fefb213c63966e8cdb371873b164a03892c2648cf025709c12660f1d9aec0018`

## Static/source closure

Inspection confirmed exactly two encoded bytes; encoder derives byte0 from AL and byte1 from AH of fixture word `0x1234`; good decoder maps byte0->low and byte1->high; bad decoder swaps those roles.

## Qualified consequence

A logical 16-bit value does not become stable bytes by itself. In this slice, explicit convention `[34,12]` reconstructed `1234`; swapping the convention reconstructed `3412`. The host conversion/representation assumption therefore becomes a visible two-byte rule.

## Authority ceiling

No general serializer, filesystem/disk format, ABI, protocol, cross-architecture portability, schema system, or architecture promotion is earned.

## P19 discriminator earned by P18

A remaining host subsidy is **nested error/control-flow propagation**. Host exceptions or high-level call structure can hide the obligation to carry failure status across layers.

P19 should use a bounded two-layer call path:
- leaf missing operation returns status `M` and does not mutate progress;
- good middle path checks and propagates `M`, leaving progress 0;
- a good success leaf returns `O`, and the same middle path applies progress 1, proving it is not a reject-all path;
- bad middle path calls the missing leaf but ignores/overwrites `M`, reports `O`, and applies progress 1.

P19 must remain an explicit status-propagation discriminator. It does not earn an exception runtime, error manager, scheduler, or architecture promotion. P20 remains unwritten until P19 consequence is closed.
