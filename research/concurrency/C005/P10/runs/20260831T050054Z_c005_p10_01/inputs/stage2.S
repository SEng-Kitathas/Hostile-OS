.code16
.section .text
.global _start
.equ DEBUG_PORT,0xe9
.equ EXIT_PORT,0xf4
.equ PIC_CMD,0x20
.equ PIC_MASK,0x21
.equ PIC_SLAVE_MASK,0xa1
.equ PIT_CH0,0x40
.equ PIT_CMD,0x43
.equ LAPIC_LO,0xfee00300
.equ LAPIC_HI,0xfee00310
.equ AP_TRAMP,0x9000
.equ AP_READY,0x6000
.equ PHASE,0x6001
.equ PAIR_A,0x6002
.equ PAIR_B,0x6003
.equ XLOCK,0x6004
.equ IRQ_COUNT,0x6005
.equ BAD_A_DONE,0x6006
.equ BAD_FINISH,0x6007
.equ BAD_AP_DONE,0x6008
.equ BAD_MIXED,0x6009
.equ GOOD_A_DONE,0x600a
.equ GOOD_IRQ_ARMED,0x600b
.equ GOOD_HOLDING,0x600c
.equ GOOD_AP_DONE,0x600d
.equ GOOD_SAW_HOLDING,0x600e
.equ GOOD_MIXED,0x600f
.equ GOOD_FINAL,0x6010
.equ AP_DONE,0x6011
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $18,%cx; xorw %ax,%ax; rep stosb
 movw $irq0_handler,0x0020; movw $0,0x0022
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 call mask_irqs
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $0,IRQ_COUNT; movb $0,BAD_MIXED; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,BAD_A_DONE; je arm_bad; decl %ecx; jnz 2b; jmp fail
arm_bad:
 call program_pit; call unmask_irq0; sti
 movl $0x04000000,%ecx
3: cmpb $1,IRQ_COUNT; jae bad_irq_done; decl %ecx; jnz 3b; jmp fail
bad_irq_done:
 cli; call mask_irqs
 movb $1,BAD_FINISH
 movl $0x04000000,%ecx
4: cmpb $1,BAD_AP_DONE; je badreport; decl %ecx; jnz 4b; jmp fail
badreport:
 movw $lab_badirq,%si; call puts; movb IRQ_COUNT,%al; call hex8; call nl
 movw $lab_badmixed,%si; call puts; movb BAD_MIXED,%al; call bit; call nl
 movb $0,%bl; cmpb $0x33,PAIR_A; jne 5f; cmpb $0x44,PAIR_B; jne 5f; movb $1,%bl
5: movw $lab_badfinal,%si; call puts; movb %bl,%al; call bit; call nl
 # Good phase reset.
 movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $0,XLOCK; movb $0,IRQ_COUNT; movb $0,GOOD_SAW_HOLDING; movb $0,GOOD_MIXED; movb $0,GOOD_FINAL; movb $2,PHASE
 movl $0x04000000,%ecx
6: cmpb $1,GOOD_A_DONE; je arm_good; decl %ecx; jnz 6b; jmp fail
arm_good:
 call program_pit; call unmask_irq0; movb $1,GOOD_IRQ_ARMED; sti
 movl $0x04000000,%ecx
7: cmpb $1,IRQ_COUNT; jae good_irq_done; decl %ecx; jnz 7b; jmp fail
good_irq_done:
 cli; call mask_irqs
 movl $0x04000000,%ecx
8: cmpb $1,GOOD_AP_DONE; je goodreport; decl %ecx; jnz 8b; jmp fail
goodreport:
 movw $lab_goodirq,%si; call puts; movb IRQ_COUNT,%al; call hex8; call nl
 movw $lab_sawholding,%si; call puts; movb GOOD_SAW_HOLDING,%al; call bit; call nl
 movw $lab_goodmixed,%si; call puts; movb GOOD_MIXED,%al; call bit; call nl
 movw $lab_goodfinal,%si; call puts; movb GOOD_FINAL,%al; call bit; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
9: cmpb $1,AP_DONE; je done; decl %ecx; jnz 9b; jmp fail
done:
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
10: hlt; jmp 10b
fail: cli; call mask_irqs; movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
11: hlt; jmp 11b
mask_irqs:
 cli; movw $PIC_MASK,%dx; movb $0xff,%al; outb %al,%dx; movw $PIC_SLAVE_MASK,%dx; outb %al,%dx; ret
unmask_irq0:
 movw $PIC_MASK,%dx; movb $0xfe,%al; outb %al,%dx; movw $PIC_SLAVE_MASK,%dx; movb $0xff,%al; outb %al,%dx; ret
program_pit:
 movw $PIT_CMD,%dx; movb $0x30,%al; outb %al,%dx; movw $0x0100,%ax; movw $PIT_CH0,%dx; outb %al,%dx; movb %ah,%al; outb %al,%dx; ret
irq0_handler:
 pushw %ax; pushw %bx; pushw %dx
 incb IRQ_COUNT
 cmpb $1,PHASE; je irq_bad
 cmpb $2,PHASE; je irq_good
 jmp irq_eoi
irq_bad:
 cmpb $0x33,PAIR_A; jne irq_eoi
 cmpb $0x22,PAIR_B; jne irq_eoi
 movb $1,BAD_MIXED
 jmp irq_eoi
irq_good:
 cmpb $1,GOOD_HOLDING; jne irq_good_lock
 movb $1,GOOD_SAW_HOLDING
irq_good_lock:
 movb $1,%al
12: xchgb %al,XLOCK; testb %al,%al; jz 13f; pause; movb $1,%al; jmp 12b
13:
 cmpb $0x33,PAIR_A; jne 14f
 cmpb $0x22,PAIR_B; jne 14f
 movb $1,GOOD_MIXED
14:
 cmpb $0x33,PAIR_A; jne 15f
 cmpb $0x44,PAIR_B; jne 15f
 movb $1,GOOD_FINAL
15: movb $0,XLOCK
irq_eoi:
 movw $PIC_MASK,%dx; movb $0xff,%al; outb %al,%dx
 movw $PIC_CMD,%dx; movb $0x20,%al; outb %al,%dx
 popw %dx; popw %bx; popw %ax; iret
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
16: pause; decl %ecx; jnz 16b; ret
dl: movl $0x400000,%ecx
17: pause; decl %ecx; jnz 17b; ret
puts: lodsb; testb %al,%al; jz 18f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
18: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 19f; addb $('A'-10),%al; jmp putc
19: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
20: cmpb $1,PHASE; jne 20b
 movb $0x33,PAIR_A; movb $1,BAD_A_DONE
21: cmpb $1,BAD_FINISH; jne 21b
 movb $0x44,PAIR_B; movb $1,BAD_AP_DONE
22: cmpb $2,PHASE; jne 22b
 # Good: hold shared exclusion across whole coupled mutation.
23: movb $1,%al; xchgb %al,XLOCK; testb %al,%al; jz 24f; pause; movb $1,%al; jmp 23b
24: movb $1,GOOD_HOLDING; movb $0x33,PAIR_A; movb $1,GOOD_A_DONE
25: cmpb $1,GOOD_IRQ_ARMED; jne 25b
 movl $0x00800000,%ecx
26: pause; decl %ecx; jnz 26b
 movb $0x44,PAIR_B; movb $0,GOOD_HOLDING; movb $0,XLOCK; movb $1,GOOD_AP_DONE
27: cmpb $3,PHASE; jne 27b
 movb $1,AP_DONE
28: hlt; jmp 28b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P10\n"
lab_ready:.asciz "AP_READY="
lab_badirq:.asciz "BAD_IRQ="
lab_badmixed:.asciz "BAD_MIXED="
lab_badfinal:.asciz "BAD_FINAL="
lab_goodirq:.asciz "GOOD_IRQ="
lab_sawholding:.asciz "GOOD_IRQ_SAW_HOLDING="
lab_goodmixed:.asciz "GOOD_MIXED="
lab_goodfinal:.asciz "GOOD_FINAL="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P10_FAIL\n"
lab_done:.asciz "DONE\n"
