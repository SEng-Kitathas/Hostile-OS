# H1 physical-probe splash wrapper qualification result — 2026-08-31

Status: **QUALIFIED WRAPPER / RECOMMENDED PHYSICAL THUMB-DRIVE IMAGE**
Physical H1 status: **UNQUALIFIED**
Nature: presentation/boot-transport wrapper around the already-qualified H1 probe; not C006, not D64-v3, no architecture promotion.

## Controlling lineage

- splash preregistration + VGA assets sealed at `2d0cfee539aab66b65cc61a65fedec24046b15c9`;
- first transport implementation commit: `4773c94c62aba8c065721e3ddfa0a64175632c2a`;
- final dual-BIOS transport/provenance repair: `600d8ad30c656ee5b558a2ac3469c05d90cdfc6c`;
- controlling run source HEAD: `600d8ad30c656ee5b558a2ac3469c05d90cdfc6c`;
- controlling source-tree object: `2837be476bc55246ed21c92c5c51946db1556ce9`.

Development failures and harness repairs are preserved in `H1_SPLASH_WRAPPER_QUALIFICATION_SCARS_2026-08-31.md`.

## Exact physical wrapper image

Recommended thumb-drive image:

`research/targets/H1_PHYSICAL_PROBE_SPLASH/package/h1_probe_splash_physical.img`

- bytes: 1,474,560;
- SHA-256: `bcd49e64a80f693b1b38afdef0e81d1045e54970bb76b0c5167240877c16ca31`.

The earlier no-splash qualified image remains preserved separately at `research/targets/H1_PHYSICAL_PROBE/package/h1_probe_physical.img`, SHA-256 `809e70bffb511d0dc67d8ca3df23cf63273db97c29bccbc781482c7d828dbead`.

## Exact wrapper body

- wrapper stage1: 512 bytes, SHA-256 `f337b47d74d3c774c3687bb68d3c44f4e65388e78811bfd71a961ffdcb906ed3`;
- splash loader: 704 bytes / 4,096-byte envelope, headroom 3,392 bytes, SHA-256 `70c97470e062097aa30dec0b0ae41dc7081eae2453668107e88711c46f6e6116`;
- palette: 96 bytes, SHA-256 `c0056796d5c7ec2cb5edc95510b66a058a1705e7dcc1dc3ec750b2f511526744`;
- pixels: 64,000 bytes, SHA-256 `c1467575fe43e5b4b466cf27be0997ad97a12496bbfd49e39057038005ac845f`.

Underlying qualified probe stage2 is unchanged:
- physical stage2 SHA-256 `c12ea44714fd2c4d7dd3590c259e0f196cd38b8a979af8618ddaf79ac31f677d`;
- QEMU stage2 SHA-256 `2b7c0c2b47f751b716d4340aa7e0764d16a07eb49b8d036311d7d9f8e13234e2`.

## Disk layout

- LBA 0: wrapper stage1;
- LBA 1..8: splash-loader envelope;
- LBA 9: VGA palette;
- LBA 10..134: 64,000-byte indexed splash frame;
- LBA 135..150: exact qualified probe stage2 envelope.

All disk reads are completed before VGA graphics mode is entered. The splash frame is staged at physical `0x10000`; the qualified probe is preloaded at `0x8000`; the wrapper then displays the frame, restores text mode, and transfers to the preloaded probe.

## Static gate

`HOSTILE_H1_SPLASH_STATIC_V1`: **PASS 15/15**.

Verified:
- stage1 is exactly 512 bytes with `55 AA` signature;
- stage1's only INT13 function is AH=02 read;
- loader's INT13 functions are only AH=41 capability query, AH=08 geometry query, AH=42 EDD read, and AH=02 CHS read;
- no BIOS disk-write functions;
- no PCI configuration ports in wrapper;
- no PIC/APIC programming ports in wrapper;
- no QEMU debug-exit port in wrapper source;
- palette/pixel payloads are exact;
- physical and QEMU parent probe stage2 bytes are exact.

## Controlling dual-BIOS QEMU run

Run:

`research/targets/H1_PHYSICAL_PROBE_SPLASH/runs/20260831T190606Z_h1_splash_wrapper_qemu_01`

Receipt SHA-256: `ae7969662acef459a043478a68e70e7563a904264ef90107d34ade8fc229ab3a`.

### Floppy-like BIOS presentation

- path: CHS fallback;
- PID: `16260`;
- status: COMPLETED;
- exit: `67`;
- backing image unchanged before/after;
- debug SHA-256: `e11cb1a60607ead44bab7c691abdd39210fd16e333a8f8ad14caa8636aab7517`;
- required splash + probe markers: PASS.

Exact early chain:

```text
H1SPLASH_DISK=CHS
H1SPLASH_PALETTE_OK
H1SPLASH_PIXELS_LOADED
H1SPLASH_PROBE_LOADED
H1SPLASH_VISIBLE
H1SPLASH_CHAIN_PROBE
H1PROBE_BEGIN
```

The underlying probe then completed through `H1PROBE_END`.

### Hard-disk-like BIOS presentation

- path: EDD;
- QEMU IDE device uses an ephemeral `snapshot=on` overlay because the IDE device model rejects a read-only block node;
- immutable backing image SHA-256 before/after: `5c2379c15d92ba162af182825314f4984fa3e78255f7cfe2b8c658f453b0c880` / same;
- PID: `8648`;
- status: COMPLETED;
- exit: `67`;
- debug SHA-256: `c3f50ec41f2da4d54ec0dd0a78452545f1034cd6e5543fe57a042588856b8266`;
- required splash + probe markers: PASS.

Exact early chain:

```text
H1SPLASH_DISK=EDD
H1SPLASH_PALETTE_OK
H1SPLASH_PIXELS_LOADED
H1SPLASH_PROBE_LOADED
H1SPLASH_VISIBLE
H1SPLASH_CHAIN_PROBE
H1PROBE_BEGIN
```

The underlying probe then completed through `H1PROBE_END` with BIOS boot drive `80`.

## Framebuffer proof

Both mappings produced the same QEMU screendump:

- PPM dimensions: 640x400;
- mode-13h representation: exact uniform 2x2 scan doubling of the 320x200 indexed frame;
- PPM SHA-256: `896e051ee93cd00b9f4fd26e6a10a89226013d15f993994d4123814346b345d1`;
- normalized RGB SHA-256: `c738ace07e0ca80894678e199853c71f300b030d323bc6d4cb7209fc2ca25c1c`;
- expected normalized RGB SHA-256: same;
- framebuffer comparison: PASS.

QEMU's observed 6-bit DAC expansion for the used values is even `v -> 4v`, odd `v -> 4v+3`; this was measured and belongs to the framebuffer evaluator, not the splash asset.

## What the commander sees

On a compatible legacy-BIOS boot path:
1. the supplied HOSTILE-OS artwork appears as a 320x200 retro VGA splash, aspect-preserved and letterboxed;
2. it remains for about three seconds, or can be skipped early with a keypress;
3. the display returns to text mode;
4. the existing H1 physical-probe text begins with `H1PROBE_BEGIN` and continues through `H1PROBE_END`.

## Authority ceiling

This result qualifies the wrapper under two QEMU legacy-BIOS drive presentations and verifies the displayed framebuffer. It does not qualify physical H1, prove every HP BIOS USB mapping, change C004/C005 pass counts, open C006, modify D64-v3, or promote architecture/release status.

The actual HP boot remains the next reality-authority boundary.


## Git/input line-ending provenance check

A post-run byte audit compared the controlling run's source-input snapshot to Git commit `600d8ad30c656ee5b558a2ac3469c05d90cdfc6c`.

- binary palette and pixel assets match committed Git blobs byte-for-byte;
- `run_qemu_qualification.py` and `splash_loader.S` match committed Git blobs byte-for-byte;
- the remaining text snapshots differ from their Git blobs only by Windows checkout CRLF expansion;
- after normalizing snapshot CRLF to Git LF, all compared text files are byte-identical to their committed blobs;
- source-tree object `2837be476bc55246ed21c92c5c51946db1556ce9` matches the run receipt.

Therefore the controlling run is source-equivalent to the sealed Git tree; there is no semantic or content drift hidden by the line-ending difference.
