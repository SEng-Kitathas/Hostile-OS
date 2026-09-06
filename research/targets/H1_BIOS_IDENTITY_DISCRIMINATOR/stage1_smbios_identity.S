.code16
.section .text
.global _start
.equ TRACE_LBA,257
.equ OUTBUF,0x5000

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp
    movb %dl,boot_drive
    sti

    call clear_out
    movw $header_enter,%si
    call copy_header
    movb boot_drive,%al
    movb %al,OUTBUF+0x10
    call write_out

    # Search the conventional SMBIOS 2.x entry-point area: F0000h-FFFFFh.
    movw $0xf000,%ax
    movw %ax,%ds
    xorw %si,%si
scan_next:
    cmpw $0xffe0,%si
    ja not_found
    cmpw $0x535f,(%si)          # "_S"
    jne advance
    cmpw $0x5f4d,2(%si)         # "M_"
    jne advance
    cmpb $0x1f,5(%si)
    jb advance

    # Validate the SMBIOS entry-point checksum over its advertised length.
    movw %si,%di
    xorw %cx,%cx
    movb 5(%si),%cl
    xorb %al,%al
sum_ep:
    addb (%di),%al
    incw %di
    loop sum_ep
    testb %al,%al
    jnz advance

    # Validate the DMI intermediate anchor and its 15-byte checksum.
    cmpw $0x445f,0x10(%si)      # "_D"
    jne advance
    cmpw $0x494d,0x12(%si)      # "MI"
    jne advance
    cmpb $0x5f,0x14(%si)        # "_"
    jne advance
    movw %si,%di
    addw $0x10,%di
    movw $15,%cx
    xorb %al,%al
sum_dmi:
    addb (%di),%al
    incw %di
    loop sum_dmi
    testb %al,%al
    jnz advance

    movw %si,%bp
    jmp found

advance:
    addw $16,%si
    jnz scan_next

not_found:
    xorw %ax,%ax
    movw %ax,%ds
    call clear_out
    movw $header_not_found,%si
    call copy_header
    movb boot_drive,%al
    movb %al,OUTBUF+0x10
    movb $1,OUTBUF+0x11
    call write_out
    jmp finish

found:
    # DS is still F000h and BP is the entry-point offset. ES remains zero.
    movw %bp,%si
    movb 5(%si),%al
    movb %al,%es:OUTBUF+0x12
    movb 6(%si),%al
    movb %al,%es:OUTBUF+0x13
    movb 7(%si),%al
    movb %al,%es:OUTBUF+0x14
    movb 0x0a(%si),%al
    movb %al,%es:OUTBUF+0x15
    movb 0x1e(%si),%al
    movb %al,%es:OUTBUF+0x16
    movb $1,%es:OUTBUF+0x17
    movw 0x16(%si),%ax
    movw %ax,%es:OUTBUF+0x18
    movw 0x1c(%si),%ax
    movw %ax,%es:OUTBUF+0x1a
    movw 0x18(%si),%ax
    movw %ax,%es:OUTBUF+0x1c
    movw 0x1a(%si),%ax
    movw %ax,%es:OUTBUF+0x1e

    # Preserve the first 32 entry-point bytes verbatim.
    movw %bp,%si
    movw $OUTBUF+0x20,%di
    movw $32,%cx
    rep movsb

    # Switch back to flat low-memory data access and build the final header.
    xorw %ax,%ax
    movw %ax,%ds
    movw $header_ok,%si
    call copy_header
    movb boot_drive,%al
    movb %al,OUTBUF+0x10
    movb $0,OUTBUF+0x11

    # The boot-sector probe only copies a table that is entirely addressable
    # through real-mode segment:offset below 1 MiB.
    movw OUTBUF+0x1e,%dx
    cmpw $0x000f,%dx
    ja table_high
    movw OUTBUF+0x1c,%bx
    movw %bx,%si
    andw $0x000f,%si
    shrw $4,%bx
    shlw $12,%dx
    orw %dx,%bx

    movw OUTBUF+0x18,%cx
    cmpw $448,%cx
    jbe copy_count_ready
    movw $448,%cx
copy_count_ready:
    movw %bx,%ax
    movw %ax,%ds
    movw $OUTBUF+0x40,%di
    rep movsb
    xorw %ax,%ax
    movw %ax,%ds
    call write_out
    jmp finish

table_high:
    movb $2,OUTBUF+0x11
    call write_out
    jmp finish

# ES is permanently zero. clear_out and copy_header require DS=0.
clear_out:
    pushw %ax
    pushw %cx
    pushw %di
    xorw %ax,%ax
    movw $OUTBUF,%di
    movw $256,%cx
    rep stosw
    popw %di
    popw %cx
    popw %ax
    ret

copy_header:
    pushw %ax
    pushw %di
    movw $OUTBUF,%di
copy_header_loop:
    lodsb
    stosb
    testb %al,%al
    jnz copy_header_loop
    popw %di
    popw %ax
    ret

# Direct EDD write. AH=43 to LBA257 is the already-earned H1 evidence path.
# This routine forces DS=0 for the DAP and boot-drive variable.
write_out:
    pushw %ax
    pushw %bx
    pushw %cx
    pushw %dx
    pushw %si
    pushw %ds
    xorw %ax,%ax
    movw %ax,%ds
    movw $write_dap,%si
    movb boot_drive,%dl
    movb $0x43,%ah
    xorb %al,%al
    int $0x13
    popw %ds
    popw %si
    popw %dx
    popw %cx
    popw %bx
    popw %ax
    ret

finish:
#ifdef QEMU_EXIT
    movw $0x00f4,%dx
    movb $0x10,%al
    outb %al,%dx
#endif
halt:
    cli
    hlt
    jmp halt

header_enter: .asciz "H1SMBIOS_ENTER"
header_not_found: .asciz "H1SMBIOS_NONE"
header_ok: .asciz "H1SMBIOS1"
boot_drive: .byte 0
.balign 4
write_dap:
    .byte 0x10,0x00
    .word 0x0001
    .word OUTBUF
    .word 0x0000
    .long TRACE_LBA
    .long 0

.org 510
.word 0xaa55
