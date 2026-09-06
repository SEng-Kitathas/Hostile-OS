# H1 BIOS USB read discriminator preregistration 08 — logical-sector stride mapping — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: physical READ4–READ7 show both EDD LBA1 and CHS sector2 reporting success while returning an all-zero destination buffer. Destination addresses 0x6000 and 0x7E00 both behave the same. The prepared images had nonzero data beginning at byte offset 512 and mostly zero data at later candidate offsets.

Question: does H1 firmware expose the boot USB with a logical-sector stride larger than 512 bytes?

This discriminator SHALL execute entirely from sector 0 and SHALL:
- perform no disk write before the read;
- place distinct 16-byte ASCII signatures in the prepared image at byte offsets 512, 1024, 2048, and 4096;
- zero destination physical 0x7E00;
- issue exactly one CHS AH=02 read of cylinder0/head0/sector2, count1, destination 0000:7E00;
- persist a forensic result sector to LBA257 after the read containing header `H1READ8_STRIDE`, carry status, and the first 128 returned bytes;
- halt forever.

Prepared-image signatures:
- byte 512:  `H1STRIDE_0512`
- byte 1024: `H1STRIDE_1024`
- byte 2048: `H1STRIDE_2048`
- byte 4096: `H1STRIDE_4096`

Only LBA257 may be written.

Interpretation:
- returned prefix matches one signature -> firmware logical sector 1 maps to that byte stride under this boot presentation;
- returned bytes remain zero -> stride candidates 512/1024/2048/4096 are not sufficient; inspect reported geometry/device parameters next;
- CF=1 -> the seeded layout changed firmware acceptance or read path; preserve exact result before further mutation.
