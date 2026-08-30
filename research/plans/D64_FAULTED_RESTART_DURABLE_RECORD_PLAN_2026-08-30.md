# D64 faulted-restart durable-record integrity plan — 2026-08-30

Status: BUILD-PLAN CANDIDATE / NOT PREREGISTRATION
Parent result: D64/PR01 clean-restart persistence PASS
Motivation: move from clean restart toward faulted durable-state recovery without overclaiming physical power-loss behavior.

## Question

Can HOSTILE-OS recover the newest **complete** durable meaning after a torn/corrupt update while rejecting incomplete or invalid durable state, without persisting volatile runtime topology?

PR01 proved clean restart/rebind from a 20-byte durable logical record. It did not test crash interruption, torn writes, checksum failure, ambiguous generations, or two competing durable records.

## Proposed mechanism pressure

Use two independent durable record sectors rather than two records in one sector:
- sector A: one complete record;
- sector B: alternate record.

Each record candidate should contain only durable meaning/currentness history plus enough integrity metadata to decide whether it is complete. Candidate fields:
- magic/version;
- monotonically ordered durable sequence within a bounded width;
- durable identity/value;
- activity/resource durable epoch history needed by current restart rules;
- integrity/check field over the payload;
- explicit complete/commit marker.

Volatile 64x20 binding topology, live counts, IRQ scratch, current runtime handles, and execution placement remain non-durable.

## Proposed discriminators

Start from valid old record A at sequence 1.

Construct boot-media fixtures **before guest boot** for:

1. A valid / B empty -> choose A.
2. A valid / B fully valid sequence 2 -> choose B.
3. A valid / B torn at each meaningful byte boundary -> reject B, choose A.
4. A valid / B payload changed but integrity field stale -> reject B, choose A.
5. A valid / B commit marker absent/wrong -> reject B, choose A.
6. A valid / B higher sequence but invalid integrity -> reject B, choose A.
7. A invalid / B valid -> choose B.
8. A invalid / B invalid -> fail closed; do not invent durable meaning.
9. Negative control: naive highest-sequence selection without integrity/commit validation accepts at least one invalid B fixture.

After selecting a valid durable record, rebuild fresh runtime state under new runtime epochs exactly as PR01 requires; old runtime handles remain invalid.

## Why separate sectors

Two copies in one sector share one sector-write failure domain. Separate sectors preserve an older complete candidate when the newer-sector update is represented as torn/corrupt in the fixture.

This is a design pressure choice, not yet a claim about actual disk-controller or BIOS atomicity.

## Evidence ceiling

A PASS would earn only:
- recovery logic against explicitly constructed torn/corrupt durable-sector states;
- preference for newest valid complete record among two candidates;
- fail-closed behavior when neither candidate is valid;
- continued separation of durable meaning from volatile topology.

It would **not** earn:
- actual power-cut atomicity;
- BIOS/controller cache ordering;
- sector atomicity guarantees;
- filesystem semantics;
- wear/endurance guarantees;
- physical-hardware crash proof.

A later fault-injection experiment may kill QEMU during real guest writes, but only after the recovery format itself survives deterministic media-state discriminators.

## First implementation decision still open

Choose the smallest integrity field that can discriminate every preregistered corrupt/torn fixture without pretending to be a cryptographic authenticity mechanism. The plan should compare at least:
- simple checksum/CRC-like integrity;
- duplicate/complement field;
- commit marker ordering;

under Pareto pressure before preregistration.
