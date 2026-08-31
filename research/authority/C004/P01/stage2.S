.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
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

 # A calling A's current binding.
 movb $0,caller_slot
 movb $1,caller_gen
 movb $1,caller_epoch
 movb $0,target_slot
 movb $1,target_gen
 movb $1,target_epoch
 movb $0,binding_index
 movb $1,binding_gen_in
 call caller_aware_read
 movw $lab_owner,%si
 call puts
 call putc
 call nl
 movw $lab_owner_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl

 # B is current but attempts to exercise A's binding.
 movb $1,caller_slot
 movb $1,caller_gen
 movb $1,caller_epoch
 call caller_aware_read
 movw $lab_b_good,%si
 call puts
 call putc
 call nl
 movw $lab_b_good_val,%si
 call puts
 movb last_value,%al
 call hex8
 call nl

 # Same B context, same exact current target handle, but bad path ignores caller.
 call currentness_only_read
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

# AL=W/R/M on current target relation; BX target slot, DI binding absolute index.
target_validate:
 xorw %bx,%bx
 movb target_slot,%bl
 cmpw $2,%bx
 jae st_r
 cmpb $0,activity_identity(%bx)
 je st_m
 movb target_gen,%al
 cmpb activity_generation(%bx),%al
 jne st_r
 movb target_epoch,%al
 cmpb activity_epoch(%bx),%al
 jne st_r
 cmpb $0,binding_index
 jne st_r
 movw %bx,%di
 cmpb $0,binding_resource_plus1(%di)
 je st_m
 movb binding_gen_in,%al
 cmpb binding_generation(%di),%al
 jne st_r
 movb $'W',%al
 ret

caller_validate:
 xorw %bx,%bx
 movb caller_slot,%bl
 cmpw $2,%bx
 jae st_r
 cmpb $0,activity_identity(%bx)
 je st_m
 movb caller_gen,%al
 cmpb activity_generation(%bx),%al
 jne st_r
 movb caller_epoch,%al
 cmpb activity_epoch(%bx),%al
 jne st_r
 movb $'W',%al
 ret

caller_aware_read:
 movb $0,last_value
 call caller_validate
 cmpb $'W',%al
 jne caller_aware_done
 movb caller_slot,%dl
 cmpb target_slot,%dl
 jne st_u
 movb caller_gen,%dl
 cmpb target_gen,%dl
 jne st_u
 movb caller_epoch,%dl
 cmpb target_epoch,%dl
 jne st_u
 call currentness_only_read
caller_aware_done:
 ret

currentness_only_read:
 movb $0,last_value
 call target_validate
 cmpb $'W',%al
 jne currentness_only_done
 movb binding_resource_plus1(%di),%dl
 decb %dl
 xorw %bx,%bx
 movb %dl,%bl
 cmpw $1,%bx
 jae st_r
 cmpb $0,resource_identity(%bx)
 je st_r
 movb resource_value(%bx),%dl
 movb %dl,last_value
 movb $'W',%al
currentness_only_done:
 ret

st_m: movb $'M',%al; ret
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
lab_test:.asciz "TEST=C004_P01\n"
lab_owner:.asciz "OWNER_CHECKED="
lab_owner_val:.asciz "OWNER_VAL="
lab_b_good:.asciz "B_CALLER_AWARE="
lab_b_good_val:.asciz "B_CALLER_AWARE_VAL="
lab_b_bad:.asciz "B_CURRENT_ONLY="
lab_b_bad_val:.asciz "B_CURRENT_ONLY_VAL="
lab_done:.asciz "DONE\n"

.section .data
activity_identity:.byte 0x41,0x42
activity_generation:.byte 1,1
activity_epoch:.byte 1,1
binding_resource_plus1:.byte 1,0
binding_generation:.byte 1,0
resource_identity:.byte 0x51
resource_value:.byte 0x7e

.section .bss
caller_slot:.byte 0
caller_gen:.byte 0
caller_epoch:.byte 0
target_slot:.byte 0
target_gen:.byte 0
target_epoch:.byte 0
binding_index:.byte 0
binding_gen_in:.byte 0
last_value:.byte 0
