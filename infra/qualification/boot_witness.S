.code16
.section .text
.global _start
_start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw $msg, %si

1:
    lodsb
    testb %al, %al
    jz 2f
    movw $0x00e9, %dx
    outb %al, %dx
    jmp 1b

2:
    movw $0x00f4, %dx
    movb $0x10, %al
    outb %al, %dx

3:
    hlt
    jmp 3b

msg:
    .asciz "PCMMAD-QEMU-OK\n"

.org 510
.word 0xaa55
