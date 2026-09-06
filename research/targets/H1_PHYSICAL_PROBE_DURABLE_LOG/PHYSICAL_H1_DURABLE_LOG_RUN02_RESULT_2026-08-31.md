# Physical H1 durable-log run 02 result — 2026-08-31

Status: **PHYSICAL RUN EXECUTED / NO JOURNAL RECORD PERSISTED / NEXT DISCRIMINATOR REQUIRED**

## Media provenance

Before H1 run 02, the SanDisk first 1 MiB was written directly and raw-readback verified against the qualified durable-log image prefix:

- bytes: 1,048,576;
- SHA-256: `d9854764012eac4f16e2c887c748abc7c85b84e29cca33960e4da21e979bca35`;
- journal LBAs 256..383 verified all-zero.

After the physical H1 boot and return, elevated raw capture verified the first 1 MiB remained byte-for-byte identical with the same SHA-256. The 64 KiB journal region was exactly all-zero (SHA-256 `de2f256064a0af797747c2b97505dc0b9f3df0de4f489eac731c23ae9ca9cc31`). No valid `H1LG` record exists.

Therefore this run does **not** support the hypothesis that the logger completed any BIOS sector write. The remaining seam is whether execution reached the logger write path at all versus H1 BIOS rejecting boot-device writes.

## Host-writer scar discovered during recovery

The earlier physical splash boot had not been prepared with a complete 1.44 MiB image. The first writer wrote exactly 1 MiB, then Windows raw write failed at the old exFAT partition boundary. That first MiB was sufficient to contain and boot the splash wrapper. A later durable-image writer attempted to resolve `F:` but the raw-imaged SanDisk had no drive letter, so it failed before writing anything.

This host-side provenance error explains the earlier zero-journal attempt and is distinct from run 02. Run 02 used a directly verified durable prefix and still produced no journal write.

## Next discriminator

Use `research/targets/H1_BIOS_USB_WRITE_DISCRIMINATOR/`: a single-sector boot program with no loader/display dependency. It attempts CHS and EDD writes of distinct sentinels to LBAs 256 and 257 respectively, then halts. This isolates BIOS boot-device write capability from the durable logger body.
