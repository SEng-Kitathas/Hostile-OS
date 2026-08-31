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
.equ XLOCK,0x6002
.equ AP_OWNS,0x6003
.equ DOUBLE_OWNER,0x6004
.equ STALLED_PROGRESS,0x6005
.equ RELEASE_REQ,0x6006
.equ AP_RELEASED,0x6007
.equ AFTER_PROGRESS,0x6008
.equ AP_DONE,0x6009
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $10,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je begin; decl %ecx; jnz 1b; jmp fail
begin:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,AP_OWNS; je stalled; decl %ecx; jnz 2b; jmp fail
stalled:
 movw $lab_owns,%si; call puts; movb AP_OWNS,%al; call bit; call nl
 # bounded64 acquisition attempts while AP deliberately holds.
 movw $64,%cx
3:
 movb $1,%al
 xchgb %al,XLOCK
 testb %al,%al
 jnz 4f
 movb $1,STALLED_PROGRESS
 cmpb $1,AP_OWNS
 jne 5f
 movb $1,DOUBLE_OWNER
5: movb $0,XLOCK
4: loop 3b
 movw $lab_double,%si; call puts; movb DOUBLE_OWNER,%al; call bit; call nl
 movw $lab_stalled,%si; call puts; movb STALLED_PROGRESS,%al; call bit; call nl
 # Explicit release request; holder acknowledges and releases.
 movb $1,RELEASE_REQ
 movl $0x04000000,%ecx
6: cmpb $1,AP_RELEASED; je after; decl %ecx; jnz 6b; jmp fail
after:
 movw $lab_released,%si; call puts; movb AP_RELEASED,%al; call bit; call nl
 # fresh acquisition after release.
 movw $0x1000,%cx
7:
 movb $1,%al
 xchgb %al,XLOCK
 testb %al,%al
 jz acquired
 pause; loop 7b
 jmp fail
acquired:
 movb $1,AFTER_PROGRESS
 movw $lab_after,%si; call puts; movb AFTER_PROGRESS,%al; call bit; call nl
 movb $0,XLOCK
 movb $2,PHASE
 movl $0x04000000,%ecx
8: cmpb $1,AP_DONE; je done; decl %ecx; jnz 8b; jmp fail
done:
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
9: hlt; jmp 9b
fail:
 movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
10: hlt; jmp 10b
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
11: pause; decl %ecx; jnz 11b; ret
dl: movl $0x400000,%ecx
12: pause; decl %ecx; jnz 12b; ret
puts: lodsb; testb %al,%al; jz 13f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
13: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
14: cmpb $1,PHASE; jne 14b
 movb $1,%al
 xchgb %al,XLOCK
 testb %al,%al
 jnz ap_fail
 movb $1,AP_OWNS
15: cmpb $1,RELEASE_REQ; je ap_release; pause; jmp 15b
ap_release:
 movb $0,XLOCK
 movb $1,AP_RELEASED
16: cmpb $2,PHASE; je ap_finish; pause; jmp 16b
ap_finish: movb $1,AP_DONE
17: hlt; jmp 17b
ap_fail: movb $1,DOUBLE_OWNER
18: hlt; jmp 18b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P06\n"
lab_ready:.asciz "AP_READY="
lab_owns:.asciz "AP_OWNS="
lab_double:.asciz "DOUBLE_OWNER="
lab_stalled:.asciz "STALLED_PROGRESS="
lab_released:.asciz "AP_RELEASED="
lab_after:.asciz "AFTER_RELEASE_PROGRESS="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P06_FAIL\n"
lab_done:.asciz "DONE\n"
