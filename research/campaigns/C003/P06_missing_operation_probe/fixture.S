.code16
.section .fixture,"a"
.global initial_state
.global known_operation
.global unknown_operation

initial_state: .byte 'A'
known_operation: .byte 0x01
unknown_operation: .byte 0x7f
