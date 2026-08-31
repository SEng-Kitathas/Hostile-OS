# H1 splash-wrapper qualification close — 2026-08-31

Status: **QUALIFIED PRESENTATION/TRANSPORT WRAPPER / PHYSICAL H1 STILL UNQUALIFIED**

Commander supplied HOSTILE-OS artwork was converted into a 320x200, 32-color VGA splash and wrapped around the existing qualified H1 physical probe without changing D64-v3 or the probe stage2.

Controlling lineage:
- asset/preregistration: `2d0cfee539aab66b65cc61a65fedec24046b15c9`;
- first transport implementation: `4773c94c62aba8c065721e3ddfa0a64175632c2a`;
- final dual-BIOS/provenance repair: `600d8ad30c656ee5b558a2ac3469c05d90cdfc6c`;
- qualification evidence: `a76578c4a716ab91dbecd2d2728832fa15abde58`.

Recommended physical image:
`research/targets/H1_PHYSICAL_PROBE_SPLASH/package/h1_probe_splash_physical.img`
SHA-256 `bcd49e64a80f693b1b38afdef0e81d1045e54970bb76b0c5167240877c16ca31`.

Controlling run `20260831T190606Z_h1_splash_wrapper_qemu_01`:
- floppy/CHS: PID16260, exit67, splash framebuffer PASS, probe END;
- IDE/EDD: PID8648, exit67, splash framebuffer PASS, probe END;
- immutable QEMU backing image unchanged before/after both runs;
- static safety gate PASS15/15;
- both framebuffer captures SHA-256 `896e051ee93cd00b9f4fd26e6a10a89226013d15f993994d4123814346b345d1` and normalize exactly to expected RGB SHA-256 `c738ace07e0ca80894678e199853c71f300b030d323bc6d4cb7209fc2ca25c1c`.

Preserved development scars include a wrong DAC evaluator assumption, QEMU IDE read-only-device rejection, nonportable disk BIOS calls after entering graphics mode, and a runner provenance hole that allowed dirty input while naming HEAD. Final runner refuses dirty source state, and final loader completes every disk read before switching to graphics.

What physical H1 should show: splash for about three seconds or key skip, text-mode restore, then `H1PROBE_BEGIN` through `H1PROBE_END`.

This result does not qualify the HP hardware, open C006, change C004/C005, modify D64-v3, or promote architecture/release status.
