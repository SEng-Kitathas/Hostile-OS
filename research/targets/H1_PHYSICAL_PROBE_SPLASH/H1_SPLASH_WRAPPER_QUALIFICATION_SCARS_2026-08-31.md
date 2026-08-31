# H1 splash-wrapper qualification scars — 2026-08-31

Status: PRESERVED DEVELOPMENT / HARNESS SCARS
Controlling qualification: **none yet at time of this note**

These failures occurred after the splash preregistration was sealed and before the final controlling run. They do not demote the already-qualified underlying H1 probe.

## Scar A — framebuffer checker assumed the wrong VGA DAC expansion

Precheck run: `20260831T185807Z_h1_splash_wrapper_qemu_01`.

The floppy boot completed end-to-end with QEMU exit 67 and reached `H1PROBE_END`, but the screenshot evaluator failed because it assumed VGA 6-bit DAC values map to 8-bit as `(v<<2)|(v>>4)`.

The actual QEMU VGA path was measured from all 32 used palette entries. In this path each channel maps as:

- even `v`: `4*v`;
- odd `v`: `4*v+3`.

After changing only the evaluator's DAC expansion rule, the same captured framebuffer PPM SHA-256 `896e051ee93cd00b9f4fd26e6a10a89226013d15f993994d4123814346b345d1` normalized exactly to expected RGB SHA-256 `c738ace07e0ca80894678e199853c71f300b030d323bc6d4cb7209fc2ca25c1c` with uniform 2x2 VGA scan doubling.

The splash asset bytes were not changed for this repair.

## Scar B — QEMU IDE device rejected a read-only block node

The first hard-disk-like precheck used `if=ide,readonly=on`. QEMU exited before BIOS boot with `Block node is read-only`.

The qualification harness was changed to use a temporary `snapshot=on` overlay for the IDE model and to hash the immutable backing image before and after the run. The backing image must remain byte-identical. No persistent target disk is attached.

## Scar C — disk BIOS calls after entering VGA mode were not portable across proxy paths

After the IDE device began booting, SeaBIOS debug output proved it loaded the wrapper at `0000:7c00` and entered VGA mode 13h. E9 traces showed:

```text
H1SPLASH_DISK=EDD
H1SPLASH_PALETTE_OK
```

and then no further progress.

The floppy CHS path could continue while issuing BIOS disk reads during graphics mode; the hard-disk EDD/AHCI path could not. Several narrower hypotheses were tested, including a low-RAM bounce buffer and explicit DS restoration after INT10; neither repaired the stall.

Final representation repair: all palette, pixel, and probe sectors are now read **before** entering graphics mode. The 64,000-byte frame is staged in conventional RAM at physical `0x10000`; the exact probe stage2 is preloaded at `0x8000`; only then does the wrapper enter mode 13h, copy the staged frame to VGA, wait, restore text mode, and jump to the preloaded probe. This removes all disk BIOS I/O from the graphics-mode interval.

## Scar D — qualification receipt could name HEAD while inputs were dirty

A successful dual-mode development precheck `20260831T190438Z_h1_splash_wrapper_qemu_01` ran while the final loader repair was still a working-tree modification. Its receipt reported Git HEAD `4773c94c62aba8c065721e3ddfa0a64175632c2a`, but its input snapshot contained a newer uncommitted `splash_loader.S`.

The run is therefore **non-controlling**, even though both modes completed with exit 67 and exact framebuffer checks.

Harness repair: `run_qemu_qualification.py` now refuses to start if `research/targets/H1_PHYSICAL_PROBE_SPLASH` has any non-ignored working-tree change. The controlling run must come from a clean committed implementation tree.

## Resulting rule

A splash-wrapper run becomes controlling only when:
- its implementation tree is clean against HEAD before launch;
- static verification passes;
- both floppy/CHS and hard-disk/EDD paths pass;
- the backing image hash is unchanged across each run;
- framebuffer comparison passes;
- the underlying probe reaches its normal terminal observation/exit.
