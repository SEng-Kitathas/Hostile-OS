.code16
.section .fixture,"a"
.global durable_record

durable_record:
    .ascii "HOS4"
    .byte 'R'
    .byte 0x5a
