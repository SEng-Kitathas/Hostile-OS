# C003 / P16 — shared backing lifetime versus premature reclaim

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P16 of 20
**Architecture promotion:** NONE
**P17 earned:** YES

## Controlling preregistration

`C003_P16_PREREGISTRATION.md` was sealed at Git commit `f649b5b20954a4bf3284719133b5412ce7cf74df` before source or execution.

## Controlling run

Run `20260830T021900Z_p16_lifetime_01`

QEMU PID `28772`, start `2026-08-30T02:19:12.817760+00:00`, end `2026-08-30T02:19:13.030636+00:00`, status `COMPLETED`, exit `33`. Evaluator exit `0`; QEMU/evaluator stderr empty.

## Exact raw observation

```text
GOOD_START=2
GOOD_AFTER_A=1
GOOD_B_OWNER=B
GOOD_B_READ=X
GOOD_AFTER_B=0
GOOD_BACKING=0
BAD_START=2
BAD_AFTER_A=1
BAD_B_OWNER=B
BAD_B_READ=0
DONE
```

Evaluator `C003-P16-shared-lifetime-v1`: passed.

## Exact hashes

Source:
- mechanism `3f804173ea0afa04c6766e868fe8e2fabbd225f7ec3f0e6612d8a7a4104abdc2`
- fixture `4f4cf834625a56981b1d1044878dd3bad59edb03b91f4962bb22398cd2dec0ed`
- linker `a071effa3ef728152aaa30c632f240cf99bb8beab34f3d8c60ea6ade85586656`
- evaluator `cdf93aeab2dae322bfb8a234ceed2e4bb99e51f71f3d4c8e7fbc70f668108be3`
- launcher `74f6f6e7b1b963457164f9bf2b24fbd3447273d875e97df0ed9c348270299733`

Run:
- boot `51234878f970dc053da8edc04600dcc528407d6151f4fcc590d67ba47f2bd87a`
- debugcon `d2cd7d4a0deaa3778a71351c6d8880de2e586fb29df3150a91065fb15ea2a668`
- evaluation `2d1735b078328186e44277e45bca17308cd76ea57225a9a4f5471bab45b4e3cf`
- receipt `ec98db716128b4b80e5e9e9e4a163064867025e6e08911624ed0b087c0c80914`
- evaluator stdout `de735fc551b60c47ac670a0cce6e489d87c2312c0969db5de74f6166611bb074`

Post-run closure matched all recorded hashes, exact raw output, evaluator pass, and QEMU `COMPLETED/33`.

## Static/source closure

Inspection confirmed one backing byte. Good A and B releases decrement live count and clear backing only on zero count. Bad A release decrements to 1 and clears backing with no zero-count check.

## Qualified consequence

For one backing X shared by A and B:
- explicit live count 2 let A release without destroying B's still-live backing;
- B remained owner B and read X at count 1;
- only the final B release at count 0 cleared backing;
- premature reclaim destroyed X while count remained 1 and B remained live;
- shared backing lifetime therefore needs an explicit current-liveness condition in this bounded representation.

## Authority ceiling

No general garbage collection, heap, reference-count architecture, cycle handling, ownership type system, concurrency lifetime safety, universal use-after-free protection, Manager primitive, or architecture promotion is earned.

## P17 discriminator earned by P16

P16 makes lifetime explicit, but fixed storage can later be reused. A high-value next seam is **stale-handle retargeting after slot reuse**, which host object identity can hide.

P17 should compose the already-earned generation/currentness idea with one reused backing slot:
- initial slot contains value X at generation 1; an old handle records generation 1;
- the slot is released and reused for value Y while generation advances to 2;
- a fresh generation-2 handle must read Y;
- a checked stale generation-1 handle must return bounded reject `R` and not read Y;
- an address-only bad control ignores generation and uses the same slot location, so the old handle incorrectly reads the new value Y.

This remains a one-slot stale-handle/reuse discriminator. It does not earn general pointer safety, memory protection, capability architecture, or allocator design. P18-P20 remain unwritten.
