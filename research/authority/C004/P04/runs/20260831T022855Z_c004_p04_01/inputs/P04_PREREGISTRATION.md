# C004/P04 preregistration — authority revocation separate from resource currentness

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P03 CLOSED PASS

## Question

Can B's delegated READ authority be revoked while resource X remains current and A's authority remains valid, or does authority revocation require disturbing resource currentness?

## Fixture
- X current at resource generation1/epoch1, value7E;
- A has READ+WRITE and remains authorized;
- B has delegated READ under authority generation1.

## Good candidate
B's authority relation has its own generation/current flag. Revocation advances/removes B authority without changing resource generation/epoch.

Expected:
- B old authority before revoke -> W/7E;
- revoke B; X remains resource gen1/epoch1;
- A read after revoke -> W/7E;
- B old authority-gen1 -> U/00.

## Bad control
A resource-currentness-only read ignores B authority generation.

Expected after revoke:
- B using current resource tuple -> W/7E.

## Ceiling
If observed, P04 earns a separate authority-currentness/revocation distinction at bounded scope. It does not determine representation width, revocation tree semantics, or enforcement against raw untrusted code.
