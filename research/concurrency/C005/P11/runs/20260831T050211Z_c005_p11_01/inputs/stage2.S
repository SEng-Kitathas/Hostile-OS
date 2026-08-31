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
.equ WRITER_A_DONE,0x6005
.equ BAD_AP_A_DONE,0x6006
.equ BAD_READ_B_GO,0x6007
.equ BAD_AP_DONE,0x6008
.equ BAD_A_SEEN,0x6009
.equ BAD_B_SEEN,0x600a
.equ GOOD_AP_ATTEMPT,0x600b
.equ GOOD_RETRY,0x600c
.equ GOOD_ACCEPT,0x600d
.equ GOOD_A_SEEN,0x600e
.equ GOOD_B_SEEN,0x600f
.equ GOOD_VER_SEEN,0x6010
.equ AP_DONE,0x6011
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $18,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0,VERSION; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $1,PHASE
 # writer begin and A update
 movb $1,VERSION; movb $0x33,PAIR_A; movb $1,WRITER_A_DONE
 movl $0x04000000,%ecx
2: cmpb $1,BAD_AP_A_DONE; je badfinish; decl %ecx; jnz 2b; jmp fail
badfinish:
 movb $0x44,PAIR_B; movb $2,VERSION; movb $1,BAD_READ_B_GO
 movl $0x04000000,%ecx
3: cmpb $1,BAD_AP_DONE; je badreport; decl %ecx; jnz 3b; jmp fail
badreport:
 movw $lab_badcross,%si; call puts; movb $1,%al; call bit; call nl
 movw $lab_bada,%si; call puts; movb BAD_A_SEEN,%al; call hex8; call nl
 movw $lab_badb,%si; call puts; movb BAD_B_SEEN,%al; call hex8; call nl
 # Good reset. AP must attempt during odd version and retry.
 movb $0,VERSION; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $0,WRITER_A_DONE; movb $2,PHASE
 movb $1,VERSION; movb $0x33,PAIR_A; movb $1,WRITER_A_DONE
 movl $0x04000000,%ecx
4: cmpb $1,GOOD_AP_ATTEMPT; je goodfinish; decl %ecx; jnz 4b; jmp fail
goodfinish:
 movb $0x44,PAIR_B; movb $2,VERSION
 movl $0x04000000,%ecx
5: cmpb $1,GOOD_ACCEPT; je goodreport; decl %ecx; jnz 5b; jmp fail
goodreport:
 movw $lab_retry,%si; call puts; movb GOOD_RETRY,%al; call bit; call nl
 movw $lab_accept,%si; call puts; movb GOOD_ACCEPT,%al; call bit; call nl
 movw $lab_gooda,%si; call puts; movb GOOD_A_SEEN,%al; call hex8; call nl
 movw $lab_goodb,%si; call puts; movb GOOD_B_SEEN,%al; call hex8; call nl
 movw $lab_goodver,%si; call puts; movb GOOD_VER_SEEN,%al; call hex8; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
6: cmpb $1,AP_DONE; je done; decl %ecx; jnz 6b; jmp fail
done:
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
7: hlt; jmp 7b
fail: movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
8: hlt; jmp 8b
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
9: pause; decl %ecx; jnz 9b; ret
dl: movl $0x400000,%ecx
10: pause; decl %ecx; jnz 10b; ret
puts: lodsb; testb %al,%al; jz 11f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
11: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 12f; addb $('A'-10),%al; jmp putc
12: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
13: cmpb $1,PHASE; jne 13b
14: cmpb $1,WRITER_A_DONE; jne 14b
 movb PAIR_A,%al; movb %al,BAD_A_SEEN; movb $1,BAD_AP_A_DONE
15: cmpb $1,BAD_READ_B_GO; jne 15b
 movb PAIR_B,%al; movb %al,BAD_B_SEEN; movb $1,BAD_AP_DONE
16: cmpb $2,PHASE; jne 16b
 # Good version validated retry loop. First attempt intentionally occurs while odd.
good_try:
 movb VERSION,%bl; movb $1,GOOD_AP_ATTEMPT
 testb $1,%bl; jnz good_retry
 movb PAIR_A,%cl; movb PAIR_B,%dl; movb VERSION,%al
 cmpb %bl,%al; jne good_retry
 testb $1,%al; jnz good_retry
 movb %cl,GOOD_A_SEEN; movb %dl,GOOD_B_SEEN; movb %al,GOOD_VER_SEEN; movb $1,GOOD_ACCEPT
 jmp good_wait_end
good_retry:
 movb $1,GOOD_RETRY
 pause
 jmp good_try
good_wait_end:
17: cmpb $3,PHASE; jne 17b
 movb $1,AP_DONE
18: hlt; jmp 18b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P11\n"
lab_ready:.asciz "AP_READY="
lab_badcross:.asciz "BAD_CROSSED="
lab_bada:.asciz "BAD_A="
lab_badb:.asciz "BAD_B="
lab_retry:.asciz "GOOD_RETRY="
lab_accept:.asciz "GOOD_ACCEPT="
lab_gooda:.asciz "GOOD_A="
lab_goodb:.asciz "GOOD_B="
lab_goodver:.asciz "GOOD_VERSION="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P11_FAIL\n"
lab_done:.asciz "DONE\n"
