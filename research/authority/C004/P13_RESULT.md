# C004/P13 result — authority failure locality under protection

Status: **CLOSED PASS**
Implementation commit: `bf12145`
Controlling run: `P13/runs/20260831T024155Z_c004_p13_01`

With the privilege boundary active, B's unauthorized WRITE returned U and left X7E; a later independently authorized READ still returned W/7E. The deliberately global-failure control converted the same denied WRITE into a latch that forced the later READ to G/00.

Earned: unauthorized operation failure can remain local; a global authority-failure latch loses a valid later future in this fixture.

Run-local inputs 8/8; stage2 993 bytes, SHA `51be7f22ac9b214e78771ddbe13d6d23927fdd1257e498da2fd9c2e160429a95`.
