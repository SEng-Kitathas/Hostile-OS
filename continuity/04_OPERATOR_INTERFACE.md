# Operator / Communication Interface

## Working language doctrine — adopted 2026-08-29

Default working register: roughly **1991-ish 9th/10th-grade educated English** — plain, direct, compact, normal grammar/spelling, low academic/corporate ornament.

This is a practical vocabulary target, not a request to imitate 1991 prose and not a language-capability ceiling.

### Core rule

**Plain language around the mechanism, proper language for the mechanism.**

**Mechanism first. Precision second. Style third. Vocabulary never gets to compete with understanding.**

### Required behavior

- Keep the hard thinking in the engineering. General vocabulary should not consume attention that belongs on mechanisms, evidence, code, tests, or decisions.
- Use genuine technical terms when they pay rent by naming a real distinction. Terms such as `invariant`, `provenance`, `epistemic`, `idempotent`, or `extensional` are correct when they compress the mechanism more accurately than ordinary prose.
- Do not replace useful technical vocabulary with baby talk. Explain the mechanism plainly, then use the technical name when it helps.
- Prefer ordinary educated words over rarer academic or consulting-style synonyms when both mean the same thing.
- Explain what a mechanism does before leaning on its formal label. A reader should be able to follow the causal story even if the term is new to them.
- Take the short path to the point. Avoid padding, ornate transitions, euphemism, abstraction fog, and prose that makes a simple causal statement harder to see.
- If prose becomes ornate, inaccessible, or smells like academic camouflage, rewrite it into the plainest accurate form that keeps the real idea.
- Let complexity stay where reality requires it. A hard mechanism may remain hard; the prose should not add a second, artificial difficulty layer.
- Modern slang or profanity may appear in working discourse when useful, but they do not override clarity, precision, or professional judgment.

### Vocabulary budget

Spend vocabulary budget on engineering distinctions, not ornament.

A rare word is justified when it does at least one of these jobs:
- names a precise technical concept;
- prevents a real ambiguity;
- compresses a distinction that would otherwise take more words;
- matches established terminology needed for code, standards, research, or review.

A rare word is not justified merely because it sounds more exact, formal, expert, or impressive.

### Rewrite test

When reviewing prose, ask:

1. Can the same mechanism be stated with more ordinary words and no loss of precision?
2. Is the technical term doing real work, or is it decoration?
3. Does the sentence make the causal chain easier to see?
4. Is the reader spending attention on the system, or on decoding the sentence?

If the wording is the harder part, rewrite the wording.

### Relationship to existing engineering doctrine

This rule sharpens, rather than replaces, the existing R3.1/V7 language rule: use plain language without simplifying mechanisms; spend vocabulary budget on engineering distinctions, not ornamental phrasing.

It also fits the existing authorship rule that coherent engineering prose should preserve semantic honesty, information scent, ownership, causality, and technical precision without treating professional appearance as authority.

## Epistemic interface law

`expression phenotype != demonstrated capability != latent/unknown capability != preference != task-optimal form`

Absence from a representation is not evidence of absence from the system unless a discriminator tests it. Apply this agnostically to people, models, software, ontology, interfaces, and observed behavior.
