.code16
.section .text
.global _start
.equ TRACE_LBA,257
_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp
    movb %dl,boot_drive
    sti

    movw $msg_stage1_enter,%si
    call trace_write

    movb boot_drive,%dl
    movw $0x55aa,%bx
    movb $0x41,%ah
    int $0x13
    jc load_fail
    cmpw $0xaa55,%bx
    jne load_fail
    testw $0x0001,%cx
    jz load_fail
    movw $load_dap,%si
    movb boot_drive,%dl
    movb $0x42,%ah
    int $0x13
    jc load_fail

    movw $msg_stage1_loaded,%si
    call trace_write

    movb boot_drive,%dl
    ljmp $0x0000,$0x6000

# SI -> NUL string. Attempts EDD breadcrumb to known-good LBA257.
trace_write:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    pushw %si
    pushw %di
    pushw %es
    xorw %ax,%ax
    movw %ax,%es
    movw $0x5000,%di
    movw $256,%cx
    rep stosw
    popw %es
    pushw %es
    xorw %ax,%ax
    movw %ax,%es
    movw $0x5000,%di
trace_copy:
    lodsb
    stosb
    testb %al,%al
    jnz trace_copy
    movb boot_drive,%dl
    movw $0x55aa,%bx
    movb $0x41,%ah
    int $0x13
    jc trace_done
    cmpw $0xaa55,%bx
    jne trace_done
    testw $0x0001,%cx
    jz trace_done
    movw $trace_dap,%si
    movb boot_drive,%dl
    movb $0x43,%ah
    xorb %al,%al
    int $0x13
trace_done:
    popw %es
    popw %di
    popw %si
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret

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

msg_stage1_enter: .asciz "H1TRACE_STAGE1_ENTER\r\n"
msg_stage1_loaded: .asciz "H1TRACE_STAGE1_LOADED\r\n"
msg_fail: .asciz "H1TRACE_STAGE1_LOAD_FAIL\r\n"
boot_drive: .byte 0
.balign 4
load_dap:
    .byte 0x10,0x00
    .word 0x0008
    .word 0x6000
    .word 0x0000
    .long 1
    .long 0x00000000
.balign 4
trace_dap:
    .byte 0x10,0x00
    .word 0x0001
    .word 0x5000
    .word 0x0000
    .long TRACE_LBA
    .long 0x00000000
