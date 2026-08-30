.code16
.section .fixture,"a"
.global eligible_a
.global eligible_b
.global initial_policy_history
.global initial_progress_a
.global initial_progress_b

eligible_a: .byte 'A'
eligible_b: .byte 'B'
initial_policy_history: .byte 'A'
initial_progress_a: .byte '0'
initial_progress_b: .byte '0'
