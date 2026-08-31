.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ BOOT_DRIVE_MEM,0x7bf0
.equ BUF,0x7000
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
 movw $lab_test16,%si
 call puts16
 movw $BUF,%bx
 movb $0x02,%ah
 movb $1,%al
 movb $0,%ch
 movb $18,%cl
 movb $0,%dh
 movb BOOT_DRIVE_MEM,%dl
 int $0x13
 jc io_fail
 cmpw $0x3448,BUF
 jne bootstrap
 cmpw $0x3141,BUF+2
 jne bootstrap
 movw $lab_recover16,%si
 call puts16
 jmp enter_pm
bootstrap:
 xorw %ax,%ax
 movw $BUF,%di
 movw $256,%cx
 rep stosw
 movw $0x3448,BUF
 movw $0x3141,BUF+2
 movb $0x41,BUF+4
 movb $1,BUF+5
 movb $1,BUF+6
 movb $1,BUF+7
 movb $0x7e,BUF+8
 movb $0,BUF+9
 movb $1,BUF+10
 movb $1,BUF+11
 movw $BUF,%bx
 movb $0x03,%ah
 movb $1,%al
 movb $0,%ch
 movb $18,%cl
 movb $0,%dh
 movb BOOT_DRIVE_MEM,%dl
 int $0x13
 jc io_fail
 movw $lab_write16,%si
 call puts16
 movw $lab_write_a16,%si
 call puts16
 movw $lab_done16,%si
 call puts16
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
io_fail:
 movw $lab_io16,%si
 call puts16
 movw $EXIT_PORT,%dx
 movb $0x12,%al
 outb %al,%dx
2: hlt
 jmp 2b
puts16:
 lodsb
 testb %al,%al
 jz 3f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp puts16
3: ret
enter_pm:
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
 movl $user_blob_start,%esi
 movl $USER_BASE,%edi
 movl $(user_blob_end-user_blob_start),%ecx
 rep movsb
 # durable meaning from BUF; good runtime uses fresh epoch2.
 movb BUF+4,%al
 movb %al,authority_owner
 movb BUF+5,%al
 movb %al,authority_rights
 movb BUF+6,%al
 movb %al,authority_generation
 movb BUF+7,%al
 incb %al
 movb %al,authority_epoch
 movb BUF+8,%al
 movb %al,resource_value
 movb $0,gp_seen
 pushl $(UDATA|3)
 pushl $USER_STACK
 pushfl
 pushl $(UCODE|3)
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
 movb $1,gp_seen
 movl $(user_after_fault-user_blob_start),8(%esp)
 popl %eax
 addl $4,%esp
 iret
# calls0 good old,1 good fresh,2 bad reset+old,3 done
mediated_handler:
 cli
 movw $KDATA,%dx
 movw %dx,%ds
 movw %dx,%es
 cmpl $0,%eax
 je good_old
 cmpl $1,%eax
 je good_fresh
 cmpl $2,%eax
 je bad_old
 cmpl $3,%eax
 je finish
 jmp ret_user
good_old:
 movb BUF+10,%dl
 cmpb authority_generation,%dl
 jne good_old_r
 movb BUF+11,%dl
 cmpb authority_epoch,%dl
 jne good_old_r
 movb $'W',%al
 jmp good_old_print
good_old_r: movb $'R',%al
good_old_print:
 movl $lab_good_old,%esi
 call puts32
 call putc32
 call nl32
 jmp ret_user
good_fresh:
 movb $'R',%al
 cmpb $1,authority_generation
 jne good_fresh_print
 cmpb $2,authority_epoch
 jne good_fresh_print
 testb $1,authority_rights
 jz good_fresh_print
 movb $'W',%al
good_fresh_print:
 movl $lab_good_fresh,%esi
 call puts32
 call putc32
 call nl32
 movl $lab_good_val,%esi
 call puts32
 movb resource_value,%al
 call hex8
 call nl32
 jmp ret_user
bad_old:
 # Bad reconstruction retains durable epoch1; old tuple aliases.
 movb BUF+7,%al
 movb %al,authority_epoch
 movb $'R',%al
 movb BUF+10,%dl
 cmpb authority_generation,%dl
 jne bad_print
 movb BUF+11,%dl
 cmpb authority_epoch,%dl
 jne bad_print
 movb $'W',%al
bad_print:
 movl $lab_bad_old,%esi
 call puts32
 call putc32
 call nl32
 movl $lab_bad_val,%esi
 call puts32
 movb resource_value,%al
 call hex8
 call nl32
 jmp ret_user
finish:
 movl $lab_gp,%esi
 call puts32
 movb gp_seen,%al
 call bit32
 call nl32
 movl $lab_done32,%esi
 call puts32
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
4: hlt
 jmp 4b
ret_user: iret
puts32:
 pushl %eax
 pushl %edx
5: lodsb
 testb %al,%al
 jz 6f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp 5b
6: popl %edx
 popl %eax
 ret
putc32:
 pushl %edx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popl %edx
 ret
nl32:
 pushl %eax
 movb $'\n',%al
 call putc32
 popl %eax
 ret
bit32:
 andb $1,%al
 addb $'0',%al
 jmp putc32
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
 jbe 7f
 addb $('A'-10),%al
 jmp putc32
7: addb $'0',%al
 jmp putc32
user_blob_start:
 movw $KDATA,%ax
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
8: jmp 8b
user_blob_end:
.code16
.section .rodata
lab_test16:.asciz "TEST=C004_P18\n"
lab_write16:.asciz "PHASE=WRITE\n"
lab_write_a16:.asciz "WRITE=A\n"
lab_recover16:.asciz "PHASE=RECOVER\n"
lab_done16:.asciz "DONE\n"
lab_io16:.asciz "IO_FAIL\n"
.code32
lab_good_old:.asciz "GOOD_OLD="
lab_good_fresh:.asciz "GOOD_FRESH="
lab_good_val:.asciz "GOOD_VAL="
lab_bad_old:.asciz "BAD_OLD="
lab_bad_val:.asciz "BAD_VAL="
lab_gp:.asciz "GP_SEEN="
lab_done32:.asciz "DONE\n"
.section .data
.align 8
gdt:.quad 0
.word 0xffff,0;.byte 0,0x9a,0xcf,0
.word 0xffff,0;.byte 0,0x92,0xcf,0
.word 0xffff,0;.byte 2,0xfa,0x40,0
.word 0xffff,0;.byte 2,0xf2,0x40,0
gdt_tss:.quad 0
gdt_end:
gdt_desc:.word gdt_end-gdt-1;.long gdt
idt_desc:.word 2047;.long idt
gp_seen:.byte 0
authority_owner:.byte 0
authority_rights:.byte 0
authority_generation:.byte 0
authority_epoch:.byte 0
resource_value:.byte 0
.section .bss
.align 8
idt:.space 2048,0
.align 16
tss:.space 104,0
