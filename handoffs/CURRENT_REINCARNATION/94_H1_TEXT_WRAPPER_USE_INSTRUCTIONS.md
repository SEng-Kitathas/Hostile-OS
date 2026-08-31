# H1 text-only wrapper — physical retest instructions

Status: **READY FOR PHYSICAL H1 DISPLAY DISCRIMINATOR**

Exact image:
`research/targets/H1_PHYSICAL_PROBE_TEXT_WRAPPER/package/h1_probe_text_physical.img`

SHA-256:
`5f90b22ad6264d2e2afb7c0155454b635a7bd4aa4ed22da6be879d14d3c26b42`

This image deliberately removes the splash graphics transition. It preserves the firmware-selected video mode and uses BIOS teletype only.

Expected first visible lines after USB boot:
- `H1TEXT_BEGIN`
- `H1TEXT_DISK=EDD` or `H1TEXT_DISK=CHS`
- `H1TEXT_WRAPPER_OK`
- `H1TEXT_CHAIN_PROBE`
- `H1PROBE_BEGIN`

Then the normal probe data follows and ends at `H1PROBE_END`.

Interpretation:
- if the TV stays synchronized and these lines appear, the splash wrapper's graphics-mode transition is strongly implicated;
- if the TV still reports NO SIGNAL before any text, preserve that result and do not infer that the probe completed invisibly;
- the image remains read-only with respect to target storage and writes no log back to the USB.

Thirty seconds with no visible output is sufficient to classify the retest as failed/partial for this discriminator. The probe has no writeback flush requirement before power-cycle.
