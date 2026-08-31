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
 xorl %eax,%eax
 movl $idt,%edi
 movl $512,%ecx
 rep stosl
 movl $tss,%edi
 movl $26,%ecx
 rep stosl
 movl $0x00007a00,tss+4
 movw $KDATA,tss+8
 movw $0x0067,gdt_tss+0
 movl $tss,%eax
 movw %ax,gdt_tss+2
 shrl $16,%eax
 movb %al,gdt_tss+4
 movb $0x89,gdt_tss+5
 movb $0,gdt_tss+6
 movb %ah,gdt_tss+7
 movw $TSSSEL,%ax
 ltr %ax
 movl $gp_handler,%eax
 movl $(idt+13*8),%edi
 movb $0x8e,%dl
 call set_gate
 movl $mediated_handler,%eax
 movl $(idt+0x30*8),%edi
 movb $0xee,%dl
 call set_gate
 lidt idt_desc
 movl $user_blob_start,%esi
 movl $USER_BASE,%edi
 movl $(user_blob_end-user_blob_start),%ecx
 rep movsb
 movl $lab_test,%esi
 call pm_puts
 pushl $(UDATA|3)
 pushl $USER_STACK
 pushfl
 pushl $(UCODE|3)
 pushl $0
 iret
set_gate:
 movw %ax,0(%edi)
 movw $KCODE,2(%edi)
 movb $0,4(%edi)
 movb %dl,5(%edi)
 shrl $16,%eax
 movw %ax,6(%edi)
 ret
gp_handler:
 cli
 pushl %eax
 movw $KDATA,%ax
 movw %ax,%ds
 movw %ax,%es
 movb $1,gp_seen
 movl $(user_after_fault-user_blob_start),8(%esp)
 popl %eax
 addl $4,%esp
 iret
# Calls: 0 good queue,1 good revoke,2 good apply,3 reset+bad queue,4 bad revoke,5 bad apply,6 done.
mediated_handler:
 cli
 movw $KDATA,%dx
 movw %dx,%ds
 movw %dx,%es
 cmpl $0,%eax
 je good_queue
 cmpl $1,%eax
 je good_revoke
 cmpl $2,%eax
 je good_apply
 cmpl $3,%eax
 je bad_queue
 cmpl $4,%eax
 je bad_revoke
 cmpl $5,%eax
 je bad_apply
 cmpl $6,%eax
 je mediated_done
 jmp mediated_return
good_queue:
 movb $0x7e,resource_value
 movb $1,authority_rights
 movb $1,authority_generation
 movb $0x41,authority_owner
 movb $0x55,queued_value
 movb authority_generation,%dl
 movb %dl,queued_generation
 movb authority_owner,%dl
 movb %dl,queued_owner
 movb $1,queue_valid
 movl $lab_good_queue,%esi
 call pm_puts
 movb $'Q',%al
 call pm_putc
 call pm_nl
 jmp mediated_return
good_revoke:
 movb $0,authority_rights
 incb authority_generation
 movl $lab_good_revoke,%esi
 call pm_puts
 movb $1,%al
 call pm_bit
 call pm_nl
 jmp mediated_return
good_apply:
 movb $'U',%al
 cmpb $1,queue_valid
 jne good_apply_print
 movb queued_owner,%dl
 cmpb authority_owner,%dl
 jne good_apply_print
 movb queued_generation,%dl
 cmpb authority_generation,%dl
 jne good_apply_print
 testb $1,authority_rights
 jz good_apply_print
 movb queued_value,%dl
 movb %dl,resource_value
 movb $'W',%al
good_apply_print:
 movl $lab_good_apply,%esi
 call pm_puts
 call pm_putc
 call pm_nl
 movl $lab_good_after,%esi
 call pm_puts
 movb resource_value,%al
 call pm_hex8
 call pm_nl
 jmp mediated_return
bad_queue:
 movb $0x7e,resource_value
 movb $1,authority_rights
 movb $1,authority_generation
 movb $0x41,authority_owner
 movb $0x55,queued_value
 movb $1,cached_authorized
 movl $lab_bad_queue,%esi
 call pm_puts
 movb $'Q',%al
 call pm_putc
 call pm_nl
 jmp mediated_return
bad_revoke:
 movb $0,authority_rights
 incb authority_generation
 movl $lab_bad_revoke,%esi
 call pm_puts
 movb $1,%al
 call pm_bit
 call pm_nl
 jmp mediated_return
bad_apply:
 movb $'U',%al
 cmpb $1,cached_authorized
 jne bad_apply_print
 movb queued_value,%dl
 movb %dl,resource_value
 movb $'W',%al
bad_apply_print:
 movl $lab_bad_apply,%esi
 call pm_puts
 call pm_putc
 call pm_nl
 movl $lab_bad_after,%esi
 call pm_puts
 movb resource_value,%al
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
 movl $3,%eax
 int $0x30
 movl $4,%eax
 int $0x30
 movl $5,%eax
 int $0x30
 movl $6,%eax
 int $0x30
5: jmp 5b
user_blob_end:
.section .rodata
lab_test:.asciz "TEST=C004_P17\n"
lab_good_queue:.asciz "GOOD_QUEUE="
lab_good_revoke:.asciz "GOOD_REVOKE="
lab_good_apply:.asciz "GOOD_APPLY="
lab_good_after:.asciz "GOOD_AFTER="
lab_bad_queue:.asciz "BAD_QUEUE="
lab_bad_revoke:.asciz "BAD_REVOKE="
lab_bad_apply:.asciz "BAD_APPLY="
lab_bad_after:.asciz "BAD_AFTER="
lab_gp:.asciz "GP_SEEN="
lab_done:.asciz "DONE\n"
.section .data
.align 8
gdt:
 .quad 0
 .word 0xffff,0x0000
 .byte 0x00,0x9a,0xcf,0x00
 .word 0xffff,0x0000
 .byte 0x00,0x92,0xcf,0x00
 .word 0xffff,0x0000
 .byte 0x02,0xfa,0x40,0x00
 .word 0xffff,0x0000
 .byte 0x02,0xf2,0x40,0x00
gdt_tss:.quad 0
gdt_end:
gdt_desc:.word gdt_end-gdt-1;.long gdt
idt_desc:.word 2047;.long idt
gp_seen:.byte 0
resource_value:.byte 0x7e
authority_owner:.byte 0x41
authority_rights:.byte 1
authority_generation:.byte 1
queued_value:.byte 0
queued_generation:.byte 0
queued_owner:.byte 0
queue_valid:.byte 0
cached_authorized:.byte 0
.section .bss
.align 8
idt:.space 2048,0
.align 16
tss:.space 104,0
