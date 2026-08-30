.code16
.section .text
.global _start
.extern owner_a_fact
.extern owner_b_fact
.extern backing_fact
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp

 call setup_shared
 movw $lab_good_start,%si
 movb live_count,%al
 addb $'0',%al
 call print_line
 call release_a_good
 movw $lab_good_after_a,%si
 movb live_count,%al
 addb $'0',%al
 call print_line
 movw $lab_good_b_owner,%si
 movb binding_b_owner,%al
 call print_line
 movw $lab_good_b_read,%si
 movb backing_value,%al
 call print_line
 call release_b_good
 movw $lab_good_after_b,%si
 movb live_count,%al
 addb $'0',%al
 call print_line
 movw $lab_good_backing,%si
 movb backing_value,%al
 addb $'0',%al
 call print_line

 call setup_shared
 movw $lab_bad_start,%si
 movb live_count,%al
 addb $'0',%al
 call print_line
 call release_a_bad
 movw $lab_bad_after_a,%si
 movb live_count,%al
 addb $'0',%al
 call print_line
 movw $lab_bad_b_owner,%si
 movb binding_b_owner,%al
 call print_line
 movw $lab_bad_b_read,%si
 movb backing_value,%al
 addb $'0',%al
 call print_line

 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

setup_shared:
 movb backing_fact,%al
 movb %al,backing_value
 movb owner_a_fact,%al
 movb %al,binding_a_owner
 movb owner_b_fact,%al
 movb %al,binding_b_owner
 movb $2,live_count
 ret

release_a_good:
 movb $0,binding_a_owner
 decb live_count
 cmpb $0,live_count
 jne 2f
 movb $0,backing_value
2: ret

release_b_good:
 movb $0,binding_b_owner
 decb live_count
 cmpb $0,live_count
 jne 3f
 movb $0,backing_value
3: ret

release_a_bad:
 movb $0,binding_a_owner
 decb live_count
 movb $0,backing_value
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
4: lodsb
 testb %al,%al
 jz 5f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp 4b
5: popw %dx
 popw %ax
 ret
print_char:
 pushw %dx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popw %dx
 ret
lab_good_start:.asciz "GOOD_START="
lab_good_after_a:.asciz "GOOD_AFTER_A="
lab_good_b_owner:.asciz "GOOD_B_OWNER="
lab_good_b_read:.asciz "GOOD_B_READ="
lab_good_after_b:.asciz "GOOD_AFTER_B="
lab_good_backing:.asciz "GOOD_BACKING="
lab_bad_start:.asciz "BAD_START="
lab_bad_after_a:.asciz "BAD_AFTER_A="
lab_bad_b_owner:.asciz "BAD_B_OWNER="
lab_bad_b_read:.asciz "BAD_B_READ="
lab_done:.asciz "DONE\n"
.section .data
backing_value:.byte 0
live_count:.byte 0
binding_a_owner:.byte 0
binding_b_owner:.byte 0
