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
 # Snapshot B's old authority handle slot0/gen1; then reuse slot0 for C/gen2/WRITE.
 movb $0,auth_slot_in
 movb $1,auth_gen_in
 movb $1,caller_slot
 movb $0,authority_owner
 movb $0,authority_rights
 incb authority_generation
 movb $2,authority_owner
 movb $WRITE_RIGHT,authority_rights
 # B stale checked write.
 movb $0x55,input_value
 call checked_write
 movw $lab_b_stale,%si
 call puts
 call putc
 call nl
 movw $lab_b_stale_after,%si
 call puts
 movb resource_value,%al
 call hex8
 call nl
 # C fresh checked write.
 movb $2,caller_slot
 movb $0,auth_slot_in
 movb $2,auth_gen_in
 movb $0x55,input_value
 call checked_write
 movw $lab_c_fresh,%si
 call puts
 call putc
 call nl
 movw $lab_c_after,%si
 call puts
 movb resource_value,%al
 call hex8
 call nl
 # Reset resource; stale B slot-only bad control retargets to C's record.
 movb $0x7e,resource_value
 movb $1,caller_slot
 movb $0,auth_slot_in
 movb $0x55,input_value
 call slot_only_write
 movw $lab_b_bad,%si
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

checked_write:
 movb auth_slot_in,%al
 cmpb $0,%al
 jne st_r
 movb auth_gen_in,%al
 cmpb authority_generation,%al
 jne st_u
 movb caller_slot,%al
 cmpb authority_owner,%al
 jne st_u
 testb $WRITE_RIGHT,authority_rights
 jz st_u
 movb input_value,%al
 movb %al,resource_value
 movb $'W',%al
 ret
slot_only_write:
 movb auth_slot_in,%al
 cmpb $0,%al
 jne st_r
 testb $WRITE_RIGHT,authority_rights
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
lab_test:.asciz "TEST=C004_P05\n"
lab_b_stale:.asciz "B_STALE="
lab_b_stale_after:.asciz "B_STALE_AFTER="
lab_c_fresh:.asciz "C_FRESH="
lab_c_after:.asciz "C_AFTER="
lab_b_bad:.asciz "B_SLOT_ONLY="
lab_b_bad_after:.asciz "B_SLOT_ONLY_AFTER="
lab_done:.asciz "DONE\n"
.section .data
authority_owner:.byte 1
authority_rights:.byte 1
authority_generation:.byte 1
resource_value:.byte 0x7e
.section .bss
caller_slot:.byte 0
auth_slot_in:.byte 0
auth_gen_in:.byte 0
input_value:.byte 0
