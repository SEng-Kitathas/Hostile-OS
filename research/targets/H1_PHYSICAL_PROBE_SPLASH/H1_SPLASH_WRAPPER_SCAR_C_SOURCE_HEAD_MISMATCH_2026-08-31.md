# H1 splash wrapper Scar C — source/HEAD mismatch during first green dual-mode run

Date: 2026-08-31
Status: **PRESERVED NON-CONTROLLING QUALIFICATION RUN**

Run `20260831T190454Z_h1_splash_wrapper_qemu_01` completed green in both floppy-like and IDE-like QEMU presentations, including exact framebuffer comparison and full chain into `H1PROBE_END`.

However, post-run readback found that `splash_loader.S` had changed after implementation commit `4773c94c62aba8c065721e3ddfa0a64175632c2a` and before/during the run. The run receipt names `4773c94...` as `source_head`, while its copied `splash_loader.S` input hash belongs to the newer working-tree source.

That mismatch makes the run non-controlling even though its observed behavior was green.

The newer source is not silently accepted by provenance. It is separately audited and deliberately adopted because it improves the transport boundary: all pixel sectors and the exact probe stage2 are read into ordinary RAM before VGA mode 13h is entered, so no BIOS disk read is needed while graphics mode is active.

Required repair:
1. commit the audited newer `splash_loader.S` explicitly;
2. rebuild from that exact committed state;
3. rerun static verification;
4. rerun both floppy-like and IDE-like QEMU qualification with framebuffer equality;
5. only the post-repair run may control splash-wrapper qualification.

This scar does not demote the underlying qualified H1 probe.
