# Donor-Scale Reference Evidence — 2026-08-30

**Mode:** BUILD-PLAN evidence intake
**Use:** workload pressure only; not architecture authority
**Local donor source status:** `HOSTILE_OS/donors/` is empty in the live repository, so these facts were recovered from source-level web mirrors and must not be described as local donor-source contact.

## Linux 0.01 source-level capacity facts

Source mirror: Linux v0.01 `include/linux/sched.h` at kernel.googlesource.com.

Observed source constant:

- `NR_TASKS 64`

Source mirror: Linux 0.01 `include/linux/fs.h` at kernelhistory.sourcentral.org.

Observed source constants:

- `NR_OPEN 20`
- `NR_INODE 32`
- `NR_FILE 64`
- `NR_SUPER 8`

These are historical Linux implementation capacities. They are not HOSTILE-OS architecture constants and do not prove the same ontology is required.

## FreeDOS/DOS-compatible corroboration

A FreeDOS source-tree PSP structure in the FreeDOS project archive describes:

- a 20-entry Job File Table (`PSPJFT`);
- default JFT size = 20.

This is interface/compatibility evidence that 20 open-style per-program references were a real DOS-family pressure point. It is not treated as the pinned FreeDOS witness source, and it does not establish a HOSTILE-OS file abstraction.

## Translation into HOSTILE-OS pressure

The useful donor-scale facts are translated without importing donor nouns:

- **64 simultaneously represented activities** is a valid historical stress point for a small general-purpose donor.
- **20 resource-binding references per activity** is a valid historical interface pressure point.
- **64 global open-style resource objects** is a valid historical global-resource pressure point.
- the Linux 32/8 inode/superblock counts are retained as donor evidence only; HOSTILE-OS does not import those object species merely because the donor had them.

## Authority ceiling

These numbers are lawful as **reference workload pressure** because Commander’s Intent names Linux 0.01 and FreeDOS as donors/quarries.

They are not lawful as:

- proof that HOSTILE-OS needs Process/File/inode/superblock primitives;
- proof that 64/20/64 are universal or optimal capacities;
- production workload measurements;
- evidence about current user demand;
- a reason to copy donor data structures.

The next design artifact may use these values as a declared donor-scale qualification profile while keeping capacity configurable.
