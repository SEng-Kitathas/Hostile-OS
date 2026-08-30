.code16
.section .fixture,"a"
.global repaired_wait_then_complete
.global repaired_complete_then_wait
.global broken_complete_then_wait

# The fixture controls ordering only. It does not implement wake/currentness behavior.
# 1 = install/check wait, 2 = terminal completion, 0 = end.
repaired_wait_then_complete:
    .byte 1, 2, 0

repaired_complete_then_wait:
    .byte 2, 1, 0

broken_complete_then_wait:
    .byte 2, 1, 0
