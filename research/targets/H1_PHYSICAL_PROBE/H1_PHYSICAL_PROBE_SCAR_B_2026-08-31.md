# H1 physical probe qualification Scar B — static checker over-ban

Date: 2026-08-31
Status: **PRESERVED CHECKER FAILURE / PROBE NOT DEMOTED**

The first `verify_static.py` run reported `stage2_no_int13=false` and failed the static gate.

That rule was wrong. The sealed preregistration explicitly permits read-only boot-drive BIOS queries, and stage2 intentionally uses:
- INT13h AH=08 for drive geometry/status;
- INT13h AH=41 for extension presence/features.

The safety rule is not "no INT13 in stage2." It is "no disk-write BIOS function or other target-disk mutation." The checker is therefore repaired to enumerate every stage2 INT13 call and require the immediately established AH function to be in the admitted read-only set `{0x08,0x41}`.

This scar is a verifier-definition failure, not evidence that the probe wrote storage.
