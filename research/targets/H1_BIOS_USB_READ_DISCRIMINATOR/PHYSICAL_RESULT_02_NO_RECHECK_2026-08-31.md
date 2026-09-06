# Physical H1 BIOS USB EDD read discriminator result 02 — no redundant support recheck — 2026-08-31

Status: **PHYSICAL EVIDENCE / AH=42 ONE-SECTOR READ FAILED AFTER SUCCESSFUL ENTRY WRITE**

Prepared image SHA-256: `4207d3211a3b93fc34378f09687f06b40694d469bc6df27c94761344a1b9aaa3`.

After one physical H1 boot, elevated raw readback of LBA257 contained exactly:

`H1READ2_AH42_FAIL\r\n`

SHA-256 of LBA257: `e8a51792505bc7dd82716d240e1194aeb8a45f509210021e04a9b385bfb448a3`.

Earned interpretation:
- sector 0 executed;
- the entry breadcrumb helper physically succeeded through AH=41 + AH=43 to LBA257;
- with no redundant standalone AH=41 gate, the immediately following one-sector AH=42 read of LBA1 returned carry set;
- therefore the prior 8-sector failure is not solely a transfer-count issue.

Open seam: the preceding AH=43 write itself may perturb the firmware's subsequent read state. Next discriminator SHALL perform AH=42 read first, before any BIOS disk write, and only then persist the outcome to LBA257.
