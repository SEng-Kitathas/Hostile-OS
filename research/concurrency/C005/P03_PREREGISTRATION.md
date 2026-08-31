# C005/P03 preregistration — publication indicator versus published payload

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P02 CLOSED PASS

## Question

If one CPU publishes a payload to another using a shared `ready` indicator, does observing `ready=1` imply the payload is already the intended new value, or must the publication protocol order payload and indicator explicitly?

## Two-CPU fixture

Shared payload begins7E and `ready=0`. AP waits for `ready=1` and immediately records the payload it sees.

## Bad control

BSP writes `ready=1`, leaves a deliberate finite window, then writes payload55.

Expected: AP observes ready1 while payload is still7E (`BAD_SEEN=7E`).

## Good witness

Reset payload7E/ready0. BSP writes payload55 first, then publishes `ready=1`. AP waits on ready and records payload.

Expected on tested x86 SMP: AP sees55 (`GOOD_SEEN=55`).

## Required controls

- same AP and same payload/indicator bytes in both phases;
- AP participation explicit;
- AP records exactly one first payload after seeing ready each phase;
- bad phase later reaches payload55 so the fixture proves a temporary publication mismatch, not failed writer completion;
- timeout UNKNOWN.

## Ceiling

PASS earns only `PUBLICATION_INDICATOR != PUBLISHED_PAYLOAD` and that publication order is future-relevant. It does not establish a complete cross-architecture memory model, compiler model, cache-coherence specification, or universal barrier primitive.
