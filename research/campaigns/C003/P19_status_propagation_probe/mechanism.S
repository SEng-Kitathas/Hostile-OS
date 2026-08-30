.code16
.section .text
.global _start
.extern known_request_fact
.extern missing_request_fact
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp

 call reset_progress
 movb missing_request_fact,%al
 call middle_checked
 movw $lab_good_miss_status,%si
 call print_line
 movw $lab_good_miss_progress,%si
 movb progress,%al
 addb $'0',%al
 call print_line

 call reset_progress
 movb known_request_fact,%al
 call middle_checked
 movw $lab_good_ok_status,%si
 call print_line
 movw $lab_good_ok_progress,%si
 movb progress,%al
 addb $'0',%al
 call print_line

 call reset_progress
 movb missing_request_fact,%al
 call middle_ignore_failure
 movw $lab_bad_miss_status,%si
 call print_line
 movw $lab_bad_miss_progress,%si
 movb progress,%al
 addb $'0',%al
 call print_line

 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

reset_progress:
 movb $0,progress
 ret

# AL=request. Returns O for known K, M otherwise. Never mutates progress.
leaf_execute:
 cmpb known_request_fact,%al
 jne leaf_missing
 movb $'O',%al
 ret
leaf_missing:
 movb $'M',%al
 ret

# AL=request. Propagates leaf failure before progress application.
middle_checked:
 call leaf_execute
 cmpb $'O',%al
 jne middle_return
 movb $1,progress
middle_return:
 ret

# AL=request. Deliberately ignores leaf failure and reports success.
middle_ignore_failure:
 call leaf_execute
 movb $1,progress
 movb $'O',%al
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
lab_good_miss_status:.asciz "GOOD_MISS_STATUS="
lab_good_miss_progress:.asciz "GOOD_MISS_PROGRESS="
lab_good_ok_status:.asciz "GOOD_OK_STATUS="
lab_good_ok_progress:.asciz "GOOD_OK_PROGRESS="
lab_bad_miss_status:.asciz "BAD_MISS_STATUS="
lab_bad_miss_progress:.asciz "BAD_MISS_PROGRESS="
lab_done:.asciz "DONE\n"
.section .data
progress:.byte 0
