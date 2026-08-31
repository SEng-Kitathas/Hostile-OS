# C004/P03 preregistration — delegation must not amplify authority

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P02 CLOSED PASS

## Question

If B legitimately holds only READ authority to X and may delegate some authority to C, can a delegation mechanism that ignores the delegator's own operation rights create a WRITE future that B itself did not possess?

## Fixture

- A: READ+WRITE to X;
- B: READ only to X;
- C: initially no authority;
- X begins `0x7e`.

## Good candidate

Delegation request carries a requested rights mask. The mechanism computes:

`granted = requested & delegator_rights`

Expected when B requests READ+WRITE for C:
- C receives READ only;
- C read -> W/7E;
- C write55 -> U, X remains7E.

## Bad control

Delegation copies requested rights without intersecting with B's current authority.

Expected:
- C receives READ+WRITE;
- C write55 -> W, X becomes55.

## Discriminator / ceiling

If observed, P03 earns only that delegated authority may need an attenuation constraint tied to the delegator's currently held operation rights. It does not establish a capability tree, ACL inheritance model, cryptographic token, or hardware enforcement mechanism.
