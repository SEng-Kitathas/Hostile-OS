.code16
.section .text
.global _start
.extern initial_count
.extern initial_members
.extern history_identity
.extern remove_identity

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4

_start:
    cli
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    # Unguarded trial.
    call load_state
    call remove_member
    call observe_raw
    movb %al,raw_cut
    call repair_history
    call observe_raw
    movb %al,raw_post

    # Guarded trial from identical fixture state.
    call load_state
    movb $1,guard_active
    call remove_member
    call observe_guard
    movb %al,guard_cut
    call repair_history
    movb $0,guard_active
    call observe_guard
    movb %al,guard_post

    movw $raw_prefix,%si
    call print_string
    movw $cut_suffix,%si
    call print_string
    movb raw_cut,%al
    call print_char
    call print_nl

    movw $raw_prefix,%si
    call print_string
    movw $post_suffix,%si
    call print_string
    movb raw_post,%al
    call print_char
    call print_nl

    movw $guard_prefix,%si
    call print_string
    movw $cut_suffix,%si
    call print_string
    movb guard_cut,%al
    call print_char
    call print_nl

    movw $guard_prefix,%si
    call print_string
    movw $post_suffix,%si
    call print_string
    movb guard_post,%al
    call print_char
    call print_nl

    movw $done_text,%si
    call print_string

    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
1:  hlt
    jmp 1b

load_state:
    movb initial_count,%al
    movb %al,state_count
    movb initial_members,%al
    movb %al,state_members
    movb initial_members+1,%al
    movb %al,state_members+1
    movb initial_members+2,%al
    movb %al,state_members+2
    movb history_identity,%al
    movb %al,state_history
    movb remove_identity,%al
    movb %al,remove_target
    movb $0,guard_active
    ret

remove_member:
    xorw %bx,%bx
2:
    xorw %cx,%cx
    movb state_count,%cl
    cmpw %cx,%bx
    jae 6f
    movb state_members(%bx),%al
    cmpb remove_target,%al
    je 3f
    incw %bx
    jmp 2b
3:
    movw %bx,%si
4:
    movw %si,%di
    incw %di
    xorw %cx,%cx
    movb state_count,%cl
    cmpw %cx,%di
    jae 5f
    movb state_members(%di),%al
    movb %al,state_members(%si)
    incw %si
    jmp 4b
5:
    decb state_count
6:
    ret

# AL=1 iff DL is a current member.
present:
    xorw %bx,%bx
7:
    xorw %cx,%cx
    movb state_count,%cl
    cmpw %cx,%bx
    jae 9f
    cmpb %dl,state_members(%bx)
    je 8f
    incw %bx
    jmp 7b
8:
    movb $1,%al
    ret
9:
    xorb %al,%al
    ret

observe_raw:
    movb state_history,%dl
    testb %dl,%dl
    jz 10f
    call present
    testb %al,%al
    jnz 10f
    movb $'S',%al
    ret
10:
    movb $'C',%al
    ret

observe_guard:
    cmpb $1,guard_active
    jne observe_raw
    movb $'R',%al
    ret

repair_history:
    movb state_history,%dl
    testb %dl,%dl
    jz 11f
    call present
    testb %al,%al
    jnz 11f
    movb $0,state_history
11:
    ret

print_string:
    pushw %ax
    pushw %dx
12:
    lodsb
    testb %al,%al
    jz 13f
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    jmp 12b
13:
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

raw_prefix: .asciz "RAW_"
guard_prefix: .asciz "GUARD_"
cut_suffix: .asciz "CUT="
post_suffix: .asciz "POST="
done_text: .asciz "DONE\n"

.section .data
state_count: .byte 0
state_members: .byte 0,0,0
state_history: .byte 0
remove_target: .byte 0
guard_active: .byte 0
raw_cut: .byte 0
raw_post: .byte 0
guard_cut: .byte 0
guard_post: .byte 0
