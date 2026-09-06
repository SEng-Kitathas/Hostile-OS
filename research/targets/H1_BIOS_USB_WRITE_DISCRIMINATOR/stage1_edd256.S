.code16
.section .text
.global _start
_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp
    movb %dl,boot_drive
    sti

    movw $0x5000,%di
    movw $256,%cx
    xorw %ax,%ax
    rep stosw
    movw $msg,%si
    movw $0x5000,%di
copy_z:
    lodsb
    stosb
    testb %al,%al
    jnz copy_z

    movb boot_drive,%dl
    movw $0x55aa,%bx
    movb $0x41,%ah
    int $0x13
    jc halt
    cmpw $0xaa55,%bx
    jne halt
    testw $0x0001,%cx
    jz halt

    movw $dap,%si
    movb boot_drive,%dl
    movb $0x43,%ah
    xorb %al,%al
    int $0x13
halt:
    cli
    hlt
    jmp halt

msg: .asciz "H1EDD256_WRITE_OK\r\n"
boot_drive: .byte 0
.balign 4
dap:
    .byte 0x10,0x00
    .word 0x0001
    .word 0x5000
    .word 0x0000
    .long 256
    .long 0x00000000
.org 510
.word 0xaa55
