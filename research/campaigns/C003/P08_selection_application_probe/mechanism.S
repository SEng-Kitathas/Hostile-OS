.code16
.section .text
.global _start
.extern eligible_a
.extern eligible_b
.extern initial_policy_history
.extern initial_progress_a
.extern initial_progress_b

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    # Separated path.
    call reset_state
    call select_next
    movb %al,sep_selected
    movb progress_a,%al
    movb %al,sep_select_a
    movb progress_b,%al
    movb %al,sep_select_b
    movb sep_selected,%al
    call apply_selected
    movb progress_a,%al
    movb %al,sep_apply_a
    movb progress_b,%al
    movb %al,sep_apply_b

    # Deliberately conflated control.
    call reset_state
    call select_and_apply_bad
    movb %al,bad_selected
    movb progress_a,%al
    movb %al,bad_select_a
    movb progress_b,%al
    movb %al,bad_select_b

    movw $lab_sep_selected,%si
    call print_string
    movb sep_selected,%al
    call print_char
    call print_nl
    movw $lab_sep_select_a,%si
    call print_string
    movb sep_select_a,%al
    call print_char
    call print_nl
    movw $lab_sep_select_b,%si
    call print_string
    movb sep_select_b,%al
    call print_char
    call print_nl
    movw $lab_sep_apply_a,%si
    call print_string
    movb sep_apply_a,%al
    call print_char
    call print_nl
    movw $lab_sep_apply_b,%si
    call print_string
    movb sep_apply_b,%al
    call print_char
    call print_nl
    movw $lab_bad_selected,%si
    call print_string
    movb bad_selected,%al
    call print_char
    call print_nl
    movw $lab_bad_select_a,%si
    call print_string
    movb bad_select_a,%al
    call print_char
    call print_nl
    movw $lab_bad_select_b,%si
    call print_string
    movb bad_select_b,%al
    call print_char
    call print_nl
    movw $lab_done,%si
    call print_string

    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
1:
    hlt
    jmp 1b

reset_state:
    movb initial_policy_history,%al
    movb %al,policy_history
    movb initial_progress_a,%al
    movb %al,progress_a
    movb initial_progress_b,%al
    movb %al,progress_b
    movb $0,selected_identity
    ret

# Returns selected identity and may update policy history, but does not touch progress.
select_next:
    movb policy_history,%al
    cmpb eligible_a,%al
    jne choose_a
    movb eligible_b,%al
    jmp selected
choose_a:
    movb eligible_a,%al
selected:
    movb %al,selected_identity
    movb %al,policy_history
    ret

# Input AL=selected identity. Apply one bounded progress step only here.
apply_selected:
    cmpb eligible_a,%al
    je apply_a
    cmpb eligible_b,%al
    je apply_b
    ret
apply_a:
    incb progress_a
    ret
apply_b:
    incb progress_b
    ret

# Negative control: selection collapses application into the same relation.
select_and_apply_bad:
    call select_next
    pushw %ax
    call apply_selected
    popw %ax
    ret

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

print_nl:
    pushw %ax
    movb $'\n',%al
    call print_char
    popw %ax
    ret

lab_sep_selected: .asciz "SEP_SELECTED="
lab_sep_select_a: .asciz "SEP_SELECT_A="
lab_sep_select_b: .asciz "SEP_SELECT_B="
lab_sep_apply_a: .asciz "SEP_APPLY_A="
lab_sep_apply_b: .asciz "SEP_APPLY_B="
lab_bad_selected: .asciz "BAD_SELECTED="
lab_bad_select_a: .asciz "BAD_SELECT_A="
lab_bad_select_b: .asciz "BAD_SELECT_B="
lab_done: .asciz "DONE\n"

.section .data
policy_history: .byte 0
selected_identity: .byte 0
progress_a: .byte 0
progress_b: .byte 0
sep_selected: .byte 0
sep_select_a: .byte 0
sep_select_b: .byte 0
sep_apply_a: .byte 0
sep_apply_b: .byte 0
bad_selected: .byte 0
bad_select_a: .byte 0
bad_select_b: .byte 0
