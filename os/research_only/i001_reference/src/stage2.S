.code16
.section .text
.global _start
.global runtime_state_start
.global runtime_state_end
.global critical_wait_begin
.global critical_wait_end

.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ BOOT_DRIVE_MEM,0x0500
.equ BUF,0x0600
.equ PIC_MASTER_MASK,0x0021
.equ PIC_SLAVE_MASK,0x00a1
.equ PIC_MASTER_CMD,0x0020
.equ PIT_CH0,0x0040
.equ PIT_CMD,0x0043

_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp
 call read_durable
 jc fatal_io
 call durable_magic_present
 cmpb $1,%al
 je boot2
 jmp boot1

boot1:
 call init_runtime
 movb $1,runtime_epoch
 call save_irq_platform_state
 call install_irq
 call mask_irqs
 sti
 movw $lab_boot,%si
 movb $'1',%al
 call print_line

 movw $0,%bx
 movb $'P',%al
 movb runtime_epoch,%ah
 call acquire_checked
 movw $lab_p_acq,%si
 call print_line
 movb act_gen,%al
 addb $'0',%al
 movw $lab_p_gen,%si
 call print_line

 movw $1,%bx
 movb $'C',%al
 movb runtime_epoch,%ah
 call acquire_checked
 movw $lab_c_acq,%si
 call print_line
 movb act_gen+1,%al
 addb $'0',%al
 movw $lab_c_gen,%si
 call print_line
 movb $0,act_parent_slot+1
 movb act_gen,%al
 movb %al,act_parent_gen+1
 movb $'R',backing_id
 movb $'Z',backing_value
 movb $2,backing_live

 movw $1,%bx
 movb $'B',%al
 movb runtime_epoch,%ah
 call acquire_checked
 movw $lab_b_full,%si
 call print_line
 movb act_identity+1,%al
 movw $lab_full_owner,%si
 call print_line

 call bind_parent_wait
 movb act_cont,%al
 addb $'0',%al
 movw $lab_wait_cont,%si
 call print_line

 movb $'U',%al
 call request_execute
 movw $lab_miss,%si
 call print_line
 movb act_progress,%al
 addb $'0',%al
 movw $lab_miss_prog,%si
 call print_line
 movb act_cont,%al
 addb $'0',%al
 movw $lab_miss_cont,%si
 call print_line

 call program_pit
 call unmask_irq0
 movw $lab_idle,%si
 movb $'1',%al
 call print_line
 sti
wait_irq:
 hlt
 cmpb $0,event_generation
 je wait_irq
 cli
 call mask_irqs
 movb event_generation,%al
 addb $'0',%al
 movw $lab_irq_event,%si
 call print_line
 movb irq_rel_ok,%al
 addb $'0',%al
 movw $lab_irq_rel,%si
 call print_line

 call record_child_completion
 call generic_wait_match
 movw $lab_wake,%si
 call print_line
 movb act_progress,%al
 addb $'0',%al
 movw $lab_wake_prog,%si
 call print_line
 call apply_parent
 movb act_progress,%al
 addb $'0',%al
 movw $lab_apply_prog,%si
 call print_line

 movb $0,act_progress
 call bad_wake_apply
 movb act_progress,%al
 addb $'0',%al
 movw $lab_bad_wake,%si
 call print_line
 movb $2,act_progress

 movw $1,%bx
 call release_binding_activity
 movw $lab_c_release,%si
 call print_line
 movb backing_live,%al
 addb $'0',%al
 movw $lab_life_c_count,%si
 call print_line
 movb backing_value,%al
 movw $lab_life_c_value,%si
 call print_line

 movw $1,%bx
 movb $'B',%al
 movb runtime_epoch,%ah
 call acquire_checked
 movw $lab_b_acq,%si
 call print_line
 movb act_gen+1,%al
 addb $'0',%al
 movw $lab_b_gen,%si
 call print_line
 movb $'K',%al
 call request_execute
 cmpb $'O',%al
 jne fatal_state
 movb $1,act_progress+1
 movb act_progress+1,%al
 addb $'0',%al
 movw $lab_b_prog,%si
 call print_line

 movw $1,%bx
 movb $1,%dl
 movb $1,%dh
 call checked_use_handle
 movw $lab_stale_c,%si
 call print_line
 movb act_identity+1,%al
 movw $lab_bad_stale,%si
 call print_line

 call run_currentness_controls
 movb ctl_flag,%al
 movw $lab_flag_ctl,%si
 call print_line
 movb ctl_ver,%al
 movw $lab_ver_ctl,%si
 call print_line
 movb ctl_stable,%al
 movw $lab_stable_ctl,%si
 call print_line

 call restore_irq_platform_state
 call write_boot1_record
 jc fatal_io
 movw $lab_durable_write,%si
 movb $'W',%al
 call print_line

 movw $0,%bx
 call release_binding_activity
 movw $lab_p_release,%si
 call print_line
 movb backing_live,%al
 addb $'0',%al
 movw $lab_life_p_count,%si
 call print_line
 movb backing_value,%al
 testb %al,%al
 jnz 1f
 movb $'0',%al
1:
 movw $lab_life_p_value,%si
 call print_line

 movw $1,%bx
 call release_activity_only
 movb $255,act_gen+1
 movw $1,%bx
 movb $'B',%al
 movb runtime_epoch,%ah
 call acquire_checked
 movw $lab_gen_exhaust,%si
 call print_line
 movb act_identity+1,%al
 testb %al,%al
 jnz 2f
 movb $'0',%al
2:
 movw $lab_gen_owner,%si
 call print_line

 call bad_global_control
 movw $lab_bad_global,%si
 call print_line
 call bad_full_control
 movw $lab_bad_full_owner,%si
 call print_line

 movw $lab_done,%si
 call print_string
 jmp success_exit

boot2:
 call verify_boot1_record
 cmpb $1,%al
 jne fatal_state
 call init_runtime
 movw $lab_boot,%si
 movb $'2',%al
 call print_line
 movw $lab_durable_pass,%si
 call print_string

 movw $0,%bx
 movb $1,%dl
 movb $1,%dh
 call checked_use_handle
 movw $lab_prebind,%si
 call print_line
 call bad_restart_use
 movw $lab_bad_restart,%si
 call print_line
 call rebind_boot2
 cmpb $'W',%al
 jne fatal_state
 movw $lab_rebind,%si
 call print_line

 movw $0,%bx
 movb $1,%dl
 movb $2,%dh
 call checked_use_handle
 movw $lab_postbind,%si
 call print_line
 movw $0,%bx
 movb $1,%dl
 movb $1,%dh
 call checked_use_handle
 movw $lab_old_token,%si
 call print_line
 movb runtime_epoch,%al
 addb $'0',%al
 movw $lab_epoch,%si
 call print_line
 call write_durable
 jc fatal_io
 movw $lab_durable_rewrite,%si
 movb $'W',%al
 call print_line
 movw $lab_done,%si
 call print_string
 jmp success_exit

init_runtime:
 pushw %di
 pushw %cx
 xorw %ax,%ax
 movw $runtime_state_start,%di
 movw $(runtime_state_end-runtime_state_start),%cx
 rep stosb
 popw %cx
 popw %di
 ret

acquire_checked:
 cmpw $2,%bx
 jae acquire_reject
 cmpb $0,act_identity(%bx)
 jne acquire_full
 cmpb $255,act_gen(%bx)
 je acquire_exhausted
 incb act_gen(%bx)
 movb %al,act_identity(%bx)
 movb %ah,act_epoch(%bx)
 movb $0,act_progress(%bx)
 movb $0,act_cont(%bx)
 movb $0,act_waiting(%bx)
 movb $0,act_woken(%bx)
 movb $0,act_parent_slot(%bx)
 movb $0,act_parent_gen(%bx)
 movb $0,act_wait_slot(%bx)
 movb $0,act_wait_gen(%bx)
 movb $'W',%al
 ret
acquire_full:
 movb $'F',%al
 ret
acquire_exhausted:
 movb $'G',%al
 ret
acquire_reject:
 movb $'R',%al
 ret

release_binding_activity:
 cmpw $2,%bx
 jae release_fail
 cmpb $0,act_identity(%bx)
 je release_fail
 cmpb $0,backing_live
 je release_fail
 decb backing_live
 cmpb $0,backing_live
 jne release_clear_activity
 movb $0,backing_id
 movb $0,backing_value
release_clear_activity:
 movb $0,act_identity(%bx)
 movb $'W',%al
 ret
release_fail:
 movb $'R',%al
 ret

release_activity_only:
 cmpw $2,%bx
 jae release_only_fail
 movb $0,act_identity(%bx)
 movb $'W',%al
 ret
release_only_fail:
 movb $'R',%al
 ret

bind_parent_wait:
 cli
critical_wait_begin:
 movb $1,act_wait_slot
 movb act_gen+1,%al
 movb %al,act_wait_gen
 movb $2,act_cont
 movb $1,act_waiting
 movb $0,act_woken
critical_wait_end:
 sti
 ret

request_execute:
 cmpb $'K',%al
 je request_known
 movb $'M',%al
 ret
request_known:
 movb $'O',%al
 ret

record_child_completion:
 movb $1,completion_slot
 movb act_gen+1,%al
 movb %al,completion_gen
 movb $'S',completion_status
 ret

generic_wait_match:
 cmpb $1,act_waiting
 jne wait_no
 cmpb $'S',completion_status
 jne wait_no
 movb act_wait_slot,%al
 cmpb completion_slot,%al
 jne wait_no
 movb act_wait_gen,%al
 cmpb completion_gen,%al
 jne wait_no
 cmpb $0,act_parent_slot+1
 jne wait_no
 movb act_parent_gen+1,%al
 cmpb act_gen,%al
 jne wait_no
 movb $0,act_waiting
 movb $1,act_woken
 movb $'1',%al
 ret
wait_no:
 movb $'0',%al
 ret

apply_parent:
 cmpb $1,act_woken
 jne apply_done
 movb act_cont,%al
 movb %al,act_progress
apply_done:
 ret

bad_wake_apply:
 movb $1,act_woken
 movb act_cont,%al
 movb %al,act_progress
 ret

checked_use_handle:
 cmpw $2,%bx
 jae handle_reject
 cmpb $0,act_identity(%bx)
 je handle_reject
 movb act_gen(%bx),%al
 cmpb %dl,%al
 jne handle_reject
 movb act_epoch(%bx),%al
 cmpb %dh,%al
 jne handle_reject
 movb $'W',%al
 ret
handle_reject:
 movb $'R',%al
 ret

run_currentness_controls:
 call reset_relation
 movb rel_active,%al
 movb %al,ctl_pre
 movb rel_owner,%al
 movb %al,ctl_old_owner
 call mutate_complete
 movb rel_history,%al
 movb %al,ctl_new_history
 movb rel_active,%al
 movb %al,ctl_post
 movb $'R',ctl_flag
 cmpb $0,ctl_pre
 jne ctl_flag_done
 cmpb $0,ctl_post
 jne ctl_flag_done
 movb ctl_old_owner,%al
 cmpb ctl_new_history,%al
 je ctl_flag_coherent
 movb $'S',ctl_flag
 jmp ctl_flag_done
ctl_flag_coherent:
 movb $'C',ctl_flag
ctl_flag_done:
 call reset_relation
 movb rel_version,%al
 movb %al,ctl_ver_pre
 movb rel_owner,%al
 movb %al,ctl_old_owner
 call mutate_complete
 movb rel_history,%al
 movb %al,ctl_new_history
 movb rel_version,%al
 movb %al,ctl_ver_post
 movb $'R',ctl_ver
 movb ctl_ver_pre,%al
 cmpb ctl_ver_post,%al
 jne ctl_ver_done
 movb ctl_old_owner,%al
 cmpb ctl_new_history,%al
 jne ctl_ver_stale
 movb $'C',ctl_ver
 jmp ctl_ver_done
ctl_ver_stale:
 movb $'S',ctl_ver
ctl_ver_done:
 movb rel_version,%al
 movb %al,ctl_ver_pre
 movb rel_owner,%al
 movb %al,ctl_old_owner
 movb rel_history,%al
 movb %al,ctl_new_history
 movb rel_version,%al
 movb %al,ctl_ver_post
 movb $'R',ctl_stable
 movb ctl_ver_pre,%al
 cmpb ctl_ver_post,%al
 jne ctl_stable_done
 movb ctl_old_owner,%al
 cmpb ctl_new_history,%al
 jne ctl_stable_stale
 movb $'C',ctl_stable
 jmp ctl_stable_done
ctl_stable_stale:
 movb $'S',ctl_stable
ctl_stable_done:
 ret

reset_relation:
 movb $'A',rel_owner
 movb $'A',rel_history
 movb $0,rel_active
 movb $1,rel_version
 ret
mutate_complete:
 movb $1,rel_active
 movb $'B',rel_owner
 movb $'B',rel_history
 incb rel_version
 movb $0,rel_active
 ret

bad_global_control:
 movb $0,bad_global_latch
 movb $'U',%al
 call bad_request_global
 cmpb $0,bad_global_latch
 jne bad_global_blocked
 movb $'O',%al
 ret
bad_global_blocked:
 movb $'X',%al
 ret
bad_request_global:
 cmpb $'K',%al
 je bad_request_ok
 movb $1,bad_global_latch
 movb $'M',%al
 ret
bad_request_ok:
 movb $'O',%al
 ret

bad_full_control:
 movb $'P',act_identity
 movb $'C',act_identity+1
 movb $'B',act_identity+1
 movb act_identity+1,%al
 ret

bad_restart_use:
 movb BUF+4,%al
 cmpb $'R',%al
 jne bad_restart_fail
 movb $'W',%al
 ret
bad_restart_fail:
 movb $'R',%al
 ret

rebind_boot2:
 movb BUF+8,%al
 cmpb $255,%al
 je rebind_exhausted
 incb %al
 movb %al,runtime_epoch
 movb %al,BUF+8
 movw $0,%bx
 movb $'P',%al
 movb runtime_epoch,%ah
 call acquire_checked
 cmpb $'W',%al
 jne rebind_done
 movb BUF+4,%dl
 movb %dl,backing_id
 movb BUF+5,%dl
 movb %dl,backing_value
 movb $1,backing_live
rebind_done:
 ret
rebind_exhausted:
 movb $'G',%al
 ret

save_irq_platform_state:
 movw 0x0020,%ax
 movw %ax,saved_irq0_off
 movw 0x0022,%ax
 movw %ax,saved_irq0_seg
 movw $PIC_MASTER_MASK,%dx
 inb %dx,%al
 movb %al,saved_master_mask
 movw $PIC_SLAVE_MASK,%dx
 inb %dx,%al
 movb %al,saved_slave_mask
 ret
restore_irq_platform_state:
 cli
 movw saved_irq0_off,%ax
 movw %ax,0x0020
 movw saved_irq0_seg,%ax
 movw %ax,0x0022
 movw $PIC_MASTER_MASK,%dx
 movb saved_master_mask,%al
 outb %al,%dx
 movw $PIC_SLAVE_MASK,%dx
 movb saved_slave_mask,%al
 outb %al,%dx
 ret

install_irq:
 movw $irq0_handler,0x0020
 movw $0,0x0022
 ret
mask_irqs:
 cli
 movw $PIC_MASTER_MASK,%dx
 movb $0xff,%al
 outb %al,%dx
 movw $PIC_SLAVE_MASK,%dx
 outb %al,%dx
 ret
unmask_irq0:
 movw $PIC_MASTER_MASK,%dx
 movb $0xfe,%al
 outb %al,%dx
 ret
program_pit:
 movw $PIT_CMD,%dx
 movb $0x30,%al
 outb %al,%dx
 movw $0x1000,%ax
 movw $PIT_CH0,%dx
 outb %al,%dx
 movb %ah,%al
 outb %al,%dx
 ret
irq0_handler:
 pushw %ax
 pushw %dx
 incb event_generation
 movb $0,irq_rel_ok
 cmpb $1,act_wait_slot
 jne irq_done_check
 movb act_gen+1,%al
 cmpb act_wait_gen,%al
 jne irq_done_check
 cmpb $2,act_cont
 jne irq_done_check
 cmpb $1,act_waiting
 jne irq_done_check
 movb $1,irq_rel_ok
irq_done_check:
 movw $PIC_MASTER_CMD,%dx
 movb $0x20,%al
 outb %al,%dx
 popw %dx
 popw %ax
 iret

read_durable:
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %dx
 movw $BUF,%bx
 movb $0x02,%ah
 movb $0x01,%al
 movb $0x00,%ch
 movb $0x0a,%cl
 movb $0x00,%dh
 movb BOOT_DRIVE_MEM,%dl
 int $0x13
 popw %dx
 popw %cx
 popw %bx
 popw %ax
 ret
write_durable:
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %dx
 movw $BUF,%bx
 movb $0x03,%ah
 movb $0x01,%al
 movb $0x00,%ch
 movb $0x0a,%cl
 movb $0x00,%dh
 movb BOOT_DRIVE_MEM,%dl
 int $0x13
 popw %dx
 popw %cx
 popw %bx
 popw %ax
 ret

durable_magic_present:
 movw $BUF,%si
 movw $durable_magic,%di
 movw $4,%cx
magic_loop:
 movb (%si),%al
 cmpb (%di),%al
 jne magic_absent
 incw %si
 incw %di
 loop magic_loop
 movb $1,%al
 ret
magic_absent:
 movb $0,%al
 ret

write_boot1_record:
 pushw %di
 pushw %cx
 xorw %ax,%ax
 movw $BUF,%di
 movw $256,%cx
 rep stosw
 movb $'H',BUF+0
 movb $'4',BUF+1
 movb $'I',BUF+2
 movb $'1',BUF+3
 movb $'R',BUF+4
 movb $'Z',BUF+5
 movb $0x34,BUF+6
 movb $0x12,BUF+7
 movb $1,BUF+8
 movb $0,BUF+9
 movb $1,BUF+10
 movb $1,BUF+11
 popw %cx
 popw %di
 call write_durable
 ret

verify_boot1_record:
 cmpb $'H',BUF+0
 jne verify_fail
 cmpb $'4',BUF+1
 jne verify_fail
 cmpb $'I',BUF+2
 jne verify_fail
 cmpb $'1',BUF+3
 jne verify_fail
 cmpb $'R',BUF+4
 jne verify_fail
 cmpb $'Z',BUF+5
 jne verify_fail
 cmpb $0x34,BUF+6
 jne verify_fail
 cmpb $0x12,BUF+7
 jne verify_fail
 cmpb $1,BUF+8
 jne verify_fail
 cmpb $0,BUF+9
 jne verify_fail
 cmpb $1,BUF+10
 jne verify_fail
 cmpb $1,BUF+11
 jne verify_fail
 movb $1,%al
 ret
verify_fail:
 movb $0,%al
 ret

print_line:
 pushw %ax
 call print_string
 popw %ax
 call print_char
 movb $'\n',%al
 jmp print_char
print_string:
 pushw %ax
 pushw %dx
print_loop:
 lodsb
 testb %al,%al
 jz print_done
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp print_loop
print_done:
 popw %dx
 popw %ax
 ret
print_char:
 pushw %dx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popw %dx
 ret

success_exit:
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
3: hlt
 jmp 3b
fatal_io:
 movw $lab_io_fail,%si
 call print_string
 jmp failure_exit
fatal_state:
 movw $lab_state_fail,%si
 call print_string
failure_exit:
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
4: hlt
 jmp 4b

.section .data
runtime_state_start:
act_identity:.byte 0,0
act_gen:.byte 0,0
act_progress:.byte 0,0
act_cont:.byte 0,0
act_waiting:.byte 0,0
act_woken:.byte 0,0
act_parent_slot:.byte 0,0
act_parent_gen:.byte 0,0
act_wait_slot:.byte 0,0
act_wait_gen:.byte 0,0
act_epoch:.byte 0,0
backing_id:.byte 0
backing_value:.byte 0
backing_live:.byte 0
completion_slot:.byte 0
completion_gen:.byte 0
completion_status:.byte 0
event_generation:.byte 0
irq_rel_ok:.byte 0
runtime_epoch:.byte 0
rel_owner:.byte 0
rel_history:.byte 0
rel_active:.byte 0
rel_version:.byte 0
ctl_pre:.byte 0
ctl_post:.byte 0
ctl_old_owner:.byte 0
ctl_new_history:.byte 0
ctl_ver_pre:.byte 0
ctl_ver_post:.byte 0
ctl_flag:.byte 0
ctl_ver:.byte 0
ctl_stable:.byte 0
bad_global_latch:.byte 0
saved_irq0_off:.word 0
saved_irq0_seg:.word 0
saved_master_mask:.byte 0
saved_slave_mask:.byte 0
runtime_state_end:

durable_magic:.ascii "H4I1"
lab_boot:.asciz "BOOT="
lab_p_acq:.asciz "P_ACQ="
lab_p_gen:.asciz "P_GEN="
lab_c_acq:.asciz "C_ACQ="
lab_c_gen:.asciz "C_GEN="
lab_b_full:.asciz "B_FULL="
lab_full_owner:.asciz "FULL_OWNER="
lab_wait_cont:.asciz "WAIT_CONT="
lab_miss:.asciz "MISS="
lab_miss_prog:.asciz "MISS_PROG="
lab_miss_cont:.asciz "MISS_CONT="
lab_idle:.asciz "IDLE_ENTER="
lab_irq_event:.asciz "IRQ_EVENT="
lab_irq_rel:.asciz "IRQ_REL="
lab_wake:.asciz "WAKE="
lab_wake_prog:.asciz "WAKE_PROG="
lab_apply_prog:.asciz "APPLY_PROG="
lab_bad_wake:.asciz "BAD_WAKE_PROG="
lab_c_release:.asciz "C_RELEASE="
lab_life_c_count:.asciz "LIFE_C_COUNT="
lab_life_c_value:.asciz "LIFE_C_VALUE="
lab_b_acq:.asciz "B_ACQ="
lab_b_gen:.asciz "B_GEN="
lab_b_prog:.asciz "B_PROG="
lab_stale_c:.asciz "STALE_C="
lab_bad_stale:.asciz "BAD_STALE="
lab_flag_ctl:.asciz "FLAG_CTL="
lab_ver_ctl:.asciz "VER_CTL="
lab_stable_ctl:.asciz "STABLE_CTL="
lab_durable_write:.asciz "DURABLE_WRITE="
lab_p_release:.asciz "P_RELEASE="
lab_life_p_count:.asciz "LIFE_P_COUNT="
lab_life_p_value:.asciz "LIFE_P_VALUE="
lab_gen_exhaust:.asciz "GEN_EXHAUST="
lab_gen_owner:.asciz "GEN_OWNER="
lab_bad_global:.asciz "BAD_GLOBAL_B="
lab_bad_full_owner:.asciz "BAD_FULL_OWNER="
lab_durable_pass:.asciz "DURABLE=PASS\n"
lab_prebind:.asciz "PREBIND="
lab_bad_restart:.asciz "BAD_RESTART_USE="
lab_rebind:.asciz "REBIND="
lab_postbind:.asciz "POSTBIND="
lab_old_token:.asciz "OLD_TOKEN="
lab_epoch:.asciz "EPOCH="
lab_durable_rewrite:.asciz "DURABLE_REWRITE="
lab_done:.asciz "DONE\n"
lab_io_fail:.asciz "IO_FAIL\n"
lab_state_fail:.asciz "STATE_FAIL\n"
