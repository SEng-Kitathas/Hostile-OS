.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ PROBE_LBA,9
.equ PROBE_SECTORS,16

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x5f00,%sp
    sti
    movb %dl,boot_drive

    movw $msg_begin,%si
    call print_both

    call detect_disk_mode
    jc disk_fail
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

    movw $msg_ok,%si
    call print_both
    movw $msg_chain,%si
    call print_both
    movb boot_drive,%dl
    ljmp $0x0000,$0x8000

# Prefer EDD packet reads when available. For BIOSes that present USB as a
# floppy-like device, use one-sector CHS fallback based on AH=08 geometry.
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

# Input: EAX=LBA, ES:BX=destination. One sector only.
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

disk_fail:
    movw $msg_fail,%si
    call print_both
1:
    cli
    hlt
    jmp 1b

print_both:
    pushw %ax
    pushw %bx
    pushw %dx
2:
    lodsb
    testb %al,%al
    jz 3f
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    movb $0x0e,%ah
    xorw %bx,%bx
    int $0x10
    jmp 2b
3:
    popw %dx
    popw %bx
    popw %ax
    ret

.section .rodata
msg_begin:    .asciz "H1TEXT_BEGIN\r\n"
msg_disk_edd: .asciz "H1TEXT_DISK=EDD\r\n"
msg_disk_chs: .asciz "H1TEXT_DISK=CHS\r\n"
msg_ok:       .asciz "H1TEXT_WRAPPER_OK\r\n"
msg_chain:    .asciz "H1TEXT_CHAIN_PROBE\r\n"
msg_fail:     .asciz "H1TEXT_DISK_READ_FAIL\r\n"

.section .data
boot_drive: .byte 0
edd_ok: .byte 0
sectors_per_track: .byte 0
heads_count: .byte 0
chs_sector: .byte 0
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
