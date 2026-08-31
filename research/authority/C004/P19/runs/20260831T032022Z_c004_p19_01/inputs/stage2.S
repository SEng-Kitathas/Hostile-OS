.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ KCODE,0x08
.equ KDATA,0x10
.equ ACODE,0x18
.equ ADATA,0x20
.equ BCODE,0x28
.equ BDATA,0x30
.equ TSSSEL,0x38
.equ A_BASE,0x00020000
.equ B_BASE,0x00030000
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
 movl $0x7a00,%esp
 cld
 xorl %eax,%eax
 movl $idt,%edi
 movl $512,%ecx
 rep stosl
 movl $tss,%edi
 movl $26,%ecx
 rep stosl
 movl $0x7a00,tss+4
 movw $KDATA,tss+8
 movw $0x0067,gdt_tss
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
 movl $user_a_start,%esi
 movl $A_BASE,%edi
 movl $(user_a_end-user_a_start),%ecx
 rep movsb
 movl $user_b_start,%esi
 movl $B_BASE,%edi
 movl $(user_b_end-user_b_start),%ecx
 rep movsb
 movl $lab_test,%esi
 call puts
 pushl $(ADATA|3)
 pushl $USER_STACK
 pushfl
 pushl $(ACODE|3)
 pushl $0
 iret
set_gate:
 movw %ax,(%edi)
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
 incb gp_count
 movl 12(%esp),%eax
 andl $0xffff,%eax
 cmpl $(ACODE|3),%eax
 je gp_a
 cmpl $(BCODE|3),%eax
 je gp_b
 jmp gp_return
gp_a:
 movl $(user_a_after_fault-user_a_start),8(%esp)
 jmp gp_return
gp_b:
 movl $(user_b_after_fault-user_b_start),8(%esp)
gp_return:
 popl %eax
 addl $4,%esp
 iret
# caller from saved CS at [esp+4]: 1=A,2=B,0=unknown in DL.
derive_caller:
 movl 8(%esp),%edx
 andl $0xffff,%edx
 cmpw $(ACODE|3),%dx
 je caller_a
 cmpw $(BCODE|3),%dx
 je caller_b
 movb $0,%dl
 ret
caller_a: movb $1,%dl; ret
caller_b: movb $2,%dl; ret
mediated_handler:
 cli
 movw $KDATA,%cx
 movw %cx,%ds
 movw %cx,%es
 call derive_caller
 cmpl $0,%eax
 je cmd_a_read
 cmpl $1,%eax
 je cmd_delegate
 cmpl $2,%eax
 je cmd_queue
 cmpl $3,%eax
 je cmd_revoke_a
 cmpl $4,%eax
 je cmd_apply
 cmpl $5,%eax
 je cmd_switch_b
 cmpl $6,%eax
 je cmd_b_read
 cmpl $7,%eax
 je cmd_b_write
 cmpl $8,%eax
 je cmd_switch_a
 cmpl $9,%eax
 je cmd_revoke_b
 cmpl $10,%eax
 je cmd_a_read_after
 cmpl $11,%eax
 je cmd_done
 jmp med_ret
cmd_a_read:
 movb $'U',%al
 cmpb $1,%dl
 jne a_read_print
 testb $1,a_rights
 jz a_read_print
 movb $'W',%al
a_read_print:
 movl $lab_a_read,%esi
 call puts
 call putc
 call nl
 movl $lab_a_val,%esi
 call puts
 movb resource_value,%al
 call hex8
 call nl
 jmp med_ret
cmd_delegate:
 cmpb $1,%dl
 jne med_ret
 testb $1,a_rights
 jz med_ret
 movb $1,b_rights
 incb b_generation
 movl $lab_delegate,%esi
 call puts
 movb $'D',%al
 call putc
 call nl
 movl $lab_b_rights,%esi
 call puts
 movb b_rights,%al
 call hex8
 call nl
 jmp med_ret
cmd_queue:
 cmpb $1,%dl
 jne med_ret
 testb $2,a_rights
 jz med_ret
 movb $1,queue_valid
 movb a_generation,%cl
 movb %cl,queue_generation
 movb $0x55,queue_value
 movl $lab_queue,%esi
 call puts
 movb $'Q',%al
 call putc
 call nl
 jmp med_ret
cmd_revoke_a:
 cmpb $1,%dl
 jne med_ret
 andb $1,a_rights
 incb a_generation
 movl $lab_a_revoke,%esi
 call puts
 movb $1,%al
 call bit
 call nl
 jmp med_ret
cmd_apply:
 movb $'U',%al
 cmpb $1,%dl
 jne apply_print
 cmpb $1,queue_valid
 jne apply_print
 movb queue_generation,%cl
 cmpb a_generation,%cl
 jne apply_print
 testb $2,a_rights
 jz apply_print
 movb queue_value,%cl
 movb %cl,resource_value
 movb $'W',%al
apply_print:
 movl $lab_apply,%esi
 call puts
 call putc
 call nl
 movl $lab_after_apply,%esi
 call puts
 movb resource_value,%al
 call hex8
 call nl
 jmp med_ret
cmd_switch_b:
 cmpb $1,%dl
 jne med_ret
 movl $0,0(%esp)
 movl $(BCODE|3),4(%esp)
 movl $USER_STACK,12(%esp)
 movl $(BDATA|3),16(%esp)
 iret
cmd_b_read:
 movb $'U',%al
 cmpb $2,%dl
 jne b_read_print
 testb $1,b_rights
 jz b_read_print
 movb $'W',%al
b_read_print:
 movl $lab_b_read,%esi
 call puts
 call putc
 call nl
 movl $lab_b_val,%esi
 call puts
 movb resource_value,%al
 call hex8
 call nl
 jmp med_ret
cmd_b_write:
 movb $'U',%al
 cmpb $2,%dl
 jne b_write_print
 testb $2,b_rights
 jz b_write_print
 movb $0x55,resource_value
 movb $'W',%al
b_write_print:
 movl $lab_b_write,%esi
 call puts
 call putc
 call nl
 movl $lab_after_b_write,%esi
 call puts
 movb resource_value,%al
 call hex8
 call nl
 jmp med_ret
cmd_switch_a:
 cmpb $2,%dl
 jne med_ret
 movl $(user_a_cont-user_a_start),0(%esp)
 movl $(ACODE|3),4(%esp)
 movl $USER_STACK,12(%esp)
 movl $(ADATA|3),16(%esp)
 iret
cmd_revoke_b:
 cmpb $1,%dl
 jne med_ret
 movb $0,b_rights
 incb b_generation
 movl $lab_b_revoke,%esi
 call puts
 movb $1,%al
 call bit
 call nl
 movl $lab_live,%esi
 call puts
 movb live_count,%al
 call hex8
 call nl
 jmp med_ret
cmd_a_read_after:
 movb $'U',%al
 cmpb $1,%dl
 jne a_after_print
 testb $1,a_rights
 jz a_after_print
 movb $'W',%al
a_after_print:
 movl $lab_a_read_after,%esi
 call puts
 call putc
 call nl
 movl $lab_a_val_after,%esi
 call puts
 movb resource_value,%al
 call hex8
 call nl
 jmp med_ret
cmd_done:
 movl $lab_gp_count,%esi
 call puts
 movb gp_count,%al
 call hex8
 call nl
 movl $lab_done,%esi
 call puts
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
med_ret: iret
puts:
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
putc:
 pushl %edx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popl %edx
 ret
nl:
 pushl %eax
 movb $'\n',%al
 call putc
 popl %eax
 ret
bit:
 andb $1,%al
 addb $'0',%al
 jmp putc
hex8:
 pushl %eax
 movb %al,%ah
 shrb $4,%al
 call nib
 movb %ah,%al
 andb $15,%al
 call nib
 popl %eax
 ret
nib:
 cmpb $9,%al
 jbe 4f
 addb $('A'-10),%al
 jmp putc
4: addb $'0',%al
 jmp putc
user_a_start:
 movw $KDATA,%ax
 movw %ax,%ds
user_a_after_fault:
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
5: jmp 5b
user_a_cont:
 movl $9,%eax
 int $0x30
 movl $10,%eax
 int $0x30
 movl $11,%eax
 int $0x30
6: jmp 6b
user_a_end:
user_b_start:
 movw $KDATA,%ax
 movw %ax,%ds
user_b_after_fault:
 movl $6,%eax
 int $0x30
 movl $7,%eax
 int $0x30
 movl $8,%eax
 int $0x30
7: jmp 7b
user_b_end:
.section .rodata
lab_test:.asciz "TEST=C004_P19\n"
lab_a_read:.asciz "A_READ="
lab_a_val:.asciz "A_VAL="
lab_delegate:.asciz "DELEGATE="
lab_b_rights:.asciz "B_RIGHTS="
lab_queue:.asciz "QUEUE="
lab_a_revoke:.asciz "A_REVOKE="
lab_apply:.asciz "APPLY="
lab_after_apply:.asciz "AFTER_APPLY="
lab_b_read:.asciz "B_READ="
lab_b_val:.asciz "B_VAL="
lab_b_write:.asciz "B_WRITE="
lab_after_b_write:.asciz "AFTER_B_WRITE="
lab_b_revoke:.asciz "B_REVOKE="
lab_live:.asciz "LIVE="
lab_a_read_after:.asciz "A_READ_AFTER="
lab_a_val_after:.asciz "A_VAL_AFTER="
lab_gp_count:.asciz "GP_COUNT="
lab_done:.asciz "DONE\n"
.section .data
.align 8
gdt:.quad 0
.word 0xffff,0;.byte 0,0x9a,0xcf,0
.word 0xffff,0;.byte 0,0x92,0xcf,0
.word 0xffff,0;.byte 2,0xfa,0x40,0
.word 0xffff,0;.byte 2,0xf2,0x40,0
.word 0xffff,0;.byte 3,0xfa,0x40,0
.word 0xffff,0;.byte 3,0xf2,0x40,0
gdt_tss:.quad 0
gdt_end:
gdt_desc:.word gdt_end-gdt-1;.long gdt
idt_desc:.word 2047;.long idt
resource_value:.byte 0x7e
live_count:.byte 2
a_rights:.byte 3
a_generation:.byte 1
b_rights:.byte 0
b_generation:.byte 0
queue_valid:.byte 0
queue_generation:.byte 0
queue_value:.byte 0
gp_count:.byte 0
.section .bss
.align 8
idt:.space 2048,0
.align 16
tss:.space 104,0
