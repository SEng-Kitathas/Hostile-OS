# C005/P12 preregistration — versioned readers versus multiple writers

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P11 CLOSED PASS

## Question

Does the P11 odd/even version protocol by itself keep its meaning when two CPUs may write concurrently, or must writer participation be constrained separately?

## Bad deterministic overlap

Version starts0. BSP begins writer1 by incrementing version to1 and marks itself active. AP is then allowed to begin writer2 without any writer exclusion; it increments the same version1->2 while BSP is still active and marks itself active.

Required bad evidence:
- two writers simultaneously active (`BAD_ACTIVE_WRITERS=02`);
- version is even02 while writes are still active (`BAD_EVEN_WHILE_ACTIVE=1`).

This destroys P11's meaning `even == quiescent` even before asking a reader to consume data.

## Good witness

Reset. Both CPUs must atomically claim one writer exclusion before changing version/data. Each writer performs odd->data->even while holding that claim and then releases. Both eventually complete, but maximum simultaneous active writers remains1 and final version04.

## Ceiling

PASS earns only that the single-writer version protocol requires a separately enforced single-writer condition when multiple CPUs can write. Atomic writer exclusion is one witness. It does not prescribe a lock type, writer queue, fairness policy or universal snapshot scheme.
