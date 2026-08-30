.code16
.section .text
.global _start
.equ ACTIVITY_CAP,64
.equ BINDINGS_PER_ACTIVITY,20
.equ BINDING_CELL_COUNT,1280
.equ RESOURCE_CAP,64
.equ DURABLE_SECTOR,0x12
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ QUAL_STAGE1_BOOT_DRIVE_MEM,0x7c4b

_start:
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp
 movb QUAL_STAGE1_BOOT_DRIVE_MEM,%al
 movb %al,boot_drive
 cli

 call durable_read
 cmpb $'W',%al
 jne fail

 # Exact magic selects Boot 2. All-zero magic selects Boot 1.
 cmpb $'H',durable_buffer
 jne check_blank_magic
 cmpb $'4',durable_buffer+1
 jne fail
 cmpb $'P',durable_buffer+2
 jne fail
 cmpb $'1',durable_buffer+3
 jne fail
 jmp boot2

check_blank_magic:
 cmpb $0,durable_buffer
 jne fail
 cmpb $0,durable_buffer+1
 jne fail
 cmpb $0,durable_buffer+2
 jne fail
 cmpb $0,durable_buffer+3
 jne fail
 jmp boot1

# -----------------------------------------------------------------------------
# Boot 1: create runtime relation, persist durable meaning, reclaim runtime state.
# -----------------------------------------------------------------------------
boot1:
 call reset_runtime
 movb $1,activity_epoch
 movb $1,resource_epoch
 movb $0,o_durable_present

 movb $0x41,%al
 call activity_acquire
 movb %al,o_a_acq
 cmpb $'W',%al
 jne fail
 movb last_activity_slot,%al
 movb %al,o_a_slot
 movb last_activity_gen,%al
 movb %al,o_a_gen
 movb activity_epoch,%al
 movb %al,o_a_epoch

 movb last_activity_slot,%bl
 movb last_activity_gen,%cl
 movb activity_epoch,%ch
 movb $0x51,%al
 movb $0x7e,%ah
 call bind_new_resource
 movb %al,o_bind
 cmpb $'W',%al
 jne fail
 movb last_binding_index,%al
 movb %al,o_bind_index
 movb last_binding_gen,%al
 movb %al,o_bind_gen
 movb last_resource_slot,%al
 movb %al,o_res_slot
 movb last_resource_gen,%al
 movb %al,o_res_gen
 movb resource_epoch,%al
 movb %al,o_res_epoch

 movb o_a_slot,%bl
 movb o_a_gen,%cl
 movb o_a_epoch,%ch
 movb o_bind_index,%dl
 movb o_bind_gen,%dh
 call binding_read
 movb %al,o_read
 movb last_read_value,%al
 movb %al,o_read_val
 cmpb $'W',o_read
 jne fail
 cmpb $0x7e,o_read_val
 jne fail

 call serialize_boot1_record
 call durable_write
 movb %al,o_persist1
 cmpb $'W',%al
 jne fail

 movb o_a_slot,%bl
 movb o_a_gen,%cl
 movb o_a_epoch,%ch
 movb o_bind_index,%dl
 movb o_bind_gen,%dh
 call binding_detach
 movb %al,o_detach
 cmpb $'W',%al
 jne fail
 movw resource_live_count,%ax
 movw %ax,o_live_after_detach
 movb resource_identity,%al
 movb %al,o_res_id_after_detach

 movb o_a_slot,%bl
 movb o_a_gen,%cl
 movb o_a_epoch,%ch
 call activity_release_checked
 movb %al,o_release
 cmpb $'W',%al
 jne fail
 movb act_identity,%al
 movb %al,o_act_id_after_release

 call print_boot1
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

# -----------------------------------------------------------------------------
# Boot 2: verify durable record, create fresh epochs, intentionally reuse indices.
# -----------------------------------------------------------------------------
boot2:
 call verify_boot1_durable_record
 cmpb $'W',%al
 jne fail

 call reset_runtime

 movb $1,o_durable_present
 movb durable_buffer+4,%al
 movb %al,o_dur_id
 movb durable_buffer+5,%al
 movb %al,o_dur_val
 movb durable_buffer+6,%al
 movb %al,o_dur_act_epoch
 movb durable_buffer+7,%al
 movb %al,o_dur_res_epoch

 # Independent restart namespace advancement; ordinary setup fails at 255.
 movb durable_buffer+6,%al
 cmpb $255,%al
 je restart_epoch_exhausted
 incb %al
 movb %al,activity_epoch
 movb durable_buffer+7,%al
 cmpb $255,%al
 je restart_epoch_exhausted
 incb %al
 movb %al,resource_epoch

 # Historical handles must reject before any runtime relation exists.
 movb durable_buffer+8,%bl
 movb durable_buffer+9,%cl
 movb durable_buffer+10,%ch
 movb durable_buffer+11,%dl
 movb durable_buffer+12,%dh
 call binding_read
 movb %al,o_old_bind_pre
 cmpb $'R',%al
 jne fail

 movb durable_buffer+13,%bl
 movb durable_buffer+14,%cl
 movb durable_buffer+15,%ch
 call resource_read
 movb %al,o_old_res_pre
 cmpb $'R',%al
 jne fail

 # Intentionally reuse activity slot/gen under fresh activity epoch.
 movb $0x41,%al
 call activity_acquire
 movb %al,o2_a_acq
 cmpb $'W',%al
 jne fail
 movb last_activity_slot,%al
 movb %al,o2_a_slot
 movb last_activity_gen,%al
 movb %al,o2_a_gen
 movb activity_epoch,%al
 movb %al,o2_a_epoch

 # Explicit rebind reuses binding/resource location+generation under fresh epochs.
 movb o2_a_slot,%bl
 movb o2_a_gen,%cl
 movb o2_a_epoch,%ch
 movb durable_buffer+4,%al
 movb durable_buffer+5,%ah
 call bind_new_resource
 movb %al,o_rebind
 cmpb $'W',%al
 jne fail
 movb last_binding_index,%al
 movb %al,o2_bind_index
 movb last_binding_gen,%al
 movb %al,o2_bind_gen
 movb last_resource_slot,%al
 movb %al,o2_res_slot
 movb last_resource_gen,%al
 movb %al,o2_res_gen
 movb resource_epoch,%al
 movb %al,o2_res_epoch

 # Old binding handle: slot/gen/index/binding-gen all intentionally match,
 # but old activity epoch must reject before resource value exposure.
 movb durable_buffer+8,%bl
 movb durable_buffer+9,%cl
 movb durable_buffer+10,%ch
 movb durable_buffer+11,%dl
 movb durable_buffer+12,%dh
 call binding_read
 movb %al,o_old_bind_post
 cmpb $'R',%al
 jne fail

 # Old direct resource handle: slot/gen intentionally match, old resource epoch rejects.
 movb durable_buffer+13,%bl
 movb durable_buffer+14,%cl
 movb durable_buffer+15,%ch
 call resource_read
 movb %al,o_old_res_post
 cmpb $'R',%al
 jne fail

 # Fresh binding read.
 movb o2_a_slot,%bl
 movb o2_a_gen,%cl
 movb o2_a_epoch,%ch
 movb o2_bind_index,%dl
 movb o2_bind_gen,%dh
 call binding_read
 movb %al,o_fresh_bind
 movb last_read_value,%al
 movb %al,o_fresh_bind_val
 cmpb $'W',o_fresh_bind
 jne fail
 cmpb $0x7e,o_fresh_bind_val
 jne fail

 # Fresh direct resource read.
 movb o2_res_slot,%bl
 movb o2_res_gen,%cl
 movb o2_res_epoch,%ch
 call resource_read
 movb %al,o_fresh_res
 movb last_read_value,%al
 movb %al,o_fresh_res_val
 cmpb $'W',o_fresh_res
 jne fail
 cmpb $0x7e,o_fresh_res_val
 jne fail

 # Negative controls omit only the corresponding namespace epoch.
 movb durable_buffer+8,%bl
 movb durable_buffer+9,%cl
 movb durable_buffer+11,%dl
 movb durable_buffer+12,%dh
 call bad_binding_epochless
 movb %al,o_bad_bind
 movb last_read_value,%al
 movb %al,o_bad_bind_val
 cmpb $'W',o_bad_bind
 jne fail

 movb durable_buffer+13,%bl
 movb durable_buffer+14,%cl
 call bad_resource_epochless
 movb %al,o_bad_res
 movb last_read_value,%al
 movb %al,o_bad_res_val
 cmpb $'W',o_bad_res
 jne fail

 # Boot2 persistence update changes only last activity/resource epoch fields.
 movb activity_epoch,%al
 movb %al,durable_buffer+6
 movb resource_epoch,%al
 movb %al,durable_buffer+7
 call durable_write
 movb %al,o_persist2
 cmpb $'W',%al
 jne fail

 call print_boot2
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
2: hlt
 jmp 2b

restart_epoch_exhausted:
 movb $'G',restart_epoch_status
 jmp fail

fail:
 movw $lab_fail,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
3: hlt
 jmp 3b

# -----------------------------------------------------------------------------
# Firmware durable-sector transport. Exactly CH0/CL18/DH0, one sector.
# -----------------------------------------------------------------------------
durable_read:
 xorw %ax,%ax
 movw %ax,%es
 movw $durable_buffer,%bx
 movb $0x02,%ah
 movb $0x01,%al
 movb $0x00,%ch
 movb $DURABLE_SECTOR,%cl
 movb $0x00,%dh
 movb boot_drive,%dl
 int $0x13
 jc durable_read_fail
 movb $'W',%al
 ret
durable_read_fail:
 movb $'R',%al
 ret

durable_write:
 xorw %ax,%ax
 movw %ax,%es
 movw $durable_buffer,%bx
 movb $0x03,%ah
 movb $0x01,%al
 movb $0x00,%ch
 movb $DURABLE_SECTOR,%cl
 movb $0x00,%dh
 movb boot_drive,%dl
 int $0x13
 jc durable_write_fail
 movb $'W',%al
 ret
durable_write_fail:
 movb $'R',%al
 ret

# -----------------------------------------------------------------------------
# Exact durable serialization / verification.
# -----------------------------------------------------------------------------
serialize_boot1_record:
 xorw %ax,%ax
 movw %ax,%es
 movw $durable_buffer,%di
 movw $512,%cx
 rep stosb
 movb $'H',durable_buffer
 movb $'4',durable_buffer+1
 movb $'P',durable_buffer+2
 movb $'1',durable_buffer+3
 movb $0x51,durable_buffer+4
 movb $0x7e,durable_buffer+5
 movb activity_epoch,%al
 movb %al,durable_buffer+6
 movb resource_epoch,%al
 movb %al,durable_buffer+7
 movb o_a_slot,%al
 movb %al,durable_buffer+8
 movb o_a_gen,%al
 movb %al,durable_buffer+9
 movb o_a_epoch,%al
 movb %al,durable_buffer+10
 movb o_bind_index,%al
 movb %al,durable_buffer+11
 movb o_bind_gen,%al
 movb %al,durable_buffer+12
 movb o_res_slot,%al
 movb %al,durable_buffer+13
 movb o_res_gen,%al
 movb %al,durable_buffer+14
 movb o_res_epoch,%al
 movb %al,durable_buffer+15
 movb $0x34,durable_buffer+16
 movb $0x12,durable_buffer+17
 movb $0x01,durable_buffer+18
 movb $0x00,durable_buffer+19
 ret

verify_boot1_durable_record:
 cmpb $'H',durable_buffer
 jne verify_record_fail
 cmpb $'4',durable_buffer+1
 jne verify_record_fail
 cmpb $'P',durable_buffer+2
 jne verify_record_fail
 cmpb $'1',durable_buffer+3
 jne verify_record_fail
 cmpb $0x51,durable_buffer+4
 jne verify_record_fail
 cmpb $0x7e,durable_buffer+5
 jne verify_record_fail
 cmpb $0x01,durable_buffer+6
 jne verify_record_fail
 cmpb $0x01,durable_buffer+7
 jne verify_record_fail
 cmpb $0x00,durable_buffer+8
 jne verify_record_fail
 cmpb $0x01,durable_buffer+9
 jne verify_record_fail
 cmpb $0x01,durable_buffer+10
 jne verify_record_fail
 cmpb $0x00,durable_buffer+11
 jne verify_record_fail
 cmpb $0x01,durable_buffer+12
 jne verify_record_fail
 cmpb $0x00,durable_buffer+13
 jne verify_record_fail
 cmpb $0x01,durable_buffer+14
 jne verify_record_fail
 cmpb $0x01,durable_buffer+15
 jne verify_record_fail
 cmpb $0x34,durable_buffer+16
 jne verify_record_fail
 cmpb $0x12,durable_buffer+17
 jne verify_record_fail
 cmpb $0x01,durable_buffer+18
 jne verify_record_fail
 cmpb $0x00,durable_buffer+19
 jne verify_record_fail
 movw $durable_buffer+20,%si
 movw $492,%cx
verify_tail_loop:
 cmpb $0,(%si)
 jne verify_record_fail
 incw %si
 loop verify_tail_loop
 movb $'W',%al
 ret
verify_record_fail:
 movb $'R',%al
 ret

# -----------------------------------------------------------------------------
# Runtime reset / activity lifecycle.
# -----------------------------------------------------------------------------
reset_runtime:
 xorw %ax,%ax
 movw %ax,%es
 movw $runtime_state_start,%di
 movw $(runtime_state_end-runtime_state_start),%cx
 rep stosb
 ret

activity_acquire:
 movb %al,input_activity_identity
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
 movb input_activity_identity,%al
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
 movb %bl,last_activity_slot
 movb act_gen(%bx),%al
 movb %al,last_activity_gen
 movb $'W',%al
 ret
activity_acquire_gen_exhausted:
 movb $'G',%al
 ret
activity_acquire_full:
 movb $'F',%al
 ret

save_activity_handle:
 movb %bl,input_activity_slot
 movb %cl,input_activity_gen
 movb %ch,input_activity_epoch
 ret

validate_activity:
 xorw %bx,%bx
 movb input_activity_slot,%bl
 cmpw $ACTIVITY_CAP,%bx
 jae validate_activity_reject
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

binding_base_from_input:
 xorw %ax,%ax
 movb input_activity_slot,%al
 movw %ax,%di
 shlw $4,%di
 movw %ax,%si
 shlw $2,%si
 addw %si,%di
 ret

activity_release_checked:
 call save_activity_handle
 call validate_activity
 cmpb $'W',%al
 jne activity_release_return
 call binding_base_from_input
 movw %di,%si
 xorw %dx,%dx
activity_release_scan:
 cmpw $BINDINGS_PER_ACTIVITY,%dx
 jae activity_release_clear
 cmpb $0,binding_resource_plus1(%si)
 jne activity_release_reject
 incw %si
 incw %dx
 jmp activity_release_scan
activity_release_clear:
 xorw %bx,%bx
 movb input_activity_slot,%bl
 movb $0,act_identity(%bx)
 movb $'W',%al
 ret
activity_release_reject:
 movb $'R',%al
activity_release_return:
 ret

# -----------------------------------------------------------------------------
# Binding/resource operations.
# -----------------------------------------------------------------------------
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
 jae bind_new_full
 cmpb $0,binding_resource_plus1(%si)
 je bind_new_binding_found
 incw %si
 incw %dx
 jmp bind_new_binding_scan
bind_new_binding_found:
 cmpb $255,binding_generation(%si)
 je bind_new_gen_exhausted
 xorw %bx,%bx
bind_new_resource_scan:
 cmpw $RESOURCE_CAP,%bx
 jae bind_new_full
 cmpb $0,resource_identity(%bx)
 je bind_new_resource_found
 incw %bx
 jmp bind_new_resource_scan
bind_new_resource_found:
 cmpb $255,resource_generation(%bx)
 je bind_new_gen_exhausted
 incb resource_generation(%bx)
 movb input_resource_identity,%al
 movb %al,resource_identity(%bx)
 movb input_resource_value,%al
 movb %al,resource_value(%bx)
 movw %bx,%di
 shlw $1,%di
 movw $1,resource_live_count(%di)
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
bind_new_full:
 movb $'F',%al
 ret
bind_new_gen_exhausted:
 movb $'G',%al
 ret
bind_new_return:
 ret

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
binding_detach_return:
 ret

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

# Negative control: validates current activity slot/gen and binding index/gen but omits activity epoch.
bad_binding_epochless:
 movb $0,last_read_value
 movb %bl,input_activity_slot
 movb %cl,input_activity_gen
 movb %dl,input_binding_index
 movb %dh,input_binding_gen
 xorw %bx,%bx
 movb input_activity_slot,%bl
 cmpw $ACTIVITY_CAP,%bx
 jae bad_binding_reject
 cmpb $0,act_identity(%bx)
 je bad_binding_reject
 movb input_activity_gen,%al
 cmpb act_gen(%bx),%al
 jne bad_binding_reject
 cmpb $BINDINGS_PER_ACTIVITY,input_binding_index
 jae bad_binding_reject
 call binding_base_from_input
 xorw %ax,%ax
 movb input_binding_index,%al
 addw %ax,%di
 cmpb $0,binding_resource_plus1(%di)
 je bad_binding_reject
 movb input_binding_gen,%al
 cmpb binding_generation(%di),%al
 jne bad_binding_reject
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

# Negative control: validates resource slot/gen but omits resource epoch.
bad_resource_epochless:
 movb $0,last_read_value
 movb %bl,input_resource_slot
 movb %cl,input_resource_gen
 xorw %bx,%bx
 movb input_resource_slot,%bl
 cmpw $RESOURCE_CAP,%bx
 jae bad_resource_reject
 cmpb $0,resource_identity(%bx)
 je bad_resource_reject
 movb input_resource_gen,%al
 cmpb resource_generation(%bx),%al
 jne bad_resource_reject
 movb resource_value(%bx),%al
 movb %al,last_read_value
 movb $'W',%al
 ret
bad_resource_reject:
 movb $'R',%al
 ret

# -----------------------------------------------------------------------------
# Output helpers.
# -----------------------------------------------------------------------------
print_boot1:
 movw $lab_boot1,%si
 call print_string
 movw $lab_durable_present,%si
 movb o_durable_present,%al
 call print_label_hex8
 movw $lab_a_acq,%si
 movb o_a_acq,%al
 call print_label_char
 movw $lab_a_slot,%si
 movb o_a_slot,%al
 call print_label_hex8
 movw $lab_a_gen,%si
 movb o_a_gen,%al
 call print_label_hex8
 movw $lab_a_epoch,%si
 movb o_a_epoch,%al
 call print_label_hex8
 movw $lab_bind,%si
 movb o_bind,%al
 call print_label_char
 movw $lab_bind_index,%si
 movb o_bind_index,%al
 call print_label_hex8
 movw $lab_bind_gen,%si
 movb o_bind_gen,%al
 call print_label_hex8
 movw $lab_res_slot,%si
 movb o_res_slot,%al
 call print_label_hex8
 movw $lab_res_gen,%si
 movb o_res_gen,%al
 call print_label_hex8
 movw $lab_res_epoch,%si
 movb o_res_epoch,%al
 call print_label_hex8
 movw $lab_read,%si
 movb o_read,%al
 call print_label_char
 movw $lab_read_val,%si
 movb o_read_val,%al
 call print_label_hex8
 movw $lab_persist1,%si
 movb o_persist1,%al
 call print_label_char
 movw $lab_detach,%si
 movb o_detach,%al
 call print_label_char
 movw $lab_live_after_detach,%si
 movw o_live_after_detach,%ax
 call print_label_hex16
 movw $lab_res_id_after_detach,%si
 movb o_res_id_after_detach,%al
 call print_label_hex8
 movw $lab_release,%si
 movb o_release,%al
 call print_label_char
 movw $lab_act_id_after_release,%si
 movb o_act_id_after_release,%al
 call print_label_hex8
 movw $lab_done1,%si
 jmp print_string

print_boot2:
 movw $lab_boot2,%si
 call print_string
 movw $lab_durable_present,%si
 movb o_durable_present,%al
 call print_label_hex8
 movw $lab_dur_id,%si
 movb o_dur_id,%al
 call print_label_hex8
 movw $lab_dur_val,%si
 movb o_dur_val,%al
 call print_label_hex8
 movw $lab_dur_act_epoch,%si
 movb o_dur_act_epoch,%al
 call print_label_hex8
 movw $lab_dur_res_epoch,%si
 movb o_dur_res_epoch,%al
 call print_label_hex8
 movw $lab_old_bind_pre,%si
 movb o_old_bind_pre,%al
 call print_label_char
 movw $lab_old_res_pre,%si
 movb o_old_res_pre,%al
 call print_label_char
 movw $lab_a_acq,%si
 movb o2_a_acq,%al
 call print_label_char
 movw $lab_a_slot,%si
 movb o2_a_slot,%al
 call print_label_hex8
 movw $lab_a_gen,%si
 movb o2_a_gen,%al
 call print_label_hex8
 movw $lab_a_epoch,%si
 movb o2_a_epoch,%al
 call print_label_hex8
 movw $lab_rebind,%si
 movb o_rebind,%al
 call print_label_char
 movw $lab_bind_index,%si
 movb o2_bind_index,%al
 call print_label_hex8
 movw $lab_bind_gen,%si
 movb o2_bind_gen,%al
 call print_label_hex8
 movw $lab_res_slot,%si
 movb o2_res_slot,%al
 call print_label_hex8
 movw $lab_res_gen,%si
 movb o2_res_gen,%al
 call print_label_hex8
 movw $lab_res_epoch,%si
 movb o2_res_epoch,%al
 call print_label_hex8
 movw $lab_old_bind_post,%si
 movb o_old_bind_post,%al
 call print_label_char
 movw $lab_old_res_post,%si
 movb o_old_res_post,%al
 call print_label_char
 movw $lab_fresh_bind,%si
 movb o_fresh_bind,%al
 call print_label_char
 movw $lab_fresh_bind_val,%si
 movb o_fresh_bind_val,%al
 call print_label_hex8
 movw $lab_fresh_res,%si
 movb o_fresh_res,%al
 call print_label_char
 movw $lab_fresh_res_val,%si
 movb o_fresh_res_val,%al
 call print_label_hex8
 movw $lab_bad_bind_epochless,%si
 movb o_bad_bind,%al
 call print_label_char
 movw $lab_bad_bind_val,%si
 movb o_bad_bind_val,%al
 call print_label_hex8
 movw $lab_bad_res_epochless,%si
 movb o_bad_res,%al
 call print_label_char
 movw $lab_bad_res_val,%si
 movb o_bad_res_val,%al
 call print_label_hex8
 movw $lab_persist2,%si
 movb o_persist2,%al
 call print_label_char
 movw $lab_done2,%si
 jmp print_string

print_label_char:
 pushw %ax
 call print_string
 popw %ax
 call print_char
 jmp newline
print_label_hex8:
 pushw %ax
 call print_string
 popw %ax
 call print_hex8
 jmp newline
print_label_hex16:
 pushw %ax
 call print_string
 popw %ax
 call print_hex16
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

.section .rodata
lab_boot1:.asciz "BOOT=1\n"
lab_boot2:.asciz "BOOT=2\n"
lab_durable_present:.asciz "DURABLE_PRESENT="
lab_a_acq:.asciz "A_ACQ="
lab_a_slot:.asciz "A_SLOT="
lab_a_gen:.asciz "A_GEN="
lab_a_epoch:.asciz "A_EPOCH="
lab_bind:.asciz "BIND="
lab_bind_index:.asciz "BIND_INDEX="
lab_bind_gen:.asciz "BIND_GEN="
lab_res_slot:.asciz "RES_SLOT="
lab_res_gen:.asciz "RES_GEN="
lab_res_epoch:.asciz "RES_EPOCH="
lab_read:.asciz "READ="
lab_read_val:.asciz "READ_VAL="
lab_persist1:.asciz "PERSIST1="
lab_detach:.asciz "DETACH="
lab_live_after_detach:.asciz "LIVE_AFTER_DETACH="
lab_res_id_after_detach:.asciz "RES_ID_AFTER_DETACH="
lab_release:.asciz "RELEASE="
lab_act_id_after_release:.asciz "ACT_ID_AFTER_RELEASE="
lab_dur_id:.asciz "DUR_ID="
lab_dur_val:.asciz "DUR_VAL="
lab_dur_act_epoch:.asciz "DUR_ACT_EPOCH="
lab_dur_res_epoch:.asciz "DUR_RES_EPOCH="
lab_old_bind_pre:.asciz "OLD_BIND_PRE="
lab_old_res_pre:.asciz "OLD_RES_PRE="
lab_rebind:.asciz "REBIND="
lab_old_bind_post:.asciz "OLD_BIND_POST="
lab_old_res_post:.asciz "OLD_RES_POST="
lab_fresh_bind:.asciz "FRESH_BIND="
lab_fresh_bind_val:.asciz "FRESH_BIND_VAL="
lab_fresh_res:.asciz "FRESH_RES="
lab_fresh_res_val:.asciz "FRESH_RES_VAL="
lab_bad_bind_epochless:.asciz "BAD_BIND_EPOCHLESS="
lab_bad_bind_val:.asciz "BAD_BIND_VAL="
lab_bad_res_epochless:.asciz "BAD_RES_EPOCHLESS="
lab_bad_res_val:.asciz "BAD_RES_VAL="
lab_persist2:.asciz "PERSIST2="
lab_done1:.asciz "DONE1\n"
lab_done2:.asciz "DONE2\n"
lab_fail:.asciz "FAIL\n"

.section .bss
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
input_activity_identity:.byte 0
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
last_activity_slot:.byte 0
last_activity_gen:.byte 0
last_binding_index:.byte 0
last_binding_gen:.byte 0
last_resource_slot:.byte 0
last_resource_gen:.byte 0
last_read_value:.byte 0
restart_epoch_status:.byte 0
# Boot1 observations
o_durable_present:.byte 0
o_a_acq:.byte 0
o_a_slot:.byte 0
o_a_gen:.byte 0
o_a_epoch:.byte 0
o_bind:.byte 0
o_bind_index:.byte 0
o_bind_gen:.byte 0
o_res_slot:.byte 0
o_res_gen:.byte 0
o_res_epoch:.byte 0
o_read:.byte 0
o_read_val:.byte 0
o_persist1:.byte 0
o_detach:.byte 0
o_live_after_detach:.word 0
o_res_id_after_detach:.byte 0
o_release:.byte 0
o_act_id_after_release:.byte 0
# Boot2 observations
o_dur_id:.byte 0
o_dur_val:.byte 0
o_dur_act_epoch:.byte 0
o_dur_res_epoch:.byte 0
o_old_bind_pre:.byte 0
o_old_res_pre:.byte 0
o2_a_acq:.byte 0
o2_a_slot:.byte 0
o2_a_gen:.byte 0
o2_a_epoch:.byte 0
o_rebind:.byte 0
o2_bind_index:.byte 0
o2_bind_gen:.byte 0
o2_res_slot:.byte 0
o2_res_gen:.byte 0
o2_res_epoch:.byte 0
o_old_bind_post:.byte 0
o_old_res_post:.byte 0
o_fresh_bind:.byte 0
o_fresh_bind_val:.byte 0
o_fresh_res:.byte 0
o_fresh_res_val:.byte 0
o_bad_bind:.byte 0
o_bad_bind_val:.byte 0
o_bad_res:.byte 0
o_bad_res_val:.byte 0
o_persist2:.byte 0
runtime_state_end:
boot_drive:.byte 0
.align 2
durable_buffer:.space 512,0
