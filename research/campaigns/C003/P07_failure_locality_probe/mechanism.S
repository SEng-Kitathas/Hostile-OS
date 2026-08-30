.code16
.section .text
.global _start
.extern missing_requester
.extern later_requester
.extern missing_operation
.extern present_operation
.extern initial_state

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    # Trial L: local missing result must not poison distinct later progress.
    movb initial_state,%al
    movb %al,protected_state
    movb $0,global_failed

    movb missing_requester,%al
    movb %al,current_activity
    movb missing_operation,%al
    call apply_operation
    movb %al,local_miss

    movb later_requester,%al
    movb %al,current_activity
    movb present_operation,%al
    call apply_operation
    movb %al,local_later
    movb protected_state,%al
    movb %al,local_state

    # Trial G: same activity-A miss, deliberately poison global control.
    movb initial_state,%al
    movb %al,protected_state
    movb $0,global_failed

    movb missing_requester,%al
    movb %al,current_activity
    movb missing_operation,%al
    call apply_operation
    movb %al,global_miss
    cmpb $'M',%al
    jne skip_poison
    movb $1,global_failed
skip_poison:

    movb later_requester,%al
    movb %al,current_activity
    movb present_operation,%al
    call apply_with_global_control
    movb %al,global_later
    movb protected_state,%al
    movb %al,global_state

    movw $lab_local_miss,%si
    call print_string
    movb local_miss,%al
    call print_char
    call print_nl

    movw $lab_local_later,%si
    call print_string
    movb local_later,%al
    call print_char
    call print_nl

    movw $lab_local_state,%si
    call print_string
    movb local_state,%al
    call print_char
    call print_nl

    movw $lab_global_miss,%si
    call print_string
    movb global_miss,%al
    call print_char
    call print_nl

    movw $lab_global_later,%si
    call print_string
    movb global_later,%al
    call print_char
    call print_nl

    movw $lab_global_state,%si
    call print_string
    movb global_state,%al
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

# Shared bounded operation relation. AL=op code; returns O or M.
# The currently bound activity identity is explicit state but does not change
# operation-presence semantics.
apply_operation:
    cmpb $0x01,%al
    jne operation_missing
    incb protected_state
    movb $'O',%al
    ret
operation_missing:
    movb $'M',%al
    ret

# Deliberately bad negative-control wrapper. It blocks all later work once the
# global poison byte is set; this is a control, not an earned manager object.
apply_with_global_control:
    cmpb $0,global_failed
    jne operation_blocked
    jmp apply_operation
operation_blocked:
    movb $'X',%al
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

lab_local_miss:  .asciz "LOCAL_MISS="
lab_local_later: .asciz "LOCAL_LATER="
lab_local_state: .asciz "LOCAL_STATE="
lab_global_miss: .asciz "GLOBAL_MISS="
lab_global_later:.asciz "GLOBAL_LATER="
lab_global_state:.asciz "GLOBAL_STATE="
lab_done:        .asciz "DONE\n"

.section .data
protected_state: .byte 0
global_failed: .byte 0
current_activity: .byte 0
local_miss: .byte 0
local_later: .byte 0
local_state: .byte 0
global_miss: .byte 0
global_later: .byte 0
global_state: .byte 0
