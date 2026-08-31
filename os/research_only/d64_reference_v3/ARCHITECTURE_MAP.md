# Architecture map — working relations, not primitives

The inherited relation compression remains:

`activity -> checked binding -> resource`

For the admitted H1 two-core increment, relation mutation has one explicit ownership rule:

`AP request payload -> request publication -> BSP-owned relation operation -> result -> completion publication`

The AP does not mutate the relation body and does not write the legacy relation-call scratch. The mailbox is a bounded coordination witness, not a general IPC primitive.

The state remains decomposed into earned responsibilities:
- identity/currentness;
- pending versus applied progress;
- wait/wake/current relation;
- binding applicability/currentness;
- resource identity/value/currentness/shared lifetime;
- IRQ observation/current-relation validation;
- durable meaning outside volatile runtime topology;
- explicit two-core request/result publication with one current relation owner.

Current availability ceiling: AP relation progress depends on BSP servicing the request. No fairness, owner-failure recovery, arbitrary core count, direct multiwriter relation API, or general scheduler/IPC architecture is claimed.
