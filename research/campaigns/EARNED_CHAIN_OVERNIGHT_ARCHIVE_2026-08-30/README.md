# Earned-chain overnight raw evidence archive

- source campaign: `.pcmmad_sync_runs/overnight/campaign_20260830T063648Z`
- terminal state: `COMPLETED`
- cycles: `3304`
- passes: `22463`
- failures: `660`
- archive: `EARNED_CHAIN_OVERNIGHT_20260830T063648Z.tar`
- archive bytes: `2143104512`
- archive SHA-256: `eef7a2fd43a1c4819927c3a0d8afb976470171af8f3cd55d0237d1e2b8f2cc0e`
- structural verification: `tar -tf` returned exit `0`

The TAR is a lossless transport of the original campaign scratch directory, including `campaign.jsonl`, `status.json`, results, and retained failure artifacts. It is raw evidence, not architecture authority. The human-readable adjudication is `research/audits/EARNED_CHAIN_OVERNIGHT_REGRESSION_2026-08-30.md`.

The archive is intentionally a large LFS publication object. An OS-only partial/blobless sparse checkout with LFS smudge disabled does not require it.
