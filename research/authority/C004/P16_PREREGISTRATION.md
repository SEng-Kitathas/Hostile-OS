# C004/P16 preregistration — authority lifetime versus resource lifetime

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P15 CLOSED PASS

## Question

Does revoking one caller's authority to use a resource imply that the underlying resource may be reclaimed, or are authority lifetime and resource/binding lifetime separate consequences?

## Fixture
- resource X current/value7E;
- D64-style resource live count starts2, representing two live bindings/relationships;
- A has READ+WRITE authority; B has READ authority.

## Good mediator
Revoke B authority only.
- resource live count remains2;
- resource identity remains current;
- A READ remains W/7E.

## Bad control
Treat authority revocation as resource reclamation: clear resource identity and live count.
- later A READ -> R/00.

## Ceiling
If observed, P16 earns `AUTHORITY_LIFETIME != RESOURCE_LIFETIME` for this bounded composition. It does not decide how bindings and authority relate in every future subsystem.
