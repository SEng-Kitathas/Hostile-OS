.code16
.section .fixture,"a"
.global missing_requester
.global later_requester
.global missing_operation
.global present_operation
.global initial_state

missing_requester: .byte 'A'
later_requester: .byte 'B'
missing_operation: .byte 0x7f
present_operation: .byte 0x01
initial_state: .byte 'A'
