.code16
.section .text
.global _start
.extern owner_a_fact
.extern owner_b_fact
.extern dirty_wait_fact
.extern dirty_cont_fact
.extern dirty_progress_fact
.extern clean_default_fact

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    call make_dirty_a
    call release_slot
    movw $lab_release_owner,%si
    movb record_owner,%al
    addb $'0',%al
    call print_line
    movw $lab_release_wait,%si
    movb record_waiting,%al
    call print_line

    call acquire_b_clean
    movw $lab_good_owner,%si
    movb record_owner,%al
    call print_line
    movw $lab_good_wait,%si
    movb record_waiting,%al
    call print_line
    movw $lab_good_cont,%si
    movb record_continuation,%al
    call print_line
    movw $lab_good_progress,%si
    movb record_progress,%al
    call print_line

    # Same physical record, same dirty A history, owner-only B reuse.
    call make_dirty_a
    call release_slot
    call acquire_b_owner_only
    movw $lab_bad_owner,%si
    movb record_owner,%al
    call print_line
    movw $lab_bad_wait,%si
    movb record_waiting,%al
    call print_line
    movw $lab_bad_cont,%si
    movb record_continuation,%al
    call print_line
    movw $lab_bad_progress,%si
    movb record_progress,%al
    call print_line

    movw $lab_done,%si
    call print_string
    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
1:
    hlt
    jmp 1b

make_dirty_a:
    movb owner_a_fact,%al
    movb %al,record_owner
    movb dirty_wait_fact,%al
    movb %al,record_waiting
    movb dirty_cont_fact,%al
    movb %al,record_continuation
    movb dirty_progress_fact,%al
    movb %al,record_progress
    ret

release_slot:
    movb $0,record_owner
    ret

acquire_b_clean:
    movb owner_b_fact,%al
    movb %al,record_owner
    movb clean_default_fact,%al
    movb %al,record_waiting
    movb %al,record_continuation
    movb %al,record_progress
    ret

acquire_b_owner_only:
    movb owner_b_fact,%al
    movb %al,record_owner
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

lab_release_owner: .asciz "RELEASE_OWNER="
lab_release_wait:  .asciz "RELEASE_WAIT="
lab_good_owner:    .asciz "GOOD_OWNER="
lab_good_wait:     .asciz "GOOD_WAIT="
lab_good_cont:     .asciz "GOOD_CONT="
lab_good_progress: .asciz "GOOD_PROGRESS="
lab_bad_owner:     .asciz "BAD_OWNER="
lab_bad_wait:      .asciz "BAD_WAIT="
lab_bad_cont:      .asciz "BAD_CONT="
lab_bad_progress:  .asciz "BAD_PROGRESS="
lab_done:          .asciz "DONE\n"

.section .data
record_owner:        .byte 0
record_waiting:      .byte 0
record_continuation: .byte 0
record_progress:     .byte 0
