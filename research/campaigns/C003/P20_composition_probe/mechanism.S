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
 movw %ax,%ss
 movw $0x7b00,%sp
 movw $DEBUG_PORT,%dx

 movb owner_a_fact,%al
 movb old_value_fact,%ah
 call acquire_checked
 movb %al,o0
 movb slot_generation,%al
 movb %al,stale_generation
 addb $'0',%al
 movb %al,o1

 movb continuation_fact,%al
 movb %al,slot_continuation
 movb $1,slot_waiting
 movb missing_request_fact,%al
 call middle_request
 movb %al,o2
 movb slot_progress,%al
 addb $'0',%al
 movb %al,o3
 movb slot_continuation,%al
 addb $'0',%al
 movb %al,o4

 movb known_request_fact,%al
 call middle_request
 movb %al,o5
 movb slot_progress,%al
 addb $'0',%al
 movb %al,o6

 movb owner_b_fact,%al
 movb new_value_fact,%ah
 call acquire_checked
 movb %al,o7
 movb slot_owner,%al
 movb %al,o8

 call release_slot
 movb owner_b_fact,%al
 movb new_value_fact,%ah
 call acquire_checked
 movb %al,o9
 movb slot_generation,%al
 movb %al,fresh_generation
 addb $'0',%al
 movb %al,o10
 movb slot_progress,%al
 addb $'0',%al
 movb %al,o11
 movb slot_continuation,%al
 addb $'0',%al
 movb %al,o12

 movb fresh_generation,%al
 call checked_read
 movb %al,o13
 movb last_read,%al
 movb %al,o14
 movb stale_generation,%al
 call checked_read
 movb %al,o15
 movb last_read,%al
 addb $'0',%al
 movb %al,o16
 movb stale_generation,%al
 call address_only_read
 movb %al,o17
 movb last_read,%al
 movb %al,o18

 movw $output,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

acquire_checked:
 cmpb $0,slot_owner
 jne acquire_full
 incb slot_generation
 movb %al,slot_owner
 movb %ah,slot_value
 xorw %ax,%ax
 movw %ax,slot_progress
 movb %al,slot_waiting
 movb $'W',%al
 ret
acquire_full:
 movb $'F',%al
 ret
release_slot:
 movb $0,slot_owner
 ret
leaf_execute:
 cmpb known_request_fact,%al
 jne leaf_missing
 movb $'O',%al
 ret
leaf_missing:
 movb $'M',%al
 ret
middle_request:
 call leaf_execute
 cmpb $'O',%al
 jne middle_return
 movb slot_continuation,%ah
 movb %ah,slot_progress
 movb $0,slot_waiting
middle_return:
 ret
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
print_string:
 lodsb
 testb %al,%al
 jz 2f
 outb %al,%dx
 jmp print_string
2: ret

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
output:
 .ascii "A_ACQ="
o0:.byte '?'
 .ascii "\nA_GEN="
o1:.byte '?'
 .ascii "\nMISS="
o2:.byte '?'
 .ascii "\nM_PROG="
o3:.byte '?'
 .ascii "\nM_CONT="
o4:.byte '?'
 .ascii "\nOK="
o5:.byte '?'
 .ascii "\nO_PROG="
o6:.byte '?'
 .ascii "\nFULL="
o7:.byte '?'
 .ascii "\nF_OWNER="
o8:.byte '?'
 .ascii "\nB_ACQ="
o9:.byte '?'
 .ascii "\nB_GEN="
o10:.byte '?'
 .ascii "\nB_PROG="
o11:.byte '?'
 .ascii "\nB_CONT="
o12:.byte '?'
 .ascii "\nFRESH="
o13:.byte '?'
 .ascii "\nF_READ="
o14:.byte '?'
 .ascii "\nSTALE="
o15:.byte '?'
 .ascii "\nS_READ="
o16:.byte '?'
 .ascii "\nBAD="
o17:.byte '?'
 .ascii "\nB_READ="
o18:.byte '?'
 .asciz "\nDONE\n"
