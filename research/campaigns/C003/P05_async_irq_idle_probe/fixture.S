.code16
.section .fixture,"a"
.global pit_divisor

# Bounded timer parameter only. The fixture does not perform the wake.
pit_divisor:
    .word 4096
