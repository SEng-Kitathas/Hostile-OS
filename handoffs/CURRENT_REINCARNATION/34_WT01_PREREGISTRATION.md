# D64/WT01 — controlled guest-write termination boundary + FR01 recovery preregistration

Date: 2026-08-30
Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent science: D64/FR01 deterministic faulted durable-record recovery CLOSED PASS
Parent feasibility: D64/IW00 non-scientific interrupted-write feasibility, commit `0e55491`
Architecture posture: `INTEGRATED_SHADOW_CANDIDATE`
Architecture promotion: forbidden by this experiment alone

## Question

When a guest performs a real BIOS INT13 write of a complete FR01-format newer durable record B, and the QEMU process is forcibly terminated while stopped at controlled guest-instruction boundaries immediately before or after the first observable backing-sector transition, do the resulting durable sectors persist as the expected whole-old/whole-new state, and does the unchanged sealed FR01 reader recover the corresponding durable meaning correctly?

This experiment does **not** claim to interrupt inside QEMU's host-side device action. IW00 observed that the backing sector changes as one whole-sector transition between two guest-instruction stop points.

## Controlling components

### Writer

A new minimal freestanding writer guest:
- qualified 8 KiB stage1 loader;
- stage2 writes only durable record B at LBA18 / C0/H1/S1;
- obtains BIOS boot drive from qualified stage1 saved byte at physical `0x7c4b`;
- contains a complete FR01-format seq2/value72 record in guest-owned bytes;
- zeroes a 512-byte guest buffer, copies the 30-byte record into it, leaves tail zero;
- emits `WRITE_READY` before setting up the BIOS write;
- exposes a symbol `writer_int13_site` on the actual `int $0x13` instruction;
- writes one sector using BIOS INT13 AH=03;
- emits `WRITE_RETURN` only if INT13 returns without carry;
- clean control exits33.

The writer must not write record A, stage1/stage2 sectors, or label sector.

### Initial durable state

Every writer disk begins with:
- A at LBA17: valid FR01 seq1/value71, epochs1/1;
- B at LBA18: all zero;
- label LBA19: zero;
- all remaining non-code fixture bytes zero.

### Recovery reader

Recovery uses the **sealed FR01 controlling binaries unchanged** from:
`research/persistence/D64_FR01/runs/20260830T212145Z_d64_fr01_01/`

Specifically:
- stage1.bin;
- stage2.padded.bin.

After writer process termination, the host creates a recovery copy of the writer disk and overwrites only:
- LBA0 with sealed FR01 stage1;
- LBA1..16 with sealed FR01 padded stage2 extent;
- LBA19 with fixture-label-only sector.

The host must hash A/B sectors before and after this recovery-code overlay and prove they are byte-identical.

Recovery boots the copy read-only under QEMU. The FR01 reader/selector itself is not modified for WT01.

## QEMU transport envelope

Writer processes:
- QEMU i386 TCG;
- `-nic none`;
- raw floppy image;
- `cache=directsync`;
- GDB remote control with CPU initially stopped (`-S`);
- no QEMU snapshot mode.

Recovery processes:
- QEMU i386 TCG;
- raw floppy recovery copy read-only;
- `-nic none`;
- sealed FR01 reader.

## GDB control

The launcher derives `writer_int13_site` from the sealed writer ELF symbol table and verifies raw stage2 bytes at that address begin `CD 13`.

For each controlled writer run:
1. start fresh QEMU paused with a unique GDB port;
2. attach through QEMU GDB remote protocol;
3. set software breakpoint at `writer_int13_site`;
4. continue until that breakpoint;
5. verify B is still exact all-zero sector;
6. remove breakpoint;
7. single-step as specified by the case;
8. terminate or continue as preregistered.

Any GDB/protocol/port ambiguity is harness failure, not science PASS/FAIL.

## Calibration phase

Run **5 fresh calibration writer processes**.

For each:
- stop at `writer_int13_site`;
- verify B equals the exact zero-sector hash;
- single-step one guest instruction at a time through BIOS;
- after each stop, read/hash B from the backing file;
- stop calibration at the first step where B differs from zero;
- classify that first changed B as:
  - `FULL` if exactly equal to the expected complete seq2/value72 sector;
  - `OTHER` otherwise.

Calibration passes only if:
- all 5 processes reach the breakpoint;
- all 5 have the same first-change step `T`;
- all 5 first changed states are exact `FULL`;
- no inspected instruction-boundary state before `T` differs from exact zero;
- `T >= 2` so both `T-1` and `T` termination boundaries exist.

`T` is a measured transport property of the controlling campaign, not a hard-coded architecture constant.

If calibration does not satisfy these requirements, the experiment aborts with no termination consequence.

## Controlled termination matrix

After successful calibration, execute the following using fresh writer disks/processes. Each class has **5 repetitions**.

### K0 — before BIOS call

Stop at `writer_int13_site` and force-terminate QEMU without executing `int 13h`.

Expected writer disk:
- A exact valid seq1/value71;
- B exact zero.

Expected FR01 recovery:
- A valid;
- B invalid/empty;
- `SELECT=A`;
- `DUR_VAL=71`;
- old handles reject;
- fresh handles accept value71.

### KPRE — one guest instruction before first observed transition

Stop at writer breakpoint, remove it, execute exactly `T-1` guest single-steps, verify B still zero, then force-terminate QEMU while guest is stopped.

Expected writer disk/recovery: same as K0.

### KPOST — immediately after first observed transition

Stop at writer breakpoint, remove it, execute exactly `T` guest single-steps, verify B is exact complete seq2/value72, then force-terminate QEMU while guest is stopped.

Expected writer disk:
- A exact valid seq1/value71;
- B exact valid seq2/value72.

Expected FR01 recovery:
- A valid;
- B valid newer;
- `SELECT=B`;
- `DUR_VAL=72`;
- old handles reject;
- fresh handles accept value72.

### CLEAN — normal writer control

Stop at writer breakpoint, remove it, continue QEMU normally.

Expected:
- writer process `COMPLETED` exit33;
- writer trace contains `WRITE_READY`, `WRITE_RETURN`, `DONE` in order;
- B exact valid seq2/value72;
- recovery selects B/value72.

## Process-termination requirements

For K0/KPRE/KPOST:
- forced termination must be issued only while GDB has the guest stopped;
- launcher records QEMU PID and termination request time;
- process must reach a verified terminal OS process state before disk inspection;
- process exit is classified `FORCED_TERMINATED`, not ordinary guest failure/success;
- no assumption is made from the requested kill alone.

## Disk-state requirements

For every writer run record:
- initial full-disk SHA256;
- A/B sector SHA256 before guest execution;
- B SHA256 at breakpoint;
- B SHA256 after each relevant calibrated step or boundary;
- A/B sector SHA256 after verified writer process termination;
- classification B=`ZERO|FULL|OTHER`.

For K0/KPRE/KPOST/CLEAN controlling runs, `OTHER` is an experiment failure requiring investigation; it must not be silently mapped to torn/valid.

Record A must remain byte-identical in every writer run.

## Recovery overlay requirements

For every termination/control writer run:
1. copy the terminal writer disk;
2. hash A/B on the copy;
3. overlay only sealed FR01 stage1/stage2 and fixture label;
4. hash A/B again;
5. require exact equality before/after overlay;
6. boot the recovery copy read-only;
7. require QEMU recovery `COMPLETED` exit33;
8. independently evaluate the FR01 trace against the actual A/B bytes.

## Expected campaign counts

- 5 calibration writer processes;
- 5 K0 writer processes + 5 recovery processes;
- 5 KPRE writer processes + 5 recovery processes;
- 5 KPOST writer processes + 5 recovery processes;
- 5 CLEAN writer processes + 5 recovery processes.

Total controlling QEMU processes: **45**.

Calibration processes are writer-only and are terminated after the first transition is observed.

## Negative-control meaning

K0/KPRE versus KPOST is the discriminator:
- the same real guest writer and backing image begins from the same durable state;
- process termination occurs at neighboring observed instruction-boundary states around the actual BIOS/device transition;
- recovery must follow the bytes actually persisted, not host intent or the nominal sequence number.

No synthetic torn B is used in WT01. FR01 already qualified torn/corrupt reader behavior separately.

## Evaluator requirements

Every field under `checks` must be literal JSON boolean.

Require at least:
1. calibration 5/5 same `T`;
2. calibration first changed state 5/5 exact FULL;
3. K0 5/5 B ZERO and recovery A/value71;
4. KPRE 5/5 B ZERO and recovery A/value71;
5. KPOST 5/5 B FULL and recovery B/value72;
6. CLEAN 5/5 guest exit33 + FULL B + recovery B/value72;
7. all A sectors unchanged;
8. all recovery overlays preserve A/B exact hashes;
9. all 20 recovery boots exit33;
10. all successful recovery traces reject old handles and accept fresh handles with the selected value;
11. no controlling run observes B=`OTHER`;
12. all forced-kill processes reach verified terminal process state before disk inspection.

## Static/source closure

Verify at least:
- writer uses qualified saved boot drive `0x7c4b`;
- writer target is CHS C0/H1/S1 / LBA18;
- writer uses BIOS AH=03 one-sector write;
- `writer_int13_site` labels exact `int $0x13` bytes;
- writer buffer contains exactly the expected FR01 seq2/value72 logical record and zero tail;
- writer never writes A or label sector;
- launcher derives symbol address from writer ELF rather than hardcoding it;
- launcher verifies CD13 bytes at symbol address;
- calibration uses fresh processes/disks;
- termination cases use measured `T`, not a hard-coded step count;
- force kill occurs while guest is GDB-stopped;
- recovery overlay paths are limited to code+label sectors;
- recovery uses sealed FR01 binary hashes from the controlling run;
- all controlling inputs are snapshotted before build/execution.

## Independent audit

Independently verify:
- run-input manifest hashes;
- writer stage1/2 envelope;
- expected writer record bytes/CRC/commit;
- calibration population and transition consistency;
- all process IDs/status classifications;
- exact A/B hashes and ZERO/FULL classification;
- recovery overlay A/B preservation;
- sealed FR01 reader hashes;
- recovery traces against actual disk bytes;
- evaluator/static closure PASS.

## Success consequence

If PASS, WT01 earns only:

> In the tested QEMU TCG + BIOS floppy + `cache=directsync` envelope, an actual guest durable-sector write has a repeatable guest-instruction observation boundary between whole-old and whole-complete-new backing states; force-terminating QEMU while stopped immediately before versus after that observed transition preserves the corresponding whole state, and the unchanged FR01 reader recovers the durable meaning represented by the bytes actually persisted.

## Authority ceiling

WT01 does **not** establish:
- interruption inside QEMU's host-side device-emulation action;
- torn actual writes;
- physical power loss;
- real hardware sector atomicity;
- host/kernel/controller cache semantics outside `cache=directsync`;
- ordering of multiple sector writes;
- filesystem/journal guarantees;
- cryptographic authenticity;
- final architecture.

An uncontrolled wall-clock kill sweep, if later run, is a separate stress/reliability plane and may not overwrite WT01's controlled result.
