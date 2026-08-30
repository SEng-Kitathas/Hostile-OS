.code16
.section .text
.global _start
.extern pit_divisor

.equ DEBUG_PORT, 0x00e9
.equ EXIT_PORT, 0x00f4
.equ PIC_MASTER_MASK, 0x0021
.equ PIC_SLAVE_MASK, 0x00a1
.equ PIC_MASTER_CMD, 0x0020
.equ PIT_CH0, 0x0040
.equ PIT_CMD, 0x0043

_start:
    cli
    xorw %ax, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movw $0x7b00, %sp

    # IRQ0 is real-mode vector 8. Install a guest handler before unmasking it.
    movw $irq0_handler, 0x0020
    movw $0x0000, 0x0022

    # Start with all maskable PIC lines masked while state is prepared.
    movw $PIC_MASTER_MASK, %dx
    movb $0xff, %al
    outb %al, %dx
    movw $PIC_SLAVE_MASK, %dx
    outb %al, %dx

    movb $0, event_generation
    movb $1, waiting
    movb $0, woken

    movw $msg_pre, %si
    call print_string
    movw $msg_idle, %si
    call print_string

    # PIT channel 0, lobyte/hibyte, mode 0 terminal-count one-shot, binary.
    movw $PIT_CMD, %dx
    movb $0x30, %al
    outb %al, %dx
    movw pit_divisor, %ax
    movw $PIT_CH0, %dx
    outb %al, %dx
    movb %ah, %al
    outb %al, %dx

    # Unmask only IRQ0. STI's interrupt shadow makes STI;HLT a safe idle entry.
    movw $PIC_MASTER_MASK, %dx
    movb $0xfe, %al
    outb %al, %dx

    sti
wait_irq:
    hlt
    cmpb $0, event_generation
    je wait_irq
    cli

    cmpb $1, event_generation
    jne state_fail
    cmpb $0, waiting
    jne state_fail
    cmpb $1, woken
    jne state_fail

    movw $msg_irq, %si
    call print_string
    movw $msg_wake, %si
    call print_string
    movw $msg_done, %si
    call print_string
    jmp success_exit

irq0_handler:
    pushw %ax
    pushw %dx
    incb event_generation
    cmpb $1, waiting
    jne irq_eoi
    movb $0, waiting
    movb $1, woken
irq_eoi:
    movw $PIC_MASTER_CMD, %dx
    movb $0x20, %al
    outb %al, %dx
    popw %dx
    popw %ax
    iret

state_fail:
    movw $msg_fail, %si
    call print_string
    movw $EXIT_PORT, %dx
    movb $0x11, %al
    outb %al, %dx
fail_halt:
    hlt
    jmp fail_halt

success_exit:
    movw $EXIT_PORT, %dx
    movb $0x10, %al
    outb %al, %dx
success_halt:
    hlt
    jmp success_halt

print_string:
    pushw %ax
    pushw %dx
print_loop:
    lodsb
    testb %al, %al
    jz print_done
    movw $DEBUG_PORT, %dx
    outb %al, %dx
    jmp print_loop
print_done:
    popw %dx
    popw %ax
    ret

msg_pre:  .asciz "PRE_EVENT=0\n"
msg_idle: .asciz "IDLE_ENTER=PASS\n"
msg_irq:  .asciz "IRQ_EVENT=PASS\n"
msg_wake: .asciz "IDLE_WAKE=PASS\n"
msg_done: .asciz "DONE\n"
msg_fail: .asciz "STATE_FAIL\n"

.section .data
event_generation: .byte 0
waiting: .byte 0
woken: .byte 0
