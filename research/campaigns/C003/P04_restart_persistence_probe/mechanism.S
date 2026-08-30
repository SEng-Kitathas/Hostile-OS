.code16
.section .text
.global _start
.extern durable_record

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT,  0x00f4
.equ BUF,        0x0600

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp
    movb %dl,boot_drive
    movb $0,runtime_access_current

    call read_sector2
    jc io_fail

    movw $BUF,%si
    movw $durable_record,%di
    movw $4,%cx
check_magic:
    movb (%si),%al
    cmpb (%di),%al
    jne boot1
    incw %si
    incw %di
    loop check_magic

    # Existing magic means this is the recovery boot. Verify all six durable bytes.
    movw $BUF,%si
    movw $durable_record,%di
    movw $6,%cx
check_record:
    movb (%si),%al
    cmpb (%di),%al
    jne durable_fail
    incw %si
    incw %di
    loop check_record

    movw $msg_boot2_durable,%si
    call print_string
    cmpb $0,runtime_access_current
    jne stale_fail
    movw $msg_boot2_stale,%si
    call print_string
    movb $1,runtime_access_current
    cmpb $1,runtime_access_current
    jne rebind_fail
    movw $msg_boot2_rebind,%si
    call print_string
    jmp success_exit

boot1:
    # Zero bounded durable sector buffer, then copy six-byte record.
    movw $BUF,%di
    xorw %ax,%ax
    movw $256,%cx
    rep stosw
    movw $durable_record,%si
    movw $BUF,%di
    movw $6,%cx
    rep movsb
    call write_sector2
    jc io_fail
    movw $msg_boot1,%si
    call print_string
    jmp success_exit

read_sector2:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    movw $BUF,%bx
    movb $0x02,%ah
    movb $0x01,%al
    movb $0x00,%ch
    movb $0x02,%cl
    movb $0x00,%dh
    movb boot_drive,%dl
    int $0x13
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret

write_sector2:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    movw $BUF,%bx
    movb $0x03,%ah
    movb $0x01,%al
    movb $0x00,%ch
    movb $0x02,%cl
    movb $0x00,%dh
    movb boot_drive,%dl
    int $0x13
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret

print_string:
    pushw %ax
    pushw %dx
print_loop:
    lodsb
    testb %al,%al
    jz print_done
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    jmp print_loop
print_done:
    popw %dx
    popw %ax
    ret

success_exit:
    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
halt_success:
    hlt
    jmp halt_success

io_fail:
    movw $msg_io_fail,%si
    call print_string
    jmp failure_exit

durable_fail:
    movw $msg_durable_fail,%si
    call print_string
    jmp failure_exit

stale_fail:
    movw $msg_stale_fail,%si
    call print_string
    jmp failure_exit

rebind_fail:
    movw $msg_rebind_fail,%si
    call print_string
    jmp failure_exit

failure_exit:
    movw $EXIT_PORT,%dx
    movb $0x11,%al
    outb %al,%dx
halt_failure:
    hlt
    jmp halt_failure

msg_boot1:         .asciz "BOOT1_INIT=PASS\n"
msg_boot2_durable: .asciz "BOOT2_DURABLE=PASS\n"
msg_boot2_stale:   .asciz "BOOT2_STALE=EXPIRED\n"
msg_boot2_rebind:  .asciz "BOOT2_REBIND=PASS\n"
msg_io_fail:       .asciz "IO=FAIL\n"
msg_durable_fail:  .asciz "BOOT2_DURABLE=FAIL\n"
msg_stale_fail:    .asciz "BOOT2_STALE=FAIL\n"
msg_rebind_fail:   .asciz "BOOT2_REBIND=FAIL\n"

.section .data
boot_drive: .byte 0
runtime_access_current: .byte 0
