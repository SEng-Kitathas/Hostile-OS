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
.equ BAD_RETRIES,0x6005
.equ BAD_FORCE,0x6006
.equ BAD_ACCEPT,0x6007
.equ BAD_MIXED,0x6008
.equ BAD_DONE,0x6009
.equ GOOD_RETRIES,0x600a
.equ GOOD_FORCE,0x600b
.equ GOOD_ACCEPT_BEFORE,0x600c
.equ GOOD_ACCEPT_AFTER,0x600d
.equ GOOD_A,0x600e
.equ GOOD_B,0x600f
.equ GOOD_RETRY_DONE,0x6010
.equ WRITER_COMPLETE,0x6011
.equ AP_DONE,0x6012
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $19,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 # BSP writer stalls odd after A update.
 movb $0,VERSION; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $1,VERSION; movb $0x33,PAIR_A; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,BAD_DONE; je badreport; decl %ecx; jnz 2b; jmp fail
badreport:
 movw $lab_badretries,%si; call puts; movb BAD_RETRIES,%al; call hex8; call nl
 movw $lab_badforce,%si; call puts; movb BAD_FORCE,%al; call bit; call nl
 movw $lab_badaccept,%si; call puts; movb BAD_ACCEPT,%al; call bit; call nl
 movw $lab_badmixed,%si; call puts; movb BAD_MIXED,%al; call bit; call nl
 # Good reset; same stall, but reader never mutates writer state.
 movb $0,VERSION; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $0,WRITER_COMPLETE; movb $2,PHASE; movb $1,VERSION; movb $0x33,PAIR_A
 movl $0x04000000,%ecx
3: cmpb $1,GOOD_RETRY_DONE; je goodpre; decl %ecx; jnz 3b; jmp fail
goodpre:
 movw $lab_goodretries,%si; call puts; movb GOOD_RETRIES,%al; call hex8; call nl
 movw $lab_goodforce,%si; call puts; movb GOOD_FORCE,%al; call bit; call nl
 movw $lab_goodbefore,%si; call puts; movb GOOD_ACCEPT_BEFORE,%al; call bit; call nl
 # Only the writer completes its own state transition.
 movb $0x44,PAIR_B; movb $2,VERSION; movb $1,WRITER_COMPLETE
 movl $0x04000000,%ecx
4: cmpb $1,GOOD_ACCEPT_AFTER; je goodreport; decl %ecx; jnz 4b; jmp fail
goodreport:
 movw $lab_goodafter,%si; call puts; movb GOOD_ACCEPT_AFTER,%al; call bit; call nl
 movw $lab_gooda,%si; call puts; movb GOOD_A,%al; call hex8; call nl
 movw $lab_goodb,%si; call puts; movb GOOD_B,%al; call hex8; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
5: cmpb $1,AP_DONE; je done; decl %ecx; jnz 5b; jmp fail
done: movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl; movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
6: hlt; jmp 6b
fail: movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
7: hlt; jmp 7b
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
8: pause; decl %ecx; jnz 8b; ret
dl: movl $0x400000,%ecx
9: pause; decl %ecx; jnz 9b; ret
puts: lodsb; testb %al,%al; jz 10f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
10: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 11f; addb $('A'-10),%al; jmp putc
11: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
12: cmpb $1,PHASE; jne 12b
 movb $0,BAD_RETRIES; movb $64,%cl
bad_retry_loop:
 movb VERSION,%al; testb $1,%al; jz bad_try_accept
 incb BAD_RETRIES; loop bad_retry_loop
 # BAD: retry budget is incorrectly treated as repair authority.
 movb $2,VERSION; movb $1,BAD_FORCE
bad_try_accept:
 movb VERSION,%bl; testb $1,%bl; jnz bad_retry_loop
 movb PAIR_A,%al; movb PAIR_B,%dl; movb VERSION,%ah
 cmpb %bl,%ah; jne bad_retry_loop
 testb $1,%ah; jnz bad_retry_loop
 movb $1,BAD_ACCEPT
 cmpb $0x33,%al; jne bad_finish
 cmpb $0x22,%dl; jne bad_finish
 movb $1,BAD_MIXED
bad_finish: movb $1,BAD_DONE
13: cmpb $2,PHASE; jne 13b
 movb $0,GOOD_RETRIES; movb $0,GOOD_FORCE; movb $0,GOOD_ACCEPT_BEFORE; movb $64,%cl
good_retry_loop:
 movb VERSION,%al; testb $1,%al; jz good_unexpected_even
 incb GOOD_RETRIES; loop good_retry_loop
 movb $1,GOOD_RETRY_DONE
 jmp good_wait_complete
good_unexpected_even:
 # would only happen if someone else mutated writer state; record an early accept if stable.
 movb VERSION,%bl; movb PAIR_A,%al; movb PAIR_B,%dl; movb VERSION,%ah; cmpb %bl,%ah; jne good_retry_loop; testb $1,%ah; jnz good_retry_loop; movb $1,GOOD_ACCEPT_BEFORE; movb $1,GOOD_RETRY_DONE
good_wait_complete:
14: cmpb $1,WRITER_COMPLETE; jne 14b
good_after_loop:
 movb VERSION,%bl; testb $1,%bl; jnz good_after_loop
 movb PAIR_A,%al; movb PAIR_B,%dl; movb VERSION,%ah; cmpb %bl,%ah; jne good_after_loop; testb $1,%ah; jnz good_after_loop
 movb %al,GOOD_A; movb %dl,GOOD_B; movb $1,GOOD_ACCEPT_AFTER
15: cmpb $3,PHASE; jne 15b
 movb $1,AP_DONE
16: hlt; jmp 16b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P14\n"
lab_ready:.asciz "AP_READY="
lab_badretries:.asciz "BAD_RETRIES="
lab_badforce:.asciz "BAD_FORCE="
lab_badaccept:.asciz "BAD_ACCEPT="
lab_badmixed:.asciz "BAD_MIXED="
lab_goodretries:.asciz "GOOD_RETRIES="
lab_goodforce:.asciz "GOOD_FORCE="
lab_goodbefore:.asciz "GOOD_ACCEPT_BEFORE="
lab_goodafter:.asciz "GOOD_ACCEPT_AFTER="
lab_gooda:.asciz "GOOD_A="
lab_goodb:.asciz "GOOD_B="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P14_FAIL\n"
lab_done:.asciz "DONE\n"
