# C003 / P05 provenance correction — named run versus committed replay

**Date:** 2026-08-29
**Status:** PROVENANCE CORRECTION / SCIENTIFIC CONSEQUENCE UNCHANGED
**P05 close commit:** `ae829292f384f89904f0ca3eef63ba122072ebc0`

## Mismatch

The sealed `C003_P05_RESULT.md` names run `20260829T213200Z_p05_async_irq_idle_01` and records that run's process receipt SHA-256 `445cfb5b8d244a96ed1984568ea2e65284828d82339c2e351decebeb4ac1f288`.

However, the P05 close commit initially tracked a second independently executed run directory, `20260829T213235Z_p05_async_irq_idle_01`, rather than the named `...213200Z...` directory.

The omission is a provenance/path packaging defect, not a scientific discrepancy.

## Cross-run comparison

Both runs used the same admitted source packet and produced identical scientific artifacts:

- `probe.bin` SHA-256: `095b347019351a392759778e8ccb47428f9f0b5651b0b49aed0942c2f8b23fe9`
- `debugcon.txt` SHA-256: `2fa966d8fb3407a4681ed337ec09286593cd030ea12fe6860117585a20992524`
- `evaluation.json` SHA-256: `d857149ba40fc752450e85f548f54fd7b0b0005b33fd3543e16b61f98561094a`
- evaluator stdout SHA-256: `5e0b8e49771210d815a700a553eaef644b67779a3a0c024aa2c739147bb585e4`
- all build/QEMU/evaluator stderr artifacts: empty SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`

Both exact guest observations were:

```text
PRE_EVENT=0
IDLE_ENTER=PASS
IRQ_EVENT=PASS
IDLE_WAKE=PASS
DONE
```

### Named run

`20260829T213200Z_p05_async_irq_idle_01`

- QEMU PID `4468`
- start `2026-08-29T21:32:44.592347+00:00`
- end `2026-08-29T21:32:44.791015+00:00`
- exit `33`
- receipt SHA-256 `445cfb5b8d244a96ed1984568ea2e65284828d82339c2e351decebeb4ac1f288`

### Already-committed replay

`20260829T213235Z_p05_async_irq_idle_01`

- QEMU PID `8768`
- start `2026-08-29T21:32:33.499157+00:00`
- end `2026-08-29T21:32:33.700527+00:00`
- exit `33`
- receipt SHA-256 `d08f9a6078a447c44029c9bdae2cea364ea1e0b0e46e3832ab157f2328af97d3`

The receipt hashes differ because run ID, PID, paths, and timestamps differ as expected.

## Resolution

The named `...213200Z...` run directory is admitted in this correction so the sealed P05 result's exact run and receipt are present in durable Git state. The previously committed `...213235Z...` run remains an independent replay/corroboration.

No scientific conclusion or authority ceiling changes.
