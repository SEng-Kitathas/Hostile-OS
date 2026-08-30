.code16
.section .fixture,"a"
.global initial_count
.global initial_members
.global history_identity
.global remove_identity

initial_count: .byte 3
initial_members: .byte 'A','B','C'
history_identity: .byte 'B'
remove_identity: .byte 'B'
