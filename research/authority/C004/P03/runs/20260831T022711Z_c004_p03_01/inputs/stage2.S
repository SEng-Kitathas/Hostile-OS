.code16
.section .text
.global _start
.equ DEBUG_PORT,0xe9
.equ EXIT_PORT,0xf4
.equ STACK_TOP,0x7a00
.equ READ_RIGHT,1
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

 # Good: B (READ only) requests READ|WRITE for C; grant attenuates to READ.
 movb $1,delegator_slot
 movb $2,delegatee_slot
 movb $(READ_RIGHT|WRITE_RIGHT),requested_rights
 call good_delegate
 movw $lab_good_grant,%si
 call puts
 movb authority_rights+2,%al
 call hex8
 call nl
 movb $2,caller_slot
 call read_x
 movw $lab_good_read,%si
 call puts
 call putc
 call nl
 movw $lab_good_read_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl
 movb $0x55,input_value
 call write_x
 movw $lab_good_write,%si
 call puts
 call putc
 call nl
 movw $lab_good_after,%si
 call puts
 movb resource_value,%al
 call hex8
 call nl

 # Reset C and X, then bad delegation copies requested rights unbounded.
 movb $0,authority_rights+2
 movb $0x7e,resource_value
 movb $1,delegator_slot
 movb $2,delegatee_slot
 movb $(READ_RIGHT|WRITE_RIGHT),requested_rights
 call bad_delegate
 movw $lab_bad_grant,%si
 call puts
 movb authority_rights+2,%al
 call hex8
 call nl
 movb $2,caller_slot
 movb $0x55,input_value
 call write_x
 movw $lab_bad_write,%si
 call puts
 call putc
 call nl
 movw $lab_bad_after,%si
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

current_caller:
 xorw %bx,%bx
 movb caller_slot,%bl
 cmpw $3,%bx
 jae st_r
 cmpb $0,activity_identity(%bx)
 je st_r
 cmpb $1,activity_generation(%bx)
 jne st_r
 cmpb $1,activity_epoch(%bx)
 jne st_r
 movb $'W',%al
 ret
read_x:
 movb $0,last_value
 call current_caller
 cmpb $'W',%al
 jne read_done
 testb $READ_RIGHT,authority_rights(%bx)
 jz st_u
 movb resource_value,%dl
 movb %dl,last_value
 movb $'W',%al
read_done: ret
write_x:
 call current_caller
 cmpb $'W',%al
 jne write_done
 testb $WRITE_RIGHT,authority_rights(%bx)
 jz st_u
 movb input_value,%dl
 movb %dl,resource_value
 movb $'W',%al
write_done: ret

good_delegate:
 xorw %bx,%bx
 movb delegator_slot,%bl
 cmpw $3,%bx
 jae st_r
 movb authority_rights(%bx),%al
 andb requested_rights,%al
 xorw %bx,%bx
 movb delegatee_slot,%bl
 movb %al,authority_rights(%bx)
 movb $'W',%al
 ret
bad_delegate:
 xorw %bx,%bx
 movb delegatee_slot,%bl
 movb requested_rights,%al
 movb %al,authority_rights(%bx)
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
lab_test:.asciz "TEST=C004_P03\n"
lab_good_grant:.asciz "GOOD_C_RIGHTS="
lab_good_read:.asciz "GOOD_C_READ="
lab_good_read_val:.asciz "GOOD_C_READ_VAL="
lab_good_write:.asciz "GOOD_C_WRITE="
lab_good_after:.asciz "GOOD_AFTER="
lab_bad_grant:.asciz "BAD_C_RIGHTS="
lab_bad_write:.asciz "BAD_C_WRITE="
lab_bad_after:.asciz "BAD_AFTER="
lab_done:.asciz "DONE\n"
.section .data
activity_identity:.byte 0x41,0x42,0x43
activity_generation:.byte 1,1,1
activity_epoch:.byte 1,1,1
authority_rights:.byte 3,1,0
resource_value:.byte 0x7e
.section .bss
caller_slot:.byte 0
delegator_slot:.byte 0
delegatee_slot:.byte 0
requested_rights:.byte 0
input_value:.byte 0
last_value:.byte 0
