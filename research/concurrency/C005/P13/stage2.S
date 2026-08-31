.code16
.section .text
.global _start
.equ DEBUG_PORT,0xe9
.equ EXIT_PORT,0xf4
.equ LAPIC_LO,0xfee00300
.equ LAPIC_HI,0xfee00310
.equ AP_TRAMP,0x9000
.equ AP_READY,0x6000
.equ PHASE,0x6001
.equ VERSION,0x6002
.equ PAIR_A,0x6003
.equ PAIR_B,0x6004
.equ AP_TRIES_DONE,0x6005
.equ STALLED_ACCEPT,0x6006
.equ RETRIES,0x6007
.equ WRITER_COMPLETE,0x6008
.equ AFTER_ACCEPT,0x6009
.equ AFTER_A,0x600a
.equ AFTER_B,0x600b
.equ AP_DONE,0x600c
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $13,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je begin; decl %ecx; jnz 1b; jmp fail
begin:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0,VERSION; movb $0x11,PAIR_A; movb $0x22,PAIR_B
 movb $1,VERSION; movb $0x33,PAIR_A; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,AP_TRIES_DONE; je stalled_report; decl %ecx; jnz 2b; jmp fail
stalled_report:
 movw $lab_stalled_accept,%si; call puts; movb STALLED_ACCEPT,%al; call bit; call nl
 movw $lab_retries,%si; call puts; movb RETRIES,%al; call hex8; call nl
 movb $0x44,PAIR_B; movb $2,VERSION; movb $1,WRITER_COMPLETE
 movl $0x04000000,%ecx
3: cmpb $1,AFTER_ACCEPT; je after_report; decl %ecx; jnz 3b; jmp fail
after_report:
 movw $lab_after_accept,%si; call puts; movb AFTER_ACCEPT,%al; call bit; call nl
 movw $lab_after_a,%si; call puts; movb AFTER_A,%al; call hex8; call nl
 movw $lab_after_b,%si; call puts; movb AFTER_B,%al; call hex8; call nl
 movb $2,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,AP_DONE; je done; decl %ecx; jnz 4b; jmp fail
done: movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl; movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
5: hlt; jmp 5b
fail: movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
6: hlt; jmp 6b
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
7: pause; decl %ecx; jnz 7b; ret
dl: movl $0x400000,%ecx
8: pause; decl %ecx; jnz 8b; ret
puts: lodsb; testb %al,%al; jz 9f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
9: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 10f; addb $('A'-10),%al; jmp putc
10: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
11: cmpb $1,PHASE; jne 11b
 movb $0,STALLED_ACCEPT; movb $0,RETRIES; movb $64,%cl
stalled_loop:
 movb VERSION,%al
 testb $1,%al; jz maybe_accept_stalled
 incb RETRIES
 loop stalled_loop
 jmp stalled_done
maybe_accept_stalled:
 movb PAIR_A,%bl; movb PAIR_B,%dl; movb VERSION,%ah
 cmpb %al,%ah; jne retry_stalled
 testb $1,%ah; jnz retry_stalled
 movb $1,STALLED_ACCEPT; jmp stalled_done
retry_stalled: incb RETRIES; loop stalled_loop
stalled_done: movb $1,AP_TRIES_DONE
12: cmpb $1,WRITER_COMPLETE; jne 12b
after_loop:
 movb VERSION,%al; testb $1,%al; jnz after_loop
 movb PAIR_A,%bl; movb PAIR_B,%dl; movb VERSION,%ah
 cmpb %al,%ah; jne after_loop
 testb $1,%ah; jnz after_loop
 movb %bl,AFTER_A; movb %dl,AFTER_B; movb $1,AFTER_ACCEPT
13: cmpb $2,PHASE; jne 13b
 movb $1,AP_DONE
14: hlt; jmp 14b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P13\n"
lab_ready:.asciz "AP_READY="
lab_stalled_accept:.asciz "STALLED_ACCEPT="
lab_retries:.asciz "STALLED_RETRIES="
lab_after_accept:.asciz "AFTER_COMPLETE_ACCEPT="
lab_after_a:.asciz "AFTER_A="
lab_after_b:.asciz "AFTER_B="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P13_FAIL\n"
lab_done:.asciz "DONE\n"
