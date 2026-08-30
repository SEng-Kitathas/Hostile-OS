# 27 — Doctrine Authority Classes and Conflict Resolution

Date: 2026-08-28
Status: `CURRENT_INTERPRETIVE_CONTROL / NOT UNIVERSAL CANON`

## Why this exists

A memorable scar, a planning default, a hard compatibility requirement, and a research hypothesis are
not the same kind of statement. Treating them as peers is a route to accidental dogma.

This file classifies the **role** a doctrine statement plays. Classification does not make a statement
true; evidence and scope still govern.

## Statement classes

### 1. Admissibility constraint
A condition that must hold for a design to satisfy the declared engineering objective or contract
within a named scope. Violating it moves the design outside the admissible set.

Examples: do not claim evidence establishes more than it establishes; do not silently mutate sealed
ancestry while claiming identity.

### 2. Standing obligation
A requirement inherited from the actual system context: safety, security, durability, protocol,
compatibility, legal/regulatory, custody, budget, SLO, physical constraint, explicit Commander/user
requirement, or other governing contract.

Standing obligations are inputs to the engineering problem, not optional style preferences.

### 3. Qualification rule
A rule about what evidence is required before a named claim, promotion, authority transition, or
operation is justified.

### 4. Default
The normal starting choice when the relevant conditions hold and no better evidence overrides it.
A default is expected to have lawful exceptions.

### 5. Heuristic / search pressure
A question or bias that improves exploration but does not itself decide acceptance.

Examples: composition before invention; ask what can disappear; prefer host-native enforcement.

### 6. Trigger
A condition that raises the required depth of analysis or verification.

Examples: irreversibility, concurrency, durable effects, external protocol commitments, high blast
radius, approaching an operating-envelope edge.

### 7. Scar / non-equivalence
A retained failure distinction. A scar says what must not be conflated; it does not automatically
prescribe one implementation forever.

### 8. Research candidate
A mechanism or rule with bounded evidence that remains attackable and carries no silent promotion
authority.

## Conflict resolution

Do **not** resolve all engineering choices by assigning one global score.

Use this order:

1. **Establish governing intent and standing obligations.** Resolve contradictions in the requirements
   or escalate them to the authority that owns the conflict.
2. **Define the admissible set.** Admissibility constraints, standing obligations, and required authority/
   evidence boundaries eliminate designs that cannot lawfully satisfy the problem as stated.
3. **Preserve explicit UNKNOWN/residuals.** Lack of evidence is not permission to pretend a constraint
   was satisfied; it also does not automatically prohibit reversible evidence-gathering action.
4. **Apply defaults and triggers.** Defaults choose an initial route; triggers raise rigor where the
   consequence topology earns it.
5. **Optimize within the admissible set.** Minimize incidental burden and consider performance,
   authorship, reserve, option value, recoverability, and other active quality dimensions.
6. **Keep Pareto tradeoffs visible.** If lawful choices remain incomparable, do not fabricate a total
   order. Record the tradeoff, decision owner, and reopening evidence.
7. **Use scars and heuristics to attack the result.** They generate hostile questions; they do not
   receive veto authority merely by being memorable.

## Precedence safeguards

- A **heuristic** cannot silently override an admissibility constraint or standing obligation.
- A **default** cannot silently become a requirement.
- A **scar** cannot silently become a permanent ban.
- A **research candidate** cannot silently become canonical practice.
- An **optimization win** cannot erase a displaced obligation; the tradeoff requires explicit
  reconciliation/waiver authority.
- A **query/request emphasis** cannot delete obligations that remain active in the actual consequence
  field.

## Key non-equivalences

`DEFAULT != ADMISSIBILITY_CONSTRAINT`

`HEURISTIC != ACCEPTANCE_CRITERION`

`TRIGGER != VERDICT`

`SCAR != PROHIBITION`

`RESEARCH_SURVIVOR != UNIVERSAL_LAW`

`OPTIMIZATION_PRESSURE != AUTHORITY_TO_BREAK_A_CONSTRAINT`

`DOCTRINE != UNIVERSAL_SCALARIZER`

## Scope note

“Lawful” in current Rahl Engineering prose means **consistent with the active engineering constraints,
authority, and declared contract in the named scope**. It does not imply legal compliance unless law/
regulation is itself one of the standing obligations.
