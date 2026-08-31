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
.equ ACTIVE,0x6003
.equ BSP_ACTIVE,0x6004
.equ AP_ACTIVE,0x6005
.equ AP_INCREMENTED,0x6006
.equ BAD_VERSION_SEEN,0x6007
.equ BAD_ACTIVE_SEEN,0x6008
.equ WRITER_LOCK,0x6009
.equ MAX_ACTIVE,0x600a
.equ BSP_COMPLETE,0x600b
.equ AP_COMPLETE,0x600c
.equ GOOD_GO,0x600d
.equ AP_DONE,0x600e
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $15,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0,VERSION; movb $0,ACTIVE; movb $1,BSP_ACTIVE; incb ACTIVE; incb VERSION; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,AP_INCREMENTED; je badreport; decl %ecx; jnz 2b; jmp fail
badreport:
 movb ACTIVE,%al; movb %al,BAD_ACTIVE_SEEN; movb VERSION,%al; movb %al,BAD_VERSION_SEEN
 movw $lab_badactive,%si; call puts; movb BAD_ACTIVE_SEEN,%al; call hex8; call nl
 movw $lab_badver,%si; call puts; movb BAD_VERSION_SEEN,%al; call hex8; call nl
 movb BAD_VERSION_SEEN,%al; andb $1,%al; xorb $1,%al; movb %al,%bl
 movw $lab_badeven,%si; call puts; movb %bl,%al; call bit; call nl
 # release bad writers and reset.
 decb ACTIVE; movb $0,BSP_ACTIVE; movb $2,PHASE
 movl $0x04000000,%ecx
3: cmpb $0,ACTIVE; je goodsetup; decl %ecx; jnz 3b; jmp fail
goodsetup:
 movb $0,VERSION; movb $0,ACTIVE; movb $0,WRITER_LOCK; movb $0,MAX_ACTIVE; movb $0,BSP_COMPLETE; movb $0,AP_COMPLETE; movb $3,PHASE
 movb $1,GOOD_GO
 # BSP atomic writer claim.
 call claim_writer
 incb ACTIVE; cmpb $1,MAX_ACTIVE; jae 4f; movb $1,MAX_ACTIVE
4: incb VERSION; movl $0x00100000,%ecx
5: pause; decl %ecx; jnz 5b
 incb VERSION; decb ACTIVE; movb $0,WRITER_LOCK; movb $1,BSP_COMPLETE
 movl $0x04000000,%ecx
6: cmpb $1,AP_COMPLETE; je goodreport; decl %ecx; jnz 6b; jmp fail
goodreport:
 movw $lab_max,%si; call puts; movb MAX_ACTIVE,%al; call hex8; call nl
 movw $lab_bspdone,%si; call puts; movb BSP_COMPLETE,%al; call bit; call nl
 movw $lab_apdone2,%si; call puts; movb AP_COMPLETE,%al; call bit; call nl
 movw $lab_finalver,%si; call puts; movb VERSION,%al; call hex8; call nl
 movb $4,PHASE
 movl $0x04000000,%ecx
7: cmpb $1,AP_DONE; je done; decl %ecx; jnz 7b; jmp fail
done: movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl; movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
8: hlt; jmp 8b
fail: movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
9: hlt; jmp 9b
claim_writer:
 movb $1,%al
10: xchgb %al,WRITER_LOCK; testb %al,%al; jz 11f; pause; movb $1,%al; jmp 10b
11: ret
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
12: pause; decl %ecx; jnz 12b; ret
dl: movl $0x400000,%ecx
13: pause; decl %ecx; jnz 13b; ret
puts: lodsb; testb %al,%al; jz 14f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
14: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 15f; addb $('A'-10),%al; jmp putc
15: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
16: cmpb $1,PHASE; jne 16b
 movb $1,AP_ACTIVE; incb ACTIVE; incb VERSION; movb $1,AP_INCREMENTED
17: cmpb $2,PHASE; jne 17b
 decb ACTIVE; movb $0,AP_ACTIVE
18: cmpb $3,PHASE; jne 18b
19: cmpb $1,GOOD_GO; jne 19b
 # acquire same writer lock
20: movb $1,%al; xchgb %al,WRITER_LOCK; testb %al,%al; jz 21f; pause; movb $1,%al; jmp 20b
21: incb ACTIVE; cmpb $1,MAX_ACTIVE; jae 22f; movb $1,MAX_ACTIVE
22: incb VERSION; movl $0x00100000,%ecx
23: pause; decl %ecx; jnz 23b
 incb VERSION; decb ACTIVE; movb $0,WRITER_LOCK; movb $1,AP_COMPLETE
24: cmpb $4,PHASE; jne 24b
 movb $1,AP_DONE
25: hlt; jmp 25b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P12\n"
lab_ready:.asciz "AP_READY="
lab_badactive:.asciz "BAD_ACTIVE_WRITERS="
lab_badver:.asciz "BAD_VERSION_WHILE_ACTIVE="
lab_badeven:.asciz "BAD_EVEN_WHILE_ACTIVE="
lab_max:.asciz "GOOD_MAX_ACTIVE="
lab_bspdone:.asciz "GOOD_BSP_COMPLETE="
lab_apdone2:.asciz "GOOD_AP_COMPLETE="
lab_finalver:.asciz "GOOD_FINAL_VERSION="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P12_FAIL\n"
lab_done:.asciz "DONE\n"
