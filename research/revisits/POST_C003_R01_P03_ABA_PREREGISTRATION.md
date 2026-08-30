# POST-C003 / R01 — P03 spanning-reader ABA/currentness revisit

**Phase:** POST-C003 REVISIT
**Revisit ID:** R01
**Parent evidence:** C003/P03 mutation coherence/currentness guard
**C003 pass count effect:** NONE — C003 remains CLOSED 20/20
**Architecture promotion:** FORBIDDEN BY THIS REVISIT ALONE

## Why this revisit exists

C003/P03 proved that an observer landing while `mutation_active=1` can reject an incoherent intermediate state. It did not test a reader that begins before a complete mutation and finishes after it, seeing `mutation_active=0` at both ends while combining an old field with a new field.

The C003 post-campaign audit identified this as the smallest open seam that directly limits later currentness claims.

This revisit is append-only evidence. It must not rewrite or relabel P03.

## Primary question

Can an active-flag-only reader falsely accept a mixed old/new snapshot when a complete mutation occurs between two field reads and the flag is clear both before and after, while a version-qualified reader over the same interleaving rejects the mixed snapshot and later accepts a stable post-mutation snapshot?

## Fixed bounded state

Use one fixed relation record only:

- `owner`
- `history`
- `mutation_active`
- `version`

Fixture starts at:

- owner = `A`
- history = `A`
- mutation_active = `0`
- version = `1`

One mutation changes the logical pair to:

- owner = `B`
- history = `B`
- version = `2`

Mutation order must be explicit:

1. set `mutation_active=1`;
2. write owner `B`;
3. write history `B`;
4. increment version exactly once;
5. clear `mutation_active=0`.

No allocator, dynamic container, scheduler, lock manager, transaction system, Process/File/Manager/Service primitive, or host-side mutation is allowed.

## Required interleaving

### Active-flag-only path

The guest must:

1. read and save `mutation_active` before the mutation (`FLAG_PRE`);
2. read and save owner before the mutation (`FLAG_OWNER`);
3. execute the complete mutation in guest code;
4. read and save history after the mutation (`FLAG_HISTORY`);
5. read and save `mutation_active` after the mutation (`FLAG_POST`);
6. apply an active-flag-only acceptance rule that accepts when both saved flag values are zero;
7. classify the accepted old-owner/new-history pair as stale/mixed `S`.

Required observations:

- `FLAG_PRE=0`
- `FLAG_OWNER=A`
- `FLAG_HISTORY=B`
- `FLAG_POST=0`
- `FLAG_ACCEPT=S`

This is the negative control: a flag that is clear at both ends must not be treated as proof that the snapshot did not span a completed mutation.

### Version-qualified path

Reset to the identical fixture state.

The guest must:

1. save version before the first field read (`VER_PRE=1`);
2. save owner before the mutation (`VER_OWNER=A`);
3. execute the same complete mutation routine;
4. save history after the mutation (`VER_HISTORY=B`);
5. save version after the second field read (`VER_POST=2`);
6. reject/retry the mixed snapshot because `VER_PRE != VER_POST`.

Required observation:

- `VER_ACCEPT=R`

The version-qualified path must not be a reject-all control.

After the mutation is complete, perform a stable reread:

1. save version before reading fields;
2. read owner and history;
3. save version after reading fields;
4. require equal versions and owner/history `B/B`;
5. accept coherent snapshot `C`.

Required observations:

- `STABLE_VER_PRE=2`
- `STABLE_OWNER=B`
- `STABLE_HISTORY=B`
- `STABLE_VER_POST=2`
- `STABLE_ACCEPT=C`

## Exact required debug matrix

```text
FLAG_PRE=0
FLAG_OWNER=A
FLAG_HISTORY=B
FLAG_POST=0
FLAG_ACCEPT=S
VER_PRE=1
VER_OWNER=A
VER_HISTORY=B
VER_POST=2
VER_ACCEPT=R
STABLE_VER_PRE=2
STABLE_OWNER=B
STABLE_HISTORY=B
STABLE_VER_POST=2
STABLE_ACCEPT=C
DONE
```

The evaluator must require exact line order and exact values.

## Static/source closure requirements

Post-run source inspection must verify:

1. there is one fixed relation record only;
2. both trials call the same complete mutation routine;
3. that mutation routine sets active, writes owner, writes history, increments version once, then clears active in that order;
4. the flag-only acceptance path does not compare version;
5. the version-qualified path compares saved pre/post versions before acceptance;
6. the stable version-qualified path can accept `B/B` at unchanged version 2;
7. the fixture supplies only the initial/target bytes and does not manufacture acceptance results;
8. host launcher/evaluator does not mutate guest state or synthesize debug lines.

## Success criterion

Success requires all of the following from one qualified freestanding run:

- exact debug matrix matches;
- QEMU reaches the expected debug-exit completion code;
- evaluator passes;
- static/source closure passes all eight checks;
- source and run hashes are captured;
- all engineering failures before a qualified run remain visible and are not counted as science.

## Failure criterion

The revisit fails scientifically if any of these occur after the build/launcher itself is qualified:

- flag-only path does not accept the mixed snapshot under clear/clear flags;
- version-qualified path accepts the mixed snapshot despite version change;
- stable version-qualified path cannot accept coherent B/B state;
- mutation order differs between the two trials;
- version path is implemented as reject-all;
- harness supplies the causal behavior.

Build/link/launcher defects are engineering scars, not scientific failure, unless they reveal that the preregistered discriminator cannot fit the qualified freestanding evidence boundary.

## Authority ceiling

A passing revisit may establish only this bounded rule:

> clear-before/clear-after mutation flags do not prove that a multi-field read did not span a completed mutation; a changed version observed around the read can detect this one ABA-shaped snapshot, while an unchanged version can still accept a stable snapshot.

It does **not** establish:

- general linearizability;
- universal ABA freedom;
- arbitrary version lifetime or wrap policy;
- SMP memory ordering;
- seqlock architecture;
- transaction architecture;
- lock-free correctness;
- scheduler/process architecture;
- architecture promotion.

P12 still controls finite-width wrap limits. This revisit cannot turn version equality into a universal lifetime guarantee.
