.code16
.section .text
.global _start
.extern activity_identity_fact
.extern initial_progress_fact

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    # Bound path: mechanism creates logical continuation 2 before blocking.
    call reset_activity
    call arm_wait_step2
    movw $lab_bound_id,%si
    movb activity_identity,%al
    call print_line
    movw $lab_bound_cont,%si
    movb continuation_id,%al
    call print_line
    call wake_activity
    movw $lab_bound_wake,%si
    movb woken,%al
    call print_line
    movw $lab_bound_pre,%si
    movb progress,%al
    call print_line
    call resume_bound
    movw $lab_bound_post,%si
    movb progress,%al
    call print_line

    # Negative control: same identity/wake, explicit binding is discarded and
    # fixed identity-only resume always applies continuation 1.
    call reset_activity
    call arm_wait_step2
    call wake_activity
    movw $lab_bad_id,%si
    movb activity_identity,%al
    call print_line
    movw $lab_bad_wake,%si
    movb woken,%al
    call print_line
    movb $0,continuation_id
    call resume_identity_only
    movw $lab_bad_post,%si
    movb progress,%al
    call print_line

    movw $lab_done,%si
    call print_string
    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
1:
    hlt
    jmp 1b

reset_activity:
    movb activity_identity_fact,%al
    movb %al,activity_identity
    movb initial_progress_fact,%al
    movb %al,progress
    movb $0,waiting
    movb $'0',woken
    movb $0,continuation_id
    ret

arm_wait_step2:
    movb $'2',continuation_id
    movb $1,waiting
    ret

wake_activity:
    cmpb $1,waiting
    jne wake_done
    movb $0,waiting
    movb $'1',woken
wake_done:
    ret

resume_bound:
    cmpb $'1',woken
    jne resume_done
    cmpb $'2',continuation_id
    je resume_step2
    cmpb $'1',continuation_id
    jne resume_done
    movb $'1',progress
    ret
resume_step2:
    movb $'2',progress
resume_done:
    ret

resume_identity_only:
    cmpb $'1',woken
    jne identity_done
    movb $'1',progress
identity_done:
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

lab_bound_id:   .asciz "BOUND_ID="
lab_bound_cont: .asciz "BOUND_CONT="
lab_bound_wake: .asciz "BOUND_WAKE="
lab_bound_pre:  .asciz "BOUND_PRE="
lab_bound_post: .asciz "BOUND_POST="
lab_bad_id:     .asciz "BAD_ID="
lab_bad_wake:   .asciz "BAD_WAKE="
lab_bad_post:   .asciz "BAD_POST="
lab_done:       .asciz "DONE\n"

.section .data
activity_identity: .byte 0
waiting: .byte 0
woken: .byte '0'
continuation_id: .byte 0
progress: .byte 0
