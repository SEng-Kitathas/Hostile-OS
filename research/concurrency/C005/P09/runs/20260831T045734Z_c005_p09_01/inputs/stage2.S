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
.equ RIGHTS,0x6002
.equ AUTH_GEN,0x6003
.equ VALUE,0x6004
.equ AP_ACCEPTED,0x6005
.equ AP_ACCEPT_GEN,0x6006
.equ GO_APPLY,0x6007
.equ APPLY_RESULT,0x6008
.equ AP_PHASE_DONE,0x6009
.equ AP_DONE,0x600a
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $11,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $2,RIGHTS; movb $1,AUTH_GEN; movb $0x7e,VALUE; movb $0,AP_ACCEPTED; movb $0,AP_PHASE_DONE; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,AP_ACCEPTED; je badrevoke; decl %ecx; jnz 2b; jmp fail
badrevoke:
 movw $lab_badaccepted,%si; call puts; movb AP_ACCEPTED,%al; call bit; call nl
 movb $0,RIGHTS; movb $2,AUTH_GEN
 movw $lab_badgen,%si; call puts; movb AUTH_GEN,%al; call hex8; call nl
 movb $1,GO_APPLY
 movl $0x04000000,%ecx
3: cmpb $1,AP_PHASE_DONE; je badreport; decl %ecx; jnz 3b; jmp fail
badreport:
 movw $lab_badapply,%si; call puts; movb APPLY_RESULT,%al; call putc; call nl
 movw $lab_badvalue,%si; call puts; movb VALUE,%al; call hex8; call nl
 # Good reset.
 movb $2,RIGHTS; movb $1,AUTH_GEN; movb $0x7e,VALUE; movb $0,AP_ACCEPTED; movb $0,AP_PHASE_DONE; movb $0,GO_APPLY; movb $2,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,AP_ACCEPTED; je goodrevoke; decl %ecx; jnz 4b; jmp fail
goodrevoke:
 movw $lab_goodaccepted,%si; call puts; movb AP_ACCEPTED,%al; call bit; call nl
 movb $0,RIGHTS; movb $2,AUTH_GEN
 movw $lab_goodgen,%si; call puts; movb AUTH_GEN,%al; call hex8; call nl
 movb $1,GO_APPLY
 movl $0x04000000,%ecx
5: cmpb $1,AP_PHASE_DONE; je goodreport; decl %ecx; jnz 5b; jmp fail
goodreport:
 movw $lab_goodapply,%si; call puts; movb APPLY_RESULT,%al; call putc; call nl
 movw $lab_goodvalue,%si; call puts; movb VALUE,%al; call hex8; call nl
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
13: cmpb $1,PHASE; je ap_bad; pause; jmp 13b
ap_bad:
 movb RIGHTS,%al; testb $2,%al; jz ap_bad_no
 movb AUTH_GEN,%al; movb %al,AP_ACCEPT_GEN; movb $1,AP_ACCEPTED
14: cmpb $1,GO_APPLY; jne 14b
 # BAD: cached accepted bit only.
 movb $0x55,VALUE; movb $'W',APPLY_RESULT; movb $1,AP_PHASE_DONE
15: cmpb $2,PHASE; jne 15b
 jmp ap_good
ap_bad_no: movb $0,AP_ACCEPTED; jmp 14b
ap_good:
 movb RIGHTS,%al; testb $2,%al; jz ap_good_no
 movb AUTH_GEN,%al; movb %al,AP_ACCEPT_GEN; movb $1,AP_ACCEPTED
16: cmpb $1,GO_APPLY; jne 16b
 # GOOD: revalidate generation and rights after revoke.
 movb $'U',APPLY_RESULT
 movb AP_ACCEPT_GEN,%al; cmpb AUTH_GEN,%al; jne ap_good_finish
 movb RIGHTS,%al; testb $2,%al; jz ap_good_finish
 movb $0x55,VALUE; movb $'W',APPLY_RESULT
ap_good_finish: movb $1,AP_PHASE_DONE
17: cmpb $3,PHASE; jne 17b
 movb $1,AP_DONE
18: hlt; jmp 18b
ap_good_no: movb $0,AP_ACCEPTED; jmp 16b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P09\n"
lab_ready:.asciz "AP_READY="
lab_badaccepted:.asciz "BAD_ACCEPTED="
lab_badgen:.asciz "BAD_REVOKE_GEN="
lab_badapply:.asciz "BAD_APPLY="
lab_badvalue:.asciz "BAD_VALUE="
lab_goodaccepted:.asciz "GOOD_ACCEPTED="
lab_goodgen:.asciz "GOOD_REVOKE_GEN="
lab_goodapply:.asciz "GOOD_APPLY="
lab_goodvalue:.asciz "GOOD_VALUE="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P09_FAIL\n"
lab_done:.asciz "DONE\n"
