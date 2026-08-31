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
.equ EPOCH,0x6003
.equ PAIR_A,0x6004
.equ PAIR_B,0x6005
.equ BAD_PRE,0x6006
.equ BAD_A_OLD,0x6007
.equ BAD_SNAP_DONE,0x6008
.equ BAD_WRITER_DONE,0x6009
.equ BAD_ACCEPT,0x600a
.equ BAD_CROSS,0x600b
.equ GOOD_PRE_VER,0x600c
.equ GOOD_PRE_EPOCH,0x600d
.equ GOOD_A_OLD,0x600e
.equ GOOD_SNAP_DONE,0x600f
.equ GOOD_WRITER_DONE,0x6010
.equ GOOD_STALE,0x6011
.equ GOOD_FRESH,0x6012
.equ GOOD_A_SEEN,0x6013
.equ GOOD_B_SEEN,0x6014
.equ AP_DONE,0x6015
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $22,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0,VERSION; movb $0,EPOCH; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,BAD_SNAP_DONE; je badwrites; decl %ecx; jnz 2b; jmp fail
badwrites:
 movw $128,%cx
bad_loop:
 incb VERSION
 movb $0x33,PAIR_A; movb $0x44,PAIR_B
 incb VERSION
 loop bad_loop
 movb $1,BAD_WRITER_DONE
 movl $0x04000000,%ecx
3: cmpb $1,BAD_ACCEPT; je badreport; decl %ecx; jnz 3b; jmp fail
badreport:
 movw $lab_badver,%si; call puts; movb VERSION,%al; call hex8; call nl
 movw $lab_badaccept,%si; call puts; movb BAD_ACCEPT,%al; call bit; call nl
 movw $lab_badcross,%si; call puts; movb BAD_CROSS,%al; call bit; call nl
 # Good reset.
 movb $0,VERSION; movb $0,EPOCH; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $0,GOOD_STALE; movb $0,GOOD_FRESH; movb $2,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,GOOD_SNAP_DONE; je goodwrites; decl %ecx; jnz 4b; jmp fail
goodwrites:
 movw $128,%cx
good_loop:
 incb VERSION
 movb $0x33,PAIR_A; movb $0x44,PAIR_B
 incb VERSION
 cmpb $0,VERSION
 jne good_no_wrap
 incb EPOCH
good_no_wrap:
 loop good_loop
 movb $1,GOOD_WRITER_DONE
 movl $0x04000000,%ecx
5: cmpb $1,GOOD_FRESH; je goodreport; decl %ecx; jnz 5b; jmp fail
goodreport:
 movw $lab_goodpacked,%si; call puts; movb EPOCH,%al; call hex8; movb VERSION,%al; call hex8; call nl
 movw $lab_goodstale,%si; call puts; movb GOOD_STALE,%al; call bit; call nl
 movw $lab_goodfresh,%si; call puts; movb GOOD_FRESH,%al; call bit; call nl
 movw $lab_gooda,%si; call puts; movb GOOD_A_SEEN,%al; call hex8; call nl
 movw $lab_goodb,%si; call puts; movb GOOD_B_SEEN,%al; call hex8; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
6: cmpb $1,AP_DONE; je done; decl %ecx; jnz 6b; jmp fail
done: movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl; movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
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
 movb VERSION,%al; movb %al,BAD_PRE; movb PAIR_A,%al; movb %al,BAD_A_OLD; movb $1,BAD_SNAP_DONE
14: cmpb $1,BAD_WRITER_DONE; jne 14b
 movb $0,BAD_ACCEPT; movb $0,BAD_CROSS
 movb VERSION,%bl; cmpb BAD_PRE,%bl; jne bad_ap_done; testb $1,%bl; jnz bad_ap_done
 movb PAIR_B,%dl; movb $1,BAD_ACCEPT
 cmpb $0x11,BAD_A_OLD; jne bad_ap_done; cmpb $0x44,%dl; jne bad_ap_done; movb $1,BAD_CROSS
bad_ap_done:
15: cmpb $2,PHASE; jne 15b
 movb VERSION,%al; movb %al,GOOD_PRE_VER; movb EPOCH,%al; movb %al,GOOD_PRE_EPOCH; movb PAIR_A,%al; movb %al,GOOD_A_OLD; movb $1,GOOD_SNAP_DONE
16: cmpb $1,GOOD_WRITER_DONE; jne 16b
 # stale packed check
 movb $0,GOOD_STALE
 movb EPOCH,%al; cmpb GOOD_PRE_EPOCH,%al; jne good_fresh_try
 movb VERSION,%al; cmpb GOOD_PRE_VER,%al; jne good_fresh_try
 testb $1,%al; jnz good_fresh_try
 movb $1,GOOD_STALE
good_fresh_try:
 # fresh stable snapshot
 movb EPOCH,%bh; movb VERSION,%bl; testb $1,%bl; jnz good_fresh_try
 movb PAIR_A,%cl; movb PAIR_B,%dl; movb EPOCH,%ah; movb VERSION,%al
 cmpb %bh,%ah; jne good_fresh_try; cmpb %bl,%al; jne good_fresh_try; testb $1,%al; jnz good_fresh_try
 movb %cl,GOOD_A_SEEN; movb %dl,GOOD_B_SEEN; movb $1,GOOD_FRESH
17: cmpb $3,PHASE; jne 17b
 movb $1,AP_DONE
18: hlt; jmp 18b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P17\n"
lab_ready:.asciz "AP_READY="
lab_badver:.asciz "BAD_VERSION="
lab_badaccept:.asciz "BAD_ACCEPT="
lab_badcross:.asciz "BAD_CROSS_ERA="
lab_goodpacked:.asciz "GOOD_PACKED="
lab_goodstale:.asciz "GOOD_STALE_ACCEPT="
lab_goodfresh:.asciz "GOOD_FRESH_ACCEPT="
lab_gooda:.asciz "GOOD_A="
lab_goodb:.asciz "GOOD_B="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P17_FAIL\n"
lab_done:.asciz "DONE\n"
