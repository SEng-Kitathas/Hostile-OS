.code16
.section .text
.global _start
.equ DEBUG_PORT,0xe9
.equ EXIT_PORT,0xf4
.equ STACK_TOP,0x7a00
.equ WRITE_RIGHT,2
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $STACK_TOP,%sp
 movw $lab_test,%si
 call puts

 # B has READ only. Checked mutation must reject.
 movb $1,caller_slot
 movb $0x55,input_value
 call checked_write
 movw $lab_checked,%si
 call puts
 call putc
 call nl
 movw $lab_checked_after,%si
 call puts
 movb resource_value,%al
 call hex8
 call nl

 # Hostile same-domain machine code bypasses the API and writes the byte directly.
 movb $0x55,resource_value
 movw $lab_raw,%si
 call puts
 movb resource_value,%al
 call hex8
 call nl

 movw $lab_done,%si
 call puts
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

checked_write:
 xorw %bx,%bx
 movb caller_slot,%bl
 cmpw $2,%bx
 jae st_r
 cmpb $0,activity_identity(%bx)
 je st_r
 cmpb $1,activity_generation(%bx)
 jne st_r
 cmpb $1,activity_epoch(%bx)
 jne st_r
 testb $WRITE_RIGHT,authority_rights(%bx)
 jz st_u
 movb input_value,%al
 movb %al,resource_value
 movb $'W',%al
 ret
st_r: movb $'R',%al; ret
st_u: movb $'U',%al; ret
puts:
 pushw %ax
 pushw %dx
2: lodsb
 testb %al,%al
 jz 3f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp 2b
3: popw %dx
 popw %ax
 ret
putc:
 pushw %dx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popw %dx
 ret
nl:
 pushw %ax
 movb $'\n',%al
 call putc
 popw %ax
 ret
hex8:
 pushw %ax
 movb %al,%ah
 shrb $4,%al
 call nibble
 movb %ah,%al
 andb $0x0f,%al
 call nibble
 popw %ax
 ret
nibble:
 cmpb $9,%al
 jbe 4f
 addb $('A'-10),%al
 jmp putc
4: addb $'0',%al
 jmp putc
.section .rodata
lab_test:.asciz "TEST=C004_P06\n"
lab_checked:.asciz "B_CHECKED_WRITE="
lab_checked_after:.asciz "B_CHECKED_AFTER="
lab_raw:.asciz "B_RAW_AFTER="
lab_done:.asciz "DONE\n"
.section .data
activity_identity:.byte 0x41,0x42
activity_generation:.byte 1,1
activity_epoch:.byte 1,1
authority_rights:.byte 3,1
resource_value:.byte 0x7e
.section .bss
caller_slot:.byte 0
input_value:.byte 0
