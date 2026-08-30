.code16
.section .text
.global _start

.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ PIC_MASTER_CMD,0x0020
.equ PIC_MASTER_MASK,0x0021
.equ PIC_SLAVE_MASK,0x00a1
.equ PIT_CH0,0x0040
.equ PIT_CMD,0x0043

_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7a00,%sp
 call save_irq_platform_state
 call install_irq
 call mask_irqs
 movw $lab_test,%si
 movb $'1',%al
 call print_line

 call reset_valid
 movb $1,stop_after
 call run_irq_phase
 movb event_generation,%al
 addb $'0',%al
 movw $lab_one_event,%si
 call print_line
 movb irq_rel_ok,%al
 addb $'0',%al
 movw $lab_one_rel,%si
 call print_line
 call semantic_gate
 movw $lab_one_sem,%si
 call print_line
 movb act_woken,%al
 addb $'0',%al
 movw $lab_one_wake,%si
 call print_line
 movb act_progress,%al
 addb $'0',%al
 movw $lab_one_preprog,%si
 call print_line
 call apply_continuation
 movb act_progress,%al
 addb $'0',%al
 movw $lab_one_prog,%si
 call print_line
 call exact_one_gate
 movw $lab_one_exact,%si
 call print_line

 call reset_valid
 movb $2,stop_after
 call run_irq_phase
 movb event_generation,%al
 addb $'0',%al
 movw $lab_multi_event,%si
 call print_line
 movb irq_rel_ok,%al
 addb $'0',%al
 movw $lab_multi_rel,%si
 call print_line
 call semantic_gate
 movw $lab_multi_sem,%si
 call print_line
 movb act_woken,%al
 addb $'0',%al
 movw $lab_multi_wake,%si
 call print_line
 movb act_progress,%al
 addb $'0',%al
 movw $lab_multi_preprog,%si
 call print_line
 call apply_continuation
 movb act_progress,%al
 addb $'0',%al
 movw $lab_multi_prog,%si
 call print_line
 call exact_one_gate
 movw $lab_multi_exact,%si
 call print_line

 call reset_badrel
 movb $2,stop_after
 call run_irq_phase
 movb event_generation,%al
 addb $'0',%al
 movw $lab_bad_event,%si
 call print_line
 movb irq_rel_ok,%al
 addb $'0',%al
 movw $lab_bad_rel,%si
 call print_line
 call semantic_gate
 movw $lab_bad_sem,%si
 call print_line
 movb act_woken,%al
 addb $'0',%al
 movw $lab_bad_wake,%si
 call print_line
 call apply_continuation
 movb act_progress,%al
 addb $'0',%al
 movw $lab_bad_prog,%si
 call print_line

 call restore_irq_platform_state
 movw $lab_done,%si
 call print_string
 jmp success_exit

reset_valid:
 cli
 call mask_irqs
 movb $1,act_gen
 movb $1,act_wait_gen
 movb $2,act_cont
 movb $1,act_waiting
 movb $0,act_woken
 movb $0,act_progress
 movb $0,event_generation
 movb $0,irq_rel_ok
 ret

reset_badrel:
 call reset_valid
 movb $2,act_wait_gen
 ret

run_irq_phase:
 call program_pit
 call unmask_irq0
 sti
phase_wait:
 hlt
 cli
 movb event_generation,%al
 cmpb stop_after,%al
 jae phase_done
 sti
 jmp phase_wait
phase_done:
 call mask_irqs
 ret

semantic_gate:
 movb $'R',%al
 cmpb $0,event_generation
 je semantic_done
 cmpb $1,irq_rel_ok
 jne semantic_done
 movb $1,act_woken
 movb $'W',%al
semantic_done:
 ret

exact_one_gate:
 movb $'R',%al
 cmpb $1,event_generation
 jne exact_done
 movb $'W',%al
exact_done:
 ret

apply_continuation:
 cmpb $1,act_woken
 jne apply_done
 cmpb $2,act_cont
 jne apply_done
 movb act_cont,%al
 movb %al,act_progress
apply_done:
 ret

save_irq_platform_state:
 movw 0x0020,%ax
 movw %ax,saved_irq0_off
 movw 0x0022,%ax
 movw %ax,saved_irq0_seg
 movw $PIC_MASTER_MASK,%dx
 inb %dx,%al
 movb %al,saved_master_mask
 movw $PIC_SLAVE_MASK,%dx
 inb %dx,%al
 movb %al,saved_slave_mask
 ret

restore_irq_platform_state:
 cli
 movw saved_irq0_off,%ax
 movw %ax,0x0020
 movw saved_irq0_seg,%ax
 movw %ax,0x0022
 movw $PIC_MASTER_MASK,%dx
 movb saved_master_mask,%al
 outb %al,%dx
 movw $PIC_SLAVE_MASK,%dx
 movb saved_slave_mask,%al
 outb %al,%dx
 ret

install_irq:
 movw $irq0_handler,0x0020
 movw $0,0x0022
 ret

mask_irqs:
 cli
 movw $PIC_MASTER_MASK,%dx
 movb $0xff,%al
 outb %al,%dx
 movw $PIC_SLAVE_MASK,%dx
 outb %al,%dx
 ret

unmask_irq0:
 movw $PIC_MASTER_MASK,%dx
 movb $0xfe,%al
 outb %al,%dx
 ret

program_pit:
 movw $PIT_CMD,%dx
 movb $0x30,%al
 outb %al,%dx
 movw $0x1000,%ax
 movw $PIT_CH0,%dx
 outb %al,%dx
 movb %ah,%al
 outb %al,%dx
 ret

irq0_handler:
 pushw %ax
 pushw %dx
 incb event_generation
 movb $0,irq_rel_ok
 movb act_gen,%al
 cmpb act_wait_gen,%al
 jne irq_threshold
 cmpb $2,act_cont
 jne irq_threshold
 cmpb $1,act_waiting
 jne irq_threshold
 movb $1,irq_rel_ok
irq_threshold:
 movb event_generation,%al
 cmpb stop_after,%al
 jb irq_eoi
 movw $PIC_MASTER_MASK,%dx
 movb $0xff,%al
 outb %al,%dx
irq_eoi:
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
print_loop:
 lodsb
 testb %al,%al
 jz print_done
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp print_loop
print_done:
 popw %dx
 popw %ax
 ret
print_char:
 pushw %dx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popw %dx
 ret

success_exit:
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

.section .data
act_gen:.byte 0
act_wait_gen:.byte 0
act_cont:.byte 0
act_waiting:.byte 0
act_woken:.byte 0
act_progress:.byte 0
event_generation:.byte 0
irq_rel_ok:.byte 0
stop_after:.byte 0
saved_irq0_off:.word 0
saved_irq0_seg:.word 0
saved_master_mask:.byte 0
saved_slave_mask:.byte 0

lab_test:.asciz "TEST=I001_IRQCOUNT01_"
lab_one_event:.asciz "ONE_EVENT="
lab_one_rel:.asciz "ONE_REL="
lab_one_sem:.asciz "ONE_SEM="
lab_one_wake:.asciz "ONE_WAKE="
lab_one_preprog:.asciz "ONE_PREPROG="
lab_one_prog:.asciz "ONE_PROG="
lab_one_exact:.asciz "ONE_EXACT="
lab_multi_event:.asciz "MULTI_EVENT="
lab_multi_rel:.asciz "MULTI_REL="
lab_multi_sem:.asciz "MULTI_SEM="
lab_multi_wake:.asciz "MULTI_WAKE="
lab_multi_preprog:.asciz "MULTI_PREPROG="
lab_multi_prog:.asciz "MULTI_PROG="
lab_multi_exact:.asciz "MULTI_EXACT="
lab_bad_event:.asciz "BADREL_EVENT="
lab_bad_rel:.asciz "BADREL_REL="
lab_bad_sem:.asciz "BADREL_SEM="
lab_bad_wake:.asciz "BADREL_WAKE="
lab_bad_prog:.asciz "BADREL_PROG="
lab_done:.asciz "DONE\n"
