# H1 BIOS USB discriminator preregistration 09 — firmware drive parameters — 2026-08-31

Status: PREREGISTERED / BUILD PENDING

Trigger: READ4–READ8 repeatedly observed BIOS disk reads reporting success while the tested destination buffer remained unchanged. API choice, transfer count, destination encoding/address, and candidate 512/1024/2048/4096 logical strides have not explained the behavior.

Question: what geometry and EDD parameters does H1 firmware actually advertise for the BIOS-selected boot device?

This discriminator SHALL execute entirely from sector 0. It SHALL perform no BIOS disk read. It SHALL:
- preserve boot drive DL;
- call INT13 AH=08 and capture carry plus returned AX/BX/CX/DX/ES/DI;
- initialize an EDD parameter buffer with size 0x42 and call INT13 AH=48 on the same DL;
- capture AH=48 carry and the returned parameter buffer bytes;
- build one 512-byte result sector at 0000:5000 with header `H1READ9_PARAMS`, boot DL, AH08 status/registers, AH48 status, and the raw returned AH48 parameter block;
- persist that result only after introspection to physically proven writable LBA257 through the existing AH=41 + AH=43 write path;
- halt forever.

Only LBA257 may be written. No disk reads, second-stage execution, graphics transition, internal-disk path, or probe execution.

Interpretation shall be based on exact returned fields, especially bytes-per-sector, total sectors, geometry, and interface/device-path information when present. No further loader repair shall be chosen until the physical parameter packet is read back.
