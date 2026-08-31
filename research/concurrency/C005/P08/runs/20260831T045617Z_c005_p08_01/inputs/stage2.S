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
.equ GEN,0x6002
.equ VALUE,0x6003
.equ AP_ENTRY_VALID,0x6004
.equ AP_USE_STARTED,0x6005
.equ GO_BAD_READ,0x6006
.equ BAD_USE_VAL,0x6007
.equ AP_BAD_DONE,0x6008
.equ GOOD_USERS,0x6009
.equ GOOD_AP_ACQUIRED,0x600a
.equ GOOD_GO_READ,0x600b
.equ GOOD_USE_VAL,0x600c
.equ GOOD_AP_RELEASED,0x600d
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
 movb $1,GEN; movb $0x7e,VALUE; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,AP_USE_STARTED; je reclaim_bad; decl %ecx; jnz 2b; jmp fail
reclaim_bad:
 movw $lab_entry,%si; call puts; movb AP_ENTRY_VALID,%al; call bit; call nl
 movb $2,GEN; movb $0,VALUE
 movw $lab_badreclaim,%si; call puts; movb $1,%al; call bit; call nl
 movb $1,GO_BAD_READ
 movl $0x04000000,%ecx
3: cmpb $1,AP_BAD_DONE; je badreport; decl %ecx; jnz 3b; jmp fail
badreport:
 movw $lab_badval,%si; call puts; movb BAD_USE_VAL,%al; call hex8; call nl
 # Good phase.
 movb $1,GEN; movb $0x7e,VALUE; movb $0,GOOD_USERS; movb $2,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,GOOD_AP_ACQUIRED; je try_good_reclaim; decl %ecx; jnz 4b; jmp fail
try_good_reclaim:
 movw $lab_usersduring,%si; call puts; movb GOOD_USERS,%al; call hex8; call nl
 # Reclaim only if no in-flight users.
 cmpb $0,GOOD_USERS
 jne good_defer
 movb $2,GEN; movb $0,VALUE; movb $1,%bl
 jmp good_reclaim_report
good_defer: movb $0,%bl
good_reclaim_report:
 movw $lab_reclaimduring,%si; call puts; movb %bl,%al; call bit; call nl
 movb $1,GOOD_GO_READ
 movl $0x04000000,%ecx
5: cmpb $1,GOOD_AP_RELEASED; je afteruse; decl %ecx; jnz 5b; jmp fail
afteruse:
 movw $lab_goodval,%si; call puts; movb GOOD_USE_VAL,%al; call hex8; call nl
 movw $lab_usersafter,%si; call puts; movb GOOD_USERS,%al; call hex8; call nl
 # Now reclaim after users reached0.
 cmpb $0,GOOD_USERS
 jne fail
 movb $2,GEN; movb $0,VALUE
 movw $lab_reclaimafter,%si; call puts; movb $1,%al; call bit; call nl
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
 cmpb $1,GEN
 jne ap_bad_invalid
 movb $1,AP_ENTRY_VALID
 movb $1,AP_USE_STARTED
14: cmpb $1,GO_BAD_READ; jne 14b
 movb VALUE,%al; movb %al,BAD_USE_VAL; movb $1,AP_BAD_DONE
15: cmpb $2,PHASE; jne 15b
 # atomic in-flight participation acquisition.
 movb $1,%al
 lock xaddb %al,GOOD_USERS
 movb $1,GOOD_AP_ACQUIRED
16: cmpb $1,GOOD_GO_READ; jne 16b
 movb VALUE,%al; movb %al,GOOD_USE_VAL
 movb $-1,%al
 lock xaddb %al,GOOD_USERS
 movb $1,GOOD_AP_RELEASED
17: cmpb $3,PHASE; jne 17b
 movb $1,AP_DONE
18: hlt; jmp 18b
ap_bad_invalid: movb $0,AP_ENTRY_VALID; movb $1,AP_USE_STARTED; jmp 14b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P08\n"
lab_ready:.asciz "AP_READY="
lab_entry:.asciz "BAD_ENTRY_VALID="
lab_badreclaim:.asciz "BAD_RECLAIM="
lab_badval:.asciz "BAD_USE_VAL="
lab_usersduring:.asciz "GOOD_USERS_DURING="
lab_reclaimduring:.asciz "GOOD_RECLAIM_DURING="
lab_goodval:.asciz "GOOD_USE_VAL="
lab_usersafter:.asciz "GOOD_USERS_AFTER="
lab_reclaimafter:.asciz "GOOD_RECLAIM_AFTER="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P08_FAIL\n"
lab_done:.asciz "DONE\n"
