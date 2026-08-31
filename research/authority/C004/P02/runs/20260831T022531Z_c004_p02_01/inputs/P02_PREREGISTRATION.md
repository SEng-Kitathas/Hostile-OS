# C004/P02 preregistration — operation-specific authority

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: C004/P01 CLOSED PASS

## Question

Once caller authority is represented separately from target currentness, is one binary `allowed` fact sufficient, or do read and mutation rights have different reachable futures?

## Fixture

- resource X begins value `0x7e`;
- owner A is authorized for read and write;
- B is deliberately delegated read authority only;
- target/currentness remains valid throughout.

## Good candidate

Authority relation carries independent `READ` and `WRITE` bits.

Expected:
- A read -> `W`, `7E`;
- A write `55` -> `W`, resource `55`;
- reset X to `7E`;
- B read -> `W`, `7E`;
- B write `55` -> `U`, resource remains `7E`.

## Bad control

One binary allowed flag says only that B may use X. The bad mutation path checks the same single allow bit used by read.

Expected:
- B bad write `55` -> `W`, resource becomes `55`.

## Discriminator

P02 passes only if the read-only B relation admits observation but rejects mutation while the binary-allow bad control mutates the same resource.

## Interpretation ceiling

If observed, P02 earns only that operation class can be an independently future-relevant authority distinction. It does not establish a universal rights bitmap, capability object, ACL, role system, or hardware enforcement boundary.
