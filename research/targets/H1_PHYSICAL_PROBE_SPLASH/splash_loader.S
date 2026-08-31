.code16
.section .text
.global _start

.equ DEBUG_PORT, 0x00e9
.equ PALETTE_LBA, 9
.equ PIXELS_LBA, 10
.equ PIXEL_SECTORS, 125
.equ PROBE_LBA, 135
.equ PROBE_SECTORS, 16

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
    jc disk_fail
    cmpb $1,edd_ok
    jne 1f
    movw $msg_disk_edd,%si
    call debug_string
    jmp 2f
1:  movw $msg_disk_chs,%si
    call debug_string
2:

    # Palette sector -> 0000:5000.
    xorw %ax,%ax
    movw %ax,%es
    movw $0x5000,%bx
    movl $PALETTE_LBA,%eax
    call read_sector
    jc disk_fail
    movw $msg_palette_ok,%si
    call debug_string

    # Finish every disk read before changing video mode. The 64,000-byte
    # frame fits inside one 64 KiB real-mode segment at physical 0x10000.
    movw $0x1000,%ax
    movw %ax,%es
    xorw %bx,%bx
    movl $PIXELS_LBA,%eax
    movw $PIXEL_SECTORS,%cx
stage_pixels_loop:
    call read_sector
    jc disk_fail
    incl %eax
    addw $512,%bx
    loop stage_pixels_loop
    movw $msg_pixels_loaded,%si
    call debug_string

    # Preload the exact qualified probe stage2 too, so no disk BIOS call is
    # required after graphics mode has been entered.
    xorw %ax,%ax
    movw %ax,%es
    movw $0x8000,%bx
    movl $PROBE_LBA,%eax
    movw $PROBE_SECTORS,%cx
preload_probe_loop:
    call read_sector
    jc disk_fail
    incl %eax
    addw $512,%bx
    loop preload_probe_loop
    movw $msg_probe_loaded,%si
    call debug_string

    # Enter VGA mode 13h and program the first 32 DAC entries.
    movw $0x0013,%ax
    int $0x10
    xorw %ax,%ax
    movw %ax,%ds
    movw $0x03c8,%dx
    xorb %al,%al
    outb %al,%dx
    incw %dx
    movw $0x5000,%si
    movw $96,%cx
palette_loop:
    lodsb
    outb %al,%dx
    loop palette_loop

    # Copy the staged 64,000-byte indexed frame to VGA memory.
    movw $0x1000,%ax
    movw %ax,%ds
    xorw %si,%si
    movw $0xa000,%ax
    movw %ax,%es
    xorw %di,%di
    movw $32000,%cx
    rep movsw
    xorw %ax,%ax
    movw %ax,%ds

    movw $msg_visible,%si
    call debug_string
    call splash_delay_or_key

    # Return to text mode before the diagnostic probe starts printing.
    movw $0x0003,%ax
    int $0x10
    xorw %ax,%ax
    movw %ax,%ds

    movw $msg_chain,%si
    call debug_string
    movb boot_drive,%dl
    ljmp $0x0000,$0x8000

# Prefer EDD packet reads when available. For BIOSes that present the USB as a
# floppy-like device, retain a one-sector CHS fallback using AH=08 geometry.
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

# Input: EAX=LBA, ES:BX=destination. One sector only. Preserves caller state.
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

splash_delay_or_key:
    movl 0x046c,%eax
    movl %eax,start_ticks
wait_loop:
    movb $0x01,%ah
    int $0x16
    jnz key_seen
    movl 0x046c,%eax
    subl start_ticks,%eax
    cmpl $55,%eax
    jb wait_loop
    ret
key_seen:
    xorw %ax,%ax
    int $0x16
    ret

disk_fail_video:
    movw $0x0003,%ax
    int $0x10
    xorw %ax,%ax
    movw %ax,%ds

disk_fail:
    movw $msg_fail,%si
    call debug_string
    movw $msg_fail,%si
    call bios_string
1:
    cli
    hlt
    jmp 1b

debug_string:
    pushw %ax
    pushw %dx
2:
    lodsb
    testb %al,%al
    jz 3f
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    jmp 2b
3:
    popw %dx
    popw %ax
    ret

bios_string:
    lodsb
    testb %al,%al
    jz 4f
    movb $0x0e,%ah
    xorw %bx,%bx
    int $0x10
    jmp bios_string
4:
    ret

.section .rodata
msg_disk_edd: .asciz "H1SPLASH_DISK=EDD\r\n"
msg_disk_chs: .asciz "H1SPLASH_DISK=CHS\r\n"
msg_palette_ok: .asciz "H1SPLASH_PALETTE_OK\r\n"
msg_pixels_loaded: .asciz "H1SPLASH_PIXELS_LOADED\r\n"
msg_probe_loaded: .asciz "H1SPLASH_PROBE_LOADED\r\n"
msg_visible: .asciz "H1SPLASH_VISIBLE\r\n"
msg_chain:   .asciz "H1SPLASH_CHAIN_PROBE\r\n"
msg_fail:    .asciz "H1SPLASH_DISK_READ_FAIL\r\n"

.section .data
boot_drive: .byte 0
edd_ok: .byte 0
sectors_per_track: .byte 0
heads_count: .byte 0
chs_sector: .byte 0
.balign 4
lba_temp: .long 0
start_ticks: .long 0
.balign 4
dap:
    .byte 0x10
    .byte 0x00
    .word 0x0001
dap_offset: .word 0
dap_segment: .word 0
dap_lba_low: .long 0
dap_lba_high: .long 0
