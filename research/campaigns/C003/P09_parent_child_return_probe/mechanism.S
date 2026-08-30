.code16
.section .text
.global _start
.extern parent_identity_fact
.extern child_identity_fact
.extern good_lineage_parent_fact
.extern bad_lineage_parent_fact
.extern wait_target_fact
.extern child_status_fact
.extern initial_parent_progress_fact

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    # Good path: C -> P, P waits on C.
    call reset_common
    movb good_lineage_parent_fact,%al
    movb %al,lineage_parent
    movb child_identity_fact,%al
    movb child_status_fact,%bl
    call record_completion
    call generic_wait_match

    movw $lab_good_complete,%si
    movb completion_status,%al
    call print_line
    movw $lab_good_wake,%si
    movb parent_woken,%al
    call print_line
    movw $lab_good_pre_progress,%si
    movb parent_progress,%al
    call print_line

    call apply_parent
    movw $lab_good_parent_status,%si
    movb parent_received_status,%al
    call print_line
    movw $lab_good_post_progress,%si
    movb parent_progress,%al
    call print_line

    # Bad path: same completion/wait target, lineage C -> Q.
    call reset_common
    movb bad_lineage_parent_fact,%al
    movb %al,lineage_parent
    movb child_identity_fact,%al
    movb child_status_fact,%bl
    call record_completion
    call generic_wait_match
    call apply_parent

    movw $lab_bad_complete,%si
    movb completion_status,%al
    call print_line
    movw $lab_bad_wake,%si
    movb parent_woken,%al
    call print_line
    movw $lab_bad_post_progress,%si
    movb parent_progress,%al
    call print_line
    movw $lab_done,%si
    call print_string

    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
1:
    hlt
    jmp 1b

reset_common:
    movb parent_identity_fact,%al
    movb %al,parent_identity
    movb child_identity_fact,%al
    movb %al,lineage_child
    movb wait_target_fact,%al
    movb %al,parent_wait_target
    movb initial_parent_progress_fact,%al
    movb %al,parent_progress
    movb $1,parent_waiting
    movb $'0',parent_woken
    movb $0,completion_current
    movb $0,parent_received_status
    ret

# AL=completed identity, BL=terminal status. No wake/application here.
record_completion:
    movb %al,completion_identity
    movb %bl,completion_status
    movb $1,completion_current
    ret

# Generic bounded wait/event matcher over explicit relation state.
generic_wait_match:
    cmpb $1,completion_current
    jne match_done
    cmpb $1,parent_waiting
    jne match_done
    movb completion_identity,%al
    cmpb parent_wait_target,%al
    jne match_done
    cmpb lineage_child,%al
    jne match_done
    movb lineage_parent,%al
    cmpb parent_identity,%al
    jne match_done
    movb $0,parent_waiting
    movb $'1',parent_woken
match_done:
    ret

# Separate ordinary parent application after generic wake.
apply_parent:
    cmpb $'1',parent_woken
    jne apply_done
    cmpb $1,completion_current
    jne apply_done
    movb completion_status,%al
    movb %al,parent_received_status
    incb parent_progress
apply_done:
    ret

# SI=label, AL=value. Preserve value while printing label.
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

lab_good_complete:      .asciz "GOOD_COMPLETE="
lab_good_wake:          .asciz "GOOD_WAKE="
lab_good_pre_progress:  .asciz "GOOD_PRE_PROGRESS="
lab_good_parent_status: .asciz "GOOD_PARENT_STATUS="
lab_good_post_progress: .asciz "GOOD_POST_PROGRESS="
lab_bad_complete:       .asciz "BAD_COMPLETE="
lab_bad_wake:           .asciz "BAD_WAKE="
lab_bad_post_progress:  .asciz "BAD_POST_PROGRESS="
lab_done:               .asciz "DONE\n"

.section .data
parent_identity: .byte 0
lineage_child: .byte 0
lineage_parent: .byte 0
parent_waiting: .byte 0
parent_wait_target: .byte 0
parent_woken: .byte '0'
completion_identity: .byte 0
completion_status: .byte 0
completion_current: .byte 0
parent_received_status: .byte 0
parent_progress: .byte 0
