# C004/P17 preregistration — authorization at request time versus effect time

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P16 CLOSED PASS

## Question

If an authorized write request is accepted but its effect is applied later, is the authority decision at request time sufficient after authority is revoked before application?

## Fixture
- protected mediator; ring3 caller cannot bypass it;
- resource X value7E;
- caller A initially has WRITE authority;
- A asks to queue value55;
- authority is then revoked before queued effect application.

## Good mediator
Queued work carries caller/authority-generation provenance and revalidates current authority at application time.
- queue accepted while current -> Q;
- revoke authority / advance authority currentness;
- apply -> U;
- X remains7E.

## Bad control
Queue stores only an `authorized=true` decision from request time and applies it after revocation without revalidation.
- queue accepted -> Q;
- revoke;
- apply -> W;
- X becomes55.

## Ceiling
If observed, P17 earns that authorization time and effect-application time are separate future-relevant moments when revocation can occur between them. It does not require a universal queue/job object or prescribe one async execution model.
