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

 # B old delegated authority before revoke.
 movb $1,caller_slot
 movb $1,input_auth_gen
 call auth_read
 movw $lab_b_before,%si
 call puts
 call putc
 call nl
 movw $lab_b_before_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl

 # Revoke B without changing resource currentness.
 movb $0,authority_rights+1
 incb authority_generation+1
 movw $lab_res_gen,%si
 call puts
 movb resource_generation,%al
 call hex8
 call nl
 movw $lab_res_epoch,%si
 call puts
 movb resource_epoch,%al
 call hex8
 call nl

 # A still current/authorized.
 movb $0,caller_slot
 movb $1,input_auth_gen
 call auth_read
 movw $lab_a_after,%si
 call puts
 call putc
 call nl
 movw $lab_a_after_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl

 # B stale authority generation is rejected.
 movb $1,caller_slot
 movb $1,input_auth_gen
 call auth_read
 movw $lab_b_old,%si
 call puts
 call putc
 call nl
 movw $lab_b_old_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl

 # Bad resource-currentness-only path ignores authority currentness.
 call resource_only_read
 movw $lab_b_bad,%si
 call puts
 call putc
 call nl
 movw $lab_b_bad_val,%si
 call puts
 movb last_value,%al
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
auth_read:
 movb $0,last_value
 call caller_current
 cmpb $'W',%al
 jne auth_done
 movb input_auth_gen,%dl
 cmpb authority_generation(%bx),%dl
 jne st_u
 testb $1,authority_rights(%bx)
 jz st_u
 movb resource_value,%dl
 movb %dl,last_value
 movb $'W',%al
auth_done: ret
resource_only_read:
 movb $0,last_value
 cmpb $0,resource_identity
 je st_r
 cmpb $1,resource_generation
 jne st_r
 cmpb $1,resource_epoch
 jne st_r
 movb resource_value,%dl
 movb %dl,last_value
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
lab_test:.asciz "TEST=C004_P04\n"
lab_b_before:.asciz "B_BEFORE="
lab_b_before_val:.asciz "B_BEFORE_VAL="
lab_res_gen:.asciz "RES_GEN="
lab_res_epoch:.asciz "RES_EPOCH="
lab_a_after:.asciz "A_AFTER="
lab_a_after_val:.asciz "A_AFTER_VAL="
lab_b_old:.asciz "B_OLD_AUTH="
lab_b_old_val:.asciz "B_OLD_AUTH_VAL="
lab_b_bad:.asciz "B_RESOURCE_ONLY="
lab_b_bad_val:.asciz "B_RESOURCE_ONLY_VAL="
lab_done:.asciz "DONE\n"
.section .data
activity_identity:.byte 0x41,0x42
activity_generation:.byte 1,1
activity_epoch:.byte 1,1
authority_rights:.byte 3,1
authority_generation:.byte 1,1
resource_identity:.byte 0x51
resource_generation:.byte 1
resource_epoch:.byte 1
resource_value:.byte 0x7e
.section .bss
caller_slot:.byte 0
input_auth_gen:.byte 0
last_value:.byte 0
