.code16
.section .text
.global _start
.equ CHS_LBA,256
.equ EDD_LBA,257
_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp
    movb %dl,boot_drive
    sti

    # Build CHS sentinel sector at 0000:5000.
    movw $0x5000,%di
    movw $256,%cx
    xorw %ax,%ax
    rep stosw
    movw $chs_msg,%si
    movw $0x5000,%di
    call copy_z

    # Geometry and CHS write to logical LBA 256.
    movb boot_drive,%dl
    movb $0x08,%ah
    int $0x13
    jc skip_chs
    movb %cl,%al
    andb $0x3f,%al
    jz skip_chs
    movb %al,spt
    movb %dh,%al
    incb %al
    jz skip_chs
    movb %al,heads

    movl $CHS_LBA,%eax
    xorl %edx,%edx
    movzbl spt,%ecx
    divl %ecx
    movb %dl,tmp_sector
    incb tmp_sector
    xorl %edx,%edx
    movzbl heads,%ecx
    divl %ecx
    # cylinder EAX, head EDX; encode cylinder high bits in CL.
    movb %al,%ch
    movb tmp_sector,%cl
    movb %ah,%al
    andb $0x03,%al
    shlb $6,%al
    orb %al,%cl
    movb %dl,%dh
    xorw %ax,%ax
    movw %ax,%es
    movw $0x5000,%bx
    movb boot_drive,%dl
    movb $0x03,%ah
    movb $0x01,%al
    int $0x13
skip_chs:

    # Build EDD sentinel sector at 0000:5200.
    xorw %ax,%ax
    movw %ax,%es
    movw $0x5200,%di
    movw $256,%cx
    xorw %ax,%ax
    rep stosw
    movw $edd_msg,%si
    movw $0x5200,%di
    call copy_z

    # EDD support gate and write LBA 257.
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

copy_z:
1:  lodsb
    stosb
    testb %al,%al
    jnz 1b
    ret

chs_msg: .asciz "H1CHS_WRITE_OK\r\n"
edd_msg: .asciz "H1EDD_WRITE_OK\r\n"
boot_drive: .byte 0
spt: .byte 0
heads: .byte 0
tmp_sector: .byte 0
.balign 4
dap:
    .byte 0x10,0x00
    .word 0x0001
    .word 0x5200
    .word 0x0000
    .long EDD_LBA
    .long 0x00000000
.org 510
.word 0xaa55
