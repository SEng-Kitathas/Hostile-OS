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

    # Loader occupies LBA 1..8, which is CHS C0/H0/S2..S9 on both
    # the 1.44MB floppy geometry and ordinary legacy hard-disk geometry.
    movw $0x6000,%bx
    movb $0x02,%ah
    movb $0x08,%al
    movb $0x00,%ch
    movb $0x02,%cl
    movb $0x00,%dh
    movb boot_drive,%dl
    int $0x13
    jc load_fail

    movb boot_drive,%dl
    ljmp $0x0000,$0x6000

load_fail:
    movw $msg_fail,%si
    call print_string
1:
    cli
    hlt
    jmp 1b

print_string:
    lodsb
    testb %al,%al
    jz 2f
    movw $0x00e9,%dx
    outb %al,%dx
    movb $0x0e,%ah
    xorw %bx,%bx
    int $0x10
    jmp print_string
2:
    ret

.section .data
boot_drive: .byte 0
msg_fail: .asciz "H1SPLASH_STAGE1_LOAD_FAIL\r\n"
