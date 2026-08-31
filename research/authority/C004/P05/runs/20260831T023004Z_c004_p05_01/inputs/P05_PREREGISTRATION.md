# C004/P05 preregistration — stale authority after authority-slot reuse

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P04 CLOSED PASS

## Question

If a finite authority record slot is reused for a different activity and different operation rights, can a stale slot-only authority reference silently retarget?

## Fixture

One authority slot:
- first occupant: B / generation1 / READ;
- B snapshots authority handle `(slot0, generation1)`;
- record is released;
- same slot reused by C / generation2 / WRITE;
- resource X stays current/value7E throughout.

## Good candidate

Authority use checks both record generation and current owner/caller identity.

Expected:
- B stale `(slot0,gen1)` write -> U, X remains7E;
- C fresh `(slot0,gen2)` write55 -> W, X becomes55.

## Bad control

Slot-only use reads whatever rights currently occupy slot0 and does not check generation or owner.

After reset X=7E, B using stale slot0 invokes write:
- W, X becomes55.

## Ceiling

If observed, P05 earns authority-record identity/currentness under finite reuse. It does not establish representation width, global capability tables, cryptographic unforgeability, or actual privilege enforcement.
