# C004/P10 preregistration — delegation attenuation inside protected mediator

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P09 CLOSED PASS

## Question

Does P03's non-amplifying delegation requirement remain necessary when the authority table is protected in ring0 and caller provenance is trusted as B rather than supplied by ring3?

## Fixture
- trusted ring0 rights: A=READ+WRITE, B=READ, C=none;
- ring3 execution context is trusted as B;
- ring3 cannot directly write ring0 authority state;
- B requests READ+WRITE delegation to C.

## Good mediator
`C_rights = requested & B_rights` -> expected `01`.

## Bad mediator control
`C_rights = requested` -> expected `03`.

The test resets C between good and bad paths. The privilege boundary remains active through the same forbidden ring0 data-selector probe used in P07-P09.

## Discriminator / ceiling
If observed, P10 earns that delegation attenuation and non-bypassable protection are independent responsibilities: protection keeps B from directly editing C's rights, while attenuation constrains what the trusted mediator itself may grant.

It does not prescribe a capability tree or delegation API.
