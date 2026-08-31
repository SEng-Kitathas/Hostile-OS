.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ PROBE_LBA,9
.equ PROBE_SECTORS,16
.equ LOG_BASE_LBA,256
.equ LOG_SECTORS,128
.equ LOGGER_HOOK_PTR,0x0500
.equ LOG_PAYLOAD_MAX,500

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x5f00,%sp
    sti
    movb %dl,boot_drive

    call detect_disk_mode
    jc disk_fail_unlogged
    call logger_init

    movw $msg_begin,%si
    call print_both
    cmpb $1,edd_ok
    jne 1f
    movw $msg_disk_edd,%si
    call print_both
    jmp 2f
1:  movw $msg_disk_chs,%si
    call print_both
2:

    xorw %ax,%ax
    movw %ax,%es
    movw $0x8000,%bx
    movl $PROBE_LBA,%eax
    movw $PROBE_SECTORS,%cx
load_probe_loop:
    call read_sector
    jc disk_fail
    incl %eax
    addw $512,%bx
    loop load_probe_loop

    movw $msg_probe_loaded,%si
    call print_both
    movw $msg_chain,%si
    call print_both
    call logger_flush
    movb boot_drive,%dl
    ljmp $0x0000,$0x8000

# ---- disk mode ----
detect_disk_mode:
    movb $0,edd_ok
    movb boot_drive,%dl
    movw $0x55aa,%bx
    movb $0x41,%ah
    int $0x13
    jc need_geometry
    cmpw $0xaa55,%bx
    jne need_geometry
    testw $0x0001,%cx
    jz need_geometry
    movb $1,edd_ok
    clc
    ret
need_geometry:
    movb boot_drive,%dl
    movb $0x08,%ah
    int $0x13
    jc detect_fail
    movb %cl,%al
    andb $0x3f,%al
    jz detect_fail
    movb %al,sectors_per_track
    movb %dh,%al
    incb %al
    jz detect_fail
    movb %al,heads_count
    clc
    ret
detect_fail:
    stc
    ret

# Input: EAX=LBA, ES:BX=destination. One sector.
read_sector:
    pushl %eax
    pushl %ecx
    pushl %edx
    pushw %si
    pushw %di
    cmpb $1,edd_ok
    jne read_chs
    movl %eax,dap_lba_low
    movw %bx,dap_offset
    movw %es,%dx
    movw %dx,dap_segment
    movw $dap,%si
    movb boot_drive,%dl
    movb $0x42,%ah
    int $0x13
    jmp read_done
read_chs:
    movl %eax,lba_temp
    xorl %edx,%edx
    movzbl sectors_per_track,%ecx
    divl %ecx
    movb %dl,chs_sector
    incb chs_sector
    xorl %edx,%edx
    movzbl heads_count,%ecx
    divl %ecx
    movb %al,%ch
    movb chs_sector,%cl
    movb %dl,%dh
    movb boot_drive,%dl
    movb $0x02,%ah
    movb $0x01,%al
    int $0x13
read_done:
    popw %di
    popw %si
    popl %edx
    popl %ecx
    popl %eax
    ret

# Input: EAX=LBA, ES:BX=source. One sector. Only logger calls this.
write_sector:
    pushl %eax
    pushl %ecx
    pushl %edx
    pushw %si
    pushw %di
    cmpb $1,edd_ok
    jne write_chs
    movl %eax,dap_lba_low
    movw %bx,dap_offset
    movw %es,%dx
    movw %dx,dap_segment
    movw $dap,%si
    movb boot_drive,%dl
    movb $0x43,%ah
    xorb %al,%al
    int $0x13
    jmp write_done
write_chs:
    movl %eax,lba_temp
    xorl %edx,%edx
    movzbl sectors_per_track,%ecx
    divl %ecx
    movb %dl,chs_sector
    incb chs_sector
    xorl %edx,%edx
    movzbl heads_count,%ecx
    divl %ecx
    movb %al,%ch
    movb chs_sector,%cl
    movb %dl,%dh
    movb boot_drive,%dl
    movb $0x03,%ah
    movb $0x01,%al
    int $0x13
write_done:
    popw %di
    popw %si
    popl %edx
    popl %ecx
    popl %eax
    ret

# ---- persistent logger at 0000:6xxx ----
logger_init:
    movb $1,log_enabled
    movw $0,log_seq
    movw $0,log_len
    movw 0x046c,%ax
    movw %ax,log_session
    movw $logger_char,LOGGER_HOOK_PTR
    ret

# Entry from wrapper print path and probe hook. Input AL=character.
# Preserves flags, general registers, DS and ES.
logger_char:
    pushf
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    pushw %si
    pushw %di
    pushw %ds
    pushw %es
    xorw %dx,%dx
    movw %dx,%ds
    cmpb $1,log_enabled
    jne logger_char_done
    movw log_len,%bx
    cmpw $LOG_PAYLOAD_MAX,%bx
    jb logger_store
    call logger_flush
    cmpb $1,log_enabled
    jne logger_char_done
    xorw %bx,%bx
logger_store:
    movb %al,log_buffer+12(%bx)
    incw %bx
    movw %bx,log_len
    cmpb $0x0a,%al
    jne logger_char_done
    call logger_flush
logger_char_done:
    popw %es
    popw %ds
    popw %di
    popw %si
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    popf
    ret

logger_flush:
    pushf
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    pushw %si
    pushw %di
    pushw %ds
    pushw %es
    xorw %dx,%dx
    movw %dx,%ds
    cmpb $1,log_enabled
    jne logger_flush_done
    cmpw $0,log_len
    je logger_flush_done
    movw log_seq,%ax
    cmpw $LOG_SECTORS,%ax
    jb logger_space_ok
    movb $0,log_enabled
    jmp logger_flush_done
logger_space_ok:
    movl $0x474c3148,log_buffer
    movw $1,log_buffer+4
    movw log_session,%dx
    movw %dx,log_buffer+6
    movw log_seq,%dx
    movw %dx,log_buffer+8
    movw log_len,%dx
    movw %dx,log_buffer+10
    movzwl log_seq,%eax
    addl $LOG_BASE_LBA,%eax
    xorw %dx,%dx
    movw %dx,%es
    movw $log_buffer,%bx
    call write_sector
    jc logger_write_fail
    incw log_seq
    movw $0,log_len
    jmp logger_flush_done
logger_write_fail:
    movb $0,log_enabled
logger_flush_done:
    popw %es
    popw %ds
    popw %di
    popw %si
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    popf
    ret

# ---- output ----
print_both:
    pushw %ax
    pushw %bx
    pushw %dx
print_both_loop:
    lodsb
    testb %al,%al
    jz print_both_done
    call logger_char
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    movb $0x0e,%ah
    xorw %bx,%bx
    int $0x10
    jmp print_both_loop
print_both_done:
    popw %dx
    popw %bx
    popw %ax
    ret

disk_fail:
    movw $msg_fail,%si
    call print_both
    call logger_flush
    jmp halt_forever

disk_fail_unlogged:
    movw $msg_fail_detect,%si
    call bios_debug_string
halt_forever:
    cli
    hlt
    jmp halt_forever

bios_debug_string:
    lodsb
    testb %al,%al
    jz 1f
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    movb $0x0e,%ah
    xorw %bx,%bx
    int $0x10
    jmp bios_debug_string
1:  ret

.section .rodata
msg_begin:        .asciz "H1LOG_BEGIN\r\n"
msg_disk_edd:     .asciz "H1LOG_DISK=EDD\r\n"
msg_disk_chs:     .asciz "H1LOG_DISK=CHS\r\n"
msg_probe_loaded: .asciz "H1LOG_PROBE_LOADED\r\n"
msg_chain:        .asciz "H1LOG_CHAIN_PROBE\r\n"
msg_fail:         .asciz "H1LOG_PROBE_READ_FAIL\r\n"
msg_fail_detect:  .asciz "H1LOG_DISK_DETECT_FAIL\r\n"

.section .data
boot_drive: .byte 0
edd_ok: .byte 0
sectors_per_track: .byte 0
heads_count: .byte 0
chs_sector: .byte 0
log_enabled: .byte 0
.balign 2
log_session: .word 0
log_seq: .word 0
log_len: .word 0
.balign 4
lba_temp: .long 0
.balign 4
dap:
    .byte 0x10
    .byte 0x00
    .word 0x0001
dap_offset: .word 0
dap_segment: .word 0
dap_lba_low: .long 0
dap_lba_high: .long 0
.balign 16
log_buffer: .space 512
