.code16
.section .text
.global _start
.equ ACTIVITY_CAP,64
.equ BINDINGS_PER_ACTIVITY,20
.equ BINDING_CELL_COUNT,1280
.equ RESOURCE_CAP,64
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ PIC_MASTER_MASK,0x0021
.equ PIC_SLAVE_MASK,0x00a1
.equ PIC_MASTER_CMD,0x0020
.equ PIT_CH0,0x0040
.equ PIT_CMD,0x0043
.equ PIT_DIVISOR,4096

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

 # A: bad bind publication, IRQ after resource lifetime is live but before binding publish.
 call reset_empty
 call program_pit
 incb resource_generation
 movb $0x51,resource_identity
 movb $0x7e,resource_value
 movw $1,resource_live_count
 call unmask_irq0
 sti
bad_bind_wait:
 hlt
 cmpb $0,irq_seen
 je bad_bind_wait
 cli
 incb binding_generation
 movb $1,binding_resource_plus1
 movb irq_bind_snapshot,%al
 movb %al,o_bad_bind_irq_bind
 movb irq_rid_snapshot,%al
 movb %al,o_bad_bind_irq_rid
 movw irq_live_snapshot,%ax
 movw %ax,o_bad_bind_irq_live
 movb binding_resource_plus1,%al
 movb %al,o_bad_bind_post_bind
 movb resource_identity,%al
 movb %al,o_bad_bind_post_rid
 movw resource_live_count,%ax
 movw %ax,o_bad_bind_post_live

 # B: good bind publication, IRQ only after all six coupled instructions.
 call mask_irqs
 call reset_empty
 call program_pit
good_bind_region_begin:
 incb resource_generation
 movb $0x51,resource_identity
 movb $0x7e,resource_value
 movw $1,resource_live_count
 incb binding_generation
 movb $1,binding_resource_plus1
good_bind_region_end:
 call unmask_irq0
 sti
good_bind_wait:
 hlt
 cmpb $0,irq_seen
 je good_bind_wait
 cli
 movb irq_bind_snapshot,%al
 movb %al,o_good_bind_irq_bind
 movb irq_rid_snapshot,%al
 movb %al,o_good_bind_irq_rid
 movw irq_live_snapshot,%ax
 movw %ax,o_good_bind_irq_live

 # C: bad final detach, IRQ after binding withdrawal but before lifetime decrement/reclaim.
 call mask_irqs
 call reset_live
 call program_pit
 movb $0,binding_resource_plus1
 call unmask_irq0
 sti
bad_detach_wait:
 hlt
 cmpb $0,irq_seen
 je bad_detach_wait
 cli
 decw resource_live_count
 cmpw $0,resource_live_count
 jne fail
 movb $0,resource_identity
 movb $0,resource_value
 movb irq_bind_snapshot,%al
 movb %al,o_bad_detach_irq_bind
 movb irq_rid_snapshot,%al
 movb %al,o_bad_detach_irq_rid
 movw irq_live_snapshot,%ax
 movw %ax,o_bad_detach_irq_live
 movb binding_resource_plus1,%al
 movb %al,o_bad_detach_post_bind
 movb resource_identity,%al
 movb %al,o_bad_detach_post_rid
 movw resource_live_count,%ax
 movw %ax,o_bad_detach_post_live

 # D: good final detach, IRQ only after six-instruction coupled region.
 call mask_irqs
 call reset_live
 call program_pit
good_detach_region_begin:
 movb $0,binding_resource_plus1
 decw resource_live_count
 cmpw $0,resource_live_count
 jne good_detach_nonzero
 movb $0,resource_identity
 movb $0,resource_value
good_detach_region_end:
 jmp good_detach_after_region
good_detach_nonzero:
 jmp fail
good_detach_after_region:
 call unmask_irq0
 sti
good_detach_wait:
 hlt
 cmpb $0,irq_seen
 je good_detach_wait
 cli
 movb irq_bind_snapshot,%al
 movb %al,o_good_detach_irq_bind
 movb irq_rid_snapshot,%al
 movb %al,o_good_detach_irq_rid
 movw irq_live_snapshot,%ax
 movw %ax,o_good_detach_irq_live

 call print_matrix
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

fail:
 movw $lab_fail,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
2: hlt
 jmp 2b

reset_empty:
 movb $0,binding_resource_plus1
 movb $0,binding_generation
 movb $0,resource_identity
 movb $0,resource_generation
 movb $0,resource_value
 movw $0,resource_live_count
 call reset_irq_snapshot
 ret

reset_live:
 movb $1,binding_resource_plus1
 movb $1,binding_generation
 movb $0x51,resource_identity
 movb $1,resource_generation
 movb $0x7e,resource_value
 movw $1,resource_live_count
 call reset_irq_snapshot
 ret

reset_irq_snapshot:
 movb $0,irq_seen
 movb $0,irq_bind_snapshot
 movb $0,irq_rid_snapshot
 movw $0,irq_live_snapshot
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
 movw $PIT_DIVISOR,%ax
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
 movb binding_resource_plus1,%al
 movb %al,irq_bind_snapshot
 movb resource_identity,%al
 movb %al,irq_rid_snapshot
 movw resource_live_count,%ax
 movw %ax,irq_live_snapshot
 movb $1,irq_seen
 movw $PIC_MASTER_CMD,%dx
 movb $0x20,%al
 outb %al,%dx
 popw %dx
 popw %ax
 iret

print_matrix:
 movw $lab_bad_bind_irq_bind,%si
 movb o_bad_bind_irq_bind,%al
 call print_line_hex8
 movw $lab_bad_bind_irq_rid,%si
 movb o_bad_bind_irq_rid,%al
 call print_line_hex8
 movw $lab_bad_bind_irq_live,%si
 movw o_bad_bind_irq_live,%ax
 call print_line_hex16
 movw $lab_bad_bind_post_bind,%si
 movb o_bad_bind_post_bind,%al
 call print_line_hex8
 movw $lab_bad_bind_post_rid,%si
 movb o_bad_bind_post_rid,%al
 call print_line_hex8
 movw $lab_bad_bind_post_live,%si
 movw o_bad_bind_post_live,%ax
 call print_line_hex16
 movw $lab_good_bind_irq_bind,%si
 movb o_good_bind_irq_bind,%al
 call print_line_hex8
 movw $lab_good_bind_irq_rid,%si
 movb o_good_bind_irq_rid,%al
 call print_line_hex8
 movw $lab_good_bind_irq_live,%si
 movw o_good_bind_irq_live,%ax
 call print_line_hex16
 movw $lab_bad_detach_irq_bind,%si
 movb o_bad_detach_irq_bind,%al
 call print_line_hex8
 movw $lab_bad_detach_irq_rid,%si
 movb o_bad_detach_irq_rid,%al
 call print_line_hex8
 movw $lab_bad_detach_irq_live,%si
 movw o_bad_detach_irq_live,%ax
 call print_line_hex16
 movw $lab_bad_detach_post_bind,%si
 movb o_bad_detach_post_bind,%al
 call print_line_hex8
 movw $lab_bad_detach_post_rid,%si
 movb o_bad_detach_post_rid,%al
 call print_line_hex8
 movw $lab_bad_detach_post_live,%si
 movw o_bad_detach_post_live,%ax
 call print_line_hex16
 movw $lab_good_detach_irq_bind,%si
 movb o_good_detach_irq_bind,%al
 call print_line_hex8
 movw $lab_good_detach_irq_rid,%si
 movb o_good_detach_irq_rid,%al
 call print_line_hex8
 movw $lab_good_detach_irq_live,%si
 movw o_good_detach_irq_live,%ax
 call print_line_hex16
 movw $lab_done,%si
 jmp print_string

print_line_hex8:
 pushw %ax
 call print_string
 popw %ax
 call print_hex8
 movb $'\n',%al
 jmp print_char

print_line_hex16:
 pushw %ax
 call print_string
 popw %ax
 call print_hex16
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

print_hex8:
 pushw %ax
 movb %al,%ah
 shrb $4,%al
 call hex_nibble
 movb %ah,%al
 andb $0x0f,%al
 call hex_nibble
 popw %ax
 ret

print_hex16:
 pushw %ax
 movb %ah,%al
 call print_hex8
 popw %ax
 call print_hex8
 ret

hex_nibble:
 cmpb $10,%al
 jb hex_digit
 addb $('A'-10),%al
 jmp print_char
hex_digit:
 addb $'0',%al
 jmp print_char

.section .data
runtime_state_start:
act_identity:.space ACTIVITY_CAP,0
act_gen:.space ACTIVITY_CAP,0
act_progress:.space ACTIVITY_CAP,0
act_cont:.space ACTIVITY_CAP,0
act_waiting:.space ACTIVITY_CAP,0
act_woken:.space ACTIVITY_CAP,0
act_parent_slot:.space ACTIVITY_CAP,0
act_parent_gen:.space ACTIVITY_CAP,0
act_wait_slot:.space ACTIVITY_CAP,0
act_wait_gen:.space ACTIVITY_CAP,0
act_epoch:.space ACTIVITY_CAP,0
activity_epoch:.byte 1
binding_resource_plus1:.space BINDING_CELL_COUNT,0
binding_generation:.space BINDING_CELL_COUNT,0
resource_identity:.space RESOURCE_CAP,0
resource_generation:.space RESOURCE_CAP,0
resource_value:.space RESOURCE_CAP,0
resource_live_count:.space RESOURCE_CAP*2,0
resource_epoch:.byte 1
irq_seen:.byte 0
irq_bind_snapshot:.byte 0
irq_rid_snapshot:.byte 0
irq_live_snapshot:.word 0
o_bad_bind_irq_bind:.byte 0
o_bad_bind_irq_rid:.byte 0
o_bad_bind_irq_live:.word 0
o_bad_bind_post_bind:.byte 0
o_bad_bind_post_rid:.byte 0
o_bad_bind_post_live:.word 0
o_good_bind_irq_bind:.byte 0
o_good_bind_irq_rid:.byte 0
o_good_bind_irq_live:.word 0
o_bad_detach_irq_bind:.byte 0
o_bad_detach_irq_rid:.byte 0
o_bad_detach_irq_live:.word 0
o_bad_detach_post_bind:.byte 0
o_bad_detach_post_rid:.byte 0
o_bad_detach_post_live:.word 0
o_good_detach_irq_bind:.byte 0
o_good_detach_irq_rid:.byte 0
o_good_detach_irq_live:.word 0
runtime_state_end:
lab_bad_bind_irq_bind:.asciz "BAD_BIND_IRQ_BIND="
lab_bad_bind_irq_rid:.asciz "BAD_BIND_IRQ_RID="
lab_bad_bind_irq_live:.asciz "BAD_BIND_IRQ_LIVE="
lab_bad_bind_post_bind:.asciz "BAD_BIND_POST_BIND="
lab_bad_bind_post_rid:.asciz "BAD_BIND_POST_RID="
lab_bad_bind_post_live:.asciz "BAD_BIND_POST_LIVE="
lab_good_bind_irq_bind:.asciz "GOOD_BIND_IRQ_BIND="
lab_good_bind_irq_rid:.asciz "GOOD_BIND_IRQ_RID="
lab_good_bind_irq_live:.asciz "GOOD_BIND_IRQ_LIVE="
lab_bad_detach_irq_bind:.asciz "BAD_DETACH_IRQ_BIND="
lab_bad_detach_irq_rid:.asciz "BAD_DETACH_IRQ_RID="
lab_bad_detach_irq_live:.asciz "BAD_DETACH_IRQ_LIVE="
lab_bad_detach_post_bind:.asciz "BAD_DETACH_POST_BIND="
lab_bad_detach_post_rid:.asciz "BAD_DETACH_POST_RID="
lab_bad_detach_post_live:.asciz "BAD_DETACH_POST_LIVE="
lab_good_detach_irq_bind:.asciz "GOOD_DETACH_IRQ_BIND="
lab_good_detach_irq_rid:.asciz "GOOD_DETACH_IRQ_RID="
lab_good_detach_irq_live:.asciz "GOOD_DETACH_IRQ_LIVE="
lab_done:.asciz "DONE\n"
lab_fail:.asciz "FAIL\n"
