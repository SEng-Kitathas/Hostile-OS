# C005/P20 result — hard-stop adversarial release-provenance challenge

Status: **CLOSED PASS / C005 HARD STOP REACHED**
Implementation commit: `1422404`
Controlling run: `P20/runs/20260831T054604Z_c005_p20_01`
Execution surface: H1 QEMU constraint proxy (`pc-q35-11.1`, `phenom`, 2 vCPU, 4096 MiB, TCG)

BSP local APIC ID was00 and AP local APIC ID was01. AP supplied forged claimed owner00.

Bad release trusted the supplied owner ID, cleared BSP's claim, and AP acquired while BSP still believed itself active (`BAD_RELEASE=1`, `BAD_AP_ACQUIRE=1`, `BAD_DOUBLE_OWNER=1`).

Good release ignored the supplied claim and compared the actual local APIC ID01 against recorded owner00. Release was denied, AP could not acquire while BSP remained active, no double ownership occurred, and AP acquired only after BSP explicitly released.

Earned: `CLAIMED_OWNER_ID != TRUSTED_RELEASE_PROVENANCE` for this tested x86 APIC-backed two-CPU boundary. Local APIC ID is an enforcement witness, not universal architecture.

The H1 QEMU proxy result is target-shaped emulator evidence only. It is **not** physical H1 hardware qualification.

P20 is the mandatory C005 hard stop. **No C005/P21 may be created or run.**
