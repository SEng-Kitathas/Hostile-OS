# Physical H1 BIOS USB read discriminator result 08 — logical-sector stride — 2026-08-31

Status: **PHYSICAL EVIDENCE / NO SEEDED STRIDE SIGNATURE RETURNED**

Prepared image SHA-256: `aaa1b167579ac25d2c794ac39de515102fc3c5e20cd814a102eda0a1003574cd`.

Prepared signatures:
- byte 512: `H1STRIDE_0512`
- byte 1024: `H1STRIDE_1024`
- byte 2048: `H1STRIDE_2048`
- byte 4096: `H1STRIDE_4096`

After one physical H1 boot, LBA257 contained a valid `H1READ8_STRIDE` forensic sector.

Decoded fields:
- CHS AH=02 status byte: `0` (carry clear);
- returned 128-byte sample: all zero;
- none of the four seeded stride signatures were present;
- LBA257 SHA-256: `6df312e0b64773e2e1f7543d32eb04ad33adf764cf93b5c4547348d7f18cec08`.

Earned interpretation:
- candidate logical-sector strides 512/1024/2048/4096 are not supported by this physical result;
- the firmware still reports successful reads while leaving the tested destination unchanged;
- next seam is firmware-reported device geometry / EDD parameterization rather than further speculative loader mutation.
