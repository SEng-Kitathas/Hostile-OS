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
.equ USERS,0x6002
.equ GEN,0x6003
.equ VALUE,0x6004
.equ BAD_WRAP,0x6005
.equ BAD_AP_ACTIVE,0x6006
.equ BAD_RECLAIM,0x6007
.equ BAD_READ_GO,0x6008
.equ BAD_USE_VAL,0x6009
.equ BAD_DONE,0x600a
.equ GOOD_ACQUIRE,0x600b
.equ GOOD_AP_DONE,0x600c
.equ AP_DONE,0x600d
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $14,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0xff,USERS; movb $1,GEN; movb $0x7e,VALUE; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,BAD_AP_ACTIVE; je badreclaim; decl %ecx; jnz 2b; jmp fail
badreclaim:
 movw $lab_badwrap,%si; call puts; movb BAD_WRAP,%al; call bit; call nl
 movb $0,BAD_RECLAIM
 cmpb $0,USERS; jne bad_no_reclaim
 movb $2,GEN; movb $0,VALUE; movb $1,BAD_RECLAIM
bad_no_reclaim:
 movw $lab_badreclaim,%si; call puts; movb BAD_RECLAIM,%al; call bit; call nl
 movb $1,BAD_READ_GO
 movl $0x04000000,%ecx
3: cmpb $1,BAD_DONE; je badreport; decl %ecx; jnz 3b; jmp fail
badreport:
 movw $lab_badval,%si; call puts; movb BAD_USE_VAL,%al; call hex8; call nl
 # Good reset.
 movb $0xff,USERS; movb $1,GEN; movb $0x7e,VALUE; movb $0,GOOD_ACQUIRE; movb $2,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,GOOD_AP_DONE; je goodreport; decl %ecx; jnz 4b; jmp fail
goodreport:
 movw $lab_goodacq,%si; call puts; movb GOOD_ACQUIRE,%al; call putc; call nl
 movw $lab_goodusers,%si; call puts; movb USERS,%al; call hex8; call nl
 movb $0,%bl; cmpb $0,USERS; jne good_no_reclaim; movb $1,%bl; movb $2,GEN; movb $0,VALUE
good_no_reclaim:
 movw $lab_goodreclaim,%si; call puts; movb %bl,%al; call bit; call nl
 movw $lab_goodvalue,%si; call puts; movb VALUE,%al; call hex8; call nl
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
 movb $1,%al
 lock xaddb %al,USERS
 cmpb $0,USERS; jne bad_not_wrap
 movb $1,BAD_WRAP
bad_not_wrap:
 movb $1,BAD_AP_ACTIVE
13: cmpb $1,BAD_READ_GO; jne 13b
 movb VALUE,%al; movb %al,BAD_USE_VAL; movb $1,BAD_DONE
14: cmpb $2,PHASE; jne 14b
 # Checked finite acquisition: FF is explicit full, do not modify.
 movb $'F',GOOD_ACQUIRE
 cmpb $0xff,USERS; je good_acquire_done
 movb $1,%al; lock xaddb %al,USERS; movb $'W',GOOD_ACQUIRE
good_acquire_done:
 movb $1,GOOD_AP_DONE
15: cmpb $3,PHASE; jne 15b
 movb $1,AP_DONE
16: hlt; jmp 16b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P16\n"
lab_ready:.asciz "AP_READY="
lab_badwrap:.asciz "BAD_WRAP="
lab_badreclaim:.asciz "BAD_RECLAIM="
lab_badval:.asciz "BAD_USE_VAL="
lab_goodacq:.asciz "GOOD_ACQUIRE="
lab_goodusers:.asciz "GOOD_USERS="
lab_goodreclaim:.asciz "GOOD_RECLAIM="
lab_goodvalue:.asciz "GOOD_VALUE="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P16_FAIL\n"
lab_done:.asciz "DONE\n"
