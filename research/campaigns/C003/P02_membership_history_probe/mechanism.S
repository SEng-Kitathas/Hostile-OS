.code16
.section .text
.global _start
.extern initial_count
.extern initial_members
.extern last_selected_id
.extern last_selected_index
.extern remove_id

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7b00, %sp

    call load_fixture

    call select_identity
    movb %al, pre_id
    call select_index
    movb %al, pre_idx

    call remove_member_compact

    call select_identity
    movb %al, post_id
    call select_index
    movb %al, post_idx

    movw $label_pre_id, %si
    call print_string
    movb pre_id, %al
    call print_char
    call print_nl

    movw $label_pre_idx, %si
    call print_string
    movb pre_idx, %al
    call print_char
    call print_nl

    movw $label_post_id, %si
    call print_string
    movb post_id, %al
    call print_char
    call print_nl

    movw $label_post_idx, %si
    call print_string
    movb post_idx, %al
    call print_char
    call print_nl

    movw $label_done, %si
    call print_string

    movw $EXIT_PORT, %dx
    movb $0x10, %al
    outb %al, %dx
1:
    hlt
    jmp 1b

load_fixture:
    movb initial_count, %al
    movb %al, member_count
    movb initial_members, %al
    movb %al, members
    movb initial_members+1, %al
    movb %al, members+1
    movb initial_members+2, %al
    movb %al, members+2
    movb last_selected_id, %al
    movb %al, history_id
    movb last_selected_index, %al
    movb %al, history_index
    movb remove_id, %al
    movb %al, remove_target
    ret

# AL = next member after the current location of history_id.
select_identity:
    xorw %bx, %bx
2:
    xorw %cx, %cx
    movb member_count, %cl
    cmpw %cx, %bx
    jae 5f
    movb members(%bx), %al
    cmpb history_id, %al
    je 3f
    incw %bx
    jmp 2b
3:
    incw %bx
    xorw %cx, %cx
    movb member_count, %cl
    cmpw %cx, %bx
    jb 4f
    xorw %bx, %bx
4:
    movb members(%bx), %al
    ret
5:
    movb $'?', %al
    ret

# Negative control: raw numeric history remains stale across compaction.
# AL = member after stale history_index in the current compacted array.
select_index:
    xorw %bx, %bx
    movb history_index, %bl
    incw %bx
    xorw %cx, %cx
    movb member_count, %cl
    cmpw %cx, %bx
    jb 6f
    xorw %bx, %bx
6:
    movb members(%bx), %al
    ret

# Remove remove_target and compact the explicit fixed-capacity member array.
# The fixture does not perform this mutation.
remove_member_compact:
    xorw %bx, %bx
7:
    xorw %cx, %cx
    movb member_count, %cl
    cmpw %cx, %bx
    jae 11f
    movb members(%bx), %al
    cmpb remove_target, %al
    je 8f
    incw %bx
    jmp 7b
8:
    movw %bx, %di
9:
    movw %di, %si
    incw %si
    xorw %ax, %ax
    movb member_count, %al
    cmpw %ax, %si
    jae 10f
    movb members(%si), %dl
    movb %dl, members(%di)
    incw %di
    jmp 9b
10:
    decb member_count
11:
    ret

print_string:
    pushw %ax
    pushw %dx
12:
    lodsb
    testb %al, %al
    jz 13f
    movw $DEBUG_PORT, %dx
    outb %al, %dx
    jmp 12b
13:
    popw %dx
    popw %ax
    ret

print_char:
    pushw %dx
    movw $DEBUG_PORT, %dx
    outb %al, %dx
    popw %dx
    ret

print_nl:
    pushw %ax
    movb $'\n', %al
    call print_char
    popw %ax
    ret

label_pre_id: .asciz "PRE_ID="
label_pre_idx: .asciz "PRE_IDX="
label_post_id: .asciz "POST_ID="
label_post_idx: .asciz "POST_IDX="
label_done: .asciz "DONE\n"

.section .data
member_count: .byte 0
members: .byte 0,0,0
history_id: .byte 0
history_index: .byte 0
remove_target: .byte 0
pre_id: .byte 0
pre_idx: .byte 0
post_id: .byte 0
post_idx: .byte 0
