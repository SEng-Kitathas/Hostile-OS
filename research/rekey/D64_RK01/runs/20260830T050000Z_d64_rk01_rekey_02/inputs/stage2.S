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

 # Path A: live activity blocks rekey.
 movb $1,%al
 call reset_state
 movb $0x41,%al
 call acquire_next
 movb $0,%bl
 call rekey_checked
 movb %al,o_live_rekey
 movb activity_epoch,%al
 movb %al,o_live_epoch
 movb act_identity,%al
 movb %al,o_live_id
 movb act_gen,%al
 movb %al,o_live_gen
 xorw %bx,%bx
 call release_index
 movb %al,o_release

 # Path B: other quiescence guards.
 movb $'S',completion_status
 call rekey_checked
 movb %al,o_comp_rekey
 movb $0,completion_status
 movb $1,backing_live
 call rekey_checked
 movb %al,o_backing_rekey
 movb $0,backing_live
 movb $1,relation_active
 call rekey_checked
 movb %al,o_active_rekey
 movb $0,relation_active

 # Seed free-slot residue to prove full-table reset.
 movb $7,act_gen+63
 movb $2,act_cont+63

 # Path C: successful quiescent rekey.
 call rekey_checked
 movb %al,o_quiescent_rekey
 movb activity_epoch,%al
 movb %al,o_new_epoch
 movb act_gen+63,%al
 movb %al,o_tail_gen
 movb act_cont+63,%al
 movb %al,o_tail_cont
 movb $0x42,%al
 call acquire_next
 movb %al,o_new_acq
 movb last_acquired_slot,%al
 movb %al,o_new_slot
 movb act_gen,%al
 movb %al,o_new_gen
 xorw %bx,%bx
 movb $1,%cl
 movb $1,%ch
 call checked_handle
 movb %al,o_old
 xorw %bx,%bx
 movb $1,%cl
 movb $2,%ch
 call checked_handle
 movb %al,o_new
 movb last_read_identity,%al
 movb %al,o_new_id

 # Path D: bad generation reset without epoch change aliases old token.
 movb $1,%al
 call reset_state
 movb $0x41,%al
 call acquire_next
 xorw %bx,%bx
 call release_index
 call bad_reset_generations
 movb $0x42,%al
 call acquire_next
 xorw %bx,%bx
 movb $1,%cl
 movb $1,%ch
 call checked_handle
 movb %al,o_bad_old
 movb last_read_identity,%al
 movb %al,o_bad_read

 # Path E: explicit checked epoch 255 -> 1 at quiescence.
 movb $255,%al
 call reset_state
 movb $0x43,%al
 call acquire_next
 xorw %bx,%bx
 call release_index
 call rekey_checked
 movb %al,o_wrap_rekey
 movb activity_epoch,%al
 movb %al,o_wrap_epoch
 movb $0x44,%al
 call acquire_next
 xorw %bx,%bx
 movb $1,%cl
 movb $255,%ch
 call checked_handle
 movb %al,o_wrap_old
 xorw %bx,%bx
 movb $1,%cl
 movb $1,%ch
 call checked_handle
 movb %al,o_wrap_new
 movb last_read_identity,%al
 movb %al,o_wrap_id

 call print_matrix
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

# AL = current epoch. Clears the complete bounded activity namespace.
reset_state:
 movb %al,reset_epoch
 xorw %bx,%bx
reset_state_loop:
 cmpw $ACTIVITY_CAP,%bx
 jae reset_state_done
 movb $0,act_identity(%bx)
 movb $0,act_gen(%bx)
 movb $0,act_progress(%bx)
 movb $0,act_cont(%bx)
 movb $0,act_waiting(%bx)
 movb $0,act_woken(%bx)
 movb $0,act_parent_slot(%bx)
 movb $0,act_parent_gen(%bx)
 movb $0,act_wait_slot(%bx)
 movb $0,act_wait_gen(%bx)
 movb $0,act_epoch(%bx)
 incw %bx
 jmp reset_state_loop
reset_state_done:
 movb $0,completion_status
 movb $0,backing_live
 movb $0,relation_active
 movb reset_epoch,%al
 movb %al,activity_epoch
 ret

# AL = identity. Uses current global activity epoch.
acquire_next:
 movb %al,input_identity
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
 movb activity_epoch,%al
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

# BX = slot. Clears occupancy only.
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

# Checked rekey: all guards happen before namespace mutation.
rekey_checked:
 xorw %bx,%bx
rekey_scan_identity:
 cmpw $ACTIVITY_CAP,%bx
 jae rekey_check_other
 cmpb $0,act_identity(%bx)
 jne rekey_reject
 incw %bx
 jmp rekey_scan_identity
rekey_check_other:
 cmpb $0,completion_status
 jne rekey_reject
 cmpb $0,backing_live
 jne rekey_reject
 cmpb $0,relation_active
 jne rekey_reject

 # Compute next nonzero epoch only after every quiescence check passed.
 movb activity_epoch,%al
 cmpb $255,%al
 je rekey_epoch_wrap
 incb %al
 jmp rekey_epoch_ready
rekey_epoch_wrap:
 movb $1,%al
rekey_epoch_ready:
 movb %al,next_epoch
 xorw %bx,%bx
rekey_reset_loop:
 cmpw $ACTIVITY_CAP,%bx
 jae rekey_reset_done
 movb $0,act_identity(%bx)
 movb $0,act_gen(%bx)
 movb $0,act_progress(%bx)
 movb $0,act_cont(%bx)
 movb $0,act_waiting(%bx)
 movb $0,act_woken(%bx)
 movb $0,act_parent_slot(%bx)
 movb $0,act_parent_gen(%bx)
 movb $0,act_wait_slot(%bx)
 movb $0,act_wait_gen(%bx)
 movb $0,act_epoch(%bx)
 incw %bx
 jmp rekey_reset_loop
rekey_reset_done:
 movb $0,completion_status
 movb $0,backing_live
 movb $0,relation_active
 movb next_epoch,%al
 movb %al,activity_epoch
 movb $'W',%al
 ret
rekey_reject:
 movb $'R',%al
 ret

# Intentionally bad control: generation reset without namespace/epoch change.
bad_reset_generations:
 xorw %bx,%bx
bad_reset_loop:
 cmpw $ACTIVITY_CAP,%bx
 jae bad_reset_done
 movb $0,act_gen(%bx)
 incw %bx
 jmp bad_reset_loop
bad_reset_done:
 ret

# BX=slot, CL=generation, CH=epoch.
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
 cmpb activity_epoch,%ch
 jne handle_reject
 movb act_identity(%bx),%al
 movb %al,last_read_identity
 movb $'W',%al
 ret
handle_reject:
 movb $'R',%al
 ret

print_matrix:
 movw $lab_cap,%si
 call print_string
 movb $ACTIVITY_CAP,%al
 call print_hex8
 call newline
 movw $lab_live_rekey,%si
 call print_string
 movb o_live_rekey,%al
 call print_char
 call newline
 movw $lab_live_epoch,%si
 call print_string
 movb o_live_epoch,%al
 call print_hex8
 call newline
 movw $lab_live_id,%si
 call print_string
 movb o_live_id,%al
 call print_hex8
 call newline
 movw $lab_live_gen,%si
 call print_string
 movb o_live_gen,%al
 call print_hex8
 call newline
 movw $lab_release,%si
 call print_string
 movb o_release,%al
 call print_char
 call newline
 movw $lab_comp_rekey,%si
 call print_string
 movb o_comp_rekey,%al
 call print_char
 call newline
 movw $lab_backing_rekey,%si
 call print_string
 movb o_backing_rekey,%al
 call print_char
 call newline
 movw $lab_active_rekey,%si
 call print_string
 movb o_active_rekey,%al
 call print_char
 call newline
 movw $lab_quiescent_rekey,%si
 call print_string
 movb o_quiescent_rekey,%al
 call print_char
 call newline
 movw $lab_new_epoch,%si
 call print_string
 movb o_new_epoch,%al
 call print_hex8
 call newline
 movw $lab_tail_gen,%si
 call print_string
 movb o_tail_gen,%al
 call print_hex8
 call newline
 movw $lab_tail_cont,%si
 call print_string
 movb o_tail_cont,%al
 call print_hex8
 call newline
 movw $lab_new_acq,%si
 call print_string
 movb o_new_acq,%al
 call print_char
 call newline
 movw $lab_new_slot,%si
 call print_string
 movb o_new_slot,%al
 call print_hex8
 call newline
 movw $lab_new_gen,%si
 call print_string
 movb o_new_gen,%al
 call print_hex8
 call newline
 movw $lab_old,%si
 call print_string
 movb o_old,%al
 call print_char
 call newline
 movw $lab_new,%si
 call print_string
 movb o_new,%al
 call print_char
 call newline
 movw $lab_new_id,%si
 call print_string
 movb o_new_id,%al
 call print_hex8
 call newline
 movw $lab_bad_old,%si
 call print_string
 movb o_bad_old,%al
 call print_char
 call newline
 movw $lab_bad_read,%si
 call print_string
 movb o_bad_read,%al
 call print_hex8
 call newline
 movw $lab_wrap_rekey,%si
 call print_string
 movb o_wrap_rekey,%al
 call print_char
 call newline
 movw $lab_wrap_epoch,%si
 call print_string
 movb o_wrap_epoch,%al
 call print_hex8
 call newline
 movw $lab_wrap_old,%si
 call print_string
 movb o_wrap_old,%al
 call print_char
 call newline
 movw $lab_wrap_new,%si
 call print_string
 movb o_wrap_new,%al
 call print_char
 call newline
 movw $lab_wrap_id,%si
 call print_string
 movb o_wrap_id,%al
 call print_hex8
 call newline
 movw $lab_done,%si
 jmp print_string

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
activity_epoch:.byte 0
completion_status:.byte 0
backing_live:.byte 0
relation_active:.byte 0
input_identity:.byte 0
last_acquired_slot:.byte 0
last_read_identity:.byte 0
reset_epoch:.byte 0
next_epoch:.byte 0
o_live_rekey:.byte 0
o_live_epoch:.byte 0
o_live_id:.byte 0
o_live_gen:.byte 0
o_release:.byte 0
o_comp_rekey:.byte 0
o_backing_rekey:.byte 0
o_active_rekey:.byte 0
o_quiescent_rekey:.byte 0
o_new_epoch:.byte 0
o_tail_gen:.byte 0
o_tail_cont:.byte 0
o_new_acq:.byte 0
o_new_slot:.byte 0
o_new_gen:.byte 0
o_old:.byte 0
o_new:.byte 0
o_new_id:.byte 0
o_bad_old:.byte 0
o_bad_read:.byte 0
o_wrap_rekey:.byte 0
o_wrap_epoch:.byte 0
o_wrap_old:.byte 0
o_wrap_new:.byte 0
o_wrap_id:.byte 0
runtime_state_end:
lab_cap:.asciz "CAP="
lab_live_rekey:.asciz "LIVE_REKEY="
lab_live_epoch:.asciz "LIVE_EPOCH="
lab_live_id:.asciz "LIVE_ID="
lab_live_gen:.asciz "LIVE_GEN="
lab_release:.asciz "RELEASE="
lab_comp_rekey:.asciz "COMP_REKEY="
lab_backing_rekey:.asciz "BACKING_REKEY="
lab_active_rekey:.asciz "ACTIVE_REKEY="
lab_quiescent_rekey:.asciz "QUIESCENT_REKEY="
lab_new_epoch:.asciz "NEW_EPOCH="
lab_tail_gen:.asciz "TAIL_GEN="
lab_tail_cont:.asciz "TAIL_CONT="
lab_new_acq:.asciz "NEW_ACQ="
lab_new_slot:.asciz "NEW_SLOT="
lab_new_gen:.asciz "NEW_GEN="
lab_old:.asciz "OLD="
lab_new:.asciz "NEW="
lab_new_id:.asciz "NEW_ID="
lab_bad_old:.asciz "BAD_OLD="
lab_bad_read:.asciz "BAD_READ="
lab_wrap_rekey:.asciz "WRAP_REKEY="
lab_wrap_epoch:.asciz "WRAP_EPOCH="
lab_wrap_old:.asciz "WRAP_OLD="
lab_wrap_new:.asciz "WRAP_NEW="
lab_wrap_id:.asciz "WRAP_ID="
lab_done:.asciz "DONE\n"
