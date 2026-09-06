# H1 durable log LBA257 repair qualification result — 2026-08-31

Status: **QUALIFIED EMULATOR INSTRUMENT / PHYSICAL RETEST PENDING**

Source HEAD: `d0b41649b430d4678e2aa030d8fd4aa61944e182`
Controlling run: `research/targets/H1_PHYSICAL_PROBE_DURABLE_LOG_LBA257/runs/20260831T212837Z_h1_durable_log_qemu_01`

Repair: journal base moved from physically non-persisting LBA256 to physically proven EDD-writable LBA257. Journal range is now LBAs257..384.

Static gate: PASS22/22.

Floppy/CHS run:
- PID 23692;
- exit 67;
- 36 journal records;
- journal reaches `H1PROBE_END`;
- bytes outside LBAs257..384 unchanged.

IDE/EDD run:
- PID 12616;
- exit 67;
- 36 journal records;
- journal reaches `H1PROBE_END`;
- bytes outside LBAs257..384 unchanged.

Physical image:
- bytes: 1474560;
- SHA-256: `7ba3a5edd4c1a5a961f514fbf8fdf278e367920aca5ddb450efa87e44f6a8701`;
- first 1 MiB SHA-256: `35234bbd8fe3acf4f1f8e2d986bf451f2564e2f25f7ed9b1637fa500d4af9477`;
- initial journal region LBAs257..384 is all-zero: True.
