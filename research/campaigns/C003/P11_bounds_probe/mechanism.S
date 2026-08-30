.code16
.section .text
.global _start
.extern valid_index_fact
.extern invalid_index_fact
.extern write_value_fact
.extern initial_slot0_fact
.extern initial_slot1_fact
.extern initial_sentinel_fact

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    call reset_state

    movw $lab_valid_index,%si
    movb valid_index_fact,%al
    addb $'0',%al
    call print_line

    movw $lab_invalid_index,%si
    movb invalid_index_fact,%al
    addb $'0',%al
    call print_line

    # Checked valid write must work, so reject-all cannot pass.
    xorw %bx,%bx
    movb valid_index_fact,%bl
    movb write_value_fact,%al
    call checked_write
    movw $lab_good_valid,%si
    call print_line

    movw $lab_good_slot1,%si
    movb relation_slots+1,%al
    call print_line

    # Checked invalid write must reject and preserve adjacent sentinel.
    xorw %bx,%bx
    movb invalid_index_fact,%bl
    movb write_value_fact,%al
    call checked_write
    movw $lab_good_invalid,%si
    call print_line

    movw $lab_good_sent,%si
    movb adjacent_sentinel,%al
    call print_line

    # Negative control: same facts, no bound check, raw index 2 write.
    call reset_state
    xorw %bx,%bx
    movb invalid_index_fact,%bl
    movb write_value_fact,%al
    call unchecked_write
    movw $lab_bad_invalid,%si
    call print_line

    movw $lab_bad_sent,%si
    movb adjacent_sentinel,%al
    call print_line

    movw $lab_done,%si
    call print_string
    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
1:
    hlt
    jmp 1b

reset_state:
    movb initial_slot0_fact,%al
    movb %al,relation_slots
    movb initial_slot1_fact,%al
    movb %al,relation_slots+1
    movb initial_sentinel_fact,%al
    movb %al,adjacent_sentinel
    ret

# BL=index, AL=value. Returns AL='W' on write or AL='R' on reject.
checked_write:
    cmpb $2,%bl
    jae checked_reject
    movb %al,relation_slots(%bx)
    movb $'W',%al
    ret
checked_reject:
    movb $'R',%al
    ret

# BL=index, AL=value. Deliberately no bounds check.
unchecked_write:
    movb %al,relation_slots(%bx)
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
2:
    lodsb
    testb %al,%al
    jz 3f
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    jmp 2b
3:
    popw %dx
    popw %ax
    ret

print_char:
    pushw %dx
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    popw %dx
    ret

lab_valid_index:   .asciz "VALID_INDEX="
lab_invalid_index: .asciz "INVALID_INDEX="
lab_good_valid:    .asciz "GOOD_VALID="
lab_good_slot1:    .asciz "GOOD_SLOT1="
lab_good_invalid:  .asciz "GOOD_INVALID="
lab_good_sent:     .asciz "GOOD_SENT="
lab_bad_invalid:   .asciz "BAD_INVALID="
lab_bad_sent:      .asciz "BAD_SENT="
lab_done:          .asciz "DONE\n"

.section .data
relation_slots:
    .byte 0,0
adjacent_sentinel:
    .byte 0
