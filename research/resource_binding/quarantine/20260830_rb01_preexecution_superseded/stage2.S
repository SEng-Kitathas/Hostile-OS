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
 call reset_all

 # Four current activities A-D through one generic acquire path.
 movb $0x41,%al
 call activity_acquire
 cmpb $'W',%al
 jne fail
 movb $0x42,%al
 call activity_acquire
 cmpb $'W',%al
 jne fail
 movb $0x43,%al
 call activity_acquire
 cmpb $'W',%al
 jne fail
 movb $0x44,%al
 call activity_acquire
 cmpb $'W',%al
 jne fail

 # Scale path: fill A's row, test A21 before global fill, then reach 64 resources.
 movb $1,next_resource_identity
 movb $0,%bl
 movb $20,%dl
 call fill_n_resources
 cmpb $'W',%al
 jne fail
 movb $0,%bl
 call count_activity_bindings
 movb %al,o_a_fill

 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb next_resource_identity,%al
 movb %al,%ah
 call bind_new_resource
 movb %al,o_a21
 call count_resources
 movb %al,o_res_after_a21

 movb $1,%bl
 movb $20,%dl
 call fill_n_resources
 cmpb $'W',%al
 jne fail
 movb $1,%bl
 call count_activity_bindings
 movb %al,o_b_fill

 movb $2,%bl
 movb $20,%dl
 call fill_n_resources
 cmpb $'W',%al
 jne fail
 movb $2,%bl
 call count_activity_bindings
 movb %al,o_c_fill

 movb $3,%bl
 movb $4,%dl
 call fill_n_resources
 cmpb $'W',%al
 jne fail
 movb $3,%bl
 call count_activity_bindings
 movb %al,o_d_fill
 call count_resources
 movb %al,o_res_count

 # D still has row capacity, so this isolates global resource-full behavior.
 movb $3,%bl
 movb $1,%cl
 movb $1,%ch
 movb next_resource_identity,%al
 movb %al,%ah
 call bind_new_resource
 movb %al,o_global65
 movb $3,%bl
 call count_activity_bindings
 movb %al,o_d_after_global65
 call count_resources
 movb %al,o_res_after_global65

 # Independent binding/resource lifetime and currentness subpath.
 call reset_binding_resource_state

 # A creates R/X; save direct-resource and binding handle currentness.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x52,%al
 movb $0x58,%ah
 call bind_new_resource
 cmpb $'W',%al
 jne fail
 movb last_resource_slot,%al
 movb %al,shared_resource_slot
 movb last_resource_gen,%al
 movb %al,shared_resource_gen
 movb resource_epoch,%al
 movb %al,shared_resource_epoch
 movb last_binding_gen,%al
 movb %al,shared_a_binding_gen

 # B binds the same current resource.
 movb $1,%bl
 movb $1,%cl
 movb $1,%ch
 movb shared_resource_slot,%dl
 movb shared_resource_gen,%dh
 movb shared_resource_epoch,%al
 call bind_existing_resource
 cmpb $'W',%al
 jne fail
 movb last_binding_gen,%al
 movb %al,shared_b_binding_gen
 xorw %bx,%bx
 movb shared_resource_slot,%bl
 movb resource_live_count(%bx),%al
 movb %al,o_shared_live

 # Detach A: resource must survive for B.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb shared_a_binding_gen,%dh
 call binding_detach
 movb %al,o_detach_a
 xorw %bx,%bx
 movb shared_resource_slot,%bl
 movb resource_live_count(%bx),%al
 movb %al,o_live_after_a
 movb resource_identity(%bx),%al
 movb %al,o_shared_id_after_a
 movb resource_value(%bx),%al
 movb %al,o_shared_val_after_a

 # Detach B: final binding permits reclaim.
 movb $1,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb shared_b_binding_gen,%dh
 call binding_detach
 movb %al,o_detach_b
 xorw %bx,%bx
 movb shared_resource_slot,%bl
 movb resource_live_count(%bx),%al
 movb %al,o_live_after_b
 movb resource_identity(%bx),%al
 movb %al,o_id_after_b
 movb resource_value(%bx),%al
 movb %al,o_val_after_b

 # A reuses binding cell 0 and resource slot 0 for Z/Y.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x5a,%al
 movb $0x59,%ah
 call bind_new_resource
 movb %al,o_reuse
 movb last_binding_gen,%al
 movb %al,o_reuse_bind_gen
 movb last_resource_gen,%al
 movb %al,o_reuse_res_gen

 # Binding currentness and index-only negative control.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb $1,%dh
 call binding_read
 movb %al,o_stale_bind
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb $2,%dh
 call binding_read
 movb %al,o_fresh_bind
 movb last_read_value,%al
 movb %al,o_fresh_bind_val
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 call bad_binding_read
 movb %al,o_bad_bind
 movb last_read_value,%al
 movb %al,o_bad_bind_val

 # Direct-resource currentness and slot-only negative control.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 call resource_read
 movb %al,o_stale_res
 movb $0,%bl
 movb $2,%cl
 movb $1,%ch
 call resource_read
 movb %al,o_fresh_res
 movb last_read_value,%al
 movb %al,o_fresh_res_val
 movb $0,%bl
 call bad_resource_read
 movb %al,o_bad_res
 movb last_read_value,%al
 movb %al,o_bad_res_val

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
 movb $0,resource_live_count(%bx)
 incw %bx
 jmp reset_resource_loop
reset_resource_done:
 movb $1,resource_epoch
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
 movb $1,resource_live_count(%bx)
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
 incb resource_live_count(%bx)
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
 cmpb $0,resource_live_count(%bx)
 je binding_detach_reject
 # Withdraw binding before lowering liveness.
 movb $0,binding_resource_plus1(%di)
 decb resource_live_count(%bx)
 cmpb $0,resource_live_count(%bx)
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
 xorw %bx,%bx
 movb input_resource_slot,%bl
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

print_matrix:
 movw $lab_act_cap,%si
 movb $ACTIVITY_CAP,%al
 call print_hex_line
 movw $lab_bind_cap,%si
 movb $BINDINGS_PER_ACTIVITY,%al
 call print_hex_line
 movw $lab_res_cap,%si
 movb $RESOURCE_CAP,%al
 call print_hex_line
 movw $lab_a_fill,%si
 movb o_a_fill,%al
 call print_hex_line
 movw $lab_a21,%si
 movb o_a21,%al
 call print_char_line
 movw $lab_res_after_a21,%si
 movb o_res_after_a21,%al
 call print_hex_line
 movw $lab_b_fill,%si
 movb o_b_fill,%al
 call print_hex_line
 movw $lab_c_fill,%si
 movb o_c_fill,%al
 call print_hex_line
 movw $lab_d_fill,%si
 movb o_d_fill,%al
 call print_hex_line
 movw $lab_res_count,%si
 movb o_res_count,%al
 call print_hex_line
 movw $lab_global65,%si
 movb o_global65,%al
 call print_char_line
 movw $lab_d_after_global65,%si
 movb o_d_after_global65,%al
 call print_hex_line
 movw $lab_res_after_global65,%si
 movb o_res_after_global65,%al
 call print_hex_line
 movw $lab_shared_live,%si
 movb o_shared_live,%al
 call print_hex_line
 movw $lab_detach_a,%si
 movb o_detach_a,%al
 call print_char_line
 movw $lab_live_after_a,%si
 movb o_live_after_a,%al
 call print_hex_line
 movw $lab_shared_id_after_a,%si
 movb o_shared_id_after_a,%al
 call print_hex_line
 movw $lab_shared_val_after_a,%si
 movb o_shared_val_after_a,%al
 call print_hex_line
 movw $lab_detach_b,%si
 movb o_detach_b,%al
 call print_char_line
 movw $lab_live_after_b,%si
 movb o_live_after_b,%al
 call print_hex_line
 movw $lab_id_after_b,%si
 movb o_id_after_b,%al
 call print_hex_line
 movw $lab_val_after_b,%si
 movb o_val_after_b,%al
 call print_hex_line
 movw $lab_reuse,%si
 movb o_reuse,%al
 call print_char_line
 movw $lab_reuse_bind_gen,%si
 movb o_reuse_bind_gen,%al
 call print_hex_line
 movw $lab_reuse_res_gen,%si
 movb o_reuse_res_gen,%al
 call print_hex_line
 movw $lab_stale_bind,%si
 movb o_stale_bind,%al
 call print_char_line
 movw $lab_fresh_bind,%si
 movb o_fresh_bind,%al
 call print_char_line
 movw $lab_fresh_bind_val,%si
 movb o_fresh_bind_val,%al
 call print_hex_line
 movw $lab_bad_bind,%si
 movb o_bad_bind,%al
 call print_char_line
 movw $lab_bad_bind_val,%si
 movb o_bad_bind_val,%al
 call print_hex_line
 movw $lab_stale_res,%si
 movb o_stale_res,%al
 call print_char_line
 movw $lab_fresh_res,%si
 movb o_fresh_res,%al
 call print_char_line
 movw $lab_fresh_res_val,%si
 movb o_fresh_res_val,%al
 call print_hex_line
 movw $lab_bad_res,%si
 movb o_bad_res,%al
 call print_char_line
 movw $lab_bad_res_val,%si
 movb o_bad_res_val,%al
 call print_hex_line
 movw $lab_done,%si
 jmp print_string

print_hex_line:
 movb %al,%ah
 call print_string
 movb %ah,%al
 call print_hex8
 jmp newline
print_char_line:
 movb %al,%ah
 call print_string
 movb %ah,%al
 call print_char
 jmp newline
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
binding_resource_plus1:.space BINDING_CELL_COUNT,0
binding_generation:.space BINDING_CELL_COUNT,0
resource_identity:.space RESOURCE_CAP,0
resource_generation:.space RESOURCE_CAP,0
resource_value:.space RESOURCE_CAP,0
resource_live_count:.space RESOURCE_CAP,0
resource_epoch:.byte 0
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
shared_resource_slot:.byte 0
shared_resource_gen:.byte 0
shared_resource_epoch:.byte 0
shared_a_binding_gen:.byte 0
shared_b_binding_gen:.byte 0
o_a_fill:.byte 0
o_a21:.byte 0
o_res_after_a21:.byte 0
o_b_fill:.byte 0
o_c_fill:.byte 0
o_d_fill:.byte 0
o_res_count:.byte 0
o_global65:.byte 0
o_d_after_global65:.byte 0
o_res_after_global65:.byte 0
o_shared_live:.byte 0
o_detach_a:.byte 0
o_live_after_a:.byte 0
o_shared_id_after_a:.byte 0
o_shared_val_after_a:.byte 0
o_detach_b:.byte 0
o_live_after_b:.byte 0
o_id_after_b:.byte 0
o_val_after_b:.byte 0
o_reuse:.byte 0
o_reuse_bind_gen:.byte 0
o_reuse_res_gen:.byte 0
o_stale_bind:.byte 0
o_fresh_bind:.byte 0
o_fresh_bind_val:.byte 0
o_bad_bind:.byte 0
o_bad_bind_val:.byte 0
o_stale_res:.byte 0
o_fresh_res:.byte 0
o_fresh_res_val:.byte 0
o_bad_res:.byte 0
o_bad_res_val:.byte 0
runtime_state_end:
lab_act_cap:.asciz "ACT_CAP="
lab_bind_cap:.asciz "BIND_CAP="
lab_res_cap:.asciz "RES_CAP="
lab_a_fill:.asciz "A_FILL="
lab_a21:.asciz "A21="
lab_res_after_a21:.asciz "RES_AFTER_A21="
lab_b_fill:.asciz "B_FILL="
lab_c_fill:.asciz "C_FILL="
lab_d_fill:.asciz "D_FILL="
lab_res_count:.asciz "RES_COUNT="
lab_global65:.asciz "GLOBAL65="
lab_d_after_global65:.asciz "D_AFTER_GLOBAL65="
lab_res_after_global65:.asciz "RES_AFTER_GLOBAL65="
lab_shared_live:.asciz "SHARED_LIVE="
lab_detach_a:.asciz "DETACH_A="
lab_live_after_a:.asciz "LIVE_AFTER_A="
lab_shared_id_after_a:.asciz "SHARED_ID_AFTER_A="
lab_shared_val_after_a:.asciz "SHARED_VAL_AFTER_A="
lab_detach_b:.asciz "DETACH_B="
lab_live_after_b:.asciz "LIVE_AFTER_B="
lab_id_after_b:.asciz "ID_AFTER_B="
lab_val_after_b:.asciz "VAL_AFTER_B="
lab_reuse:.asciz "REUSE="
lab_reuse_bind_gen:.asciz "REUSE_BIND_GEN="
lab_reuse_res_gen:.asciz "REUSE_RES_GEN="
lab_stale_bind:.asciz "STALE_BIND="
lab_fresh_bind:.asciz "FRESH_BIND="
lab_fresh_bind_val:.asciz "FRESH_BIND_VAL="
lab_bad_bind:.asciz "BAD_BIND="
lab_bad_bind_val:.asciz "BAD_BIND_VAL="
lab_stale_res:.asciz "STALE_RES="
lab_fresh_res:.asciz "FRESH_RES="
lab_fresh_res_val:.asciz "FRESH_RES_VAL="
lab_bad_res:.asciz "BAD_RES="
lab_bad_res_val:.asciz "BAD_RES_VAL="
lab_done:.asciz "DONE\n"
lab_fail:.asciz "FAIL\n"
