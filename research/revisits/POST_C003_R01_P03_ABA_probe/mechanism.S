.code16
.section .text
.global _start
.extern initial_owner
.extern initial_history
.extern initial_version
.extern target_owner
.extern target_history
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ state_owner,0x0500
.equ state_history,0x0501
.equ state_active,0x0502
.equ state_version,0x0503
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%ss
 movw $0x7b00,%sp
 movw $DEBUG_PORT,%dx

 call load_state
 movb state_active,%al
 addb $'0',%al
 movb %al,o0
 movb state_owner,%al
 movb %al,o1
 call mutate_complete
 movb state_history,%al
 movb %al,o2
 movb state_active,%al
 addb $'0',%al
 movb %al,o3
 call flag_accept
 movb %al,o4

 call load_state
 movb state_version,%al
 addb $'0',%al
 movb %al,o5
 movb state_owner,%al
 movb %al,o6
 call mutate_complete
 movb state_history,%al
 movb %al,o7
 movb state_version,%al
 addb $'0',%al
 movb %al,o8
 call version_accept
 movb %al,o9

 movb state_version,%al
 addb $'0',%al
 movb %al,o10
 movb state_owner,%al
 movb %al,o11
 movb state_history,%al
 movb %al,o12
 movb state_version,%al
 addb $'0',%al
 movb %al,o13
 call stable_accept
 movb %al,o14

 movw $output,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

load_state:
 movb initial_owner,%al
 movb %al,state_owner
 movb initial_history,%al
 movb %al,state_history
 movb initial_version,%al
 movb %al,state_version
 movb $0,state_active
 ret

mutate_complete:
 movb $1,state_active
 movb target_owner,%al
 movb %al,state_owner
 movb target_history,%al
 movb %al,state_history
 incb state_version
 movb $0,state_active
 ret

flag_accept:
 cmpb $'0',o0
 jne flag_reject
 cmpb $'0',o3
 jne flag_reject
 movb o1,%al
 cmpb o2,%al
 jne flag_stale
 movb $'C',%al
 ret
flag_stale:
 movb $'S',%al
 ret
flag_reject:
 movb $'R',%al
 ret

version_accept:
 movb o5,%al
 cmpb o8,%al
 jne version_reject
 movb o6,%al
 cmpb o7,%al
 jne version_stale
 movb $'C',%al
 ret
version_stale:
 movb $'S',%al
 ret
version_reject:
 movb $'R',%al
 ret

stable_accept:
 movb o10,%al
 cmpb o13,%al
 jne stable_reject
 movb o11,%al
 cmpb o12,%al
 jne stable_stale
 movb $'C',%al
 ret
stable_stale:
 movb $'S',%al
 ret
stable_reject:
 movb $'R',%al
 ret

print_string:
 lodsb
 testb %al,%al
 jz 2f
 outb %al,%dx
 jmp print_string
2: ret

.section .data
output:
 .ascii "FLAG_PRE="
o0:.byte '?'
 .ascii "\nFLAG_OWNER="
o1:.byte '?'
 .ascii "\nFLAG_HISTORY="
o2:.byte '?'
 .ascii "\nFLAG_POST="
o3:.byte '?'
 .ascii "\nFLAG_ACCEPT="
o4:.byte '?'
 .ascii "\nVER_PRE="
o5:.byte '?'
 .ascii "\nVER_OWNER="
o6:.byte '?'
 .ascii "\nVER_HISTORY="
o7:.byte '?'
 .ascii "\nVER_POST="
o8:.byte '?'
 .ascii "\nVER_ACCEPT="
o9:.byte '?'
 .ascii "\nSTABLE_VER_PRE="
o10:.byte '?'
 .ascii "\nSTABLE_OWNER="
o11:.byte '?'
 .ascii "\nSTABLE_HISTORY="
o12:.byte '?'
 .ascii "\nSTABLE_VER_POST="
o13:.byte '?'
 .ascii "\nSTABLE_ACCEPT="
o14:.byte '?'
 .asciz "\nDONE\n"
