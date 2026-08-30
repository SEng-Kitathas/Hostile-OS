# Engineering / Research SOP adoption state

Adopted surface: `RAHL_ENGINEERING_IN_HOUSE_SOP_SPLIT_CANDIDATE_R3_1_2026-08-29`

- Status: `ADOPTED_IN_HOUSE_SOP`
- Replacement ready: `true` for the operational SOP surface
- Candidate/original package authority: `COMPRESSION_ONLY_INHERITS_NO_NEW_AUTHORITY`
- Parent lineage/fallback authority: `R6`
- Parent R6 SHA-256 declared by R3.1: `69721b7b6c4b8c04d5377f1b7c0afa044530a6352496c7cb564f4cb4ef2df257`
- Foundation promotion: `false`
- R1 / R2: rejected as replacement candidates
- Adopted R3.1 ZIP SHA-256: `4d205becc2413889bdb37c6b6ff7513d6f759a7dff1d9f9b8fddaddd8235a278`
- R3.1 package verifier: PASS in Linux sandbox against the uploaded package
- Local Windows independent manifest/hash verification: PASS
- Sealed verifier Windows portability scar: nested path separators cause false membership drift on Windows
- Assurance ceiling of sealed package: `STRUCTURE_SOURCE_CLASS_BODY_COVERAGE_AND_INTEGRITY_ONLY`
- Adoption adjudication: `R3_1_SOP_ADOPTION_ADJUDICATION_2026-08-30.md`

## Exact adoption rule

Use R3.1 as the normal in-house engineering/research SOP and cold-start surface.

R3.1 does not gain new foundation authority from adoption. Its classified engineering rules keep their inherited V5/R6 statement classes. R6 remains preserved ancestry and fallback authority for ambiguity, omitted context, conflict, or qualification questions, but it is no longer the normal day-to-day first-read surface when R3.1 directly covers the question.

`replacement_ready=true` means the R3.1 surface is approved to replace routine use of the R6 surface operationally. It does **not** mean every sentence/context in R6 has been proven semantically identical, that R6 may be deleted, or that product/foundation/architecture authority has been promoted.

When R3.1 and R6 appear to differ, resolve through actual project obligations, inherited statement class, exact ancestry, evidence, and currentness. Record any real semantic mismatch as a scar/revisit rather than silently smoothing it away.

## Adoption basis

- The sealed candidate's only declared replacement blocker was fresh real-project shadow use.
- `R3_1_SHADOW_SESSION_REINCARNATION_PACKAGE.md` recorded a bounded fresh real-project shadow session with no materially different lawful decision and lower query-to-authority distance.
- Subsequent HOSTILE-OS work continued under the split surface without exposing authority-class collapse or loss of execution/release discipline.
- On 2026-08-30 the operator explicitly instructed: `Adopt this as SOP and then proceed`.

The sealed candidate package itself remains unchanged and retains its historical `SHADOW_USE_CANDIDATE` metadata. Adoption is recorded by this state file plus the separate adjudication artifact.
