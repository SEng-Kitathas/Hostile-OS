.code16
.section .text
.global _start
.extern owner_a_fact
.extern owner_b_fact
.extern old_value_fact
.extern new_value_fact
.extern known_request_fact
.extern missing_request_fact
.extern continuation_fact
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp

 movb owner_a_fact,%al
 movb old_value_fact,%ah
 call acquire_checked
 movw $lab_a_acq,%si
 call print_line
 movb slot_generation,%al
 movb %al,stale_generation
 movw $lab_a_gen,%si
 addb $'0',%al
 call print_line

 movb continuation_fact,%al
 movb %al,slot_continuation
 movb $1,slot_waiting
 movb missing_request_fact,%al
 call middle_request
 movw $lab_miss,%si
 call print_line
 movw $lab_m_prog,%si
 movb slot_progress,%al
 addb $'0',%al
 call print_line
 movw $lab_m_cont,%si
 movb slot_continuation,%al
 addb $'0',%al
 call print_line

 movb known_request_fact,%al
 call middle_request
 movw $lab_ok,%si
 call print_line
 movw $lab_o_prog,%si
 movb slot_progress,%al
 addb $'0',%al
 call print_line

 movb owner_b_fact,%al
 movb new_value_fact,%ah
 call acquire_checked
 movw $lab_full,%si
 call print_line
 movw $lab_f_owner,%si
 movb slot_owner,%al
 call print_line

 call release_slot
 movb owner_b_fact,%al
 movb new_value_fact,%ah
 call acquire_checked
 movw $lab_b_acq,%si
 call print_line
 movb slot_generation,%al
 movb %al,fresh_generation
 movw $lab_b_gen,%si
 addb $'0',%al
 call print_line
 movw $lab_b_prog,%si
 movb slot_progress,%al
 addb $'0',%al
 call print_line
 movw $lab_b_cont,%si
 movb slot_continuation,%al
 addb $'0',%al
 call print_line

 movb fresh_generation,%al
 call checked_read
 movw $lab_fresh,%si
 call print_line
 movw $lab_f_read,%si
 movb last_read,%al
 call print_line

 movb stale_generation,%al
 call checked_read
 movw $lab_stale,%si
 call print_line
 movw $lab_s_read,%si
 movb last_read,%al
 addb $'0',%al
 call print_line

 movb stale_generation,%al
 call address_only_read
 movw $lab_bad,%si
 call print_line
 movw $lab_b_read,%si
 movb last_read,%al
 call print_line

 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

# AL=owner AH=value. One-slot checked acquire with clean field init.
acquire_checked:
 cmpb $0,slot_owner
 jne acquire_full
 incb slot_generation
 movb %al,slot_owner
 movb %ah,slot_value
 movb $0,slot_progress
 movb $0,slot_continuation
 movb $0,slot_waiting
 movb $'W',%al
 ret
acquire_full:
 movb $'F',%al
 ret

release_slot:
 movb $0,slot_owner
 ret

# AL=request. Returns O only for K; no state mutation.
leaf_execute:
 cmpb known_request_fact,%al
 jne leaf_missing
 movb $'O',%al
 ret
leaf_missing:
 movb $'M',%al
 ret

# Propagate failure before applying stored continuation.
middle_request:
 call leaf_execute
 cmpb $'O',%al
 jne middle_return
 cmpb $0,slot_waiting
 je middle_return
 movb slot_continuation,%ah
 movb %ah,slot_progress
 movb $0,slot_waiting
middle_return:
 ret

# AL=handle generation. Compare before value read.
checked_read:
 cmpb slot_generation,%al
 jne stale_reject
 movb slot_value,%ah
 movb %ah,last_read
 movb $'W',%al
 ret
stale_reject:
 movb $0,last_read
 movb $'R',%al
 ret

address_only_read:
 movb slot_value,%ah
 movb %ah,last_read
 movb $'W',%al
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

lab_a_acq:.asciz "A_ACQ="
lab_a_gen:.asciz "A_GEN="
lab_miss:.asciz "MISS="
lab_m_prog:.asciz "M_PROG="
lab_m_cont:.asciz "M_CONT="
lab_ok:.asciz "OK="
lab_o_prog:.asciz "O_PROG="
lab_full:.asciz "FULL="
lab_f_owner:.asciz "F_OWNER="
lab_b_acq:.asciz "B_ACQ="
lab_b_gen:.asciz "B_GEN="
lab_b_prog:.asciz "B_PROG="
lab_b_cont:.asciz "B_CONT="
lab_fresh:.asciz "FRESH="
lab_f_read:.asciz "F_READ="
lab_stale:.asciz "STALE="
lab_s_read:.asciz "S_READ="
lab_bad:.asciz "BAD="
lab_b_read:.asciz "B_READ="
lab_done:.asciz "DONE\n"

.section .data
slot_owner:.byte 0
slot_generation:.byte 0
slot_value:.byte 0
slot_progress:.byte 0
slot_continuation:.byte 0
slot_waiting:.byte 0
stale_generation:.byte 0
fresh_generation:.byte 0
last_read:.byte 0
