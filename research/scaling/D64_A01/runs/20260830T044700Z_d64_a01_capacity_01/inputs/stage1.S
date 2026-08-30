.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ BOOT_DRIVE_MEM,0x0500
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
 movb $0x08,%al
 movb $0x00,%ch
 movb $0x02,%cl
 movb $0x00,%dh
 movb BOOT_DRIVE_MEM,%dl
 int $0x13
 jc load_fail
 movw $msg_ok,%si
 call print_string
 ljmp $0x0000,$0x8000
load_fail:
 movw $msg_fail,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
1: hlt
 jmp 1b
print_string:
 lodsb
 testb %al,%al
 jz 2f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp print_string
2: ret
.section .data
msg_ok:.asciz "S1_OK\n"
msg_fail:.asciz "S1_FAIL\n"
