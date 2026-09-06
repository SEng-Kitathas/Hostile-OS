# H1 BIOS USB EDD read discriminator preregistration 05 — equivalent segment:offset encoding — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: READ4 physically observed AH=42 return carry clear with post-call DAP count 1, yet the first 128 bytes at physical address 0x6000 remained all-zero. No alternate sector translation was evidenced.

Question: does H1 firmware mishandle an EDD read destination encoded as segment:offset `0000:6000` even though that physical address is valid?

This discriminator SHALL keep the same physical destination address 0x6000 and change only the DAP buffer encoding:
- prior encoding: offset `0x6000`, segment `0x0000`;
- test encoding: offset `0x0000`, segment `0x0600`;
- both resolve to physical address `0x6000`.

It SHALL:
- perform no BIOS disk write before the read;
- zero physical 0x6000 before AH=42;
- issue one AH=42 read of LBA1 using DAP buffer `0600:0000`;
- persist a READ5 forensic result to LBA257 after the read containing carry status, post-call DAP count, and the first 128 bytes at physical 0x6000;
- halt.

Only LBA257 may be written. No second stage, graphics transition, internal-disk path, or probe execution.

Interpretation:
- returned bytes now match LBA1 -> firmware has a segment:offset encoding quirk; use non-zero segment form in physical H1 loader DAPs.
- returned bytes remain zero with CF=0 -> zero-segment encoding is not the cause; inspect EDD parameter/device presentation and destination constraints next.
- CF=1 -> encoding changes call acceptance; capture status and continue from earned evidence.
