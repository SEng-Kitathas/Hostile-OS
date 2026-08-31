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
.equ LOCKA,0x6002
.equ LOCKB,0x6003
.equ BSP_FIRST,0x6004
.equ AP_FIRST,0x6005
.equ GO_SECOND,0x6006
.equ BSP_SECOND,0x6007
.equ AP_SECOND,0x6008
.equ AP_BAD_DONE,0x6009
.equ CLEANUP,0x600a
.equ AP_RELEASED,0x600b
.equ GOOD_AP_READY,0x600c
.equ GOOD_GO,0x600d
.equ GOOD_BSP_COMPLETE,0x600e
.equ GOOD_AP_COMPLETE,0x600f
.equ AP_DONE,0x6010
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $17,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 # BSP first claim A.
 call acquire_a
 movb $1,BSP_FIRST
 movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,AP_FIRST; je second; decl %ecx; jnz 2b; jmp fail
second:
 movb $1,GO_SECOND
 # BSP bounded attempts B while retaining A.
 movw $64,%cx
3:
 movb $1,%al
 xchgb %al,LOCKB
 testb %al,%al
 jnz 4f
 movb $1,BSP_SECOND
 movb $0,LOCKB
 jmp 5f
4: loop 3b
5:
 movl $0x04000000,%ecx
6: cmpb $1,AP_BAD_DONE; je badreport; decl %ecx; jnz 6b; jmp fail
badreport:
 movw $lab_bspfirst,%si; call puts; movb BSP_FIRST,%al; call bit; call nl
 movw $lab_apfirst,%si; call puts; movb AP_FIRST,%al; call bit; call nl
 movw $lab_bspsecond,%si; call puts; movb BSP_SECOND,%al; call bit; call nl
 movw $lab_apsecond,%si; call puts; movb AP_SECOND,%al; call bit; call nl
 movb BSP_SECOND,%al; orb AP_SECOND,%al; xorb $1,%al; andb $1,%al; movb %al,%bl
 movw $lab_blocked,%si; call puts; movb %bl,%al; call bit; call nl
 # cleanup each owner's first claim.
 movb $1,CLEANUP
 movl $0x04000000,%ecx
7: cmpb $1,AP_RELEASED; je cleanbsp; decl %ecx; jnz 7b; jmp fail
cleanbsp:
 movb $0,LOCKA
 movb $0,LOCKB
 movb $2,PHASE
 movl $0x04000000,%ecx
8: cmpb $1,GOOD_AP_READY; je goodstart; decl %ecx; jnz 8b; jmp fail
goodstart:
 movb $1,GOOD_GO
 # Both CPUs now use A then B. Acquire with bounded spins.
 call acquire_a
 call acquire_b
 movb $1,GOOD_BSP_COMPLETE
 movb $0,LOCKB
 movb $0,LOCKA
 movl $0x04000000,%ecx
9: cmpb $1,GOOD_AP_COMPLETE; je goodreport; decl %ecx; jnz 9b; jmp fail
goodreport:
 movw $lab_goodbsp,%si; call puts; movb GOOD_BSP_COMPLETE,%al; call bit; call nl
 movw $lab_goodap,%si; call puts; movb GOOD_AP_COMPLETE,%al; call bit; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
10: cmpb $1,AP_DONE; je done; decl %ecx; jnz 10b; jmp fail
done:
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
11: hlt; jmp 11b
fail: movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
12: hlt; jmp 12b
acquire_a:
 movw $0x4000,%cx
13: movb $1,%al; xchgb %al,LOCKA; testb %al,%al; jz 14f; pause; loop 13b; jmp fail
14: ret
acquire_b:
 movw $0x4000,%cx
15: movb $1,%al; xchgb %al,LOCKB; testb %al,%al; jz 16f; pause; loop 15b; jmp fail
16: ret
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
17: pause; decl %ecx; jnz 17b; ret
dl: movl $0x400000,%ecx
18: pause; decl %ecx; jnz 18b; ret
puts: lodsb; testb %al,%al; jz 19f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
19: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
20: cmpb $1,PHASE; jne 20b
 # AP first claim B.
 movb $1,%al
21: xchgb %al,LOCKB; testb %al,%al; jz 22f; pause; movb $1,%al; jmp 21b
22: movb $1,AP_FIRST
23: cmpb $1,GO_SECOND; jne 23b
 # bounded attempts A while retaining B.
 movw $64,%cx
24: movb $1,%al; xchgb %al,LOCKA; testb %al,%al; jnz 25f; movb $1,AP_SECOND; movb $0,LOCKA; jmp 26f
25: loop 24b
26: movb $1,AP_BAD_DONE
27: cmpb $1,CLEANUP; jne 27b
 movb $0,LOCKB
 movb $1,AP_RELEASED
28: cmpb $2,PHASE; jne 28b
 movb $1,GOOD_AP_READY
29: cmpb $1,GOOD_GO; jne 29b
 # Same A then B order as BSP.
30: movb $1,%al; xchgb %al,LOCKA; testb %al,%al; jz 31f; pause; jmp 30b
31: movb $1,%al
32: xchgb %al,LOCKB; testb %al,%al; jz 33f; pause; movb $1,%al; jmp 32b
33: movb $1,GOOD_AP_COMPLETE
 movb $0,LOCKB; movb $0,LOCKA
34: cmpb $3,PHASE; jne 34b
 movb $1,AP_DONE
35: hlt; jmp 35b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P07\n"
lab_ready:.asciz "AP_READY="
lab_bspfirst:.asciz "BAD_BSP_FIRST="
lab_apfirst:.asciz "BAD_AP_FIRST="
lab_bspsecond:.asciz "BAD_BSP_SECOND="
lab_apsecond:.asciz "BAD_AP_SECOND="
lab_blocked:.asciz "BAD_BOTH_BLOCKED="
lab_goodbsp:.asciz "GOOD_BSP_COMPLETE="
lab_goodap:.asciz "GOOD_AP_COMPLETE="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P07_FAIL\n"
lab_done:.asciz "DONE\n"
