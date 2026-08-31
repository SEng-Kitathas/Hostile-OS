# Architecture map — working relations, not primitives

The current body is organized around a useful compression:

`activity -> checked binding -> resource`

This is not a claim that those words are irreducible OS atoms.

The state is deliberately decomposed into the earned relations:
- identity/currentness;
- pending versus applied progress;
- current wait versus wake/notification;
- binding applicability/currentness;
- resource identity/value/currentness/shared lifetime;
- IRQ observation versus current-relation validation;
- durable meaning kept outside the runtime topology.

Parent-lineage arrays present in some historical D64 fixtures are omitted from the v2 shared baseline because the planned reviewer workloads do not currently require that consequence. They can be re-earned by a later workload.

State layout and byte rationale are frozen in the project research plan; this `os/` copy carries only the resulting constants so the sparse checkout does not depend on R&D files.
