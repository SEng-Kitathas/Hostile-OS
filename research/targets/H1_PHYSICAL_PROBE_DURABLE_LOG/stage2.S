.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ QEMU_EXIT_PORT,0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7a00,%sp
    sti
    movb %dl,boot_drive

    movw $msg_begin,%si
    call print_string

    call probe_cpuid
    call probe_boot
    call probe_firmware
    call probe_irq
    call probe_e820
    call probe_pci

    movw $msg_end,%si
    call print_string
#ifdef QEMU_EXIT
    movw $QEMU_EXIT_PORT,%dx
    movb $0x21,%al
    outb %al,%dx
#endif
halt_forever:
    cli
    hlt
    jmp halt_forever

/* ---------------- output ---------------- */
putc:
    pushl %eax
    pushl %ebx
    pushl %edx
    call *0x0500
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    movb $0x0e,%ah
    movb $0x00,%bh
    movb $0x07,%bl
    int $0x10
    popl %edx
    popl %ebx
    popl %eax
    ret

print_string:
    lodsb
    testb %al,%al
    jz 1f
    call putc
    jmp print_string
1:  ret

print_nibble:
    andb $0x0f,%al
    cmpb $9,%al
    jbe 1f
    addb $('A'-10),%al
    jmp 2f
1:  addb $'0',%al
2:  call putc
    ret

print_hex8:
    pushl %eax
    pushl %ebx
    pushw %cx
    movb %al,%bl
    movw $2,%cx
1:  rolb $4,%bl
    movb %bl,%al
    call print_nibble
    loop 1b
    popw %cx
    popl %ebx
    popl %eax
    ret

print_hex16:
    pushl %eax
    pushl %ebx
    pushw %cx
    movw %ax,%bx
    movw $4,%cx
1:  rolw $4,%bx
    movb %bl,%al
    call print_nibble
    loop 1b
    popw %cx
    popl %ebx
    popl %eax
    ret

print_hex32:
    pushl %eax
    pushl %ebx
    pushw %cx
    movl %eax,%ebx
    movw $8,%cx
1:  roll $4,%ebx
    movb %bl,%al
    call print_nibble
    loop 1b
    popw %cx
    popl %ebx
    popl %eax
    ret

/* ---------------- CPUID ---------------- */
probe_cpuid:
    xorl %eax,%eax
    cpuid
    movl %eax,cpuid_max
    movl %ebx,vendor_buf
    movl %edx,vendor_buf+4
    movl %ecx,vendor_buf+8

    movw $msg_cpu_vendor,%si
    call print_string
    movw $vendor_buf,%si
    call print_string
    movw $msg_cpu_max,%si
    call print_string
    movl cpuid_max,%eax
    call print_hex32
    movw $msg_crlf,%si
    call print_string

    cmpl $1,cpuid_max
    jb cpuid_no_leaf1
    movl $1,%eax
    cpuid
    movl %eax,cpuid1_eax
    movl %ebx,cpuid1_ebx
    movl %ecx,cpuid1_ecx
    movl %edx,cpuid1_edx

    movw $msg_cpu_l1,%si
    call print_string
    movl cpuid1_eax,%eax
    call print_hex32
    movw $msg_bx,%si
    call print_string
    movl cpuid1_ebx,%eax
    call print_hex32
    movw $msg_cx,%si
    call print_string
    movl cpuid1_ecx,%eax
    call print_hex32
    movw $msg_dx,%si
    call print_string
    movl cpuid1_edx,%eax
    call print_hex32
    movw $msg_crlf,%si
    call print_string

    movl cpuid1_eax,%eax
    movb %al,%bl
    andb $0x0f,%bl
    movb %bl,cpu_stepping
    shrl $4,%eax
    movb %al,%bl
    andb $0x0f,%bl
    movb %bl,cpu_model
    shrl $4,%eax
    movb %al,%bl
    andb $0x0f,%bl
    movb %bl,cpu_family

    movl cpuid1_eax,%eax
    shrl $16,%eax
    andb $0x0f,%al
    movb %al,cpu_ext_model
    movl cpuid1_eax,%eax
    shrl $20,%eax
    andb $0xff,%al
    movb %al,cpu_ext_family

    movb cpu_family,%al
    cmpb $0x0f,%al
    jne 1f
    addb cpu_ext_family,%al
    movb %al,cpu_family
1:
    movl cpuid1_eax,%eax
    shrl $8,%eax
    andb $0x0f,%al
    cmpb $0x06,%al
    je 2f
    cmpb $0x0f,%al
    jne 3f
2:
    movb cpu_ext_model,%al
    shlb $4,%al
    addb %al,cpu_model
3:
    movl cpuid1_ebx,%eax
    shrl $16,%eax
    movb %al,cpu_logical
    movl cpuid1_edx,%eax
    shrl $9,%eax
    andb $1,%al
    movb %al,cpu_apic
    movl cpuid1_edx,%eax
    shrl $5,%eax
    andb $1,%al
    movb %al,cpu_msr

    movw $msg_cpu_dec,%si
    call print_string
    movb cpu_family,%al
    call print_hex8
    movw $msg_model,%si
    call print_string
    movb cpu_model,%al
    call print_hex8
    movw $msg_step,%si
    call print_string
    movb cpu_stepping,%al
    call print_hex8
    movw $msg_logical,%si
    call print_string
    movb cpu_logical,%al
    call print_hex8
    movw $msg_apic,%si
    call print_string
    movb cpu_apic,%al
    call print_hex8
    movw $msg_msr,%si
    call print_string
    movb cpu_msr,%al
    call print_hex8
    movw $msg_crlf,%si
    call print_string
    ret

cpuid_no_leaf1:
    movw $msg_cpu_no_l1,%si
    call print_string
    ret

/* ---------------- boot / INT13 ---------------- */
probe_boot:
    movw $msg_boot_drive,%si
    call print_string
    movb boot_drive,%al
    call print_hex8
    movw $msg_crlf,%si
    call print_string

    movb boot_drive,%dl
    movb $0x08,%ah
    int $0x13
    jc boot_geom_fail
    movb %ch,geom_ch
    movb %cl,geom_cl
    movb %dh,geom_dh
    movb %dl,geom_dl
    movw $msg_boot_geom,%si
    call print_string
    movb geom_ch,%al
    call print_hex8
    movw $msg_cl,%si
    call print_string
    movb geom_cl,%al
    call print_hex8
    movw $msg_dh,%si
    call print_string
    movb geom_dh,%al
    call print_hex8
    movw $msg_dl,%si
    call print_string
    movb geom_dl,%al
    call print_hex8
    movw $msg_crlf,%si
    call print_string
    jmp boot_ext
boot_geom_fail:
    movw $msg_boot_geom_fail,%si
    call print_string

boot_ext:
    movb boot_drive,%dl
    movw $0x55aa,%bx
    movb $0x41,%ah
    int $0x13
    jc boot_ext_fail
    cmpw $0xaa55,%bx
    jne boot_ext_fail
    movw %cx,boot_ext_cx
    movw $msg_boot_ext,%si
    call print_string
    movw boot_ext_cx,%ax
    call print_hex16
    movw $msg_crlf,%si
    call print_string
    ret
boot_ext_fail:
    movw $msg_boot_ext_fail,%si
    call print_string
    ret

/* ---------------- IRQ/APIC read-only facts ---------------- */
probe_irq:
    movw $0x21,%dx
    inb %dx,%al
    movb %al,pic1_mask
    movw $0xa1,%dx
    inb %dx,%al
    movb %al,pic2_mask
    movw $msg_irq_pic,%si
    call print_string
    movb pic1_mask,%al
    call print_hex8
    movw $msg_slash,%si
    call print_string
    movb pic2_mask,%al
    call print_hex8
    movw $msg_crlf,%si
    call print_string

    movw $msg_irq_cap,%si
    call print_string
    movb cpu_apic,%al
    call print_hex8
    movw $msg_msr,%si
    call print_string
    movb cpu_msr,%al
    call print_hex8
    movw $msg_crlf,%si
    call print_string

    cmpb $1,cpu_apic
    jne irq_no_base
    cmpb $1,cpu_msr
    jne irq_no_base
    movl $0x1b,%ecx
    rdmsr
    movl %eax,apic_base_lo
    movl %edx,apic_base_hi
    movw $msg_irq_base,%si
    call print_string
    movl apic_base_hi,%eax
    call print_hex32
    movl apic_base_lo,%eax
    call print_hex32
    movw $msg_crlf,%si
    call print_string
    ret
irq_no_base:
    movw $msg_irq_base_na,%si
    call print_string
    ret


/* ---------------- firmware / ACPI root read-only facts ---------------- */
probe_firmware:
    movw 0x040e,%ax
    movw %ax,ebda_seg
    movw $msg_fw_ebda,%si
    call print_string
    movw ebda_seg,%ax
    call print_hex16
    movw $msg_crlf,%si
    call print_string

    movw ebda_seg,%bx
    testw %bx,%bx
    jz fw_scan_high
    movw $64,%cx
fw_scan_ebda:
    movw %bx,%ax
    call rsdp_check_segment
    jc fw_rsdp_found_bx
    incw %bx
    loop fw_scan_ebda

fw_scan_high:
    movw $0xe000,%bx
    movw $8192,%cx
fw_scan_high_loop:
    movw %bx,%ax
    call rsdp_check_segment
    jc fw_rsdp_found_bx
    incw %bx
    loop fw_scan_high_loop
    movw $msg_fw_rsdp_none,%si
    call print_string
    ret

fw_rsdp_found_bx:
    movw %bx,rsdp_seg
    movzwl %bx,%eax
    shll $4,%eax
    movl %eax,rsdp_phys

    pushw %ds
    movw %bx,%ax
    movw %ax,%ds
    movb 15, %al
    movb %al,%cs:rsdp_rev
    movl 16, %eax
    movl %eax,%cs:rsdp_rsdt
    cmpb $2,15
    jb 1f
    movl 24,%eax
    movl %eax,%cs:rsdp_xsdt_lo
    movl 28,%eax
    movl %eax,%cs:rsdp_xsdt_hi
1:  popw %ds

    movw $msg_fw_rsdp,%si
    call print_string
    movl rsdp_phys,%eax
    call print_hex32
    movw $msg_rev,%si
    call print_string
    movb rsdp_rev,%al
    call print_hex8
    movw $msg_rsdt,%si
    call print_string
    movl rsdp_rsdt,%eax
    call print_hex32
    movw $msg_xsdt,%si
    call print_string
    movl rsdp_xsdt_hi,%eax
    call print_hex32
    movl rsdp_xsdt_lo,%eax
    call print_hex32
    movw $msg_crlf,%si
    call print_string
    ret

rsdp_check_segment:
    pushw %ds
    movw %ax,%ds
    cmpb $'R',0
    jne 9f
    cmpb $'S',1
    jne 9f
    cmpb $'D',2
    jne 9f
    cmpb $' ',3
    jne 9f
    cmpb $'P',4
    jne 9f
    cmpb $'T',5
    jne 9f
    cmpb $'R',6
    jne 9f
    cmpb $' ',7
    jne 9f
    popw %ds
    stc
    ret
9:  popw %ds
    clc
    ret

/* ---------------- BIOS E820 ---------------- */
probe_e820:
    xorw %ax,%ax
    movw %ax,%es
    xorl %ebx,%ebx
    movb $0,e820_count
    movw $msg_e820_begin,%si
    call print_string

e820_next:
    cmpb $32,e820_count
    jae e820_truncated
    movw $e820_buf,%di
    movl $0xe820,%eax
    movl $0x534d4150,%edx
    movl $24,%ecx
    int $0x15
    jc e820_bios_end
    cmpl $0x534d4150,%eax
    jne e820_bad_sig

    movw $msg_e820_entry,%si
    call print_string
    movb e820_count,%al
    call print_hex8
    movw $msg_base,%si
    call print_string
    movl e820_buf+4,%eax
    call print_hex32
    movl e820_buf,%eax
    call print_hex32
    movw $msg_len,%si
    call print_string
    movl e820_buf+12,%eax
    call print_hex32
    movl e820_buf+8,%eax
    call print_hex32
    movw $msg_type,%si
    call print_string
    movl e820_buf+16,%eax
    call print_hex32
    movw $msg_crlf,%si
    call print_string

    incb e820_count
    testl %ebx,%ebx
    jnz e820_next
    movw $msg_e820_end,%si
    call print_string
    ret

e820_bios_end:
    cmpb $0,e820_count
    jne e820_normal_cf_end
    movw $msg_e820_fail,%si
    call print_string
    ret
e820_normal_cf_end:
    movw $msg_e820_cf_end,%si
    call print_string
    ret
e820_bad_sig:
    movw $msg_e820_bad_sig,%si
    call print_string
    ret
e820_truncated:
    movw $msg_e820_trunc,%si
    call print_string
    ret

/* ---------------- PCI config mechanism #1, read-only ---------------- */
probe_pci:
    movw $msg_pci_begin,%si
    call print_string
    movw $0,pci_bus
pci_bus_loop:
    cmpw $256,pci_bus
    jae pci_done
    movb $0,pci_dev
pci_dev_loop:
    cmpb $32,pci_dev
    jae pci_next_bus
    movb $0,pci_fn
pci_fn_loop:
    cmpb $8,pci_fn
    jae pci_next_dev

    movb $0x00,pci_off
    call pci_read32
    movl %eax,pci_id
    cmpw $0xffff,%ax
    je pci_next_fn

    movb $0x08,pci_off
    call pci_read32
    movl %eax,pci_class
    movb $0x0c,pci_off
    call pci_read32
    movl %eax,pci_hdr

    movw $msg_pci,%si
    call print_string
    movw pci_bus,%ax
    call print_hex8
    movb $':',%al
    call putc
    movb pci_dev,%al
    call print_hex8
    movb $'.',%al
    call putc
    movb pci_fn,%al
    call print_hex8

    movw $msg_id,%si
    call print_string
    movw pci_id,%ax
    call print_hex16
    movb $':',%al
    call putc
    movl pci_id,%eax
    shrl $16,%eax
    call print_hex16

    movw $msg_class,%si
    call print_string
    movl pci_class,%eax
    shrl $24,%eax
    call print_hex8
    movb $'/',%al
    call putc
    movl pci_class,%eax
    shrl $16,%eax
    call print_hex8
    movb $'/',%al
    call putc
    movl pci_class,%eax
    shrl $8,%eax
    call print_hex8

    movw $msg_hdr,%si
    call print_string
    movl pci_hdr,%eax
    shrl $16,%eax
    call print_hex8

    movl pci_hdr,%eax
    shrl $16,%eax
    andb $0x7f,%al
    cmpb $0,%al
    je pci_bars6
    cmpb $1,%al
    je pci_bars2
    movb $0,pci_bar_count
    jmp pci_bar_loop_init
pci_bars6:
    movb $6,pci_bar_count
    jmp pci_bar_loop_init
pci_bars2:
    movb $2,pci_bar_count
pci_bar_loop_init:
    movb $0,pci_bar_idx
pci_bar_loop:
    movb pci_bar_idx,%al
    cmpb pci_bar_count,%al
    jae pci_line_end
    movw $msg_bar,%si
    call print_string
    movb pci_bar_idx,%al
    call print_hex8
    movb $'=',%al
    call putc
    movb pci_bar_idx,%al
    shlb $2,%al
    addb $0x10,%al
    movb %al,pci_off
    call pci_read32
    call print_hex32
    incb pci_bar_idx
    jmp pci_bar_loop
pci_line_end:
    movw $msg_crlf,%si
    call print_string

pci_next_fn:
    incb pci_fn
    jmp pci_fn_loop
pci_next_dev:
    incb pci_dev
    jmp pci_dev_loop
pci_next_bus:
    incw pci_bus
    jmp pci_bus_loop
pci_done:
    movw $msg_pci_end,%si
    call print_string
    ret

pci_read32:
    pushl %ecx
    pushl %edx
    movzwl pci_bus,%eax
    shll $16,%eax
    movzbl pci_dev,%ecx
    shll $11,%ecx
    orl %ecx,%eax
    movzbl pci_fn,%ecx
    shll $8,%ecx
    orl %ecx,%eax
    movzbl pci_off,%ecx
    andl $0xfc,%ecx
    orl %ecx,%eax
    orl $0x80000000,%eax
    movw $0xcf8,%dx
    outl %eax,%dx
    movw $0xcfc,%dx
    inl %dx,%eax
    popl %edx
    popl %ecx
    ret

.section .rodata
msg_begin: .asciz "H1PROBE_BEGIN\r\n"
msg_end: .asciz "H1PROBE_END\r\n"
msg_crlf: .asciz "\r\n"
msg_slash: .asciz "/"
msg_cpu_vendor: .asciz "CPU_VENDOR="
msg_cpu_max: .asciz " CPU_MAX="
msg_cpu_l1: .asciz "CPU_L1 EAX="
msg_bx: .asciz " EBX="
msg_cx: .asciz " ECX="
msg_dx: .asciz " EDX="
msg_cpu_dec: .asciz "CPU_DEC family="
msg_model: .asciz " model="
msg_step: .asciz " stepping="
msg_logical: .asciz " logical="
msg_apic: .asciz " apic="
msg_msr: .asciz " msr="
msg_cpu_no_l1: .asciz "CPU_L1=UNAVAILABLE\r\n"
msg_cpu_none: .asciz "CPU_CPUID=UNAVAILABLE\r\n"
msg_boot_drive: .asciz "BOOT_DRIVE="
msg_boot_geom: .asciz "BOOT_GEOM CH="
msg_cl: .asciz " CL="
msg_dh: .asciz " DH="
msg_dl: .asciz " DL="
msg_boot_geom_fail: .asciz "BOOT_GEOM=ERROR\r\n"
msg_boot_ext: .asciz "BOOT_EXT CX="
msg_boot_ext_fail: .asciz "BOOT_EXT=NO\r\n"
msg_fw_ebda: .asciz "FW_EBDA="
msg_fw_rsdp: .asciz "FW_RSDP="
msg_fw_rsdp_none: .asciz "FW_RSDP=NOT_FOUND\r\n"
msg_rev: .asciz " rev="
msg_rsdt: .asciz " rsdt="
msg_xsdt: .asciz " xsdt="
msg_irq_pic: .asciz "IRQ_PIC_MASK="
msg_irq_cap: .asciz "IRQ_CAP apic="
msg_irq_base: .asciz "IRQ_APIC_BASE="
msg_irq_base_na: .asciz "IRQ_APIC_BASE=NA\r\n"
msg_e820_begin: .asciz "E820_BEGIN\r\n"
msg_e820_entry: .asciz "E820 i="
msg_base: .asciz " base="
msg_len: .asciz " len="
msg_type: .asciz " type="
msg_e820_end: .asciz "E820_END NORMAL\r\n"
msg_e820_cf_end: .asciz "E820_END CF_AFTER_ENTRIES\r\n"
msg_e820_fail: .asciz "E820_ERROR FIRST_CALL\r\n"
msg_e820_bad_sig: .asciz "E820_ERROR BAD_SIGNATURE\r\n"
msg_e820_trunc: .asciz "E820_TRUNCATED limit=20h\r\n"
msg_pci_begin: .asciz "PCI_BEGIN\r\n"
msg_pci: .asciz "PCI "
msg_id: .asciz " id="
msg_class: .asciz " class="
msg_hdr: .asciz " hdr="
msg_bar: .asciz " b"
msg_pci_end: .asciz "PCI_END\r\n"

.section .data
boot_drive: .byte 0
geom_ch: .byte 0
geom_cl: .byte 0
geom_dh: .byte 0
geom_dl: .byte 0
boot_ext_cx: .word 0
ebda_seg: .word 0
rsdp_seg: .word 0
rsdp_phys: .long 0
rsdp_rev: .byte 0
.balign 4
rsdp_rsdt: .long 0
rsdp_xsdt_lo: .long 0
rsdp_xsdt_hi: .long 0
pic1_mask: .byte 0
pic2_mask: .byte 0
cpuid_max: .long 0
cpuid1_eax: .long 0
cpuid1_ebx: .long 0
cpuid1_ecx: .long 0
cpuid1_edx: .long 0
cpu_family: .byte 0
cpu_model: .byte 0
cpu_stepping: .byte 0
cpu_ext_model: .byte 0
cpu_ext_family: .byte 0
cpu_logical: .byte 0
cpu_apic: .byte 0
cpu_msr: .byte 0
apic_base_lo: .long 0
apic_base_hi: .long 0
vendor_buf: .space 12
vendor_zero: .byte 0
.balign 4
e820_buf: .space 24
e820_count: .byte 0
pci_bus: .word 0
pci_dev: .byte 0
pci_fn: .byte 0
pci_off: .byte 0
pci_bar_idx: .byte 0
pci_bar_count: .byte 0
.balign 4
pci_id: .long 0
pci_class: .long 0
pci_hdr: .long 0
