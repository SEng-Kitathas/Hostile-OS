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

 # Path S: all 64 activities, all 1280 binding cells share resource 0.
 call reset_all
 xorw %di,%di
share_acquire_activity_loop:
 cmpw $ACTIVITY_CAP,%di
 jae share_acquire_done
 movw %di,%ax
 incb %al
 call activity_acquire
 cmpb $'W',%al
 jne fail
 incw %di
 jmp share_acquire_activity_loop
share_acquire_done:
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x51,%al
 movb $0x7e,%ah
 call bind_new_resource
 cmpb $'W',%al
 jne fail
 movb last_resource_slot,%al
 movb %al,share_resource_slot
 movb last_resource_gen,%al
 movb %al,share_resource_gen
 movb resource_epoch,%al
 movb %al,share_resource_epoch
 movb $0,share_activity_slot
share_activity_loop:
 cmpb $ACTIVITY_CAP,share_activity_slot
 jae share_fill_done
 movb $20,%al
 cmpb $0,share_activity_slot
 jne share_count_ready
 movb $19,%al
share_count_ready:
 movb %al,share_remaining
share_binding_loop:
 cmpb $0,share_remaining
 je share_next_activity
 movb share_activity_slot,%bl
 movb $1,%cl
 movb $1,%ch
 movb share_resource_slot,%dl
 movb share_resource_gen,%dh
 movb share_resource_epoch,%al
 call bind_existing_resource
 cmpb $'W',%al
 jne fail
 decb share_remaining
 jmp share_binding_loop
share_next_activity:
 incb share_activity_slot
 jmp share_activity_loop
share_fill_done:
 movb share_resource_slot,%bl
 call load_resource_live_word
 movw %ax,o_share_count
 # Activity 63 row is full: extra bind must fail and not change count.
 movb $63,%bl
 movb $1,%cl
 movb $1,%ch
 movb share_resource_slot,%dl
 movb share_resource_gen,%dh
 movb share_resource_epoch,%al
 call bind_existing_resource
 movb %al,o_share_full
 movb share_resource_slot,%bl
 call load_resource_live_word
 movw %ax,o_share_count_post
 # Last binding remains readable.
 movb $63,%bl
 movb $1,%cl
 movb $1,%ch
 movb $19,%dl
 movb $1,%dh
 call binding_read
 movb %al,o_share_last
 movb last_read_value,%al
 movb %al,o_share_val

 # Path G: four activities, 64 distinct resources with one shared R0.
 call reset_all
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

 movb $1,next_resource_identity
 movb $0x80,next_resource_value
 movb $0,fill_activity_slot
 movb $20,fill_remaining
 call fill_new_sequence
 cmpb $'W',%al
 jne fail
 # Save old A binding0 and direct resource0 handle.
 movb binding_generation,%al
 movb %al,old_a_binding_gen
 movb resource_generation,%al
 movb %al,old_resource_gen
 movb resource_epoch,%al
 movb %al,old_resource_epoch
 # A21: row full before global resource full.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb next_resource_identity,%al
 movb next_resource_value,%ah
 call bind_new_resource
 movb %al,o_a_full
 call count_resources
 xorb %ah,%ah
 movw %ax,o_res_after_a

 # B binding0 shares R0.
 movb $1,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb $1,%dh
 movb $1,%al
 call bind_existing_resource
 cmpb $'W',%al
 jne fail
 movb last_binding_gen,%al
 movb %al,b_shared_binding_gen
 # B creates 19 more resources.
 movb $1,fill_activity_slot
 movb $19,fill_remaining
 call fill_new_sequence
 cmpb $'W',%al
 jne fail
 # C creates 20.
 movb $2,fill_activity_slot
 movb $20,fill_remaining
 call fill_new_sequence
 cmpb $'W',%al
 jne fail
 # D creates 5.
 movb $3,fill_activity_slot
 movb $5,fill_remaining
 call fill_new_sequence
 cmpb $'W',%al
 jne fail
 call count_resources
 xorb %ah,%ah
 movw %ax,o_global_count
 # D has free cell 5, but global table is full.
 movb $3,%bl
 movb $1,%cl
 movb $1,%ch
 movb next_resource_identity,%al
 movb next_resource_value,%ah
 call bind_new_resource
 movb %al,o_global_full
 movb binding_resource_plus1+65,%al
 movb %al,o_d_bind5
 movb $0,%bl
 call load_resource_live_word
 movw %ax,o_r0_live2

 # Detach A binding0; B still sees R0/X.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb old_a_binding_gen,%dh
 call binding_detach
 movb %al,o_detach_a
 movb $0,%bl
 call load_resource_live_word
 movw %ax,o_r0_after_a
 movb $1,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb b_shared_binding_gen,%dh
 call binding_read
 movb %al,o_b_read
 movb last_read_value,%al
 movb %al,o_b_val

 # Detach B binding0; R0 reclaimed but generation preserved.
 movb $1,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb b_shared_binding_gen,%dh
 call binding_detach
 movb %al,o_detach_b
 movb $0,%bl
 call load_resource_live_word
 movw %ax,o_r0_after_b
 movb resource_identity,%al
 movb %al,o_r0_id_after_b

 # D creates new resource Z/EE: first free binding is D index5, first free resource slot0.
 movb $3,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0x5a,%al
 movb $0xee,%ah
 call bind_new_resource
 movb %al,o_reuse_new
 movb last_binding_index,%al
 movb %al,o_reuse_bind
 movb last_resource_slot,%al
 movb %al,o_reuse_res
 movb last_resource_gen,%al
 movb %al,o_reuse_rgen

 # A rebinds current R0; A binding0 generation advances to2.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb $2,%dh
 movb $1,%al
 call bind_existing_resource
 movb %al,o_a_rebind
 movb last_binding_gen,%al
 movb %al,o_a_bgen
 movb $0,%bl
 call load_resource_live_word
 movw %ax,o_r0_live

 # Binding currentness controls.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 movb $1,%dh
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
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 movb $0,%dl
 call bad_binding_read
 movb %al,o_bad_bind
 movb last_read_value,%al
 movb %al,o_bad_bind_val

 # Direct resource currentness controls.
 movb $0,%bl
 movb $1,%cl
 movb $1,%ch
 call resource_read
 movb %al,o_old_res
 movb $0,%bl
 movb $2,%cl
 movb $1,%ch
 call resource_read
 movb %al,o_new_res
 movb last_read_value,%al
 movb %al,o_new_res_val
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
 movw %bx,%si
 shlw $1,%si
 movw $0,resource_live_count(%si)
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


print_matrix:
 movw $lab_act_cap,%si
 movb $ACTIVITY_CAP,%al
 call print_hex8_line
 movw $lab_bind_per_act,%si
 movb $BINDINGS_PER_ACTIVITY,%al
 call print_hex8_line
 movw $lab_res_cap,%si
 movb $RESOURCE_CAP,%al
 call print_hex8_line
 movw $lab_cell_count,%si
 movw $BINDING_CELL_COUNT,%ax
 call print_hex16_line
 movw $lab_share_count,%si
 movw o_share_count,%ax
 call print_hex16_line
 movw $lab_share_full,%si
 movb o_share_full,%al
 call print_char_line
 movw $lab_share_count_post,%si
 movw o_share_count_post,%ax
 call print_hex16_line
 movw $lab_share_last,%si
 movb o_share_last,%al
 call print_char_line
 movw $lab_share_val,%si
 movb o_share_val,%al
 call print_hex8_line
 movw $lab_a_full,%si
 movb o_a_full,%al
 call print_char_line
 movw $lab_res_after_a,%si
 movw o_res_after_a,%ax
 call print_hex16_line
 movw $lab_global_count,%si
 movw o_global_count,%ax
 call print_hex16_line
 movw $lab_global_full,%si
 movb o_global_full,%al
 call print_char_line
 movw $lab_d_bind5,%si
 movb o_d_bind5,%al
 call print_hex8_line
 movw $lab_r0_live2,%si
 movw o_r0_live2,%ax
 call print_hex16_line
 movw $lab_detach_a,%si
 movb o_detach_a,%al
 call print_char_line
 movw $lab_r0_after_a,%si
 movw o_r0_after_a,%ax
 call print_hex16_line
 movw $lab_b_read,%si
 movb o_b_read,%al
 call print_char_line
 movw $lab_b_val,%si
 movb o_b_val,%al
 call print_hex8_line
 movw $lab_detach_b,%si
 movb o_detach_b,%al
 call print_char_line
 movw $lab_r0_after_b,%si
 movw o_r0_after_b,%ax
 call print_hex16_line
 movw $lab_r0_id_after_b,%si
 movb o_r0_id_after_b,%al
 call print_hex8_line
 movw $lab_reuse_new,%si
 movb o_reuse_new,%al
 call print_char_line
 movw $lab_reuse_bind,%si
 movb o_reuse_bind,%al
 call print_hex8_line
 movw $lab_reuse_res,%si
 movb o_reuse_res,%al
 call print_hex8_line
 movw $lab_reuse_rgen,%si
 movb o_reuse_rgen,%al
 call print_hex8_line
 movw $lab_a_rebind,%si
 movb o_a_rebind,%al
 call print_char_line
 movw $lab_a_bgen,%si
 movb o_a_bgen,%al
 call print_hex8_line
 movw $lab_r0_live,%si
 movw o_r0_live,%ax
 call print_hex16_line
 movw $lab_old_bind,%si
 movb o_old_bind,%al
 call print_char_line
 movw $lab_new_bind,%si
 movb o_new_bind,%al
 call print_char_line
 movw $lab_new_bind_val,%si
 movb o_new_bind_val,%al
 call print_hex8_line
 movw $lab_bad_bind,%si
 movb o_bad_bind,%al
 call print_char_line
 movw $lab_bad_bind_val,%si
 movb o_bad_bind_val,%al
 call print_hex8_line
 movw $lab_old_res,%si
 movb o_old_res,%al
 call print_char_line
 movw $lab_new_res,%si
 movb o_new_res,%al
 call print_char_line
 movw $lab_new_res_val,%si
 movb o_new_res_val,%al
 call print_hex8_line
 movw $lab_bad_res,%si
 movb o_bad_res,%al
 call print_char_line
 movw $lab_bad_res_val,%si
 movb o_bad_res_val,%al
 call print_hex8_line
 movw $lab_done,%si
 jmp print_string

print_hex8_line:
 movb %al,%ah
 call print_string
 movb %ah,%al
 call print_hex8
 jmp newline
print_hex16_line:
 pushw %ax
 call print_string
 popw %ax
 call print_hex16
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
o_share_count:.word 0
o_share_full:.byte 0
o_share_count_post:.word 0
o_share_last:.byte 0
o_share_val:.byte 0
o_a_full:.byte 0
o_res_after_a:.word 0
o_global_count:.word 0
o_global_full:.byte 0
o_d_bind5:.byte 0
o_r0_live2:.word 0
o_detach_a:.byte 0
o_r0_after_a:.word 0
o_b_read:.byte 0
o_b_val:.byte 0
o_detach_b:.byte 0
o_r0_after_b:.word 0
o_r0_id_after_b:.byte 0
o_reuse_new:.byte 0
o_reuse_bind:.byte 0
o_reuse_res:.byte 0
o_reuse_rgen:.byte 0
o_a_rebind:.byte 0
o_a_bgen:.byte 0
o_r0_live:.word 0
o_old_bind:.byte 0
o_new_bind:.byte 0
o_new_bind_val:.byte 0
o_bad_bind:.byte 0
o_bad_bind_val:.byte 0
o_old_res:.byte 0
o_new_res:.byte 0
o_new_res_val:.byte 0
o_bad_res:.byte 0
o_bad_res_val:.byte 0
runtime_state_end:
lab_act_cap:.asciz "ACT_CAP="
lab_bind_per_act:.asciz "BIND_PER_ACT="
lab_res_cap:.asciz "RES_CAP="
lab_cell_count:.asciz "CELL_COUNT="
lab_share_count:.asciz "SHARE_COUNT="
lab_share_full:.asciz "SHARE_FULL="
lab_share_count_post:.asciz "SHARE_COUNT_POST="
lab_share_last:.asciz "SHARE_LAST="
lab_share_val:.asciz "SHARE_VAL="
lab_a_full:.asciz "A_FULL="
lab_res_after_a:.asciz "RES_AFTER_A="
lab_global_count:.asciz "GLOBAL_COUNT="
lab_global_full:.asciz "GLOBAL_FULL="
lab_d_bind5:.asciz "D_BIND5="
lab_r0_live2:.asciz "R0_LIVE2="
lab_detach_a:.asciz "DETACH_A="
lab_r0_after_a:.asciz "R0_AFTER_A="
lab_b_read:.asciz "B_READ="
lab_b_val:.asciz "B_VAL="
lab_detach_b:.asciz "DETACH_B="
lab_r0_after_b:.asciz "R0_AFTER_B="
lab_r0_id_after_b:.asciz "R0_ID_AFTER_B="
lab_reuse_new:.asciz "REUSE_NEW="
lab_reuse_bind:.asciz "REUSE_BIND="
lab_reuse_res:.asciz "REUSE_RES="
lab_reuse_rgen:.asciz "REUSE_RGEN="
lab_a_rebind:.asciz "A_REBIND="
lab_a_bgen:.asciz "A_BGEN="
lab_r0_live:.asciz "R0_LIVE="
lab_old_bind:.asciz "OLD_BIND="
lab_new_bind:.asciz "NEW_BIND="
lab_new_bind_val:.asciz "NEW_BIND_VAL="
lab_bad_bind:.asciz "BAD_BIND="
lab_bad_bind_val:.asciz "BAD_BIND_VAL="
lab_old_res:.asciz "OLD_RES="
lab_new_res:.asciz "NEW_RES="
lab_new_res_val:.asciz "NEW_RES_VAL="
lab_bad_res:.asciz "BAD_RES="
lab_bad_res_val:.asciz "BAD_RES_VAL="
lab_done:.asciz "DONE\n"
lab_fail:.asciz "FAIL\n"
