# Physical H1 BIOS USB write discriminator result 02 — exact EDD LBA256 — 2026-08-31

Status: **PHYSICAL EVIDENCE / EDD LBA256 DOES NOT PERSIST**

Prepared image SHA-256: `e8117517f5988bfe9e13c9a5604097f772a85414f257d931d78eb072242372cf`.
The prepared image was raw-readback verified before physical execution and LBA256 was verified zero.

After one H1 boot, elevated raw readback of LBA256 produced:
- 512 bytes;
- all zero;
- SHA-256 `076a27c79e5ace2a3d47f9dd2e83e4ff6ea8872b3c2218f66c92b89b55f36560`;
- sentinel `H1EDD256_WRITE_OK` absent.

Combined with physical discriminator 01:
- EDD AH=43 write to LBA257 persisted (`H1EDD_WRITE_OK`);
- EDD AH=43 write to LBA256 did not persist;
- CHS AH=03 target LBA256 did not persist.

Earned interpretation: H1's boot-device BIOS path has an address-specific write anomaly/protection at LBA256. The durable logger's first record targeted LBA256, so it disabled itself on its first failed write and could never persist later records.

Required repair: relocate journal base away from LBA256; selected next base is LBA257 because EDD persistence at that exact sector is already physically earned.
