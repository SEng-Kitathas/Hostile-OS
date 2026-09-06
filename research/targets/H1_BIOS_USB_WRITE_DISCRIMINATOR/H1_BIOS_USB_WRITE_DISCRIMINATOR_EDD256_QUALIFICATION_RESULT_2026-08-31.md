# H1 BIOS USB write discriminator — EDD LBA256 qualification result — 2026-08-31

Status: **QUALIFIED EMULATOR DISCRIMINATOR / PHYSICAL TEST PENDING**

Preregistration: `H1_BIOS_USB_WRITE_DISCRIMINATOR_PREREG_02_EDD_LBA256_2026-08-31.md`

Image:
- bytes: 1,048,576;
- SHA-256: `e8117517f5988bfe9e13c9a5604097f772a85414f257d931d78eb072242372cf`.

Boot sector:
- bytes: 512;
- SHA-256: `e532cc13dbd90113ce437fb7adfca806c6038bc99036c4b72efc8b660fa0f24b`.

QEMU IDE/EDD qualification:
- EDD support gate passed;
- exactly one AH=43 write targeted LBA256;
- LBA256 begins `H1EDD256_WRITE_OK\r\n`;
- only LBA256 changed;
- LBA256 post-write SHA-256: `3a17e618b7e804731ba4d3851765fe658a591300470eb98cac02bc6221822eea`.

This discriminator executes entirely from sector 0, performs no CHS write, no second-stage load, and no video-mode transition.
