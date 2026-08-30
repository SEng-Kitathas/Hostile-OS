.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cmpb $0xa5,tail_marker
 jne tail_fail
 movw $msg_ok,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
tail_fail:
 movw $msg_fail,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
2: hlt
 jmp 2b
print_string:
 lodsb
 testb %al,%al
 jz 3f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp print_string
3: ret
.section .rodata
msg_ok:.asciz "S2_8K_OK\n"
msg_fail:.asciz "S2_8K_FAIL\n"
.section .tail,"a"
.global tail_marker
tail_marker:.byte 0xa5
