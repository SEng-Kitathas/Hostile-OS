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
.equ READY,0x6002
.equ PAYLOAD,0x6003
.equ SEEN,0x6004
.equ AP_DONE,0x6005
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $6,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0x7e,PAYLOAD; movb $0,READY; movb $1,PHASE
 movb $1,READY
 movl $0x00800000,%ecx
2: pause; decl %ecx; jnz 2b
 movb $0x55,PAYLOAD
 movl $0x04000000,%ecx
3: cmpb $1,PHASE; jne bad_report; decl %ecx; jnz 3b; jmp fail
bad_report:
 movw $lab_bad_seen,%si; call puts; movb SEEN,%al; call hex8; call nl
 movw $lab_bad_final,%si; call puts; movb PAYLOAD,%al; call hex8; call nl
 movb $0x7e,PAYLOAD; movb $0,READY; movb $2,PHASE
 movb $0x55,PAYLOAD
 movb $1,READY
 movl $0x04000000,%ecx
4: cmpb $2,PHASE; jne good_report; decl %ecx; jnz 4b; jmp fail
good_report:
 movw $lab_good_seen,%si; call puts; movb SEEN,%al; call hex8; call nl
 movw $lab_good_final,%si; call puts; movb PAYLOAD,%al; call hex8; call nl
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
aploop:
 cmpb $1,PHASE; je apread1
 cmpb $2,PHASE; je apread2
 cmpb $3,PHASE; je apfinish
 pause; jmp aploop
apread1: cmpb $1,READY; jne apread1; movb PAYLOAD,%al; movb %al,SEEN; movb $0,PHASE; jmp aploop
apread2: cmpb $1,READY; jne apread2; movb PAYLOAD,%al; movb %al,SEEN; movb $0,PHASE; jmp aploop
apfinish: movb $1,AP_DONE
12: hlt; jmp 12b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P03\n"
lab_ready:.asciz "AP_READY="
lab_bad_seen:.asciz "BAD_SEEN="
lab_bad_final:.asciz "BAD_FINAL="
lab_good_seen:.asciz "GOOD_SEEN="
lab_good_final:.asciz "GOOD_FINAL="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P03_FAIL\n"
lab_done:.asciz "DONE\n"
