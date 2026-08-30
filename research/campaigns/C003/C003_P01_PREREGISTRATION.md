# C003 / P01 preregistration — host-subsidy inventory and first freestanding falsifier

**Preregistered:** 2026-08-29
**Status:** PREREGISTERED / NOT EXECUTED
**Scientific pass:** C003/P01 of 20
**Architecture promotion:** FORBIDDEN
**Parent campaign state:** C001 20/20 CLOSED; C002 20/20 CLOSED; no C002/P21

## Governing question

Which Python-host capabilities were silently carrying the C002 whole-P01 relation composition, and what is the smallest freestanding x86/QEMU executable slice that can falsify one high-value hidden dependency without importing Process/Scheduler/File/Manager/Service as primitives?

## P01 scope

P01 SHALL do only two things:

1. Build the smallest explicit inventory/mapping of Python-host services actually relied on by the recovered C002 mechanism/evaluator sources, binding each observed dependency to exactly one primary disposition:
   - explicit relation state;
   - low-level mechanism to embody;
   - test/harness-only support;
   - UNKNOWN.
2. Select and execute only the first smallest freestanding falsifier earned by that inventory.

P02-P20 SHALL NOT be prewritten. P01 earns P02.

## Required evidence recovery before execution

The current reincarnation working tree contains the C002/P20 closeout and payload-history archives, but not yet an inspected, source-level inventory proving every Python runtime service used by the final C002 descendant. Therefore P01 execution must first recover the exact final C002 mechanism, fixture, launcher, and evaluator bytes from durable payload history or another provenance-qualified source and record their hashes.

No dependency may be labeled "relied on" from the suspect list alone.

## Suspect inventory to test, not assume

- dynamic allocation
- Python object identity
- dict/list/set ordering and membership semantics
- arbitrary-width integers
- automatic lifetime/reference handling
- exception control flow
- strings/labels
- host file I/O
- collection mutation semantics
- implicit memory safety
- implicit atomicity
- host scheduling/timing
- interpreter stack/continuation
- default initialization
- serialization/conversion helpers

## C002 survivors that the mapping must preserve

Under the qualified C002/P01 boundary, the closeout supports explicit distinctions including identity, resource identity, lineage, eligibility, waiting, continuation binding/state, memory binding, access/backing binding, durable bytes, policy history where needed, current wait/access instance, lost-wake-safe wake entry, and bounded current terminal completion condition.

The closeout also preserves these negative boundaries:
- selection remains separable from execution application;
- wait/event matching remains separable from execution application;
- parent-child return did not earn a special return primitive;
- idle identity was not required;
- stale runtime bindings do not become current merely because durable identity survives restart;
- architecture promotion did not occur.

## First candidate freestanding falsifier

Subject to source-level dependency recovery and infrastructure qualification, the first candidate slice is:

**fixed-capacity relation state + explicit identity/currentness + completion-before-wait / wait-before-completion two-order discriminator, booted freestanding under x86/QEMU and reporting only through a minimal durable observation channel.**

Purpose: test whether the P17/P18 completion/currentness distinction can survive without Python object identity, dynamic containers, automatic lifetime, exceptions, or interpreter scheduling semantics.

The slice SHALL use static/fixed-capacity storage initially so dynamic allocation is not smuggled in as an unearned necessity. It SHALL represent completion currentness explicitly rather than via a one-shot notification. The harness SHALL vary order but SHALL NOT perform wake/control behavior for the mechanism.

## Infrastructure gate before scientific execution

Current environment inventory shows QEMU, NASM, GCC, Clang, GNU ld/as, and make are not resolved on PATH; IA16/BCC had no hits in the targeted search roots. Therefore C003/P01 is preregistered but **BLOCKED FROM SCIENTIFIC EXECUTION** until infrastructure qualification establishes a real freestanding build/launch path with exact tool identities.

Qualification is infrastructure work, not C003/P01 scientific success.

## Execution evidence contract

For the eventual P01 run, mechanism, fixture, launcher, evaluator, environment, and observed consequence remain separate. Each substantive run requires:

- stable run directory;
- intent/discriminator statement;
- exact source hashes;
- exact cwd/interpreter/toolchain/QEMU identity and environment;
- durable launcher command;
- stdout and stderr capture;
- PID/start/end/exit/completion receipt where applicable;
- result artifact hashes;
- post-run non-mutating inspection;
- evaluator version/hash separate from mechanism;
- UNKNOWN on timeout or ambiguous process state.

## Success / failure criterion

P01 succeeds scientifically if it produces a source-grounded host-subsidy map and a qualified consequence from the smallest falsifier, whether the consequence is green or a failure that identifies a hidden host dependency or newly irreducible distinction.

A build, boot banner, trace, command exit, or QEMU window alone is not a qualified consequence.

## Stop rule

After the P01 result is reconciled into the campaign state, stop. Do not infer or write C003/P02 until P01 has earned the next discriminator.
