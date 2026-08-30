.code16
.section .text
.global _start

.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ BUF_A,0x7000
.equ BUF_B,0x7200
.equ BUF_CASE,0x7400
.equ ACTIVITY_CAP,64
.equ BINDINGS_PER_ACTIVITY,20
.equ BINDING_CELL_COUNT,1280
.equ RESOURCE_CAP,64

_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7a00,%sp
 movb %dl,boot_drive

 movw $BUF_A,%bx
 movb $0,%dh
 movb $18,%cl
 call read_sector
 jc io_fail
 movw $BUF_B,%bx
 movb $1,%dh
 movb $1,%cl
 call read_sector
 jc io_fail
 movw $BUF_CASE,%bx
 movb $1,%dh
 movb $2,%cl
 call read_sector
 jc io_fail
 call validate_case_label
 cmpb $1,case_valid
 jne label_fail

 movw $BUF_A,%si
 call validate_record
 movb %al,a_valid
 movw $BUF_B,%si
 call validate_record
 movb %al,b_valid
 call checked_select
 call naive_select
 call maybe_reconstruct
 call emit_trace
 call success_exit

io_fail:
 movw $lab_iofail,%si
 call print_string
 jmp fail_exit
label_fail:
 movw $lab_labelfail,%si
 call print_string
 jmp fail_exit

read_sector:
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %dx
 movb $0x02,%ah
 movb $0x01,%al
 movb $0x00,%ch
 movb boot_drive,%dl
 int $0x13
 popw %dx
 popw %cx
 popw %bx
 popw %ax
 ret

validate_case_label:
 movb $0,case_valid
 movw $BUF_CASE,%si
 cmpw $0x4143,0(%si)
 jne validate_case_done
 cmpw $0x4553,2(%si)
 jne validate_case_done
 movb $1,case_valid
validate_case_done:
 ret

# SI=record buffer, AL returns 1 valid / 0 invalid.
validate_record:
 pushw %bx
 pushw %cx
 pushw %dx
 pushw %si
 movb $0,%al
 cmpw $0x3448,0(%si)
 jne validate_record_done
 cmpw $0x3146,2(%si)
 jne validate_record_done
 cmpw $0x1234,16(%si)
 jne validate_record_done
 cmpb $1,18(%si)
 jne validate_record_done
 cmpb $0,19(%si)
 jne validate_record_done
 cmpw $0x4d43,26(%si)
 jne validate_record_done
 cmpw $0x5449,28(%si)
 jne validate_record_done
 call crc16_payload
 cmpw 24(%si),%dx
 jne validate_record_done
 movb $1,%al
validate_record_done:
 popw %si
 popw %dx
 popw %cx
 popw %bx
 ret

# CRC-16/CCITT-FALSE over 24 bytes at SI. Return DX.
crc16_payload:
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %si
 movw $0xffff,%dx
 movw $24,%cx
crc_byte_loop:
 movb (%si),%al
 incw %si
 xorb %dh,%al
 movb %al,%dh
 movb $8,%bl
crc_bit_loop:
 shlw $1,%dx
 jnc crc_no_poly
 xorw $0x1021,%dx
crc_no_poly:
 decb %bl
 jnz crc_bit_loop
 loop crc_byte_loop
 popw %si
 popw %cx
 popw %bx
 popw %ax
 ret

checked_select:
 movb $'N',selected_kind
 movw $0,selected_ptr
 cmpb $1,a_valid
 je checked_a_valid
 cmpb $1,b_valid
 je checked_choose_b
 ret
checked_a_valid:
 cmpb $1,b_valid
 jne checked_choose_a
 # both valid: compare seq high then low unsigned
 movw $BUF_A,%si
 movw $BUF_B,%di
 movw 22(%si),%ax
 cmpw 22(%di),%ax
 ja checked_choose_a
 jb checked_choose_b
 movw 20(%si),%ax
 cmpw 20(%di),%ax
 ja checked_choose_a
 jb checked_choose_b
 # equal sequence: identical bytes0..29 => A, otherwise X
 pushw %si
 pushw %di
 movw $30,%cx
 repe cmpsb
 popw %di
 popw %si
 jne checked_ambiguous
 jmp checked_choose_a
checked_ambiguous:
 movb $'X',selected_kind
 ret
checked_choose_a:
 movb $'A',selected_kind
 movw $BUF_A,selected_ptr
 ret
checked_choose_b:
 movb $'B',selected_kind
 movw $BUF_B,selected_ptr
 ret

# Deliberately bad selector: magic + sequence only; never drives reconstruction.
naive_select:
 movb $'N',naive_kind
 movw $BUF_A,%si
 call magic_only
 movb %al,naive_a_magic
 movw $BUF_B,%si
 call magic_only
 movb %al,naive_b_magic
 cmpb $1,naive_a_magic
 je naive_a_present
 cmpb $1,naive_b_magic
 je naive_choose_b
 ret
naive_a_present:
 cmpb $1,naive_b_magic
 jne naive_choose_a
 movw $BUF_A,%si
 movw $BUF_B,%di
 movw 22(%si),%ax
 cmpw 22(%di),%ax
 ja naive_choose_a
 jb naive_choose_b
 movw 20(%si),%ax
 cmpw 20(%di),%ax
 ja naive_choose_a
 jb naive_choose_b
 jmp naive_choose_a
naive_choose_a:
 movb $'A',naive_kind
 ret
naive_choose_b:
 movb $'B',naive_kind
 ret

magic_only:
 movb $0,%al
 cmpw $0x3448,0(%si)
 jne magic_done
 cmpw $0x3146,2(%si)
 jne magic_done
 movb $1,%al
magic_done:
 ret

maybe_reconstruct:
 movb $0,durable_value
 movb $'-',old_bind_status
 movb $'-',old_res_status
 movb $'-',fresh_bind_status
 movb $'-',fresh_res_status
 movb $0,fresh_bind_value
 movb $0,fresh_res_value
 cmpb $'A',selected_kind
 je have_selected
 cmpb $'B',selected_kind
 je have_selected
 ret
have_selected:
 movw selected_ptr,%si
 cmpb $255,6(%si)
 je epoch_exhaust
 cmpb $255,7(%si)
 je epoch_exhaust
 movb 5(%si),%al
 movb %al,durable_value
 call init_runtime
 # current namespace epochs are selected durable epochs + 1
 movb 6(%si),%al
 incb %al
 movb %al,activity_epoch
 movb 7(%si),%al
 incb %al
 movb %al,resource_epoch
 # reconstruct one fresh relation at slot/index/resource 0, generations 1.
 movb $0x41,act_identity
 movb $1,act_gen
 movb activity_epoch,%al
 movb %al,act_epoch
 movb $1,binding_generation
 movb $1,binding_resource_plus1
 movb 4(%si),%al
 movb %al,resource_identity
 movb $1,resource_generation
 movb durable_value,%al
 movb %al,resource_value
 movw $1,resource_live_count
 # historical binding read from selected scalar handle fields.
 movb 8(%si),%bl
 movb 9(%si),%cl
 movb 10(%si),%ch
 movb 11(%si),%dl
 movb 12(%si),%dh
 call binding_read_handle
 movb %al,old_bind_status
 # historical resource read.
 movb 13(%si),%bl
 movb 14(%si),%cl
 movb 15(%si),%ch
 call resource_read_handle
 movb %al,old_res_status
 # fresh binding handle uses current epochs/gen1.
 movb $0,%bl
 movb $1,%cl
 movb activity_epoch,%ch
 movb $0,%dl
 movb $1,%dh
 call binding_read_handle
 movb %al,fresh_bind_status
 movb last_read_value,%al
 movb %al,fresh_bind_value
 # fresh direct resource handle.
 movb $0,%bl
 movb $1,%cl
 movb resource_epoch,%ch
 call resource_read_handle
 movb %al,fresh_res_status
 movb last_read_value,%al
 movb %al,fresh_res_value
 ret
epoch_exhaust:
 movb $'G',selected_kind
 movw $0,selected_ptr
 ret

init_runtime:
 pushw %ax
 pushw %cx
 pushw %di
 xorw %ax,%ax
 movw $runtime_begin,%di
 movw $(runtime_end-runtime_begin),%cx
 rep stosb
 popw %di
 popw %cx
 popw %ax
 ret

# Inputs: BL activity slot, CL act gen, CH act epoch, DL binding index, DH binding gen.
binding_read_handle:
 movb %bl,input_activity_slot
 movb %cl,input_activity_gen
 movb %ch,input_activity_epoch
 movb %dl,input_binding_index
 movb %dh,input_binding_gen
 movb $0,last_read_value
 xorw %bx,%bx
 movb input_activity_slot,%bl
 cmpw $ACTIVITY_CAP,%bx
 jae binding_read_reject
 cmpb $0,act_identity(%bx)
 je binding_read_reject
 movb input_activity_gen,%al
 cmpb act_gen(%bx),%al
 jne binding_read_reject
 movb input_activity_epoch,%al
 cmpb act_epoch(%bx),%al
 jne binding_read_reject
 cmpb activity_epoch,%al
 jne binding_read_reject
 cmpb $BINDINGS_PER_ACTIVITY,input_binding_index
 jae binding_read_reject
 # base = slot*20 + index
 movw %bx,%di
 shlw $4,%di
 movw %bx,%ax
 shlw $2,%ax
 addw %ax,%di
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

# Inputs: BL resource slot, CL generation, CH resource epoch.
resource_read_handle:
 movb %bl,input_resource_slot
 movb %cl,input_resource_gen
 movb %ch,input_resource_epoch
 movb $0,last_read_value
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

emit_trace:
 movw $lab_test,%si
 call print_string
 movw $lab_case,%si
 call print_string
 movw $(BUF_CASE+4),%si
 call print_string
 call newline
 movw $lab_a_valid,%si
 call print_string
 movb a_valid,%al
 call print_bit
 call newline
 movw $lab_a_seq,%si
 call print_string
 movw $BUF_A,%si
 call print_seq32
 call newline
 movw $lab_b_valid,%si
 call print_string
 movb b_valid,%al
 call print_bit
 call newline
 movw $lab_b_seq,%si
 call print_string
 movw $BUF_B,%si
 call print_seq32
 call newline
 movw $lab_select,%si
 call print_string
 movb selected_kind,%al
 call print_char
 call newline
 movw $lab_naive,%si
 call print_string
 movb naive_kind,%al
 call print_char
 call newline
 movw $lab_dur_val,%si
 call print_string
 movb durable_value,%al
 call print_hex8
 call newline
 movw $lab_old_bind,%si
 call print_string
 movb old_bind_status,%al
 call print_char
 call newline
 movw $lab_old_res,%si
 call print_string
 movb old_res_status,%al
 call print_char
 call newline
 movw $lab_fresh_bind,%si
 call print_string
 movb fresh_bind_status,%al
 call print_char
 call newline
 movw $lab_fresh_bind_val,%si
 call print_string
 movb fresh_bind_value,%al
 call print_hex8
 call newline
 movw $lab_fresh_res,%si
 call print_string
 movb fresh_res_status,%al
 call print_char
 call newline
 movw $lab_fresh_res_val,%si
 call print_string
 movb fresh_res_value,%al
 call print_hex8
 call newline
 movw $lab_done,%si
 call print_string
 ret

print_seq32:
 movw 22(%si),%ax
 xchgb %al,%ah
 xchgb %al,%ah
 # print high word high byte, low byte, then low word high byte, low byte
 movb 23(%si),%al
 call print_hex8
 movb 22(%si),%al
 call print_hex8
 movb 21(%si),%al
 call print_hex8
 movb 20(%si),%al
 call print_hex8
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
print_nibble:
 cmpb $9,%al
 jbe nib_digit
 addb $('A'-10),%al
 jmp print_char
nib_digit:
 addb $'0',%al
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
newline:
 pushw %ax
 movb $'\n',%al
 call print_char
 popw %ax
 ret

success_exit:
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
fail_exit:
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
2: hlt
 jmp 2b

.section .rodata
lab_test:.asciz "TEST=D64_FR01\n"
lab_case:.asciz "CASE="
lab_a_valid:.asciz "A_VALID="
lab_a_seq:.asciz "A_SEQ="
lab_b_valid:.asciz "B_VALID="
lab_b_seq:.asciz "B_SEQ="
lab_select:.asciz "SELECT="
lab_naive:.asciz "NAIVE="
lab_dur_val:.asciz "DUR_VAL="
lab_old_bind:.asciz "OLD_BIND="
lab_old_res:.asciz "OLD_RES="
lab_fresh_bind:.asciz "FRESH_BIND="
lab_fresh_bind_val:.asciz "FRESH_BIND_VAL="
lab_fresh_res:.asciz "FRESH_RES="
lab_fresh_res_val:.asciz "FRESH_RES_VAL="
lab_done:.asciz "DONE\n"
lab_iofail:.asciz "IO_FAIL\n"
lab_labelfail:.asciz "LABEL_FAIL\n"

.section .bss
boot_drive:.byte 0
case_valid:.byte 0
a_valid:.byte 0
b_valid:.byte 0
selected_kind:.byte 0
naive_kind:.byte 0
naive_a_magic:.byte 0
naive_b_magic:.byte 0
selected_ptr:.word 0
durable_value:.byte 0
old_bind_status:.byte 0
old_res_status:.byte 0
fresh_bind_status:.byte 0
fresh_res_status:.byte 0
fresh_bind_value:.byte 0
fresh_res_value:.byte 0
last_read_value:.byte 0
input_activity_slot:.byte 0
input_activity_gen:.byte 0
input_activity_epoch:.byte 0
input_binding_index:.byte 0
input_binding_gen:.byte 0
input_resource_slot:.byte 0
input_resource_gen:.byte 0
input_resource_epoch:.byte 0
input_tmp_slot:.byte 0
runtime_begin:
act_identity:.space ACTIVITY_CAP,0
act_gen:.space ACTIVITY_CAP,0
act_epoch:.space ACTIVITY_CAP,0
binding_resource_plus1:.space BINDING_CELL_COUNT,0
binding_generation:.space BINDING_CELL_COUNT,0
resource_identity:.space RESOURCE_CAP,0
resource_generation:.space RESOURCE_CAP,0
resource_value:.space RESOURCE_CAP,0
resource_live_count:.space RESOURCE_CAP*2,0
activity_epoch:.byte 0
resource_epoch:.byte 0
runtime_end:
