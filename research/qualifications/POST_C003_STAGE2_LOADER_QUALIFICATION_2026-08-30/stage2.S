.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 movw $msg,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
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
.section .rodata
msg:.asciz "S2_OK\n"
