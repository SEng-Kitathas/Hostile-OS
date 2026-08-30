.code16
.section .text
.global _start
.extern repaired_wait_then_complete
.extern repaired_complete_then_wait
.extern broken_complete_then_wait

.equ OP_WAIT, 1
.equ OP_COMPLETE, 2
.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7b00, %sp

    movw $repaired_wait_then_complete, %si
    call reset_repaired
    call run_repaired
    movw $label_r_wc, %si
    call print_string
    call repaired_pass
    call print_pf

    movw $repaired_complete_then_wait, %si
    call reset_repaired
    call run_repaired
    movw $label_r_cw, %si
    call print_string
    call repaired_pass
    call print_pf

    movw $broken_complete_then_wait, %si
    call reset_broken
    call run_broken
    movw $label_b_cw, %si
    call print_string
    call broken_pass
    call print_pf

    movw $label_done, %si
    call print_string

    movw $EXIT_PORT, %dx
    movb $0x10, %al
    outb %al, %dx
1:
    hlt
    jmp 1b

# Fixture interpreter: fixture provides only operation order.
run_repaired:
2:
    lodsb
    testb %al, %al
    jz 5f
    cmpb $OP_WAIT, %al
    je 3f
    cmpb $OP_COMPLETE, %al
    je 4f
    jmp 2b
3:
    call repaired_wait
    jmp 2b
4:
    call repaired_complete
    jmp 2b
5:
    ret

run_broken:
6:
    lodsb
    testb %al, %al
    jz 9f
    cmpb $OP_WAIT, %al
    je 7f
    cmpb $OP_COMPLETE, %al
    je 8f
    jmp 6b
7:
    call broken_wait
    jmp 6b
8:
    call broken_complete
    jmp 6b
9:
    ret

# Repaired mechanism: terminal completion is explicit current state.
# wait checks current completion before arming a wait.
repaired_wait:
    cmpb $1, completion_current
    jne 10f
    movb $1, parent_runnable
    movb $0, wait_active
    ret
10:
    movb $1, wait_active
    movb $0, parent_runnable
    ret

# completion persists as current state and also wakes an already-armed wait.
repaired_complete:
    movb $1, completion_current
    cmpb $1, wait_active
    jne 11f
    movb $0, wait_active
    movb $1, parent_runnable
11:
    ret

# Deliberately broken one-shot control: completion is not retained when no wait exists.
broken_wait:
    movb $1, wait_active
    movb $0, parent_runnable
    ret

broken_complete:
    cmpb $1, wait_active
    jne 12f
    movb $0, wait_active
    movb $1, parent_runnable
12:
    ret

reset_repaired:
    movb $0, completion_current
    movb $0, wait_active
    movb $0, parent_runnable
    ret

reset_broken:
    movb $0, completion_current
    movb $0, wait_active
    movb $0, parent_runnable
    ret

# AL=1 only if repaired terminal state is coherent and runnable.
repaired_pass:
    xorb %al, %al
    cmpb $1, completion_current
    jne 13f
    cmpb $0, wait_active
    jne 13f
    cmpb $1, parent_runnable
    jne 13f
    movb $1, %al
13:
    ret

# AL=1 only if the broken control accidentally looks successful.
broken_pass:
    xorb %al, %al
    cmpb $0, wait_active
    jne 14f
    cmpb $1, parent_runnable
    jne 14f
    movb $1, %al
14:
    ret

print_pf:
    testb %al, %al
    jz 15f
    movw $text_pass, %si
    jmp print_string
15:
    movw $text_fail, %si
    jmp print_string

print_string:
    pushw %ax
    pushw %dx
16:
    lodsb
    testb %al, %al
    jz 17f
    movw $DEBUG_PORT, %dx
    outb %al, %dx
    jmp 16b
17:
    popw %dx
    popw %ax
    ret

label_r_wc: .asciz "R_WC="
label_r_cw: .asciz "R_CW="
label_b_cw: .asciz "B_CW="
label_done: .asciz "DONE\n"
text_pass: .asciz "PASS\n"
text_fail: .asciz "FAIL\n"

.section .data
completion_current: .byte 0
wait_active: .byte 0
parent_runnable: .byte 0
