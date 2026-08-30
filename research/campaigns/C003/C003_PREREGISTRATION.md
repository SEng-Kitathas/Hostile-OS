# C003 preregistration — Freestanding low-level embodiment / host-subsidy exposure

**Status:** selected next campaign; not started by this package  
**Cadence:** exactly 20 scientific passes; hard stop after C003/P20  
**Architecture promotion:** forbidden by campaign success alone

## Primary question

Can the C002 whole-P01 relation composition be embodied in freestanding low-level x86/QEMU state and behavior without primitive Process/Scheduler/File/Manager/Service species, and what hidden capabilities/costs was the Python host silently providing?

## P01 only

Build the smallest explicit inventory/mapping of Python-host services that C002 relied on and bind each to one of: explicit relation state, low-level mechanism to be embodied, test/harness-only support, or UNKNOWN. Then choose the first smallest freestanding executable slice that can falsify one high-value hidden dependency.

Do **not** prewrite P02-P20. P01 earns P02.

## Whole-workload obligations inherited from C002

Boot/initialization boundary; finite activity; multiple progress-capable activities; block/wait; wake; child/parent return; persistent bytes across restart; bounded missing-operation failure; asynchronous/event consequence; idle/no-useful-work behavior.

## High-value hidden-host suspects

Dynamic allocation; Python object identity; dict/list/set ordering and membership semantics; arbitrary-width integers; automatic lifetime/reference handling; exception control flow; strings/labels; host file I/O; collection mutation semantics; implicit memory safety; implicit atomicity; host scheduling/timing; interpreter stack/continuation; default initialization; serialization/conversion helpers.

These are suspects, not assumed requirements.

## Forbidden shortcuts

- do not create Process/Scheduler/File/Manager/Service primitives by name;
- do not promote ECS/holons merely because typed relations map nicely to structs;
- do not copy Linux/FreeDOS algorithms as target architecture;
- do not let the test harness perform missing control behavior;
- do not hide low-level complexity behind a host runtime and call the result freestanding;
- do not claim x86/QEMU success as physical-hardware proof outside the tested boundary;
- do not delete state solely because it is ugly; require a future-equivalence discriminator;
- do not count a pass without durable execution evidence and post-inspection.

## Success shape

A useful C003 result can be failure. A translation failure that identifies a hidden host dependency or a newly irreducible state distinction is progress. The campaign is about exposing the real causal/burden surface, not forcing a green low-level port.
