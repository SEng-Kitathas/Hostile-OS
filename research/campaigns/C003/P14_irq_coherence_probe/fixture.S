.code16
.section .fixture,"a"
.global old_owner_fact
.global old_cont_fact
.global new_owner_fact
.global new_cont_fact
.global pit_divisor
old_owner_fact: .byte 'A'
old_cont_fact:  .byte '1'
new_owner_fact: .byte 'B'
new_cont_fact:  .byte '2'
pit_divisor:   .word 4096
