# External I001 reproduction report — Opus / 2026-08-30

Status: EXTERNAL FULL-RERUN REPORT / FOREIGN RAW PACKET NOT YET SUPPLIED
Source: operator-supplied text attributed to Opus

## Reported environment independence

The outside host reportedly used:
- a different operating system from the authoring Windows host;
- Clang 18.1.3 instead of historical 21.0.0;
- a different LLD;
- QEMU 6.2.0 instead of historical 11.1.0;
- a clean clone with no author-local paths.

## Reported reproduction result

The external report states that all packaging checks passed and that the outside host independently satisfied both:

1. **machine-byte reproduction** — rebuilt stage1/stage2 match the controlling I001 hashes;
2. **scientific rerun** — the two-boot workload completes in two distinct QEMU processes with exit33 and no host disk write between boots.

Reported checks:

```text
stage1_hash_matches_i001        TRUE
stage2_hash_matches_i001        TRUE
stage1_size_512                 TRUE
stage1_signature_55aa           TRUE
stage2_within_4096              TRUE
distinct_qemu_pids              TRUE
boot1_exit33                    TRUE
boot2_exit33                    TRUE
no_host_write_between_boots     TRUE
irq_event_positive              TRUE
historical_exact_irq_event_one  TRUE
failures: []
```

The field `irq_event_positive` identifies this as a reproduction against the earlier research-only verifier interface, before the later IRQCOUNT01 adoption narrowed the living verifier to the tested set `{1,2}`. The reported run observed exact count one; this is compatible with the historical I001 trace and with the later IRQCOUNT01 result, but a single outside count-one run is not a discriminator between count-one and count-two semantics.

## Evidence ceiling

The foreign build/run files, tool hashes, debug traces, and manifests were not supplied in this chat turn. Therefore this repository records the outside result as an **external reported reproduction**, not as locally hash-verified foreign raw evidence.

If the external packet is later supplied, admit it without rewriting this report and verify its manifest/raw artifacts separately.

## Portability defects discovered by the outside run

The outside run required three manual repairs before success:
- preserve LLVM multi-call invocation identity instead of resolving symlink names before exec;
- set QEMU module directory for the transplanted module tree;
- disable the unrelated default QEMU NIC to avoid missing option-ROM dependency.

Those defects were independently adjudicated against the current repository and repaired after this report. See:
`research/external_review/OPUS_INDEPENDENT_HOST_I001_REPRODUCTION_ADJUDICATION_2026-08-30.md`.
