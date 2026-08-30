.code16
.section .text
.global _start
.extern old_owner_fact
.extern old_cont_fact
.extern new_owner_fact
.extern new_cont_fact
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
    xorw %ax,%ax
    movw %ax,%ds
    movw %ax,%es
    movw %ax,%ss
    movw $0x7b00,%sp

    movw $irq0_handler,0x0020
    movw $0x0000,0x0022
    call mask_irqs

    # Good: both relation writes happen before IRQ0 can observe.
    call reset_relation
    call program_pit
    movb new_owner_fact,%al
    movb %al,relation_owner
    movb new_cont_fact,%al
    movb %al,relation_continuation
    call unmask_irq0
    sti
1:
    hlt
    cmpb $0,irq_seen
    je 1b
    cli
    movw $lab_good_irq_owner,%si
    movb irq_owner_snapshot,%al
    call print_line
    movw $lab_good_irq_cont,%si
    movb irq_cont_snapshot,%al
    call print_line
    movw $lab_good_post_owner,%si
    movb relation_owner,%al
    call print_line
    movw $lab_good_post_cont,%si
    movb relation_continuation,%al
    call print_line

    # Bad: IRQ0 is allowed to observe after owner write but before continuation.
    call mask_irqs
    call reset_relation
    call program_pit
    movb new_owner_fact,%al
    movb %al,relation_owner
    call unmask_irq0
    sti
2:
    hlt
    cmpb $0,irq_seen
    je 2b
    cli
    movb new_cont_fact,%al
    movb %al,relation_continuation
    movw $lab_bad_irq_owner,%si
    movb irq_owner_snapshot,%al
    call print_line
    movw $lab_bad_irq_cont,%si
    movb irq_cont_snapshot,%al
    call print_line
    movw $lab_bad_post_owner,%si
    movb relation_owner,%al
    call print_line
    movw $lab_bad_post_cont,%si
    movb relation_continuation,%al
    call print_line

    movw $lab_done,%si
    call print_string
    movw $EXIT_PORT,%dx
    movb $0x10,%al
    outb %al,%dx
3:
    hlt
    jmp 3b

reset_relation:
    movb old_owner_fact,%al
    movb %al,relation_owner
    movb old_cont_fact,%al
    movb %al,relation_continuation
    movb $0,irq_seen
    movb $0,irq_owner_snapshot
    movb $0,irq_cont_snapshot
    ret

mask_irqs:
    cli
    movw $PIC_MASTER_MASK,%dx
    movb $0xff,%al
    outb %al,%dx
    movw $PIC_SLAVE_MASK,%dx
    outb %al,%dx
    ret

program_pit:
    movw $PIT_CMD,%dx
    movb $0x30,%al
    outb %al,%dx
    movw pit_divisor,%ax
    movw $PIT_CH0,%dx
    outb %al,%dx
    movb %ah,%al
    outb %al,%dx
    ret

unmask_irq0:
    movw $PIC_MASTER_MASK,%dx
    movb $0xfe,%al
    outb %al,%dx
    ret

irq0_handler:
    pushw %ax
    pushw %dx
    movb relation_owner,%al
    movb %al,irq_owner_snapshot
    movb relation_continuation,%al
    movb %al,irq_cont_snapshot
    movb $1,irq_seen
    movw $PIC_MASTER_CMD,%dx
    movb $0x20,%al
    outb %al,%dx
    popw %dx
    popw %ax
    iret

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
4:
    lodsb
    testb %al,%al
    jz 5f
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    jmp 4b
5:
    popw %dx
    popw %ax
    ret

print_char:
    pushw %dx
    movw $DEBUG_PORT,%dx
    outb %al,%dx
    popw %dx
    ret

lab_good_irq_owner:  .asciz "GOOD_IRQ_OWNER="
lab_good_irq_cont:   .asciz "GOOD_IRQ_CONT="
lab_good_post_owner: .asciz "GOOD_POST_OWNER="
lab_good_post_cont:  .asciz "GOOD_POST_CONT="
lab_bad_irq_owner:   .asciz "BAD_IRQ_OWNER="
lab_bad_irq_cont:    .asciz "BAD_IRQ_CONT="
lab_bad_post_owner:  .asciz "BAD_POST_OWNER="
lab_bad_post_cont:   .asciz "BAD_POST_CONT="
lab_done:            .asciz "DONE\n"

.section .data
relation_owner:       .byte 0
relation_continuation:.byte 0
irq_seen:             .byte 0
irq_owner_snapshot:   .byte 0
irq_cont_snapshot:    .byte 0
