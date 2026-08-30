# C003 / P11 — explicit bounds check versus adjacent-state corruption

**Disposition:** PASS CLOSED / BOUNDED SCIENTIFIC SUCCESS
**Scientific pass:** C003/P11 of 20
**Architecture promotion:** NONE
**P12 earned:** YES

## Question

Can a two-slot fixed-capacity relation state accept an in-range write, reject an out-of-range write, and preserve an immediately adjacent sentinel using only an explicit bounds check — while an intentionally unchecked control with the same invalid index overwrites that adjacent sentinel?

## Controlling preregistration

`C003_P11_PREREGISTRATION.md` was sealed at Git commit `0a6b50a44869e10ee980a7b6cb5ea2007a19b19b` before any P11 mechanism code or execution existed.

## Controlling scientific run

Run: `20260830T020800Z_p11_explicit_bounds_01`

QEMU:
- PID: `21924`
- started: `2026-08-30T02:08:02.961435+00:00`
- ended: `2026-08-30T02:08:05.168033+00:00`
- status: `COMPLETED`
- exit: `33`
- timeout ceiling: 5 seconds
- stdout: empty
- stderr: empty

Evaluator exit: `0`.
Evaluator stderr: empty.

## Exact raw observation

```text
VALID_INDEX=1
INVALID_INDEX=2
GOOD_VALID=W
GOOD_SLOT1=X
GOOD_INVALID=R
GOOD_SENT=S
BAD_INVALID=W
BAD_SENT=X
DONE
```

Evaluator version: `C003-P11-explicit-bounds-v1`
Evaluator result: `passed=true`.

## Exact source hashes

- mechanism: `8243ef142a5dd961ecfe1fb2c12dbaba64b4649c7de332aa7ddcc69ca49e6000`
- fixture: `0c1dcf1358d67c162d55538ff49edf749f42072ae704a2ed2f5c47f8f2fbd2e4`
- linker: `7accb26f364ed060449b3bc3363f7569439148938074588f35f07888351c590b`
- evaluator: `e17921c474a7eb1576544ebfe65c5fd9404504441460ba11fddca06ba25c0120`
- launcher: `0fdaa57fb07a94541a8176d3db1f31547ae17524dee7aa12468a6946b11f67ab`

## Exact run hashes

- boot image: 512 bytes
- boot image SHA-256: `d79911e94db07db94df73c15d7cb26ff8a2f1148a25a721842299bc0fc17e090`
- debugcon SHA-256: `cff0f806025f82a1bfef6bb674171841d522870f2375f90d109a6634d401eeca`
- evaluation SHA-256: `715c2ff7aad17c3bd7b933107d3775a50ed8574f9b2dbed536b7029451a4b39a`
- receipt SHA-256: `ffcb12b428e7b95c408c9aa58a201be21ed3806a890764d67b74d123c65318fe`
- evaluator stdout SHA-256: `ac3c309bcf380cfc44a9b950bc8d31470d74263ed9325e30f363bcd38abd7630`
- all QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Post-run non-mutating closure matched all five source hashes, seven recorded run-artifact hashes, the exact raw matrix, evaluator pass state, and QEMU `COMPLETED/33` state.

## Linked-layout verification

Non-mutating `llvm-objdump -t` inspection of the controlling linked ELF found:

- `relation_slots` address: `32070` decimal (`0x7d46`);
- `adjacent_sentinel` address: `32072` decimal (`0x7d48`).

Therefore `adjacent_sentinel == relation_slots + 2` in the linked image. The invalid index `2` used by the unchecked control truly addressed the immediately adjacent byte; the observed `BAD_SENT=X` was not produced by a separate sentinel-specific test mutation.

## Qualified consequence

For this fixed three-byte relation/sentinel layout:

- checked index `1` returned `W` and changed relation slot 1 from `B` to `X`;
- the checked mechanism therefore was not a reject-all stub;
- checked index `2` returned bounded reject status `R`;
- after that rejected write, the adjacent sentinel remained `S`;
- after reset to the same fixture facts, the unchecked raw index-2 write returned `W` and changed the adjacent sentinel from `S` to `X`;
- one explicit capacity bound was sufficient to distinguish the valid relation mutation from the out-of-range mutation in this bounded layout;
- the freestanding representation did not receive Python-style collection bounds safety for free.

This exposes a real hidden-host service at the lowest tested level: safe indexed relation mutation needs an explicit bound or an equivalent mechanism once raw memory writes are available.

## Authority ceiling / nonclaims

P11 does **not** establish:
- general memory safety;
- arbitrary buffer safety;
- memory protection;
- virtual memory;
- allocator design;
- object lifetime safety;
- pointer provenance;
- concurrency safety;
- spatial safety outside this fixed layout;
- a MemoryManager primitive;
- architecture promotion.

It establishes only the fixed-layout bounds distinction required by this discriminator.

## Pareto / ontology consequence

The tested safety property did not require importing a historical memory subsystem. The smallest successful mechanism was a fixed capacity plus an explicit index bound before mutation.

That does not prove the same mechanism will remain sufficient as the representation widens. It does show that this bounded host subsidy can be paid with a very small explicit distinction rather than a new subsystem species.

## P12 discriminator earned by P11

A high-value remaining Python-host suspect is **arbitrary-width integer semantics**, especially where a bounded generation/version field is used to reject stale identities or bindings.

P03 established currentness guarding in a bounded mutation slice, but it did not pressure finite-width wraparound. Python integers do not wrap at 8 or 16 bits unless explicitly modeled; machine fields do.

P12 should test the smallest aliasing discriminator:
- a stale token records generation `0`;
- a deliberately narrow 8-bit generation advances through exactly 256 increments and wraps to `0`, causing a naive equality-only currentness check to accept the stale token;
- a wider explicit generation representation under the same 256-increment fixture does not alias `0` and rejects the stale token;
- the evaluator must distinguish stale-token false acceptance from preserved currentness.

P12 must remain a bounded generation-width test, not a claim that 16 bits is universally sufficient. P13-P20 remain unwritten.
