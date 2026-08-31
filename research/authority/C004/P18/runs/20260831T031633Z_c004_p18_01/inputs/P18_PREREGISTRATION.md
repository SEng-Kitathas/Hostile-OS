# C004/P18 preregistration — authority currentness across restart

Status: PREREGISTERED BEFORE IMPLEMENTATION
Parent: P17 CLOSED PASS

## Question

If durable grant meaning survives a fresh machine boot and a new runtime authority record is reconstructed, can a historical authority handle remain valid merely because slot+generation are reused, or is a restart authority epoch/currentness boundary required?

## Two-boot fixture

Boot1:
- protected authority record for A READ on resource X/value7E;
- authority handle tuple slot0/gen1/epoch1 is recorded as historical negative-control bytes;
- durable grant meaning A+READ+X and prior authority epoch1 are written to one sector;
- clean exit33.

Boot2 is a fresh QEMU process on the same disk, with no host write between boots.

Good reconstruction:
- validate durable record;
- advance authority epoch1->2;
- reconstruct fresh authority record slot0/gen1/epoch2 from durable grant meaning;
- historical handle slot0/gen1/epoch1 -> R;
- fresh handle -> W/7E.

Bad control:
- reconstruct the same fresh grant but incorrectly retain authority epoch1;
- historical slot0/gen1/epoch1 aliases the reconstructed record -> W/7E.

Ring3 cannot bypass the mediator; the same protected boundary remains active.

## Ceiling

If observed, P18 earns a restart currentness boundary for reusable authority handles at this tested scope. It does not require persistence of all authority/grants, prescribe a credential store, or imply that every authority relation should survive restart.
