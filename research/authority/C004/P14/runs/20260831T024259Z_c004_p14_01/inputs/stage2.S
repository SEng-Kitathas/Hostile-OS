.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ KCODE,0x08
.equ KDATA,0x10
.equ UCODE,0x18
.equ UDATA,0x20
.equ TSSSEL,0x28
.equ USER_BASE,0x00020000
.equ USER_STACK,0x0000f000

_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7a00,%sp
 lgdt gdt_desc
 movl %cr0,%eax
 orl $1,%eax
 movl %eax,%cr0
 # 16:16 far jump is sufficient because pm_entry is below 64 KiB linear.
 .byte 0xea
 .word pm_entry
 .word KCODE

.code32
pm_entry:
 movw $KDATA,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movl $0x00007a00,%esp
 cld
 # Zero IDT + TSS backing memory explicitly.
 xorl %eax,%eax
 movl $idt,%edi
 movl $512,%ecx
 rep stosl
 movl $tss,%edi
 movl $26,%ecx
 rep stosl
 movl $0x00007a00,tss+4
 movw $KDATA,tss+8
 # Fill TSS descriptor base at runtime.
 movw $0x0067,gdt_tss+0
 movl $tss,%eax
 movw %ax,gdt_tss+2
 shrl $16,%eax
 movb %al,gdt_tss+4
 movb $0x89,gdt_tss+5
 movb $0x00,gdt_tss+6
 movb %ah,gdt_tss+7
 movw $TSSSEL,%ax
 ltr %ax
 # #GP gate vector 13, ring0 only.
 movl $gp_handler,%eax
 movl $(idt+13*8),%edi
 movb $0x8e,%dl
 call set_gate
 # Explicit ring3 -> ring0 mediated gate vector 0x30, DPL3.
 movl $mediated_handler,%eax
 movl $(idt+0x30*8),%edi
 movb $0xee,%dl
 call set_gate
 lidt idt_desc
 # Copy tiny untrusted code blob into its separate 64 KiB user segment.
 movl $user_blob_start,%esi
 movl $USER_BASE,%edi
 movl $(user_blob_end-user_blob_start),%ecx
 rep movsb
 movb $0x7e,resource_value
 movb $0,gp_seen
 movl $lab_test,%esi
 call pm_puts
 # Enter CPL3. User code first attempts to load ring0 writable selector.
 pushl $(UDATA|3)
 pushl $USER_STACK
 pushfl
 pushl $(UCODE|3)
 pushl $0
 iret

set_gate:
 # EAX=handler linear, EDI=entry, DL=attributes.
 movw %ax,0(%edi)
 movw $KCODE,2(%edi)
 movb $0,4(%edi)
 movb %dl,5(%edi)
 shrl $16,%eax
 movw %ax,6(%edi)
 ret

# CPU enters here on ring3's forbidden KDATA selector load.
gp_handler:
 cli
 pushl %eax
 movw $KDATA,%ax
 movw %ax,%ds
 movw %ax,%es
 movb $1,gp_seen
 # With pushed EAX: [esp+4]=error, [esp+8]=saved EIP.
 movl $(user_after_fault-user_blob_start),8(%esp)
 popl %eax
 addl $4,%esp
 iret

# Protected finite authority table: two occupied records. EAX0 good allocate C,
# EAX1 bad overwrite-on-full, EAX2 done.
mediated_handler:
 cli
 movw $KDATA,%dx
 movw %dx,%ds
 movw %dx,%es
 cmpl $0,%eax
 je good_alloc
 cmpl $1,%eax
 je bad_alloc
 cmpl $2,%eax
 je mediated_done
 jmp mediated_return
good_alloc:
 cmpb $0,authority_owner
 je good_use0
 cmpb $0,authority_owner+1
 je good_use1
 movb $'F',%al
 jmp good_print
good_use0:
 movb $0x43,authority_owner
 movb $1,authority_rights
 movb $'W',%al
 jmp good_print
good_use1:
 movb $0x43,authority_owner+1
 movb $1,authority_rights+1
 movb $'W',%al
good_print:
 movl $lab_good,%esi
 call pm_puts
 call pm_putc
 call pm_nl
 movl $lab_good0,%esi
 call pm_puts
 movb authority_owner,%al
 call pm_hex8
 call pm_nl
 movl $lab_good1,%esi
 call pm_puts
 movb authority_owner+1,%al
 call pm_hex8
 call pm_nl
 jmp mediated_return
bad_alloc:
 movb $0x43,authority_owner
 movb $1,authority_rights
 movb $'W',%al
 movl $lab_bad,%esi
 call pm_puts
 call pm_putc
 call pm_nl
 movl $lab_bad0,%esi
 call pm_puts
 movb authority_owner,%al
 call pm_hex8
 call pm_nl
 movl $lab_bad1,%esi
 call pm_puts
 movb authority_owner+1,%al
 call pm_hex8
 call pm_nl
 jmp mediated_return
mediated_done:
 movl $lab_gp,%esi
 call pm_puts
 movb gp_seen,%al
 call pm_bit
 call pm_nl
 movl $lab_done,%esi
 call pm_puts
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
mediated_return:
 iret

pm_puts:
 pushl %eax
 pushl %edx
2: lodsb
 testb %al,%al
 jz 3f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp 2b
3: popl %edx
 popl %eax
 ret
pm_bit:
 andb $1,%al
 addb $'0',%al
 jmp pm_putc
pm_putc:
 pushl %edx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popl %edx
 ret
pm_nl:
 pushl %eax
 movb $'\n',%al
 call pm_putc
 popl %eax
 ret
pm_hex8:
 pushl %eax
 movb %al,%ah
 shrb $4,%al
 call pm_nibble
 movb %ah,%al
 andb $0x0f,%al
 call pm_nibble
 popl %eax
 ret
pm_nibble:
 cmpb $9,%al
 jbe 4f
 addb $('A'-10),%al
 jmp pm_putc
4: addb $'0',%al
 jmp pm_putc

# Ring3 B proves boundary then requests C allocation in full table.
user_blob_start:
 movw $KDATA,%ax
user_fault_site:
 movw %ax,%ds
user_after_fault:
 movl $0,%eax
 int $0x30
 movl $1,%eax
 int $0x30
 movl $2,%eax
 int $0x30
5: jmp 5b
user_blob_end:

.section .rodata
lab_test:.asciz "TEST=C004_P14\n"
lab_good:.asciz "GOOD_FULL="
lab_good0:.asciz "GOOD_OWNER0="
lab_good1:.asciz "GOOD_OWNER1="
lab_bad:.asciz "BAD_ALLOC="
lab_bad0:.asciz "BAD_OWNER0="
lab_bad1:.asciz "BAD_OWNER1="
lab_gp:.asciz "GP_SEEN="
lab_done:.asciz "DONE\n"

.section .data
.align 8
gdt:
 .quad 0
 # ring0 flat code
 .word 0xffff,0x0000
 .byte 0x00,0x9a,0xcf,0x00
 # ring0 flat data
 .word 0xffff,0x0000
 .byte 0x00,0x92,0xcf,0x00
 # ring3 code: base 0x20000, 64 KiB byte-granular, 32-bit
 .word 0xffff,0x0000
 .byte 0x02,0xfa,0x40,0x00
 # ring3 data: same bounded region
 .word 0xffff,0x0000
 .byte 0x02,0xf2,0x40,0x00
gdt_tss:
 .quad 0
gdt_end:
gdt_desc:
 .word gdt_end-gdt-1
 .long gdt
idt_desc:
 .word 2047
 .long idt
resource_value:.byte 0x7e
gp_seen:.byte 0
authority_owner:.byte 0x41,0x42
authority_rights:.byte 3,1

.section .bss
.align 8
idt:.space 2048,0
.align 16
tss:.space 104,0
