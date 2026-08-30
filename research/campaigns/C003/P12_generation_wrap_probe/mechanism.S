.code16
.section .text
.global _start
.extern initial_generation_fact
.extern stale_token_fact
.extern increment_count_fact

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    movw initial_generation_fact,%ax
    movb %al,generation8
    movw %ax,generation16

    movw $lab_count_hi,%si
    movb increment_count_fact+1,%al
    addb $'0',%al
    call print_line

    movw $lab_count_lo,%si
    movb increment_count_fact,%al
    addb $'0',%al
    call print_line

    movw $lab_stale,%si
    movb stale_token_fact,%al
    addb $'0',%al
    call print_line

    # One shared history: both widths increment once per iteration.
    movw increment_count_fact,%cx
1:
    incb generation8
    incw generation16
    loop 1b

    movw generation16,%ax
    movw %ax,fresh_token16

    movw $lab_narrow_gen,%si
    movb generation8,%al
    addb $'0',%al
    call print_line

    movb stale_token_fact,%al
    cmpb generation8,%al
    jne narrow_reject
    movb $'A',%al
    jmp narrow_emit
narrow_reject:
    movb $'R',%al
narrow_emit:
    movw $lab_narrow_stale,%si
    call print_line

    movw $lab_wide_hi,%si
    movb generation16+1,%al
    addb $'0',%al
    call print_line

    movw $lab_wide_lo,%si
    movb generation16,%al
    addb $'0',%al
    call print_line

    movw fresh_token16,%ax
    call check_wide
    movw $lab_wide_fresh,%si
    call print_line

    movw stale_token_fact,%ax
    call check_wide
    movw $lab_wide_stale,%si
    call print_line

    movw $lab_done,%si
    call print_string
    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
2:
    hlt
    jmp 2b

# AX=token; returns AL='A' on exact 16-bit currentness equality, else 'R'.
check_wide:
    cmpw generation16,%ax
    jne wide_reject
    movb $'A',%al
    ret
wide_reject:
    movb $'R',%al
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
3:
    lodsb
    testb %al,%al
    jz 4f
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    jmp 3b
4:
    popw %dx
    popw %ax
    ret

print_char:
    pushw %dx
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    popw %dx
    ret

lab_count_hi:     .asciz "COUNT_HI="
lab_count_lo:     .asciz "COUNT_LO="
lab_stale:        .asciz "STALE_TOKEN="
lab_narrow_gen:   .asciz "NARROW_GEN="
lab_narrow_stale: .asciz "NARROW_STALE="
lab_wide_hi:      .asciz "WIDE_HI="
lab_wide_lo:      .asciz "WIDE_LO="
lab_wide_fresh:   .asciz "WIDE_FRESH="
lab_wide_stale:   .asciz "WIDE_STALE="
lab_done:         .asciz "DONE\n"

.section .data
generation8:   .byte 0
generation16:  .word 0
fresh_token16: .word 0
