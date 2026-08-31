# C005/P18 result — durable meaning versus transient concurrency ownership across restart

Status: **CLOSED PASS**
Implementation commit: `52b84ee`
Controlling run: `P18/runs/20260831T054246Z_c005_p18_01`

Boot1 durably wrote resource value7E/generation05 plus captured runtime concurrency fields held1/users1/epoch1. Boot2 was a fresh QEMU process on the same disk with no host write between boots and read-only media.

Bad reconstruction treated held1/users1 as live, blocking fresh acquisition and creating a phantom user. Good reconstruction preserved durable resource meaning/value7E, reset runtime held/users to0, advanced concurrency epoch1->2, and allowed a fresh claim.

Earned: `DURABLE_RESOURCE_MEANING != DURABLE_RUNTIME_CONCURRENCY_OWNERSHIP`. Runtime ownership/participation that did not survive restart must be reconstructed, not blindly reloaded.
