# C004/P12 preregistration — direct I/O versus mediated I/O authority

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P11 CLOSED PASS

## Question

Does the enforcement boundary also need to cover device/I/O effects, rather than only writes to kernel-owned memory?

## Fixture
- ring3 executes with IOPL0 and TSS I/O bitmap disabled by setting I/O-map base beyond TSS limit;
- ring3 attempts direct `OUT` to debug port0xE9;
- #GP handler resumes after the denied instruction;
- ring3 then invokes the explicit DPL3->ring0 gate;
- trusted handler performs/logs the mediated I/O consequence and exits.

## Expected
- direct ring3 OUT triggers #GP;
- no raw user marker reaches debugcon;
- trusted mediated gate is reached and can output its marker;
- normal exit.

## Ceiling
If observed, P12 earns that untrusted I/O effects need enforcement distinct from software operation checks, and that privileged mediation is one working witness. It does not prescribe x86 port-I/O architecture, drivers, device managers, or a final I/O model.
