.code16
.section .text
.global _start
.equ DEBUG_PORT,0xe9
.equ EXIT_PORT,0xf4
.equ STACK_TOP,0x7a00
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $STACK_TOP,%sp
 movw $lab_test,%si
 call puts

 # A owns both read and write rights.
 movb $0,caller_slot
 call good_read
 movw $lab_a_read,%si
 call puts
 call putc
 call nl
 movw $lab_a_read_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl
 movb $0x55,input_value
 call good_write
 movw $lab_a_write,%si
 call puts
 call putc
 call nl
 movw $lab_a_after,%si
 call puts
 movb resource_value,%al
 call hex8
 call nl

 # Reset only the resource value for the delegated-B discriminator.
 movb $0x7e,resource_value
 movb $1,caller_slot
 call good_read
 movw $lab_b_read,%si
 call puts
 call putc
 call nl
 movw $lab_b_read_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl
 movb $0x55,input_value
 call good_write
 movw $lab_b_write,%si
 call puts
 call putc
 call nl
 movw $lab_b_after,%si
 call puts
 movb resource_value,%al
 call hex8
 call nl

 # Bad binary-allow path uses the same allow bit for mutation.
 movb $0x55,input_value
 call bad_binary_write
 movw $lab_b_bad_write,%si
 call puts
 call putc
 call nl
 movw $lab_b_bad_after,%si
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

caller_current:
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
 movb $'W',%al
 ret

good_read:
 movb $0,last_value
 call caller_current
 cmpb $'W',%al
 jne good_read_done
 cmpb $1,read_allowed(%bx)
 jne st_u
 movb resource_value,%dl
 movb %dl,last_value
 movb $'W',%al
good_read_done:
 ret

good_write:
 call caller_current
 cmpb $'W',%al
 jne good_write_done
 cmpb $1,write_allowed(%bx)
 jne st_u
 movb input_value,%dl
 movb %dl,resource_value
 movb $'W',%al
good_write_done:
 ret

bad_binary_write:
 call caller_current
 cmpb $'W',%al
 jne bad_binary_done
 cmpb $1,binary_allowed(%bx)
 jne st_u
 movb input_value,%dl
 movb %dl,resource_value
 movb $'W',%al
bad_binary_done:
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
lab_test:.asciz "TEST=C004_P02\n"
lab_a_read:.asciz "A_READ="
lab_a_read_val:.asciz "A_READ_VAL="
lab_a_write:.asciz "A_WRITE="
lab_a_after:.asciz "A_AFTER="
lab_b_read:.asciz "B_READ="
lab_b_read_val:.asciz "B_READ_VAL="
lab_b_write:.asciz "B_WRITE="
lab_b_after:.asciz "B_AFTER="
lab_b_bad_write:.asciz "B_BINARY_WRITE="
lab_b_bad_after:.asciz "B_BINARY_AFTER="
lab_done:.asciz "DONE\n"
.section .data
activity_identity:.byte 0x41,0x42
activity_generation:.byte 1,1
activity_epoch:.byte 1,1
read_allowed:.byte 1,1
write_allowed:.byte 1,0
binary_allowed:.byte 1,1
resource_value:.byte 0x7e
.section .bss
caller_slot:.byte 0
input_value:.byte 0
last_value:.byte 0
