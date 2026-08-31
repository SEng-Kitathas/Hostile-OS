.code16
.section .text
.global _start

.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ ACTIVITY_CAP,64
.equ BINDINGS_PER_ACTIVITY,20
.equ BINDING_CELL_COUNT,1280
.equ RESOURCE_CAP,64
.equ DURABLE_A_BUF,0x7000
.equ DURABLE_B_BUF,0x7200
.equ MODE_BUF,0x7400
.equ STACK_TOP,0x7a00
.equ QUAL_STAGE1_BOOT_DRIVE_MEM,0x7c4b
.equ PIC_MASTER_CMD,0x0020
.equ PIC_MASTER_MASK,0x0021
.equ PIC_SLAVE_MASK,0x00a1
.equ PIT_CH0,0x0040
.equ PIT_CMD,0x0043
.equ SMP_LAPIC_ID,0xfee00020
.equ SMP_LAPIC_ICR_LOW,0xfee00300
.equ SMP_LAPIC_ICR_HIGH,0xfee00310
.equ SMP_AP_TRAMP,0x6000
.equ SMP_AP_VECTOR,0x06

_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $STACK_TOP,%sp
 movb QUAL_STAGE1_BOOT_DRIVE_MEM,%al
 movb %al,boot_drive
 call detect_mode
 cmpb $'S',%al
 je start_smp
 cmpb $'R',%al
 je start_restart
 cmpb $'F',%al
 je start_fault
 call core_review
 call irq_review
 jmp start_done
start_smp:
 call smp_min_review
 jmp start_done
start_restart:
 call persistence_restart_review
 jmp start_done
start_fault:
 call persistence_fault_review
start_done:
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

# -----------------------------------------------------------------------------
# Mode control and durable record/restart reviewer layer.
# Control sector is LBA19 / C0-H1-S2 and contains "V2MD" + mode byte.
# Durable candidates are A=LBA17/C0-H0-S18, B=LBA18/C0-H1-S1.
# -----------------------------------------------------------------------------
detect_mode:
 movb $'C',%al
 movw $MODE_BUF,%bx
 movb $1,%dh
 movb $2,%cl
 call bios_read_sector
 jc detect_mode_done
 cmpw $0x3256,MODE_BUF
 jne detect_mode_done
 cmpw $0x444d,MODE_BUF+2
 jne detect_mode_done
 movb MODE_BUF+4,%al
detect_mode_done:
 ret

bios_read_sector:
 # BX buffer, DH head, CL sector. Cylinder0, one sector, saved boot drive.
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %dx
 movb $0x02,%ah
 movb $0x01,%al
 movb $0,%ch
 movb boot_drive,%dl
 int $0x13
 popw %dx
 popw %cx
 popw %bx
 popw %ax
 ret
bios_write_sector:
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %dx
 movb $0x03,%ah
 movb $0x01,%al
 movb $0,%ch
 movb boot_drive,%dl
 int $0x13
 popw %dx
 popw %cx
 popw %bx
 popw %ax
 ret

read_durable_candidates:
 movw $DURABLE_A_BUF,%bx
 movb $0,%dh
 movb $18,%cl
 call bios_read_sector
 jc persist_io_fail
 movw $DURABLE_B_BUF,%bx
 movb $1,%dh
 movb $1,%cl
 call bios_read_sector
 jc persist_io_fail
 movw $DURABLE_A_BUF,%si
 call record_validate
 movb %al,durable_a_valid
 movw $DURABLE_B_BUF,%si
 call record_validate
 movb %al,durable_b_valid
 clc
 ret
persist_io_fail:
 stc
 ret

# AL=1 only for structure+CRC+CMIT-valid 30-byte FR01 record at SI.
record_validate:
 pushw %bx
 pushw %cx
 pushw %dx
 pushw %si
 movb $0,%al
 cmpw $0x3448,0(%si)
 jne record_validate_done
 cmpw $0x3146,2(%si)
 jne record_validate_done
 cmpw $0x1234,16(%si)
 jne record_validate_done
 cmpb $1,18(%si)
 jne record_validate_done
 cmpb $0,19(%si)
 jne record_validate_done
 cmpw $0x4d43,26(%si)
 jne record_validate_done
 cmpw $0x5449,28(%si)
 jne record_validate_done
 call crc16_payload
 cmpw 24(%si),%dx
 jne record_validate_done
 movb $1,%al
record_validate_done:
 popw %si
 popw %dx
 popw %cx
 popw %bx
 ret

# CRC-16/CCITT-FALSE over 24 bytes at SI, result DX.
crc16_payload:
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %si
 movw $0xffff,%dx
 movw $24,%cx
crc16_byte:
 movb (%si),%al
 incw %si
 xorb %dh,%al
 movb %al,%dh
 movb $8,%bl
crc16_bit:
 shlw $1,%dx
 jnc crc16_no_poly
 xorw $0x1021,%dx
crc16_no_poly:
 decb %bl
 jnz crc16_bit
 loop crc16_byte
 popw %si
 popw %cx
 popw %bx
 popw %ax
 ret

select_durable:
 movb $'N',durable_select
 movw $0,durable_selected_ptr
 cmpb $1,durable_a_valid
 je select_a_valid
 cmpb $1,durable_b_valid
 je select_choose_b
 ret
select_a_valid:
 cmpb $1,durable_b_valid
 jne select_choose_a
 movw $DURABLE_A_BUF,%si
 movw $DURABLE_B_BUF,%di
 movw 22(%si),%ax
 cmpw 22(%di),%ax
 ja select_choose_a
 jb select_choose_b
 movw 20(%si),%ax
 cmpw 20(%di),%ax
 ja select_choose_a
 jb select_choose_b
 # Equal sequence: byte-identical logical records are equivalent; conflict fails X.
 pushw %si
 pushw %di
 movw $30,%cx
 repe cmpsb
 popw %di
 popw %si
 jne select_conflict
 jmp select_choose_a
select_conflict:
 movb $'X',durable_select
 ret
select_choose_a:
 movb $'A',durable_select
 movw $DURABLE_A_BUF,durable_selected_ptr
 jmp select_epoch_check
select_choose_b:
 movb $'B',durable_select
 movw $DURABLE_B_BUF,durable_selected_ptr
select_epoch_check:
 movw durable_selected_ptr,%si
 cmpb $0xff,6(%si)
 je select_epoch_exhaust
 cmpb $0xff,7(%si)
 je select_epoch_exhaust
 ret
select_epoch_exhaust:
 movb $'G',durable_select
 movw $0,durable_selected_ptr
 ret

# True only if first30 logical bytes of A and B are all zero.
records_uninitialized:
 movw $DURABLE_A_BUF,%si
 movw $30,%cx
records_zero_a:
 cmpb $0,(%si)
 jne records_not_zero
 incw %si
 loop records_zero_a
 movw $DURABLE_B_BUF,%si
 movw $30,%cx
records_zero_b:
 cmpb $0,(%si)
 jne records_not_zero
 incw %si
 loop records_zero_b
 movb $1,%al
 ret
records_not_zero:
 movb $0,%al
 ret

persistence_restart_review:
 movw $lab_persist_test,%si
 call print_string
 movw $lab_mode_r,%si
 call print_string
 call read_durable_candidates
 jc persistence_fail_io
 call records_uninitialized
 cmpb $1,%al
 je persistence_bootstrap_write
 call select_durable
 movw $lab_phase_recover,%si
 call print_string
 call persistence_recover_and_print
 ret
persistence_bootstrap_write:
 movw $lab_phase_write,%si
 call print_string
 call build_bootstrap_relation_and_record
 jc persistence_fail_io
 movw $lab_write_a,%si
 call print_string
 movw $lab_persist_done,%si
 call print_string
 ret
persistence_fail_io:
 movw $lab_persist_iofail,%si
 call print_string
 ret

persistence_fault_review:
 movw $lab_persist_test,%si
 call print_string
 movw $lab_mode_f,%si
 call print_string
 call read_durable_candidates
 jc persistence_fail_io
 call select_durable
 movw $lab_phase_recover,%si
 call print_string
 call persistence_recover_and_print
 ret

# Establish a live relation, serialize only durable meaning/currentness history,
# CRC+commit it, and write candidate A. B remains untouched.
build_bootstrap_relation_and_record:
 call init_runtime
 movb $0x41,input_identity
 call activity_acquire
 movb output_slot,%al
 movb %al,saved_act0_slot
 movb output_gen,%al
 movb %al,saved_act0_gen
 movb output_epoch,%al
 movb %al,saved_act0_epoch
 movb $0x51,input_identity
 movb $0x71,input_value
 call resource_create
 movb output_slot,%al
 movb %al,saved_res_slot
 movb output_gen,%al
 movb %al,saved_res_gen
 movb output_epoch,%al
 movb %al,saved_res_epoch
 call load_saved_act0
 call load_saved_res
 call binding_attach_first
 movb output_binding,%al
 movb %al,saved_bind0_index
 movb output_binding_gen,%al
 movb %al,saved_bind0_gen
 # Zero candidate sector then serialize 24-byte payload.
 xorw %ax,%ax
 movw $DURABLE_A_BUF,%di
 movw $512,%cx
 rep stosb
 movw $DURABLE_A_BUF,%di
 movw $0x3448,0(%di)
 movw $0x3146,2(%di)
 movb $0x51,4(%di)
 movb $0x71,5(%di)
 movb activity_epoch_global,%al
 movb %al,6(%di)
 movb resource_epoch_global,%al
 movb %al,7(%di)
 movb saved_act0_slot,%al
 movb %al,8(%di)
 movb saved_act0_gen,%al
 movb %al,9(%di)
 movb saved_act0_epoch,%al
 movb %al,10(%di)
 movb saved_bind0_index,%al
 movb %al,11(%di)
 movb saved_bind0_gen,%al
 movb %al,12(%di)
 movb saved_res_slot,%al
 movb %al,13(%di)
 movb saved_res_gen,%al
 movb %al,14(%di)
 movb saved_res_epoch,%al
 movb %al,15(%di)
 movw $0x1234,16(%di)
 movb $1,18(%di)
 movb $0,19(%di)
 movw $1,20(%di)
 movw $0,22(%di)
 movw $DURABLE_A_BUF,%si
 call crc16_payload
 movw %dx,24(%di)
 movw $0x4d43,26(%di)
 movw $0x5449,28(%di)
 movw $DURABLE_A_BUF,%bx
 movb $0,%dh
 movb $18,%cl
 call bios_write_sector
 ret

persistence_recover_and_print:
 movw $lab_select,%si
 call print_string
 movb durable_select,%al
 call print_char
 call newline
 movb $0,durable_recovered_value
 movb $'-',durable_old_bind_status
 movb $'-',durable_old_res_status
 movb $'-',durable_fresh_bind_status
 movb $0,durable_fresh_value
 movw durable_selected_ptr,%si
 cmpw $0,%si
 je persistence_print_recovery
 movb 5(%si),%al
 movb %al,durable_recovered_value
 # Fresh namespace epochs derive from durable prior epochs +1.
 movb 6(%si),%al
 incb %al
 movb %al,tmp_count
 movb 7(%si),%al
 incb %al
 movb %al,tmp_identity
 call init_runtime
 movb tmp_count,%al
 movb %al,activity_epoch_global
 movb tmp_identity,%al
 movb %al,resource_epoch_global
 movb $0x41,input_identity
 call activity_acquire
 movb output_slot,%al
 movb %al,saved_act0_slot
 movb output_gen,%al
 movb %al,saved_act0_gen
 movb output_epoch,%al
 movb %al,saved_act0_epoch
 movw durable_selected_ptr,%si
 movb 4(%si),%al
 movb %al,input_identity
 movb 5(%si),%al
 movb %al,input_value
 call resource_create
 movb output_slot,%al
 movb %al,saved_res_slot
 movb output_gen,%al
 movb %al,saved_res_gen
 movb output_epoch,%al
 movb %al,saved_res_epoch
 call load_saved_act0
 call load_saved_res
 call binding_attach_first
 movb output_binding,%al
 movb %al,saved_bind0_index
 movb output_binding_gen,%al
 movb %al,saved_bind0_gen
 # Historical binding handle from durable record must reject under fresh epoch.
 movw durable_selected_ptr,%si
 movb 8(%si),%al
 movb %al,input_activity_slot
 movb 9(%si),%al
 movb %al,input_activity_gen
 movb 10(%si),%al
 movb %al,input_activity_epoch
 movb 11(%si),%al
 movb %al,input_binding_index
 movb 12(%si),%al
 movb %al,input_binding_gen
 call binding_read
 movb %al,durable_old_bind_status
 # Historical direct resource handle must reject under fresh resource epoch.
 movw durable_selected_ptr,%si
 movb 13(%si),%al
 movb %al,input_resource_slot
 movb 14(%si),%al
 movb %al,input_resource_gen
 movb 15(%si),%al
 movb %al,input_resource_epoch
 call resource_read
 movb %al,durable_old_res_status
 # Fresh relation reads selected value.
 call load_saved_act0
 movb saved_bind0_index,%al
 movb %al,input_binding_index
 movb saved_bind0_gen,%al
 movb %al,input_binding_gen
 call binding_read
 movb %al,durable_fresh_bind_status
 movb last_value,%al
 movb %al,durable_fresh_value
persistence_print_recovery:
 movw $lab_dur_val,%si
 call print_string
 movb durable_recovered_value,%al
 call print_hex8
 call newline
 movw $lab_persist_old_bind,%si
 call print_string
 movb durable_old_bind_status,%al
 call print_char
 call newline
 movw $lab_persist_old_res,%si
 call print_string
 movb durable_old_res_status,%al
 call print_char
 call newline
 movw $lab_persist_fresh_bind,%si
 call print_string
 movb durable_fresh_bind_status,%al
 call print_char
 call newline
 movw $lab_persist_fresh_val,%si
 call print_string
 movb durable_fresh_value,%al
 call print_hex8
 call newline
 movw $lab_persist_done,%si
 call print_string
 ret

# -----------------------------------------------------------------------------
# Reviewer workload: finite capacity, checked currentness, binding sharing,
# local missing, lifecycle blocking, shared lifetime, stale resource reuse.
# This is embodiment/reviewer behavior, not new scientific evidence.
# -----------------------------------------------------------------------------
core_review:
 movw $lab_test,%si
 call print_string

 # Phase A: activity capacity 64, then explicit full.
 call init_runtime
 movb $1,tmp_identity
 movb $0,tmp_count
core_fill_activities:
 movb tmp_identity,%al
 movb %al,input_identity
 call activity_acquire
 cmpb $'W',%al
 jne core_capacity_done
 incb tmp_count
 incb tmp_identity
 cmpb $64,tmp_count
 jb core_fill_activities
core_capacity_done:
 movw $lab_act_filled,%si
 call print_string
 movb tmp_count,%al
 call print_hex8
 call newline
 movb $0x7f,input_identity
 call activity_acquire
 movw $lab_act_over,%si
 call print_string
 call print_char
 call newline

 # Phase B: one activity, one shared resource, fill all 20 binding cells.
 call init_runtime
 movb $0x41,input_identity
 call activity_acquire
 movb output_slot,%al
 movb %al,saved_act0_slot
 movb output_gen,%al
 movb %al,saved_act0_gen
 movb output_epoch,%al
 movb %al,saved_act0_epoch
 movb $0x51,input_identity
 movb $0x7e,input_value
 call resource_create
 movb output_slot,%al
 movb %al,saved_res_slot
 movb output_gen,%al
 movb %al,saved_res_gen
 movb output_epoch,%al
 movb %al,saved_res_epoch
 movb $0,tmp_count
core_fill_row:
 call load_saved_act0
 call load_saved_res
 call binding_attach_first
 cmpb $'W',%al
 jne core_row_done
 incb tmp_count
 cmpb $20,tmp_count
 jb core_fill_row
core_row_done:
 movw $lab_row_filled,%si
 call print_string
 movb tmp_count,%al
 call print_hex8
 call newline
 call load_saved_act0
 call load_saved_res
 call binding_attach_first
 movw $lab_row_over,%si
 call print_string
 call print_char
 call newline

 # Phase C: two activities share one resource, then exercise stale/current paths.
 call init_runtime
 movb $0x41,input_identity
 call activity_acquire
 movb output_slot,%al
 movb %al,saved_act0_slot
 movb output_gen,%al
 movb %al,saved_act0_gen
 movb output_epoch,%al
 movb %al,saved_act0_epoch
 movb $0x42,input_identity
 call activity_acquire
 movb output_slot,%al
 movb %al,saved_act1_slot
 movb output_gen,%al
 movb %al,saved_act1_gen
 movb output_epoch,%al
 movb %al,saved_act1_epoch
 movb $0x51,input_identity
 movb $0x7e,input_value
 call resource_create
 movb output_slot,%al
 movb %al,saved_res_slot
 movb output_gen,%al
 movb %al,saved_res_gen
 movb output_epoch,%al
 movb %al,saved_res_epoch
 call load_saved_act0
 call load_saved_res
 call binding_attach_first
 movb output_binding,%al
 movb %al,saved_bind0_index
 movb output_binding_gen,%al
 movb %al,saved_bind0_gen
 call load_saved_act1
 call load_saved_res
 call binding_attach_first
 movb output_binding,%al
 movb %al,saved_bind1_index
 movb output_binding_gen,%al
 movb %al,saved_bind1_gen

 # Shared live count must be 2.
 xorw %bx,%bx
 movb saved_res_slot,%bl
 shlw $1,%bx
 movw resource_live_count(%bx),%ax
 movw $lab_share_live,%si
 call print_string
 call print_hex16
 call newline

 # Deliberately stale binding generation.
 call load_saved_act0
 movb saved_bind0_index,%al
 movb %al,input_binding_index
 movb saved_bind0_gen,%al
 incb %al
 movb %al,input_binding_gen
 call binding_read
 movw $lab_stale_bind,%si
 call print_string
 call print_char
 call newline

 # Fresh binding reads resource value.
 call load_saved_act0
 movb saved_bind0_index,%al
 movb %al,input_binding_index
 movb saved_bind0_gen,%al
 movb %al,input_binding_gen
 call binding_read
 movw $lab_fresh_bind,%si
 call print_string
 call print_char
 call newline
 movw $lab_fresh_bind_val,%si
 call print_string
 movb last_value,%al
 call print_hex8
 call newline

 # Empty local binding cell is MISSING, not global failure.
 call load_saved_act0
 movb $1,input_binding_index
 movb $0,input_binding_gen
 call binding_read
 movw $lab_missing_bind,%si
 call print_string
 call print_char
 call newline

 # Bound activity cannot be released.
 call load_saved_act0
 call activity_release
 movw $lab_release_bound,%si
 call print_string
 call print_char
 call newline

 # Detach first binding; resource remains live with count1.
 call load_saved_act0
 movb saved_bind0_index,%al
 movb %al,input_binding_index
 movb saved_bind0_gen,%al
 movb %al,input_binding_gen
 call binding_detach
 xorw %bx,%bx
 movb saved_res_slot,%bl
 shlw $1,%bx
 movw resource_live_count(%bx),%ax
 movw $lab_detach_one,%si
 call print_string
 call print_hex16
 call newline

 # Detach last binding; resource is reclaimed at zero live count.
 call load_saved_act1
 movb saved_bind1_index,%al
 movb %al,input_binding_index
 movb saved_bind1_gen,%al
 movb %al,input_binding_gen
 call binding_detach
 xorw %bx,%bx
 movb saved_res_slot,%bl
 shlw $1,%bx
 movw resource_live_count(%bx),%ax
 movw $lab_detach_last,%si
 call print_string
 call print_hex16
 call newline

 # Reuse same resource slot; generation advances. Old handle must reject.
 movb $0x52,input_identity
 movb $0x55,input_value
 call resource_create
 movb output_slot,%al
 movb %al,saved_new_res_slot
 movb output_gen,%al
 movb %al,saved_new_res_gen
 movb output_epoch,%al
 movb %al,saved_new_res_epoch
 movb saved_res_slot,%al
 movb %al,input_resource_slot
 movb saved_res_gen,%al
 movb %al,input_resource_gen
 movb saved_res_epoch,%al
 movb %al,input_resource_epoch
 call resource_read
 movw $lab_old_res,%si
 call print_string
 call print_char
 call newline
 movb saved_new_res_slot,%al
 movb %al,input_resource_slot
 movb saved_new_res_gen,%al
 movb %al,input_resource_gen
 movb saved_new_res_epoch,%al
 movb %al,input_resource_epoch
 call resource_read
 movw $lab_new_res,%si
 call print_string
 call print_char
 call newline
 movw $lab_new_res_val,%si
 call print_string
 movb last_value,%al
 call print_hex8
 call newline

 movw $lab_done,%si
 call print_string
 ret

# -----------------------------------------------------------------------------
# Real IRQ0 reviewer workload. Event count is observed, but semantic wake depends
# on the current wait relation. Tested reviewer phases use counts 1 and 2 only.
# -----------------------------------------------------------------------------
irq_review:
 movw $lab_irq_test,%si
 call print_string
 # Valid relation, one real IRQ0 event.
 movb $1,%al
 movb $0,%ah
 call irq_case
 movw $lab_irq_one_event,%si
 call print_string
 movb irq_event_count,%al
 call print_hex8
 call newline
 movw $lab_irq_one_rel,%si
 call print_string
 movb irq_relation_ok,%al
 call print_bit
 call newline
 movw $lab_irq_one_wake,%si
 call print_string
 movb activity_woken,%al
 call print_bit
 call newline
 movw $lab_irq_one_prog,%si
 call print_string
 movb activity_progress,%al
 call print_hex8
 call newline

 # Valid relation, two real IRQ0 events. Same semantic consequence.
 movb $2,%al
 movb $0,%ah
 call irq_case
 movw $lab_irq_two_event,%si
 call print_string
 movb irq_event_count,%al
 call print_hex8
 call newline
 movw $lab_irq_two_rel,%si
 call print_string
 movb irq_relation_ok,%al
 call print_bit
 call newline
 movw $lab_irq_two_wake,%si
 call print_string
 movb activity_woken,%al
 call print_bit
 call newline
 movw $lab_irq_two_prog,%si
 call print_string
 movb activity_progress,%al
 call print_hex8
 call newline

 # Stale wait generation, two real IRQ0 events. Event presence does not wake.
 movb $2,%al
 movb $1,%ah
 call irq_case
 movw $lab_irq_bad_event,%si
 call print_string
 movb irq_event_count,%al
 call print_hex8
 call newline
 movw $lab_irq_bad_rel,%si
 call print_string
 movb irq_relation_ok,%al
 call print_bit
 call newline
 movw $lab_irq_bad_wake,%si
 call print_string
 movb activity_woken,%al
 call print_bit
 call newline
 movw $lab_irq_bad_prog,%si
 call print_string
 movb activity_progress,%al
 call print_hex8
 call newline
 movw $lab_irq_done,%si
 call print_string
 ret

# AL=target event count (1 or2), AH=1 means stale wait generation.
irq_case:
 movb %al,tmp_count
 movb %ah,tmp_identity
 call init_runtime
 call save_irq_platform_state
 call install_irq
 call mask_irqs
 movb $0x41,input_identity
 call activity_acquire
 # First acquired slot is 0. Build current wait relation in array state.
 movb output_gen,%al
 movb %al,activity_wait_generation
 cmpb $1,tmp_identity
 jne irq_case_waitgen_done
 incb activity_wait_generation
irq_case_waitgen_done:
 movb $2,activity_pending_progress
 movb $1,activity_waiting
 movb $0,activity_woken
 movb $0,activity_progress
 movb $0,irq_event_count
 movb $0,irq_relation_ok
 movb tmp_count,%al
 movb %al,irq_phase_target
 call run_irq_phase
 call irq_semantic_gate
 call irq_apply_progress
 call restore_irq_platform_state
 ret

run_irq_phase:
 call program_pit
 call unmask_irq0
 sti
irq_phase_wait:
 hlt
 cli
 movb irq_event_count,%al
 cmpb irq_phase_target,%al
 jae irq_phase_done
 call program_pit
 call unmask_irq0
 sti
 jmp irq_phase_wait
irq_phase_done:
 call mask_irqs
 ret

irq_semantic_gate:
 cmpb $0,irq_event_count
 je irq_semantic_done
 cmpb $1,irq_relation_ok
 jne irq_semantic_done
 movb $1,activity_woken
irq_semantic_done:
 ret

irq_apply_progress:
 cmpb $1,activity_woken
 jne irq_apply_done
 movb activity_pending_progress,%al
 movb %al,activity_progress
irq_apply_done:
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
 pushw %bx
 pushw %dx
 incb irq_event_count
 movb $0,irq_relation_ok
 # Reviewer IRQ relation is activity slot0 and must remain current.
 cmpb $0,activity_identity
 je irq_check_threshold
 movb activity_generation,%al
 cmpb activity_wait_generation,%al
 jne irq_check_threshold
 movb activity_epoch,%al
 cmpb activity_epoch_global,%al
 jne irq_check_threshold
 cmpb $2,activity_pending_progress
 jne irq_check_threshold
 cmpb $1,activity_waiting
 jne irq_check_threshold
 movb $1,irq_relation_ok
irq_check_threshold:
 movb irq_event_count,%al
 cmpb irq_phase_target,%al
 jb irq_send_eoi
 movw $PIC_MASTER_MASK,%dx
 movb $0xff,%al
 outb %al,%dx
irq_send_eoi:
 movw $PIC_MASTER_CMD,%dx
 movb $0x20,%al
 outb %al,%dx
 popw %dx
 popw %bx
 popw %ax
 iret

# -----------------------------------------------------------------------------
# Runtime initialization and handle helpers.
# -----------------------------------------------------------------------------
init_runtime:
 pushw %ax
 pushw %cx
 pushw %di
 xorw %ax,%ax
 movw $v2_state_begin,%di
 movw $(v2_state_end-v2_state_begin),%cx
 rep stosb
 movb $1,activity_epoch_global
 movb $1,resource_epoch_global
 popw %di
 popw %cx
 popw %ax
 ret

# input_identity -> AL status; output_slot/gen/epoch.
activity_acquire:
 movb $0,saw_exhausted
 xorw %bx,%bx
activity_acquire_loop:
 cmpw $ACTIVITY_CAP,%bx
 jae activity_acquire_none
 cmpb $0,activity_identity(%bx)
 jne activity_acquire_next
 cmpb $0xff,activity_generation(%bx)
 jne activity_acquire_use
 movb $1,saw_exhausted
 jmp activity_acquire_next
activity_acquire_use:
 incb activity_generation(%bx)
 movb input_identity,%dl
 movb %dl,activity_identity(%bx)
 movb activity_epoch_global,%dl
 movb %dl,activity_epoch(%bx)
 movb $0,activity_progress(%bx)
 movb $0,activity_pending_progress(%bx)
 movb $0,activity_waiting(%bx)
 movb $0,activity_woken(%bx)
 movb $0,activity_wait_slot(%bx)
 movb $0,activity_wait_generation(%bx)
 movb %bl,output_slot
 movb activity_generation(%bx),%dl
 movb %dl,output_gen
 movb activity_epoch(%bx),%dl
 movb %dl,output_epoch
 movb $'W',%al
 ret
activity_acquire_next:
 incw %bx
 jmp activity_acquire_loop
activity_acquire_none:
 cmpb $1,saw_exhausted
 je status_g
 movb $'F',%al
 ret

# Validates input_activity_slot/gen/epoch. AL=W or R/M. BX=slot on W.
activity_validate:
 xorw %bx,%bx
 movb input_activity_slot,%bl
 cmpw $ACTIVITY_CAP,%bx
 jae status_r
 cmpb $0,activity_identity(%bx)
 je status_m
 movb input_activity_gen,%al
 cmpb activity_generation(%bx),%al
 jne status_r
 movb input_activity_epoch,%al
 cmpb activity_epoch(%bx),%al
 jne status_r
 cmpb activity_epoch_global,%al
 jne status_r
 movb $'W',%al
 ret

activity_release:
 call activity_validate
 cmpb $'W',%al
 jne activity_release_done
 # scan owned row; any binding blocks release.
 movw %bx,%di
 shlw $4,%di
 movw %bx,%dx
 shlw $2,%dx
 addw %dx,%di
 movw $20,%cx
activity_release_scan:
 cmpb $0,binding_resource_plus1(%di)
 jne activity_release_blocked
 incw %di
 loop activity_release_scan
 movb $0,activity_identity(%bx)
 movb $0,activity_progress(%bx)
 movb $0,activity_pending_progress(%bx)
 movb $0,activity_waiting(%bx)
 movb $0,activity_woken(%bx)
 movb $'W',%al
 ret
activity_release_blocked:
 movb $'B',%al
activity_release_done:
 ret

# input_identity/input_value -> AL status; output slot/gen/epoch.
resource_create:
 movb $0,saw_exhausted
 xorw %bx,%bx
resource_create_loop:
 cmpw $RESOURCE_CAP,%bx
 jae resource_create_none
 cmpb $0,resource_identity(%bx)
 jne resource_create_next
 cmpb $0xff,resource_generation(%bx)
 jne resource_create_use
 movb $1,saw_exhausted
 jmp resource_create_next
resource_create_use:
 incb resource_generation(%bx)
 movb input_identity,%dl
 movb %dl,resource_identity(%bx)
 movb input_value,%dl
 movb %dl,resource_value(%bx)
 movw %bx,%di
 shlw $1,%di
 movw $0,resource_live_count(%di)
 movb %bl,output_slot
 movb resource_generation(%bx),%dl
 movb %dl,output_gen
 movb resource_epoch_global,%dl
 movb %dl,output_epoch
 movb $'W',%al
 ret
resource_create_next:
 incw %bx
 jmp resource_create_loop
resource_create_none:
 cmpb $1,saw_exhausted
 je status_g
 movb $'F',%al
 ret

# input_resource_slot/gen/epoch -> AL W/R/M, BX slot on W, last_value on W.
resource_read:
 movb $0,last_value
 xorw %bx,%bx
 movb input_resource_slot,%bl
 cmpw $RESOURCE_CAP,%bx
 jae status_r
 cmpb $0,resource_identity(%bx)
 je status_r
 movb input_resource_gen,%al
 cmpb resource_generation(%bx),%al
 jne status_r
 movb input_resource_epoch,%al
 cmpb resource_epoch_global,%al
 jne status_r
 movb resource_value(%bx),%al
 movb %al,last_value
 movb $'W',%al
 ret

# Validate resource without disturbing last_value. AL W/R, BX slot.
resource_validate:
 xorw %bx,%bx
 movb input_resource_slot,%bl
 cmpw $RESOURCE_CAP,%bx
 jae status_r
 cmpb $0,resource_identity(%bx)
 je status_r
 movb input_resource_gen,%al
 cmpb resource_generation(%bx),%al
 jne status_r
 movb input_resource_epoch,%al
 cmpb resource_epoch_global,%al
 jne status_r
 movb $'W',%al
 ret

# Attach first available cell in activity row to current resource.
# inputs activity handle + resource handle. output_binding/gen.
binding_attach_first:
 call activity_validate
 cmpb $'W',%al
 jne binding_attach_done
 movw %bx,%si
 call resource_validate
 cmpb $'W',%al
 jne binding_attach_done
 movw %bx,%dx                 # resource slot
 # row base from activity slot SI.
 movw %si,%di
 shlw $4,%di
 movw %si,%ax
 shlw $2,%ax
 addw %ax,%di
 movb $0,saw_exhausted
 movb $0,tmp_binding_index
 movw $20,%cx
binding_attach_scan:
 cmpb $0,binding_resource_plus1(%di)
 jne binding_attach_next
 cmpb $0xff,binding_generation(%di)
 jne binding_attach_use
 movb $1,saw_exhausted
 jmp binding_attach_next
binding_attach_use:
 incb binding_generation(%di)
 movb %dl,%al
 incb %al
 movb %al,binding_resource_plus1(%di)
 movb tmp_binding_index,%al
 movb %al,output_binding
 movb binding_generation(%di),%al
 movb %al,output_binding_gen
 movw %dx,%bx
 shlw $1,%bx
 incw resource_live_count(%bx)
 movb $'W',%al
 ret
binding_attach_next:
 incw %di
 incb tmp_binding_index
 loop binding_attach_scan
 cmpb $1,saw_exhausted
 je status_g
 movb $'F',%al
binding_attach_done:
 ret

# inputs activity handle + binding index/gen. W/M/R; last_value on W.
binding_read:
 movb $0,last_value
 call activity_validate
 cmpb $'W',%al
 jne binding_read_done
 cmpb $20,input_binding_index
 jae status_r
 movw %bx,%di
 shlw $4,%di
 movw %bx,%dx
 shlw $2,%dx
 addw %dx,%di
 xorw %dx,%dx
 movb input_binding_index,%dl
 addw %dx,%di
 cmpb $0,binding_resource_plus1(%di)
 je status_m
 movb input_binding_gen,%al
 cmpb binding_generation(%di),%al
 jne status_r
 movb binding_resource_plus1(%di),%al
 decb %al
 xorw %bx,%bx
 movb %al,%bl
 cmpw $RESOURCE_CAP,%bx
 jae status_r
 cmpb $0,resource_identity(%bx)
 je status_r
 movb resource_value(%bx),%al
 movb %al,last_value
 movb $'W',%al
binding_read_done:
 ret

# inputs activity handle + binding index/gen. W/M/R.
binding_detach:
 call activity_validate
 cmpb $'W',%al
 jne binding_detach_done
 cmpb $20,input_binding_index
 jae status_r
 movw %bx,%di
 shlw $4,%di
 movw %bx,%dx
 shlw $2,%dx
 addw %dx,%di
 xorw %dx,%dx
 movb input_binding_index,%dl
 addw %dx,%di
 cmpb $0,binding_resource_plus1(%di)
 je status_m
 movb input_binding_gen,%al
 cmpb binding_generation(%di),%al
 jne status_r
 movb binding_resource_plus1(%di),%al
 decb %al
 movb $0,binding_resource_plus1(%di)
 xorw %bx,%bx
 movb %al,%bl
 movw %bx,%di
 shlw $1,%di
 cmpw $0,resource_live_count(%di)
 je status_r
 decw resource_live_count(%di)
 cmpw $0,resource_live_count(%di)
 jne binding_detach_ok
 # final detach reclaims resource identity/value but retains generation.
 movb $0,resource_identity(%bx)
 movb $0,resource_value(%bx)
binding_detach_ok:
 movb $'W',%al
binding_detach_done:
 ret

load_saved_act0:
 movb saved_act0_slot,%al
 movb %al,input_activity_slot
 movb saved_act0_gen,%al
 movb %al,input_activity_gen
 movb saved_act0_epoch,%al
 movb %al,input_activity_epoch
 ret
load_saved_act1:
 movb saved_act1_slot,%al
 movb %al,input_activity_slot
 movb saved_act1_gen,%al
 movb %al,input_activity_gen
 movb saved_act1_epoch,%al
 movb %al,input_activity_epoch
 ret
load_saved_res:
 movb saved_res_slot,%al
 movb %al,input_resource_slot
 movb saved_res_gen,%al
 movb %al,input_resource_gen
 movb saved_res_epoch,%al
 movb %al,input_resource_epoch
 ret

status_m: movb $'M',%al; ret
status_r: movb $'R',%al; ret
status_g: movb $'G',%al; ret

# -----------------------------------------------------------------------------
# H1-SMP-MIN01 integration reviewer. No relation-table mutation on AP.
# -----------------------------------------------------------------------------
smp_min_review:
 movb $0,smp_ap_ready
 movb $0,smp_bsp_id
 movb $0,smp_ap_id
 cld
 movw $smp_ap_blob_start,%si
 movw $SMP_AP_TRAMP,%di
 movw $(smp_ap_blob_end-smp_ap_blob_start),%cx
 rep movsb
 movl $SMP_LAPIC_ID,%edi
 movl (%edi),%eax
 shrl $24,%eax
 movb %al,smp_bsp_id
 call smp_start_ap1
 movl $0x04000000,%ecx
smp_wait_ready:
 cmpb $1,smp_ap_ready
 je smp_ready
 pause
 decl %ecx
 jnz smp_wait_ready
smp_ready:
 movw $lab_smp_test,%si
 call print_string
 movw $lab_smp_bsp_id,%si
 call print_string
 movb smp_bsp_id,%al
 call print_hex8
 call newline
 movw $lab_smp_ap_id,%si
 call print_string
 movb smp_ap_id,%al
 call print_hex8
 call newline
 movw $lab_smp_ready,%si
 call print_string
 movb smp_ap_ready,%al
 call print_bit
 call newline
 movw $lab_smp_done,%si
 call print_string
 ret

smp_start_ap1:
 movl $0x01000000,%eax
 movl $SMP_LAPIC_ICR_HIGH,%edi
 movl %eax,(%edi)
 movl $0x0000c500,%eax
 movl $SMP_LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call smp_icr_wait
 call smp_delay_long
 movl $0x00008500,%eax
 movl $SMP_LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call smp_icr_wait
 call smp_delay_short
 movl $(0x00000600+SMP_AP_VECTOR),%eax
 movl $SMP_LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call smp_icr_wait
 call smp_delay_short
 movl $(0x00000600+SMP_AP_VECTOR),%eax
 movl $SMP_LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call smp_icr_wait
 ret
smp_icr_wait:
 movl $SMP_LAPIC_ICR_LOW,%edi
 movl (%edi),%eax
 testl $0x1000,%eax
 jnz smp_icr_wait
 ret
smp_delay_short:
 movl $0x00040000,%ecx
smp_delay_short_loop:
 pause
 decl %ecx
 jnz smp_delay_short_loop
 ret
smp_delay_long:
 movl $0x00400000,%ecx
smp_delay_long_loop:
 pause
 decl %ecx
 jnz smp_delay_long_loop
 ret

# Copied to physical 0x6000 and entered by SIPI vector 6.
smp_ap_blob_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x6800,%sp
 movl $SMP_LAPIC_ID,%edi
 movl (%edi),%eax
 shrl $24,%eax
 movb %al,smp_ap_id
 movb $1,smp_ap_ready
smp_ap_halt:
 hlt
 jmp smp_ap_halt
smp_ap_blob_end:

# -----------------------------------------------------------------------------
# Debug output helpers.
# -----------------------------------------------------------------------------
print_string:
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
print_char:
 pushw %dx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popw %dx
 ret
newline:
 pushw %ax
 movb $'\n',%al
 call print_char
 popw %ax
 ret
print_bit:
 andb $1,%al
 addb $'0',%al
 jmp print_char
print_hex8:
 pushw %ax
 movb %al,%ah
 shrb $4,%al
 call print_nibble
 movb %ah,%al
 andb $0x0f,%al
 call print_nibble
 popw %ax
 ret
print_hex16:
 pushw %ax
 movb %ah,%al
 call print_hex8
 popw %ax
 call print_hex8
 ret
print_nibble:
 cmpb $9,%al
 jbe 4f
 addb $('A'-10),%al
 jmp print_char
4: addb $'0',%al
 jmp print_char

.section .rodata
lab_smp_test:.asciz "TEST=H1_SMP_MIN01\n"
lab_smp_bsp_id:.asciz "BSP_ID="
lab_smp_ap_id:.asciz "AP_ID="
lab_smp_ready:.asciz "AP_READY="
lab_smp_done:.asciz "SMP_DONE\n"
lab_test:.asciz "TEST=D64_V2_CORE\n"
lab_act_filled:.asciz "ACT_FILLED="
lab_act_over:.asciz "ACT_OVER="
lab_row_filled:.asciz "ROW_FILLED="
lab_row_over:.asciz "ROW_OVER="
lab_share_live:.asciz "SHARE_LIVE="
lab_stale_bind:.asciz "STALE_BIND="
lab_fresh_bind:.asciz "FRESH_BIND="
lab_fresh_bind_val:.asciz "FRESH_BIND_VAL="
lab_missing_bind:.asciz "MISSING_BIND="
lab_release_bound:.asciz "RELEASE_BOUND="
lab_detach_one:.asciz "DETACH_ONE_LIVE="
lab_detach_last:.asciz "DETACH_LAST_LIVE="
lab_old_res:.asciz "OLD_RES="
lab_new_res:.asciz "NEW_RES="
lab_new_res_val:.asciz "NEW_RES_VAL="
lab_persist_test:.asciz "TEST=D64_V2_PERSIST\n"
lab_mode_r:.asciz "MODE=R\n"
lab_mode_f:.asciz "MODE=F\n"
lab_phase_write:.asciz "PHASE=WRITE\n"
lab_phase_recover:.asciz "PHASE=RECOVER\n"
lab_write_a:.asciz "WRITE=A\n"
lab_select:.asciz "SELECT="
lab_dur_val:.asciz "DUR_VAL="
lab_persist_old_bind:.asciz "OLD_BIND="
lab_persist_old_res:.asciz "OLD_RES="
lab_persist_fresh_bind:.asciz "FRESH_BIND="
lab_persist_fresh_val:.asciz "FRESH_BIND_VAL="
lab_persist_done:.asciz "PERSIST_DONE\n"
lab_persist_iofail:.asciz "PERSIST_IO_FAIL\n"
lab_irq_test:.asciz "TEST=D64_V2_IRQ\n"
lab_irq_one_event:.asciz "IRQ1_EVENT="
lab_irq_one_rel:.asciz "IRQ1_REL="
lab_irq_one_wake:.asciz "IRQ1_WAKE="
lab_irq_one_prog:.asciz "IRQ1_PROG="
lab_irq_two_event:.asciz "IRQ2_EVENT="
lab_irq_two_rel:.asciz "IRQ2_REL="
lab_irq_two_wake:.asciz "IRQ2_WAKE="
lab_irq_two_prog:.asciz "IRQ2_PROG="
lab_irq_bad_event:.asciz "IRQBAD_EVENT="
lab_irq_bad_rel:.asciz "IRQBAD_REL="
lab_irq_bad_wake:.asciz "IRQBAD_WAKE="
lab_irq_bad_prog:.asciz "IRQBAD_PROG="
lab_irq_done:.asciz "IRQ_DONE\n"
lab_done:.asciz "DONE\n"

.section .bss
.global v2_state_begin
.global v2_state_end
v2_state_begin:
activity_identity:.space ACTIVITY_CAP,0
activity_generation:.space ACTIVITY_CAP,0
activity_epoch:.space ACTIVITY_CAP,0
activity_progress:.space ACTIVITY_CAP,0
activity_pending_progress:.space ACTIVITY_CAP,0
activity_waiting:.space ACTIVITY_CAP,0
activity_woken:.space ACTIVITY_CAP,0
activity_wait_slot:.space ACTIVITY_CAP,0
activity_wait_generation:.space ACTIVITY_CAP,0
activity_epoch_global:.byte 0
binding_resource_plus1:.space BINDING_CELL_COUNT,0
binding_generation:.space BINDING_CELL_COUNT,0
resource_identity:.space RESOURCE_CAP,0
resource_generation:.space RESOURCE_CAP,0
resource_value:.space RESOURCE_CAP,0
resource_live_count:.space RESOURCE_CAP*2,0
resource_epoch_global:.byte 0
irq_event_count:.byte 0
irq_relation_ok:.byte 0
irq_phase_target:.byte 0
saved_irq0_off:.word 0
saved_irq0_seg:.word 0
saved_master_mask:.byte 0
saved_slave_mask:.byte 0
v2_state_end:

# <=128 bytes implementation scratch allowance.
implementation_scratch:
boot_drive:.byte 0
input_identity:.byte 0
input_value:.byte 0
input_activity_slot:.byte 0
input_activity_gen:.byte 0
input_activity_epoch:.byte 0
input_resource_slot:.byte 0
input_resource_gen:.byte 0
input_resource_epoch:.byte 0
input_binding_index:.byte 0
input_binding_gen:.byte 0
output_slot:.byte 0
output_gen:.byte 0
output_epoch:.byte 0
output_binding:.byte 0
output_binding_gen:.byte 0
last_value:.byte 0
saw_exhausted:.byte 0
tmp_identity:.byte 0
tmp_count:.byte 0
tmp_binding_index:.byte 0
saved_act0_slot:.byte 0
saved_act0_gen:.byte 0
saved_act0_epoch:.byte 0
saved_act1_slot:.byte 0
saved_act1_gen:.byte 0
saved_act1_epoch:.byte 0
saved_res_slot:.byte 0
saved_res_gen:.byte 0
saved_res_epoch:.byte 0
saved_bind0_index:.byte 0
saved_bind0_gen:.byte 0
saved_bind1_index:.byte 0
saved_bind1_gen:.byte 0
saved_new_res_slot:.byte 0
saved_new_res_gen:.byte 0
saved_new_res_epoch:.byte 0
durable_a_valid:.byte 0
durable_b_valid:.byte 0
durable_select:.byte 0
durable_selected_ptr:.word 0
durable_recovered_value:.byte 0
durable_old_bind_status:.byte 0
durable_old_res_status:.byte 0
durable_fresh_bind_status:.byte 0
durable_fresh_value:.byte 0
smp_bsp_id:.byte 0
smp_ap_id:.byte 0
smp_ap_ready:.byte 0
.space (128-(.-implementation_scratch)),0
