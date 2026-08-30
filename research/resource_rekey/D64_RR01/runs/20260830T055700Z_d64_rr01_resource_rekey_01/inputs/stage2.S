.code16
.section .text
.global _start
.equ ACTIVITY_CAP,64
.equ BINDINGS_PER_ACTIVITY,20
.equ BINDING_CELL_COUNT,1280
.equ RESOURCE_CAP,64
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4

_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%ss
 movw $0x7b00,%sp

 # Path G: current activity survives resource namespace rekey.
 call reset_all
 movb $0x41,%al
 call activity_acquire
 cmpb $'W',%al
 jne fail
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x51,%al
 movb $0x7e,%ah
 call bind_new_resource
 cmpb $'W',%al
 jne fail
 movb last_binding_gen,%al
 movb %al,old_binding_gen_g
 movb last_resource_gen,%al
 movb %al,old_resource_gen_g
 movb resource_epoch,%al
 movb %al,old_resource_epoch_g
 call resource_rekey_checked
 movb %al,o_live_rekey
 movb resource_epoch,%al
 movb %al,o_live_repoch
 movb resource_identity,%al
 movb %al,o_live_rid
 movw resource_live_count,%ax
 movw %ax,o_live_rcount
 movb binding_resource_plus1,%al
 movb %al,o_live_bind

 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb old_binding_gen_g,%dh
 call binding_detach
 movb %al,o_detach
 movw resource_live_count,%ax
 movw %ax,o_after_rcount
 movb resource_identity,%al
 movb %al,o_after_rid
 movb resource_generation,%al
 movb %al,o_after_rgen
 movb act_identity,%al
 movb %al,o_a_id
 movb act_gen,%al
 movb %al,o_a_gen
 movb activity_epoch,%al
 movb %al,o_a_epoch
 movb binding_generation,%al
 movb %al,o_bgen_before

 call resource_rekey_checked
 movb %al,o_good_rekey
 movb resource_epoch,%al
 movb %al,o_new_repoch
 movb resource_generation,%al
 movb %al,o_rgen_after_rekey
 movb activity_epoch,%al
 movb %al,o_a_epoch_after
 movb act_identity,%al
 movb %al,o_a_id_after
 movb act_gen,%al
 movb %al,o_a_gen_after
 movb binding_generation,%al
 movb %al,o_bgen_after_rekey

 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x5a,%al
 movb $0xee,%ah
 call bind_new_resource
 movb %al,o_y_create
 movb last_binding_gen,%al
 movb %al,o_y_bgen
 movb last_resource_gen,%al
 movb %al,o_y_rgen
 movb $0,%bl
 movb old_resource_gen_g,%cl
 movb old_resource_epoch_g,%ch
 call resource_read
 movb %al,o_old_res
 movb $0,%bl
 movb $1,%cl
 movb $2,%ch
 call resource_read
 movb %al,o_new_res
 movb last_read_value,%al
 movb %al,o_new_res_val
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb old_binding_gen_g,%dh
 call binding_read
 movb %al,o_old_bind
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb $2,%dh
 call binding_read
 movb %al,o_new_bind
 movb last_read_value,%al
 movb %al,o_new_bind_val

 # Path B: bad generation-only reset aliases old direct resource handle.
 call reset_all
 movb $0x41,%al
 call activity_acquire
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x51,%al
 movb $0x7e,%ah
 call bind_new_resource
 movb last_binding_gen,%al
 movb %al,temp_binding_gen
 movb last_resource_gen,%al
 movb %al,temp_resource_gen
 movb resource_epoch,%al
 movb %al,temp_resource_epoch
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb temp_binding_gen,%dh
 call binding_detach
 call resource_reset_generation_only
 movb %al,o_bad_reset
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x5a,%al
 movb $0xee,%ah
 call bind_new_resource
 movb $0,%bl
 movb temp_resource_gen,%cl
 movb temp_resource_epoch,%ch
 call resource_read
 movb %al,o_bad_old_res
 movb last_read_value,%al
 movb %al,o_bad_old_val

 # Path W: explicit resource epoch 255 -> 1.
 call reset_all
 movb $255,resource_epoch
 movb $0x41,%al
 call activity_acquire
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x51,%al
 movb $0x7e,%ah
 call bind_new_resource
 movb last_binding_gen,%al
 movb %al,temp_binding_gen
 movb last_resource_gen,%al
 movb %al,temp_resource_gen
 movb resource_epoch,%al
 movb %al,temp_resource_epoch
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb temp_binding_gen,%dh
 call binding_detach
 call resource_rekey_checked
 movb %al,o_wrap_rekey
 movb resource_epoch,%al
 movb %al,o_wrap_repoch
 movb resource_generation,%al
 movb %al,o_wrap_rgen
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x5a,%al
 movb $0xee,%ah
 call bind_new_resource
 movb $0,%bl
 movb temp_resource_gen,%cl
 movb temp_resource_epoch,%ch
 call resource_read
 movb %al,o_wrap_old
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 call resource_read
 movb %al,o_wrap_new
 movb last_read_value,%al
 movb %al,o_wrap_val

 call print_matrix
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

reset_all:
 xorw %bx,%bx
reset_activity_loop:
 cmpw $ACTIVITY_CAP,%bx
 jae reset_activity_done
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
 jmp reset_activity_loop
reset_activity_done:
 movb $1,activity_epoch
 call reset_binding_resource_state
 ret

reset_binding_resource_state:
 xorw %bx,%bx
reset_binding_loop:
 cmpw $BINDING_CELL_COUNT,%bx
 jae reset_resource_begin
 movb $0,binding_resource_plus1(%bx)
 movb $0,binding_generation(%bx)
 incw %bx
 jmp reset_binding_loop
reset_resource_begin:
 xorw %bx,%bx
reset_resource_loop:
 cmpw $RESOURCE_CAP,%bx
 jae reset_resource_done
 movb $0,resource_identity(%bx)
 movb $0,resource_generation(%bx)
 movb $0,resource_value(%bx)
 movw %bx,%si
 shlw $1,%si
 movw $0,resource_live_count(%si)
 incw %bx
 jmp reset_resource_loop
reset_resource_done:
 movb $1,resource_epoch
 movb $0,completion_status
 movb $0,backing_live
 movb $0,relation_active
 ret

activity_acquire:
 movb %al,input_resource_identity
 xorw %bx,%bx
activity_acquire_scan:
 cmpw $ACTIVITY_CAP,%bx
 jae activity_acquire_full
 cmpb $0,act_identity(%bx)
 je activity_acquire_found
 incw %bx
 jmp activity_acquire_scan
activity_acquire_found:
 cmpb $255,act_gen(%bx)
 je activity_acquire_gen_exhausted
 incb act_gen(%bx)
 movb input_resource_identity,%al
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
 movb $'W',%al
 ret
activity_acquire_gen_exhausted:
 movb $'G',%al
 ret
activity_acquire_full:
 movb $'F',%al
 ret

# BL slot, CL generation, CH epoch -> W/R.
validate_activity:
 cmpb $ACTIVITY_CAP,%bl
 jae validate_activity_reject
 xorw %bx,%bx
 movb input_activity_slot,%bl
 cmpb $0,act_identity(%bx)
 je validate_activity_reject
 movb input_activity_gen,%al
 cmpb act_gen(%bx),%al
 jne validate_activity_reject
 movb input_activity_epoch,%al
 cmpb act_epoch(%bx),%al
 jne validate_activity_reject
 cmpb activity_epoch,%al
 jne validate_activity_reject
 movb $'W',%al
 ret
validate_activity_reject:
 movb $'R',%al
 ret

save_activity_handle:
 movb %bl,input_activity_slot
 movb %cl,input_activity_gen
 movb %ch,input_activity_epoch
 ret

binding_base_from_input:
 xorw %ax,%ax
 movb input_activity_slot,%al
 movw %ax,%di
 shlw $2,%di
 shlw $4,%ax
 addw %ax,%di
 ret

# BL act slot, CL act gen, CH act epoch, AL resource identity, AH value.
bind_new_resource:
 movb %al,input_resource_identity
 movb %ah,input_resource_value
 call save_activity_handle
 call validate_activity
 cmpb $'W',%al
 jne bind_new_return
 call binding_base_from_input
 movw %di,%si
 xorw %dx,%dx
bind_new_binding_scan:
 cmpw $BINDINGS_PER_ACTIVITY,%dx
 jae bind_new_row_full
 cmpb $0,binding_resource_plus1(%si)
 je bind_new_binding_found
 incw %si
 incw %dx
 jmp bind_new_binding_scan
bind_new_binding_found:
 cmpb $255,binding_generation(%si)
 je bind_new_generation_exhausted
 xorw %bx,%bx
bind_new_resource_scan:
 cmpw $RESOURCE_CAP,%bx
 jae bind_new_global_full
 cmpb $0,resource_identity(%bx)
 je bind_new_resource_found
 incw %bx
 jmp bind_new_resource_scan
bind_new_resource_found:
 cmpb $255,resource_generation(%bx)
 je bind_new_generation_exhausted
 # Coupled publication region: initialize resource before publishing binding.
 incb resource_generation(%bx)
 movb input_resource_identity,%al
 movb %al,resource_identity(%bx)
 movb input_resource_value,%al
 movb %al,resource_value(%bx)
 pushw %si
 movw %bx,%si
 shlw $1,%si
 movw $1,resource_live_count(%si)
 popw %si
 incb binding_generation(%si)
 movb %bl,%al
 incb %al
 movb %al,binding_resource_plus1(%si)
 movb %dl,last_binding_index
 movb binding_generation(%si),%al
 movb %al,last_binding_gen
 movb %bl,last_resource_slot
 movb resource_generation(%bx),%al
 movb %al,last_resource_gen
 movb $'W',%al
 ret
bind_new_row_full:
bind_new_global_full:
 movb $'F',%al
 ret
bind_new_generation_exhausted:
 movb $'G',%al
 ret
bind_new_return:
 ret

# BL act slot, CL act gen, CH act epoch, DL res slot, DH res gen, AL res epoch.
bind_existing_resource:
 movb %dl,input_resource_slot
 movb %dh,input_resource_gen
 movb %al,input_resource_epoch
 call save_activity_handle
 call validate_activity
 cmpb $'W',%al
 jne bind_existing_return
 xorw %bx,%bx
 movb input_resource_slot,%bl
 cmpw $RESOURCE_CAP,%bx
 jae bind_existing_reject
 cmpb $0,resource_identity(%bx)
 je bind_existing_reject
 movb input_resource_gen,%al
 cmpb resource_generation(%bx),%al
 jne bind_existing_reject
 movb input_resource_epoch,%al
 cmpb resource_epoch,%al
 jne bind_existing_reject
 movb %bl,validated_resource_slot
 call binding_base_from_input
 movw %di,%si
 xorw %dx,%dx
bind_existing_binding_scan:
 cmpw $BINDINGS_PER_ACTIVITY,%dx
 jae bind_existing_full
 cmpb $0,binding_resource_plus1(%si)
 je bind_existing_binding_found
 incw %si
 incw %dx
 jmp bind_existing_binding_scan
bind_existing_binding_found:
 cmpb $255,binding_generation(%si)
 je bind_existing_gen_exhausted
 xorw %bx,%bx
 movb validated_resource_slot,%bl
 pushw %si
 movw %bx,%si
 shlw $1,%si
 incw resource_live_count(%si)
 popw %si
 incb binding_generation(%si)
 movb %bl,%al
 incb %al
 movb %al,binding_resource_plus1(%si)
 movb %dl,last_binding_index
 movb binding_generation(%si),%al
 movb %al,last_binding_gen
 movb $'W',%al
 ret
bind_existing_full:
 movb $'F',%al
 ret
bind_existing_gen_exhausted:
 movb $'G',%al
 ret
bind_existing_reject:
 movb $'R',%al
 ret
bind_existing_return:
 ret

# BL act slot, CL act gen, CH act epoch, DL binding index, DH binding gen.
binding_detach:
 movb %dl,input_binding_index
 movb %dh,input_binding_gen
 call save_activity_handle
 call validate_activity
 cmpb $'W',%al
 jne binding_detach_return
 cmpb $BINDINGS_PER_ACTIVITY,input_binding_index
 jae binding_detach_reject
 call binding_base_from_input
 xorw %ax,%ax
 movb input_binding_index,%al
 addw %ax,%di
 cmpb $0,binding_resource_plus1(%di)
 je binding_detach_reject
 movb input_binding_gen,%al
 cmpb binding_generation(%di),%al
 jne binding_detach_reject
 movb binding_resource_plus1(%di),%al
 decb %al
 movb %al,validated_resource_slot
 xorw %bx,%bx
 movb validated_resource_slot,%bl
 cmpw $RESOURCE_CAP,%bx
 jae binding_detach_reject
 cmpb $0,resource_identity(%bx)
 je binding_detach_reject
 movw %bx,%si
 shlw $1,%si
 cmpw $0,resource_live_count(%si)
 je binding_detach_reject
 # Withdraw binding before lowering liveness.
 movb $0,binding_resource_plus1(%di)
 decw resource_live_count(%si)
 cmpw $0,resource_live_count(%si)
 jne binding_detach_done
 movb $0,resource_identity(%bx)
 movb $0,resource_value(%bx)
binding_detach_done:
 movb $'W',%al
 ret
binding_detach_reject:
 movb $'R',%al
 ret
binding_detach_return:
 ret

# Good binding read with binding-generation currentness.
binding_read:
 movb $0,last_read_value
 movb %dl,input_binding_index
 movb %dh,input_binding_gen
 call save_activity_handle
 call validate_activity
 cmpb $'W',%al
 jne binding_read_return
 cmpb $BINDINGS_PER_ACTIVITY,input_binding_index
 jae binding_read_reject
 call binding_base_from_input
 xorw %ax,%ax
 movb input_binding_index,%al
 addw %ax,%di
 cmpb $0,binding_resource_plus1(%di)
 je binding_read_reject
 movb input_binding_gen,%al
 cmpb binding_generation(%di),%al
 jne binding_read_reject
 movb binding_resource_plus1(%di),%al
 decb %al
 xorw %bx,%bx
 movb %al,%bl
 cmpw $RESOURCE_CAP,%bx
 jae binding_read_reject
 cmpb $0,resource_identity(%bx)
 je binding_read_reject
 movb resource_value(%bx),%al
 movb %al,last_read_value
 movb $'W',%al
 ret
binding_read_reject:
 movb $'R',%al
 ret
binding_read_return:
 ret

# Negative control: validates activity and index, ignores binding generation.
bad_binding_read:
 movb $0,last_read_value
 movb %dl,input_binding_index
 call save_activity_handle
 call validate_activity
 cmpb $'W',%al
 jne bad_binding_return
 cmpb $BINDINGS_PER_ACTIVITY,input_binding_index
 jae bad_binding_reject
 call binding_base_from_input
 xorw %ax,%ax
 movb input_binding_index,%al
 addw %ax,%di
 cmpb $0,binding_resource_plus1(%di)
 je bad_binding_reject
 movb binding_resource_plus1(%di),%al
 decb %al
 xorw %bx,%bx
 movb %al,%bl
 cmpw $RESOURCE_CAP,%bx
 jae bad_binding_reject
 cmpb $0,resource_identity(%bx)
 je bad_binding_reject
 movb resource_value(%bx),%al
 movb %al,last_read_value
 movb $'W',%al
 ret
bad_binding_reject:
 movb $'R',%al
 ret
bad_binding_return:
 ret

# Good direct resource read: BL slot, CL generation, CH epoch.
resource_read:
 movb $0,last_read_value
 movb %bl,input_resource_slot
 movb %cl,input_resource_gen
 movb %ch,input_resource_epoch
 xorw %bx,%bx
 movb input_resource_slot,%bl
 cmpw $RESOURCE_CAP,%bx
 jae resource_read_reject
 cmpb $0,resource_identity(%bx)
 je resource_read_reject
 movb input_resource_gen,%al
 cmpb resource_generation(%bx),%al
 jne resource_read_reject
 movb input_resource_epoch,%al
 cmpb resource_epoch,%al
 jne resource_read_reject
 movb resource_value(%bx),%al
 movb %al,last_read_value
 movb $'W',%al
 ret
resource_read_reject:
 movb $'R',%al
 ret

# Negative control: resource-slot-only read, ignores generation and epoch.
bad_resource_read:
 movb $0,last_read_value
 cmpb $RESOURCE_CAP,%bl
 jae bad_resource_reject
 xorb %bh,%bh
 cmpb $0,resource_identity(%bx)
 je bad_resource_reject
 movb resource_value(%bx),%al
 movb %al,last_read_value
 movb $'W',%al
 ret
bad_resource_reject:
 movb $'R',%al
 ret

# BL activity slot, DL count. Uses generic bind_new_resource.
fill_n_resources:
 movb %bl,fill_activity_slot
 movb %dl,fill_remaining
fill_n_loop:
 cmpb $0,fill_remaining
 je fill_n_done
 movb fill_activity_slot,%bl
 movb $1,%cl
 movb $1,%ch
 movb next_resource_identity,%al
 movb %al,%ah
 call bind_new_resource
 cmpb $'W',%al
 jne fill_n_return
 incb next_resource_identity
 decb fill_remaining
 jmp fill_n_loop
fill_n_done:
 movb $'W',%al
fill_n_return:
 ret

# BL activity slot -> AL live binding count.
count_activity_bindings:
 movb %bl,input_activity_slot
 call binding_base_from_input
 movw %di,%si
 xorw %dx,%dx
 xorw %ax,%ax
count_bind_loop:
 cmpw $BINDINGS_PER_ACTIVITY,%dx
 jae count_bind_done
 cmpb $0,binding_resource_plus1(%si)
 je count_bind_next
 incb %al
count_bind_next:
 incw %si
 incw %dx
 jmp count_bind_loop
count_bind_done:
 ret

count_resources:
 xorw %bx,%bx
 xorw %ax,%ax
count_res_loop:
 cmpw $RESOURCE_CAP,%bx
 jae count_res_done
 cmpb $0,resource_identity(%bx)
 je count_res_next
 incb %al
count_res_next:
 incw %bx
 jmp count_res_loop
count_res_done:
 ret


# BL resource slot -> AX 16-bit live count.
load_resource_live_word:
 xorb %bh,%bh
 movw %bx,%si
 shlw $1,%si
 movw resource_live_count(%si),%ax
 ret

# fill_activity_slot + fill_remaining + next_resource_identity/value.
fill_new_sequence:
 cmpb $0,fill_remaining
 je fill_new_sequence_done
 movb fill_activity_slot,%bl
 movb $1,%cl
 movb $1,%ch
 movb next_resource_identity,%al
 movb next_resource_value,%ah
 call bind_new_resource
 cmpb $'W',%al
 jne fill_new_sequence_return
 incb next_resource_identity
 incb next_resource_value
 decb fill_remaining
 jmp fill_new_sequence
fill_new_sequence_done:
 movb $'W',%al
fill_new_sequence_return:
 ret



# BL slot, CL generation, CH activity epoch.

# Resource rekey: activities may remain current; bindings/resources must be quiescent.
resource_rekey_checked:
 xorw %bx,%bx
resource_rekey_scan_bindings:
 cmpw $BINDING_CELL_COUNT,%bx
 jae resource_rekey_scan_resources_begin
 cmpb $0,binding_resource_plus1(%bx)
 jne resource_rekey_reject
 incw %bx
 jmp resource_rekey_scan_bindings
resource_rekey_scan_resources_begin:
 xorw %bx,%bx
resource_rekey_scan_resources:
 cmpw $RESOURCE_CAP,%bx
 jae resource_rekey_other_guard
 cmpb $0,resource_identity(%bx)
 jne resource_rekey_reject
 movw %bx,%si
 shlw $1,%si
 cmpw $0,resource_live_count(%si)
 jne resource_rekey_reject
 incw %bx
 jmp resource_rekey_scan_resources
resource_rekey_other_guard:
 cmpb $0,relation_active
 jne resource_rekey_reject
 movb resource_epoch,%al
 cmpb $255,%al
 je resource_rekey_wrap
 incb %al
 jmp resource_rekey_epoch_ready
resource_rekey_wrap:
 movb $1,%al
resource_rekey_epoch_ready:
 movb %al,next_resource_epoch
 xorw %bx,%bx
resource_rekey_reset_loop:
 cmpw $RESOURCE_CAP,%bx
 jae resource_rekey_publish
 movb $0,resource_identity(%bx)
 movb $0,resource_generation(%bx)
 movb $0,resource_value(%bx)
 movw %bx,%si
 shlw $1,%si
 movw $0,resource_live_count(%si)
 incw %bx
 jmp resource_rekey_reset_loop
resource_rekey_publish:
 movb next_resource_epoch,%al
 movb %al,resource_epoch
 movb $'W',%al
 ret
resource_rekey_reject:
 movb $'R',%al
 ret

# Deliberately bad control: reset resource generations without epoch change.
resource_reset_generation_only:
 xorw %bx,%bx
resource_bad_reset_loop:
 cmpw $RESOURCE_CAP,%bx
 jae resource_bad_reset_done
 movb $0,resource_generation(%bx)
 incw %bx
 jmp resource_bad_reset_loop
resource_bad_reset_done:
 movb $'W',%al
 ret


print_matrix:
 movw $lab_act_cap,%si
 call print_string
 movb $ACTIVITY_CAP,%al
 call print_hex8
 call newline
 movw $lab_bind_per,%si
 call print_string
 movb $BINDINGS_PER_ACTIVITY,%al
 call print_hex8
 call newline
 movw $lab_res_cap,%si
 call print_string
 movb $RESOURCE_CAP,%al
 call print_hex8
 call newline
 movw $lab_live_rekey,%si
 call print_string
 movb o_live_rekey,%al
 call print_char
 call newline
 movw $lab_live_repoch,%si
 call print_string
 movb o_live_repoch,%al
 call print_hex8
 call newline
 movw $lab_live_rid,%si
 call print_string
 movb o_live_rid,%al
 call print_hex8
 call newline
 movw $lab_live_rcount,%si
 call print_string
 movw o_live_rcount,%ax
 call print_hex16
 call newline
 movw $lab_live_bind,%si
 call print_string
 movb o_live_bind,%al
 call print_hex8
 call newline
 movw $lab_detach,%si
 call print_string
 movb o_detach,%al
 call print_char
 call newline
 movw $lab_after_rcount,%si
 call print_string
 movw o_after_rcount,%ax
 call print_hex16
 call newline
 movw $lab_after_rid,%si
 call print_string
 movb o_after_rid,%al
 call print_hex8
 call newline
 movw $lab_after_rgen,%si
 call print_string
 movb o_after_rgen,%al
 call print_hex8
 call newline
 movw $lab_a_id,%si
 call print_string
 movb o_a_id,%al
 call print_hex8
 call newline
 movw $lab_a_gen,%si
 call print_string
 movb o_a_gen,%al
 call print_hex8
 call newline
 movw $lab_a_epoch,%si
 call print_string
 movb o_a_epoch,%al
 call print_hex8
 call newline
 movw $lab_bgen_before,%si
 call print_string
 movb o_bgen_before,%al
 call print_hex8
 call newline
 movw $lab_good_rekey,%si
 call print_string
 movb o_good_rekey,%al
 call print_char
 call newline
 movw $lab_new_repoch,%si
 call print_string
 movb o_new_repoch,%al
 call print_hex8
 call newline
 movw $lab_rgen_after_rekey,%si
 call print_string
 movb o_rgen_after_rekey,%al
 call print_hex8
 call newline
 movw $lab_a_epoch_after,%si
 call print_string
 movb o_a_epoch_after,%al
 call print_hex8
 call newline
 movw $lab_a_id_after,%si
 call print_string
 movb o_a_id_after,%al
 call print_hex8
 call newline
 movw $lab_a_gen_after,%si
 call print_string
 movb o_a_gen_after,%al
 call print_hex8
 call newline
 movw $lab_bgen_after_rekey,%si
 call print_string
 movb o_bgen_after_rekey,%al
 call print_hex8
 call newline
 movw $lab_y_create,%si
 call print_string
 movb o_y_create,%al
 call print_char
 call newline
 movw $lab_y_bgen,%si
 call print_string
 movb o_y_bgen,%al
 call print_hex8
 call newline
 movw $lab_y_rgen,%si
 call print_string
 movb o_y_rgen,%al
 call print_hex8
 call newline
 movw $lab_old_res,%si
 call print_string
 movb o_old_res,%al
 call print_char
 call newline
 movw $lab_new_res,%si
 call print_string
 movb o_new_res,%al
 call print_char
 call newline
 movw $lab_new_res_val,%si
 call print_string
 movb o_new_res_val,%al
 call print_hex8
 call newline
 movw $lab_old_bind,%si
 call print_string
 movb o_old_bind,%al
 call print_char
 call newline
 movw $lab_new_bind,%si
 call print_string
 movb o_new_bind,%al
 call print_char
 call newline
 movw $lab_new_bind_val,%si
 call print_string
 movb o_new_bind_val,%al
 call print_hex8
 call newline
 movw $lab_bad_reset,%si
 call print_string
 movb o_bad_reset,%al
 call print_char
 call newline
 movw $lab_bad_old_res,%si
 call print_string
 movb o_bad_old_res,%al
 call print_char
 call newline
 movw $lab_bad_old_val,%si
 call print_string
 movb o_bad_old_val,%al
 call print_hex8
 call newline
 movw $lab_wrap_rekey,%si
 call print_string
 movb o_wrap_rekey,%al
 call print_char
 call newline
 movw $lab_wrap_repoch,%si
 call print_string
 movb o_wrap_repoch,%al
 call print_hex8
 call newline
 movw $lab_wrap_rgen,%si
 call print_string
 movb o_wrap_rgen,%al
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
 movw $lab_wrap_val,%si
 call print_string
 movb o_wrap_val,%al
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
print_hex16:
 pushw %ax
 movb %ah,%al
 call print_hex8
 popw %ax
 call print_hex8
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
binding_resource_plus1:.space BINDING_CELL_COUNT,0
binding_generation:.space BINDING_CELL_COUNT,0
resource_identity:.space RESOURCE_CAP,0
resource_generation:.space RESOURCE_CAP,0
resource_value:.space RESOURCE_CAP,0
resource_live_count:.space RESOURCE_CAP*2,0
resource_epoch:.byte 0
completion_status:.byte 0
backing_live:.byte 0
relation_active:.byte 0
next_resource_epoch:.byte 0
input_activity_slot:.byte 0
input_activity_gen:.byte 0
input_activity_epoch:.byte 0
input_resource_identity:.byte 0
input_resource_value:.byte 0
input_resource_slot:.byte 0
input_resource_gen:.byte 0
input_resource_epoch:.byte 0
input_binding_index:.byte 0
input_binding_gen:.byte 0
validated_resource_slot:.byte 0
last_binding_index:.byte 0
last_binding_gen:.byte 0
last_resource_slot:.byte 0
last_resource_gen:.byte 0
last_read_value:.byte 0
fill_activity_slot:.byte 0
fill_remaining:.byte 0
next_resource_identity:.byte 0
next_resource_value:.byte 0
share_resource_slot:.byte 0
share_resource_gen:.byte 0
share_resource_epoch:.byte 0
share_activity_slot:.byte 0
share_remaining:.byte 0
old_a_binding_gen:.byte 0
old_resource_gen:.byte 0
old_resource_epoch:.byte 0
b_shared_binding_gen:.byte 0
old_binding_gen_g:.byte 0
old_resource_gen_g:.byte 0
old_resource_epoch_g:.byte 0
temp_binding_gen:.byte 0
temp_resource_gen:.byte 0
temp_resource_epoch:.byte 0
o_live_rekey:.byte 0
o_live_repoch:.byte 0
o_live_rid:.byte 0
o_live_rcount:.word 0
o_live_bind:.byte 0
o_detach:.byte 0
o_after_rcount:.word 0
o_after_rid:.byte 0
o_after_rgen:.byte 0
o_a_id:.byte 0
o_a_gen:.byte 0
o_a_epoch:.byte 0
o_bgen_before:.byte 0
o_good_rekey:.byte 0
o_new_repoch:.byte 0
o_rgen_after_rekey:.byte 0
o_a_epoch_after:.byte 0
o_a_id_after:.byte 0
o_a_gen_after:.byte 0
o_bgen_after_rekey:.byte 0
o_y_create:.byte 0
o_y_bgen:.byte 0
o_y_rgen:.byte 0
o_old_res:.byte 0
o_new_res:.byte 0
o_new_res_val:.byte 0
o_old_bind:.byte 0
o_new_bind:.byte 0
o_new_bind_val:.byte 0
o_bad_reset:.byte 0
o_bad_old_res:.byte 0
o_bad_old_val:.byte 0
o_wrap_rekey:.byte 0
o_wrap_repoch:.byte 0
o_wrap_rgen:.byte 0
o_wrap_old:.byte 0
o_wrap_new:.byte 0
o_wrap_val:.byte 0
runtime_state_end:
lab_act_cap:.asciz "ACT_CAP="
lab_bind_per:.asciz "BIND_PER_ACT="
lab_res_cap:.asciz "RES_CAP="
lab_live_rekey:.asciz "LIVE_REKEY="
lab_live_repoch:.asciz "LIVE_REPOCH="
lab_live_rid:.asciz "LIVE_RID="
lab_live_rcount:.asciz "LIVE_RCOUNT="
lab_live_bind:.asciz "LIVE_BIND="
lab_detach:.asciz "DETACH="
lab_after_rcount:.asciz "AFTER_RCOUNT="
lab_after_rid:.asciz "AFTER_RID="
lab_after_rgen:.asciz "AFTER_RGEN="
lab_a_id:.asciz "A_ID="
lab_a_gen:.asciz "A_GEN="
lab_a_epoch:.asciz "A_EPOCH="
lab_bgen_before:.asciz "BGEN_BEFORE="
lab_good_rekey:.asciz "GOOD_REKEY="
lab_new_repoch:.asciz "NEW_REPOCH="
lab_rgen_after_rekey:.asciz "RGEN_AFTER_REKEY="
lab_a_epoch_after:.asciz "A_EPOCH_AFTER="
lab_a_id_after:.asciz "A_ID_AFTER="
lab_a_gen_after:.asciz "A_GEN_AFTER="
lab_bgen_after_rekey:.asciz "BGEN_AFTER_REKEY="
lab_y_create:.asciz "Y_CREATE="
lab_y_bgen:.asciz "Y_BGEN="
lab_y_rgen:.asciz "Y_RGEN="
lab_old_res:.asciz "OLD_RES="
lab_new_res:.asciz "NEW_RES="
lab_new_res_val:.asciz "NEW_RES_VAL="
lab_old_bind:.asciz "OLD_BIND="
lab_new_bind:.asciz "NEW_BIND="
lab_new_bind_val:.asciz "NEW_BIND_VAL="
lab_bad_reset:.asciz "BAD_RESET="
lab_bad_old_res:.asciz "BAD_OLD_RES="
lab_bad_old_val:.asciz "BAD_OLD_VAL="
lab_wrap_rekey:.asciz "WRAP_REKEY="
lab_wrap_repoch:.asciz "WRAP_REPOCH="
lab_wrap_rgen:.asciz "WRAP_RGEN="
lab_wrap_old:.asciz "WRAP_OLD="
lab_wrap_new:.asciz "WRAP_NEW="
lab_wrap_val:.asciz "WRAP_VAL="
lab_done:.asciz "DONE\n"
lab_fail:.asciz "FAIL\n"
