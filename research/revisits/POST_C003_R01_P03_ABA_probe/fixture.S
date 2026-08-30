.code16
.section .fixture,"a"
.global initial_owner
.global initial_history
.global initial_version
.global target_owner
.global target_history
initial_owner: .byte 'A'
initial_history: .byte 'A'
initial_version: .byte 1
target_owner: .byte 'B'
target_history: .byte 'B'
