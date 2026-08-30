# C003 / P03 — intermediate mutation coherence / explicit currentness guard

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS AFTER TWO IMPLEMENTATION SCARS
**Scientific pass:** C003/P03 of 20
**Architecture promotion:** NONE
**P04 earned:** YES

## Question

Can a minimal explicit mutation-currentness guard prevent an observer from accepting incoherent intermediate membership/history state during bounded lifecycle mutation, while an otherwise identical unguarded control exposes that stale state?

## Preregistered matrix

```text
RAW_CUT=S
RAW_POST=C
GUARD_CUT=R
GUARD_POST=C
DONE
```

`S` = stale accepted snapshot, `R` = retry/reject intermediate state, `C` = coherent accepted snapshot.

## Implementation scars preserved

### Attempt 01 — build failure

Run directory: `20260829T212130Z_p03_mutation_coherence_01`

No guest ran. Clang rejected an invalid 16-bit addressing form:

`error: invalid 16-bit base/index register combination`

Server execution stderr log:
- `.pcmmad_sync_runs/sync-71b99bf12614.stderr.log`
- SHA-256 `ac5e412b297701211ae66460361f141f40456ddb9d5f62d63bb618fc90183cad`

This was a representation/implementation failure, not a scientific consequence.

### Attempt 02 — Pareto size failure

Run directory: `20260829T212230Z_p03_mutation_coherence_02`

Addressing was repaired, compilation succeeded, but the preregistered linker ceiling failed:

`ld.lld: error: P03 probe exceeds one boot sector`

Measured object sections before link:
- mechanism `.text`: `0x214` = 532 bytes
- mechanism `.data`: 16 bytes
- fixture: 6 bytes

Server execution stderr log:
- `.pcmmad_sync_runs/sync-9cc1700e2195.stderr.log`
- SHA-256 `54ddd9746d18792897378e5624b7419ec439e180cc19219cb0f9ed651a6a98d9`

No guest ran. The size limit was not relaxed. Representation was compressed by serially reusing one fixed state buffer for the unguarded and guarded trials and factoring shared state/membership logic.

## Qualified run

Run: `20260829T212310Z_p03_mutation_coherence_03`

Observed guest output:

```text
RAW_CUT=S
RAW_POST=C
GUARD_CUT=R
GUARD_POST=C
DONE
```

Separate evaluator:
- version `C003-P03-mutation-coherence-v1`
- `passed=true`
- evaluation SHA-256 `63f40d587bcb11532e1dc29edbbbb4a021430bc833677101ab6430f191d20229`

QEMU:
- expected exit 33
- observed exit 33
- stdout empty
- stderr empty

Evaluator stderr: empty

Raw image:
- 512 bytes
- SHA-256 `4dc5141879c7bdf6902051dccd391df1429d3593e2cfc9ba0b216160d9b47637`

Debug artifact SHA-256:
- `9b549725a58ebadf7ece6761309a34967acf0217fdbe77ba7ce1a5c6b6f9b3c9`

Receipt SHA-256:
- `e76f6acf5ef404a43e29640f245b987d4acafc6db5ade33bdc380fd198646cd6`

## Final source hashes

- mechanism: `6a062701d501ea56ef1448403b5367691b57bb6bd4642807ab790d4b94c78165`
- fixture: `025cd8dd99dcb0e3388f7aa7e48994d63c57a23d06e9e0a6d3a10065a087b994`
- linker: `0cc3c39c53eaf895dbf66a4077d4b3438c5246af0427d658911fab7d38b5ee3d`
- evaluator: `dbd061dfc58a9dec5ebe1c490e2bc0b640d966b0884c972a1a2c3c4f06b6e4d2`
- launcher: `4894aa3b2ca897869c0a05a09b7e93dc84d8ae2529f8110c2be2f929b71f1519`

## Qualified conclusion

For this single-core, explicit-cut bounded model:

- membership mutation can transiently expose policy history whose identity is no longer current;
- an unguarded observer can accept that incoherent intermediate state;
- one explicit mutation-currentness byte is sufficient to make the observer reject/retry at the tested cut;
- after repair and commit, the guarded observer accepts coherent state;
- this mechanism fits inside the original 512-byte freestanding limit after structural compression.

This is a narrow explicit-currentness result. It does not establish general linearizability, lock-freedom, interrupt semantics, SMP atomicity, or memory-ordering correctness.

## P04 discriminator earned by P03

P01-P03 have now pressured current completion, membership/history identity, and intermediate mutation coherence entirely in volatile fixed-capacity state.

The largest untouched whole-P01 obligation is persistence across restart, and C002 specifically preserves the distinction:

- durable resource identity/bytes may survive restart;
- runtime access currentness must expire;
- clean restart requires a fresh qualified rebind;
- stale runtime bindings must not be hydrated as current.

P04 is therefore earned as an **actual two-QEMU-process restart discriminator** using a raw disk sector:

1. first boot writes a bounded durable record;
2. QEMU exits completely;
3. second QEMU process boots from the same image;
4. durable identity/payload must survive;
5. runtime access currentness must begin expired because it is volatile boot state;
6. a fresh in-guest rebind may then make access current;
7. evaluator must inspect both boot observations and the durable sector independently.

This directly pressures still-UNKNOWN host file-I/O, serialization, default initialization, automatic lifetime, and runtime-binding subsidies.

P05-P20 remain unwritten.
