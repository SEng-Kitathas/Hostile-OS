.code16
.section .text
.global _start
.extern initial_state
.extern known_operation
.extern unknown_operation

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    movb initial_state,%al
    movb %al,protected_state

    movb known_operation,%al
    call apply_operation
    movb %al,known_status

    movb protected_state,%al
    movb %al,before_unknown

    movb unknown_operation,%al
    call apply_operation
    movb %al,unknown_status

    movb protected_state,%al
    movb %al,after_unknown

    movw $lab_known,%si
    call print_string
    movb known_status,%al
    call print_char
    call print_nl

    movw $lab_unknown,%si
    call print_string
    movb unknown_status,%al
    call print_char
    call print_nl

    movw $lab_before,%si
    call print_string
    movb before_unknown,%al
    call print_char
    call print_nl

    movw $lab_after,%si
    call print_string
    movb after_unknown,%al
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

# Input AL=operation code. Return AL='O' for known operation or 'M' for missing.
# Missing path does not mutate protected_state.
apply_operation:
    cmpb $0x01,%al
    jne operation_missing
    incb protected_state
    movb $'O',%al
    ret
operation_missing:
    movb $'M',%al
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

lab_known: .asciz "KNOWN_STATUS="
lab_unknown: .asciz "UNKNOWN_STATUS="
lab_before: .asciz "BEFORE_UNKNOWN="
lab_after: .asciz "AFTER_UNKNOWN="
lab_done: .asciz "DONE\n"

.section .data
protected_state: .byte 0
known_status: .byte 0
unknown_status: .byte 0
before_unknown: .byte 0
after_unknown: .byte 0
