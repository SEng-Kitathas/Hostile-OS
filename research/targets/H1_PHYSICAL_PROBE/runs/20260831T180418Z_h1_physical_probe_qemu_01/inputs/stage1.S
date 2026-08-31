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

    movw $0x8000,%bx
    movb $0x02,%ah
    movb $0x10,%al
    movb $0x00,%ch
    movb $0x02,%cl
    movb $0x00,%dh
    movb boot_drive,%dl
    int $0x13
    jc load_fail

    movb boot_drive,%dl
    ljmp $0x0000,$0x8000

load_fail:
    movw $msg_fail,%si
    call print_string
1:  hlt
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
2:  ret

.section .data
boot_drive: .byte 0
msg_fail: .asciz "H1PROBE_STAGE1_LOAD_FAIL\r\n"
