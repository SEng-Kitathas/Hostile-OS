# Physical H1 BIOS USB EDD read discriminator result 05 — equivalent segment encoding — 2026-08-31

Status: **PHYSICAL EVIDENCE / AH=42 STILL REPORTS SUCCESS WITHOUT MODIFYING DESTINATION**

Prepared image SHA-256: `d097e68f47c1f4d7d8274b73d00e11ddadce7318aa4e334edfe464b9a515e91f`.

READ5 changed only the DAP destination encoding from `0000:6000` to equivalent `0600:0000`, both physical address `0x6000`.

After one physical H1 boot, LBA257 contained a valid `H1READ5_RAW` result:
- status byte: 0 (AH=42 returned carry clear);
- post-call DAP count: 1;
- first 128 bytes at physical 0x6000: all zero;
- bytes did not match prepared LBA1.

LBA257 SHA-256: `1ef0a66a145fba3e6a037f2648f2933f0de2dea9548ba1d95b0783c2e01a1fd6`.

Earned interpretation: the zero-segment DAP encoding was not the cause. On this physical H1 USB presentation, EDD AH=42 reports success but does not deliver observable data to the requested low-memory buffer for either equivalent segment:offset encoding tested.

Next discriminator: one-sector CHS AH=02 read-first of C0/H0/S2 into physical 0x6000, with returned bytes persisted only after the read via proven EDD write to LBA257.
