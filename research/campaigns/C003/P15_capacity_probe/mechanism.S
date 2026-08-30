.code16
.section .text
.global _start
.extern identity_a_fact
.extern identity_b_fact
.extern identity_c_fact
.extern capacity_fact
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp
 call reset_store
 movb identity_a_fact,%al
 call admit_checked
 movw $lab_good_a,%si
 call print_line
 movb identity_b_fact,%al
 call admit_checked
 movw $lab_good_b,%si
 call print_line
 movb identity_c_fact,%al
 call admit_checked
 movw $lab_good_c,%si
 call print_line
 movw $lab_good_s0,%si
 movb slots,%al
 call print_line
 movw $lab_good_s1,%si
 movb slots+1,%al
 call print_line

 call reset_store
 movb identity_a_fact,%al
 call admit_checked
 movw $lab_bad_a,%si
 call print_line
 movb identity_b_fact,%al
 call admit_checked
 movw $lab_bad_b,%si
 call print_line
 movb identity_c_fact,%al
 call admit_overwrite_full
 movw $lab_bad_c,%si
 call print_line
 movw $lab_bad_s0,%si
 movb slots,%al
 call print_line
 movw $lab_bad_s1,%si
 movb slots+1,%al
 call print_line
 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

reset_store:
 movb $0,slots
 movb $0,slots+1
 movb $0,count
 ret

# AL=identity, returns W or F.
admit_checked:
 movb %al,%ah
 movb count,%bl
 cmpb capacity_fact,%bl
 jae checked_full
 xorb %bh,%bh
 movb %ah,slots(%bx)
 incb count
 movb $'W',%al
 ret
checked_full:
 movb $'F',%al
 ret

# AL=identity; when full, deliberately clobber slot 0.
admit_overwrite_full:
 movb %al,%ah
 movb count,%bl
 cmpb capacity_fact,%bl
 jb overwrite_not_full
 movb %ah,slots
 movb $'W',%al
 ret
overwrite_not_full:
 jmp admit_checked

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

lab_good_a:.asciz "GOOD_A="
lab_good_b:.asciz "GOOD_B="
lab_good_c:.asciz "GOOD_C="
lab_good_s0:.asciz "GOOD_SLOT0="
lab_good_s1:.asciz "GOOD_SLOT1="
lab_bad_a:.asciz "BAD_A="
lab_bad_b:.asciz "BAD_B="
lab_bad_c:.asciz "BAD_C="
lab_bad_s0:.asciz "BAD_SLOT0="
lab_bad_s1:.asciz "BAD_SLOT1="
lab_done:.asciz "DONE\n"
.section .data
slots:.byte 0,0
count:.byte 0
