.code16
.section .text
.global _start
.equ ACTIVITY_CAP,64
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%ss
 movw $0x7b00,%sp
 movb $1,runtime_epoch

 xorw %di,%di
fill_loop:
 movw %di,%ax
 incb %al
 movb runtime_epoch,%ah
 call acquire_next
 cmpb $'W',%al
 jne fail
 incb fill_count
 incw %di
 cmpw $ACTIVITY_CAP,%di
 jb fill_loop

 movb $0x41,%al
 movb runtime_epoch,%ah
 call acquire_next
 movb %al,full_status

 movw $31,%bx
 call release_index
 movb %al,release_status

 movb $0x5a,%al
 movb runtime_epoch,%ah
 call acquire_next
 movb %al,reuse_status
 movb last_acquired_slot,%al
 movb %al,reuse_slot_obs
 movb act_identity+31,%al
 movb %al,reuse_id_obs
 movb act_gen+31,%al
 movb %al,reuse_gen_obs

 movw $31,%bx
 movb $1,%cl
 movb $1,%ch
 call checked_handle
 movb %al,stale_status

 movw $31,%bx
 movb $2,%cl
 movb $1,%ch
 call checked_handle
 movb %al,fresh_status
 movb last_read_identity,%al
 movb %al,fresh_id_obs

 movw $lab_cap,%si
 call print_string
 movb $ACTIVITY_CAP,%al
 call print_hex8
 call newline
 movw $lab_fill,%si
 call print_string
 movb fill_count,%al
 call print_hex8
 call newline
 movw $lab_first_id,%si
 call print_string
 movb act_identity,%al
 call print_hex8
 call newline
 movw $lab_first_gen,%si
 call print_string
 movb act_gen,%al
 call print_hex8
 call newline
 movw $lab_last_id,%si
 call print_string
 movb act_identity+63,%al
 call print_hex8
 call newline
 movw $lab_last_gen,%si
 call print_string
 movb act_gen+63,%al
 call print_hex8
 call newline
 movw $lab_full,%si
 call print_string
 movb full_status,%al
 call print_char
 call newline
 movw $lab_post_first,%si
 call print_string
 movb act_identity,%al
 call print_hex8
 call newline
 movw $lab_post_last,%si
 call print_string
 movb act_identity+63,%al
 call print_hex8
 call newline
 movw $lab_release,%si
 call print_string
 movb release_status,%al
 call print_char
 call newline
 movw $lab_reuse,%si
 call print_string
 movb reuse_status,%al
 call print_char
 call newline
 movw $lab_reuse_slot,%si
 call print_string
 movb reuse_slot_obs,%al
 call print_hex8
 call newline
 movw $lab_reuse_id,%si
 call print_string
 movb reuse_id_obs,%al
 call print_hex8
 call newline
 movw $lab_reuse_gen,%si
 call print_string
 movb reuse_gen_obs,%al
 call print_hex8
 call newline
 movw $lab_stale,%si
 call print_string
 movb stale_status,%al
 call print_char
 call newline
 movw $lab_fresh,%si
 call print_string
 movb fresh_status,%al
 call print_char
 call newline
 movw $lab_fresh_id,%si
 call print_string
 movb fresh_id_obs,%al
 call print_hex8
 call newline
 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

fail:
 movw $lab_fail,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
2: hlt
 jmp 2b

# AL=identity, AH=epoch. Returns AL status; records last acquired slot.
acquire_next:
 movb %al,input_identity
 movb %ah,input_epoch
 xorw %bx,%bx
acquire_scan:
 cmpw $ACTIVITY_CAP,%bx
 jae acquire_full
 cmpb $0,act_identity(%bx)
 je acquire_found
 incw %bx
 jmp acquire_scan
acquire_found:
 cmpb $255,act_gen(%bx)
 je acquire_generation_exhausted
 incb act_gen(%bx)
 movb input_identity,%al
 movb %al,act_identity(%bx)
 movb $0,act_progress(%bx)
 movb $0,act_cont(%bx)
 movb $0,act_waiting(%bx)
 movb $0,act_woken(%bx)
 movb $0,act_parent_slot(%bx)
 movb $0,act_parent_gen(%bx)
 movb $0,act_wait_slot(%bx)
 movb $0,act_wait_gen(%bx)
 movb input_epoch,%al
 movb %al,act_epoch(%bx)
 movb %bl,last_acquired_slot
 movb $'W',%al
 ret
acquire_generation_exhausted:
 movb $'G',%al
 ret
acquire_full:
 movb $'F',%al
 ret

# BX=slot. Clears occupancy only; generation stays for reuse currentness.
release_index:
 cmpw $ACTIVITY_CAP,%bx
 jae release_reject
 cmpb $0,act_identity(%bx)
 je release_reject
 movb $0,act_identity(%bx)
 movb $'W',%al
 ret
release_reject:
 movb $'R',%al
 ret

# BX=slot, CL=generation, CH=epoch. Exposes identity only after currentness checks.
checked_handle:
 movb $0,last_read_identity
 cmpw $ACTIVITY_CAP,%bx
 jae handle_reject
 cmpb $0,act_identity(%bx)
 je handle_reject
 cmpb act_gen(%bx),%cl
 jne handle_reject
 cmpb act_epoch(%bx),%ch
 jne handle_reject
 movb act_identity(%bx),%al
 movb %al,last_read_identity
 movb $'W',%al
 ret
handle_reject:
 movb $'R',%al
 ret

print_string:
 lodsb
 testb %al,%al
 jz print_done
 call print_char
 jmp print_string
print_done:
 ret
print_char:
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 ret
print_hex8:
 pushw %ax
 movb %al,%ah
 shrb $4,%al
 call hex_nibble
 movb %ah,%al
 andb $0x0f,%al
 call hex_nibble
 popw %ax
 ret
hex_nibble:
 cmpb $10,%al
 jb hex_digit
 addb $('A'-10),%al
 jmp print_char
hex_digit:
 addb $'0',%al
 jmp print_char
newline:
 movb $'\n',%al
 jmp print_char

.section .data
runtime_state_start:
act_identity:.space ACTIVITY_CAP,0
act_gen:.space ACTIVITY_CAP,0
act_progress:.space ACTIVITY_CAP,0
act_cont:.space ACTIVITY_CAP,0
act_waiting:.space ACTIVITY_CAP,0
act_woken:.space ACTIVITY_CAP,0
act_parent_slot:.space ACTIVITY_CAP,0
act_parent_gen:.space ACTIVITY_CAP,0
act_wait_slot:.space ACTIVITY_CAP,0
act_wait_gen:.space ACTIVITY_CAP,0
act_epoch:.space ACTIVITY_CAP,0
runtime_epoch:.byte 0
fill_count:.byte 0
input_identity:.byte 0
input_epoch:.byte 0
last_acquired_slot:.byte 0
last_read_identity:.byte 0
full_status:.byte 0
release_status:.byte 0
reuse_status:.byte 0
reuse_slot_obs:.byte 0
reuse_id_obs:.byte 0
reuse_gen_obs:.byte 0
stale_status:.byte 0
fresh_status:.byte 0
fresh_id_obs:.byte 0
runtime_state_end:
lab_cap:.asciz "CAP="
lab_fill:.asciz "FILL_COUNT="
lab_first_id:.asciz "FIRST_ID="
lab_first_gen:.asciz "FIRST_GEN="
lab_last_id:.asciz "LAST_ID="
lab_last_gen:.asciz "LAST_GEN="
lab_full:.asciz "FULL="
lab_post_first:.asciz "POST_FULL_FIRST="
lab_post_last:.asciz "POST_FULL_LAST="
lab_release:.asciz "RELEASE="
lab_reuse:.asciz "REUSE="
lab_reuse_slot:.asciz "REUSE_SLOT="
lab_reuse_id:.asciz "REUSE_ID="
lab_reuse_gen:.asciz "REUSE_GEN="
lab_stale:.asciz "STALE="
lab_fresh:.asciz "FRESH="
lab_fresh_id:.asciz "FRESH_ID="
lab_done:.asciz "DONE\n"
lab_fail:.asciz "FAIL\n"
