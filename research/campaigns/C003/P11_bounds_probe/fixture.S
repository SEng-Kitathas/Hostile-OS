.code16
.section .fixture,"a"
.global valid_index_fact
.global invalid_index_fact
.global write_value_fact
.global initial_slot0_fact
.global initial_slot1_fact
.global initial_sentinel_fact
valid_index_fact:      .byte 1
invalid_index_fact:    .byte 2
write_value_fact:      .byte 'X'
initial_slot0_fact:    .byte 'A'
initial_slot1_fact:    .byte 'B'
initial_sentinel_fact: .byte 'S'
