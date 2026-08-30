# Experiment Run Input Snapshot Protocol

**Status:** required for future mutating experiments after I001
**Reason:** I001 attempts 1 and 2 preserved executable artifacts and traces but did not preserve an independent copy of the exact failed-run source inputs

## Core rule

Before any build or execution step that may create scientific or engineering evidence, the launcher must create the run directory and snapshot the exact controlling inputs into it.

A run that executes before its input snapshot is complete is not allowed to become controlling science.

## Minimum per-run input snapshot

Create:

`<run>/inputs/`

and copy the exact bytes of all applicable inputs before compilation/execution:

- controlling preregistration or qualification spec;
- mechanism/source files;
- fixture files;
- linker scripts;
- launcher source;
- evaluator source;
- static/source checker source;
- build configuration files;
- any generated-but-controlling source input;
- explicit environment/config file if one controls behavior.

Do not copy mutable outputs into `inputs/` after execution as though they were original inputs.

## Input manifest

Before build, write:

`<run>/inputs_manifest.json`

containing at least:

- run ID;
- UTC snapshot time;
- source project-relative path for each input;
- run-relative snapshot path;
- byte count;
- SHA-256;
- controlling Git HEAD if available;
- controlling preregistration commit if applicable;
- launcher path/hash;
- declared working directory;
- declared tool paths or references to the tool receipt surface.

After the manifest is written, compute and record its SHA-256 in the later run receipt.

## Ordering requirement

Required order:

1. create unique run directory;
2. create `inputs/`;
3. copy exact controlling inputs;
4. write/hash `inputs_manifest.json`;
5. only then begin compile/link/build;
6. execute only after build succeeds;
7. collect outputs/traces;
8. evaluate/static-check;
9. write final receipt referencing the pre-build input-manifest hash.

## Failure handling

If a build or run fails:

- keep the input snapshot;
- keep build stdout/stderr and partial outputs;
- record the failure stage;
- do not replace the run directory on retry;
- create a new run ID for the repair/retry.

This makes failed runs independently reconstructable without guessing which later working-tree source produced them.

## Source mutation after snapshot

If any controlling input changes after snapshot and before execution:

- abort that run before scientific execution;
- record `INPUT_CHANGED_AFTER_SNAPSHOT`;
- create a fresh run directory and fresh input snapshot for the changed source.

Do not silently update `inputs/` in place after a build/run has started.

## Verification

A controlling scientific result should verify:

- every receipt source hash matches the corresponding `inputs/` snapshot, not merely the current working tree;
- the input manifest hash is present in the receipt;
- controlling Git/preregistration lineage matches the declared run;
- the working-tree source may be compared for convenience, but the run-local snapshot is the forensic authority for what was actually built.

## Scope

This protocol applies to future HOSTILE-OS experiments, qualifications, revisits, integrations, and other mutating evidence-producing jobs where exact source lineage matters.

It does not retroactively invent source snapshots for historical runs that did not capture them.

## Principle

**The run directory must know what it ran, even if the working tree changes later.**
