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
.equ BAD_COUNTER,0x6002
.equ BAD_BSP_READ,0x6003
.equ BAD_AP_READ,0x6004
.equ BAD_GO,0x6005
.equ BAD_BSP_DONE,0x6006
.equ BAD_AP_DONE,0x6007
.equ GOOD_COUNTER,0x6008
.equ GOOD_AP_READY,0x6009
.equ GOOD_GO,0x600a
.equ GOOD_BSP_DONE,0x600b
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
 movb $0,BAD_COUNTER; movb $1,PHASE
 movb BAD_COUNTER,%bl
 movb $1,BAD_BSP_READ
 movl $0x04000000,%ecx
2: cmpb $1,BAD_AP_READ; je bothread; decl %ecx; jnz 2b; jmp fail
bothread:
 movb $1,BAD_GO
 incb %bl
 movb %bl,BAD_COUNTER
 movb $1,BAD_BSP_DONE
 movl $0x04000000,%ecx
3: cmpb $1,BAD_AP_DONE; je badreport; decl %ecx; jnz 3b; jmp fail
badreport:
 movw $lab_bspread,%si; call puts; movb BAD_BSP_READ,%al; call bit; call nl
 movw $lab_apread,%si; call puts; movb BAD_AP_READ,%al; call bit; call nl
 movw $lab_badintents,%si; call puts; movb $2,%al; call hex8; call nl
 movw $lab_badfinal,%si; call puts; movb BAD_COUNTER,%al; call hex8; call nl
 # Good atomic update.
 movb $0,GOOD_COUNTER; movb $2,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,GOOD_AP_READY; je goodstart; decl %ecx; jnz 4b; jmp fail
goodstart:
 movb $1,GOOD_GO
 movb $1,%al
 lock xaddb %al,GOOD_COUNTER
 movb $1,GOOD_BSP_DONE
 movl $0x04000000,%ecx
5: cmpb $1,GOOD_AP_DONE; je goodreport; decl %ecx; jnz 5b; jmp fail
goodreport:
 movw $lab_goodintents,%si; call puts; movb $2,%al; call hex8; call nl
 movw $lab_goodfinal,%si; call puts; movb GOOD_COUNTER,%al; call hex8; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
6: cmpb $1,AP_DONE; je done; decl %ecx; jnz 6b; jmp fail
done:
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
7: hlt; jmp 7b
fail:
 movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
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
aploop:
 cmpb $1,PHASE; je apbad
 cmpb $2,PHASE; je apgood
 cmpb $3,PHASE; je apfinish
 pause; jmp aploop
apbad:
 movb BAD_COUNTER,%bl
 movb $1,BAD_AP_READ
13: cmpb $1,BAD_GO; je apbadstore; pause; jmp 13b
apbadstore:
 incb %bl
 movb %bl,BAD_COUNTER
 movb $1,BAD_AP_DONE
14: cmpb $2,PHASE; je apgood; pause; jmp 14b
apgood:
 movb $1,GOOD_AP_READY
15: cmpb $1,GOOD_GO; je apgooddo; pause; jmp 15b
apgooddo:
 movb $1,%al
 lock xaddb %al,GOOD_COUNTER
 movb $1,GOOD_AP_DONE
16: cmpb $3,PHASE; je apfinish; pause; jmp 16b
apfinish:
 movb $1,AP_DONE
17: hlt; jmp 17b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P04\n"
lab_ready:.asciz "AP_READY="
lab_bspread:.asciz "BAD_BSP_READ="
lab_apread:.asciz "BAD_AP_READ="
lab_badintents:.asciz "BAD_INTENTS="
lab_badfinal:.asciz "BAD_FINAL="
lab_goodintents:.asciz "GOOD_INTENTS="
lab_goodfinal:.asciz "GOOD_FINAL="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P04_FAIL\n"
lab_done:.asciz "DONE\n"
