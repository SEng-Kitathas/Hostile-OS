.code16
.section .text
.global _start
.extern old_value_fact
.extern new_value_fact
.extern initial_generation_fact
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp
 call setup_old
 movw $lab_old_gen,%si
 movb stale_handle_generation,%al
 addb $'0',%al
 call print_line
 call reuse_slot
 movw $lab_new_gen,%si
 movb slot_generation,%al
 addb $'0',%al
 call print_line

 movb fresh_handle_generation,%al
 call checked_read
 movw $lab_fresh_status,%si
 call print_line
 movw $lab_fresh_read,%si
 movb last_read,%al
 call print_line

 movb stale_handle_generation,%al
 call checked_read
 movw $lab_stale_status,%si
 call print_line
 movw $lab_stale_read,%si
 movb last_read,%al
 addb $'0',%al
 call print_line

 movb stale_handle_generation,%al
 call address_only_read
 movw $lab_bad_status,%si
 call print_line
 movw $lab_bad_read,%si
 movb last_read,%al
 call print_line
 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

setup_old:
 movb old_value_fact,%al
 movb %al,slot_value
 movb initial_generation_fact,%al
 movb %al,slot_generation
 movb %al,stale_handle_generation
 movb $0,fresh_handle_generation
 movb $0,last_read
 ret
reuse_slot:
 incb slot_generation
 movb new_value_fact,%al
 movb %al,slot_value
 movb slot_generation,%al
 movb %al,fresh_handle_generation
 ret

# AL=handle generation. Compare before value read.
checked_read:
 cmpb slot_generation,%al
 jne checked_stale
 movb slot_value,%ah
 movb %ah,last_read
 movb $'W',%al
 ret
checked_stale:
 movb $0,last_read
 movb $'R',%al
 ret

# Bad control: same slot address, no generation check.
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
lab_old_gen:.asciz "OLD_GEN="
lab_new_gen:.asciz "NEW_GEN="
lab_fresh_status:.asciz "FRESH_STATUS="
lab_fresh_read:.asciz "FRESH_READ="
lab_stale_status:.asciz "STALE_STATUS="
lab_stale_read:.asciz "STALE_READ="
lab_bad_status:.asciz "BAD_STATUS="
lab_bad_read:.asciz "BAD_READ="
lab_done:.asciz "DONE\n"
.section .data
slot_value:.byte 0
slot_generation:.byte 0
stale_handle_generation:.byte 0
fresh_handle_generation:.byte 0
last_read:.byte 0
