# Concurrent continuity conflict — resolution

**Detected:** 2026-08-29
**Mode:** BUILD-COMMIT
**Disposition:** quarantined verbatim; not treated as active authority

## Preserved conflicting artifacts

- `LIVE_SHADOW.concurrent.md`
  - SHA-256 `bda4f52cc902eda3e9294c36bf8d2d7834e746666801c66749ed462c3d388043`
- `DESIGN_THREAD_STREAM.concurrent.md`
  - SHA-256 `0abeeaa0ed5d1d7ff2a681f3398736078e01bc05a39e8546f77c9b3df4bf5e85`

## Conflict

The uncommitted concurrent Live Shadow stated that P04 was not preregistered and replaced the P04 frontier with an active-flag ABA/generation-version discriminator.

At the same time, Git HEAD `f43883584e04b78301cf749a65deed0ba38c87bf` already contained the sealed `C003_P04_PREREGISTRATION.md` for a different discriminator: durable bytes across two real QEMU process lifetimes with runtime binding expiry/rebind.

## Resolution rule

Committed campaign evidence outranks an uncommitted shadow rewrite. The concurrent pair was copied here before the active pair was restored from Git.

The ABA/version idea remains preserved as a speculative/revisit branch. It did not have authority to replace the already-preregistered P04.

A second downstream conflict appeared when the first concurrent P04 result proposed crash/partial-write recovery as P05. The recovered C002 closeout explicitly says crash/partial-write recovery was not earned. That P05 proposal was therefore preserved but rejected as unearned widening. The adopted next seam remains inside inherited C003 obligations: asynchronous/event consequence plus idle/no-useful-work behavior.
