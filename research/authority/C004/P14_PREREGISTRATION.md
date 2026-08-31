# C004/P14 preregistration — finite authority capacity and non-overwriting full result

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P13 CLOSED PASS

## Question

When protected authority storage is finite and already full, is an explicit FULL result sufficient, or may allocation silently destroy an existing authority relation?

## Fixture
- protected authority table has exactly two records: A/rights3 and B/rights1;
- ring3 context B requests a delegated READ record for C;
- both slots are occupied.

## Good mediator
Scan for an empty record. None exists -> `F`; existing owners remain A/B (`41/42`).

## Bad control
Overwrite slot0 on full -> `W`; owners become C/B (`43/42`).

## Ceiling
If observed, P14 earns explicit finite authority-capacity exhaustion as a bounded behavior. It does not establish that two records or any fixed capacity is generally sufficient, nor does it earn dynamic allocation.
