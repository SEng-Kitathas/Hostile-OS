.code16
.section .fixture,"a"
.global owner_a_fact
.global owner_b_fact
.global dirty_wait_fact
.global dirty_cont_fact
.global dirty_progress_fact
.global clean_default_fact
owner_a_fact:        .byte 'A'
owner_b_fact:        .byte 'B'
dirty_wait_fact:     .byte '1'
dirty_cont_fact:     .byte '2'
dirty_progress_fact: .byte '7'
clean_default_fact:  .byte '0'
