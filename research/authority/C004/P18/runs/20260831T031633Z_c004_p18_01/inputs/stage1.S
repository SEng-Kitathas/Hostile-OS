.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ BOOT_DRIVE_MEM,0x7bf0
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp
 movb %dl,BOOT_DRIVE_MEM
 movw $0x8000,%bx
 movb $0x02,%ah
 movb $0x10,%al
 movb $0,%ch
 movb $0x02,%cl
 movb $0,%dh
 int $0x13
 jc fail
 movw $ok,%si
 call puts
 ljmp $0,$0x8000
fail:
 movw $bad,%si
 call puts
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
1: hlt
 jmp 1b
puts:
 lodsb
 testb %al,%al
 jz 2f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp puts
2: ret
.section .data
ok:.asciz "S1_8K_OK\n"
bad:.asciz "S1_8K_FAIL\n"
.org 510
.word 0xaa55
