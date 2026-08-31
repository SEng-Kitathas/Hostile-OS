# C004/P17 preregistration sealing scar — 2026-08-31

Status: PROCESS / LINEAGE DEFECT; OBSERVED SCIENCE NOT RECOLORED

P17's preregistration was authored before P17 implementation and existed on disk before the controlling run, but it was accidentally omitted from the Git staging set when the P17 implementation was sealed.

Verified facts:
- current prereg SHA-256: `7e6e475746e9b5e615cc740af7d4736b01eb5d1eb65b794531ddef0ca7da5a59`;
- controlling run snapshot prereg SHA-256: `7e6e475746e9b5e615cc740af7d4736b01eb5d1eb65b794531ddef0ca7da5a59`;
- current prereg bytes == run-local snapshot bytes: **true**;
- P17 controlling run input manifest Git head: `9b20fe00eac94b767183dbe3514e5ca359b2cfc0`;
- the run-local input snapshot therefore proves the exact question/expected consequence bytes existed before P17 runtime execution;
- Git history does **not** prove those preregistration bytes were committed before the implementation commit.

Disposition:
- P17 result remains an observed protected-boundary result;
- claim only `PREREGISTERED_BEFORE_RUNTIME` for P17 from durable evidence;
- do not claim `GIT_SEALED_BEFORE_IMPLEMENTATION` for P17;
- admit this scar and the original preregistration unchanged now;
- later C004 passes must continue the stricter sequence: prereg commit -> implementation commit -> runtime.

No P17 result or evaluator is changed by this adjudication.
