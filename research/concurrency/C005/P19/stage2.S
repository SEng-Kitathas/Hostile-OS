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
.equ WRITER_LOCK,0x6005
.equ WRITER_A_DONE,0x6006
.equ READ_ATTEMPT,0x6007
.equ WRITER_DONE,0x6008
.equ READ_RETRY,0x6009
.equ READ_ACCEPT,0x600a
.equ READ_A,0x600b
.equ READ_B,0x600c
.equ USERS,0x600d
.equ AP_USE_ACTIVE,0x600e
.equ AUTH_RIGHTS,0x600f
.equ AUTH_GEN,0x6010
.equ AP_ACCEPTED,0x6011
.equ AP_ACCEPT_GEN,0x6012
.equ APPLY_GO,0x6013
.equ DELAY_RESULT,0x6014
.equ RESOURCE_VAL,0x6015
.equ AP_USE_DONE,0x6016
.equ AP_DONE,0x6017
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $24,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je phase1; decl %ecx; jnz 1b; jmp fail
phase1:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0,VERSION; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $0,WRITER_LOCK; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,WRITER_A_DONE; je reader_overlap; decl %ecx; jnz 2b; jmp fail
reader_overlap:
 # First reader attempt sees odd version and must retry.
 movb VERSION,%al
 testb $1,%al
 jz fail
 movb $1,READ_RETRY
 movb $1,READ_ATTEMPT
 movl $0x04000000,%ecx
3: cmpb $1,WRITER_DONE; je reader_retry; decl %ecx; jnz 3b; jmp fail
reader_retry:
reader_loop:
 movb VERSION,%bl; testb $1,%bl; jnz reader_loop
 movb PAIR_A,%cl; movb PAIR_B,%dl; movb VERSION,%al
 cmpb %bl,%al; jne reader_loop
 testb $1,%al; jnz reader_loop
 movb %cl,READ_A; movb %dl,READ_B; movb $1,READ_ACCEPT
 movw $lab_retry,%si; call puts; movb READ_RETRY,%al; call bit; call nl
 movw $lab_accept,%si; call puts; movb READ_ACCEPT,%al; call bit; call nl
 movw $lab_reada,%si; call puts; movb READ_A,%al; call hex8; call nl
 movw $lab_readb,%si; call puts; movb READ_B,%al; call hex8; call nl
 # Phase2 lifetime + delayed authority.
 movb $0,USERS; movb $2,AUTH_RIGHTS; movb $1,AUTH_GEN; movb $0x7e,RESOURCE_VAL; movb $0,AP_USE_ACTIVE; movb $0,AP_ACCEPTED; movb $0,AP_USE_DONE; movb $0,APPLY_GO; movb $2,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,AP_USE_ACTIVE; jne 4b
 movl $0x04000000,%ecx
5: cmpb $1,AP_ACCEPTED; je lifetime_report; decl %ecx; jnz 5b; jmp fail
lifetime_report:
 movw $lab_usersduring,%si; call puts; movb USERS,%al; call hex8; call nl
 movb $0,%bl; cmpb $0,USERS; je reclaim_during_yes; jmp reclaim_during_report
reclaim_during_yes: movb $1,%bl
reclaim_during_report:
 movw $lab_reclaimduring,%si; call puts; movb %bl,%al; call bit; call nl
 # Revoke before application.
 movb $0,AUTH_RIGHTS; movb $2,AUTH_GEN
 movw $lab_authgen,%si; call puts; movb AUTH_GEN,%al; call hex8; call nl
 movb $1,APPLY_GO
 movl $0x04000000,%ecx
6: cmpb $1,AP_USE_DONE; je final_report; decl %ecx; jnz 6b; jmp fail
final_report:
 movw $lab_delay,%si; call puts; movb DELAY_RESULT,%al; call putc; call nl
 movw $lab_value,%si; call puts; movb RESOURCE_VAL,%al; call hex8; call nl
 movw $lab_usersafter,%si; call puts; movb USERS,%al; call hex8; call nl
 movb $0,%bl; cmpb $0,USERS; jne reclaim_after_report; movb $1,%bl
reclaim_after_report:
 movw $lab_reclaimafter,%si; call puts; movb %bl,%al; call bit; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
7: cmpb $1,AP_DONE; je done; decl %ecx; jnz 7b; jmp fail
done: movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl; movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
8: hlt; jmp 8b
fail: movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
9: hlt; jmp 9b
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
10: pause; decl %ecx; jnz 10b; ret
dl: movl $0x400000,%ecx
11: pause; decl %ecx; jnz 11b; ret
puts: lodsb; testb %al,%al; jz 12f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
12: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 13f; addb $('A'-10),%al; jmp putc
13: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
14: cmpb $1,PHASE; jne 14b
 # Writer exclusion + versioned coupled write.
15: movb $1,%al; xchgb %al,WRITER_LOCK; testb %al,%al; jz 16f; pause; movb $1,%al; jmp 15b
16: movb $1,VERSION; movb $0x33,PAIR_A; movb $1,WRITER_A_DONE
17: cmpb $1,READ_ATTEMPT; jne 17b
 movb $0x44,PAIR_B; movb $2,VERSION; movb $0,WRITER_LOCK; movb $1,WRITER_DONE
18: cmpb $2,PHASE; jne 18b
 # Register in-flight lifetime use.
 movb $1,%al; lock xaddb %al,USERS; movb $1,AP_USE_ACTIVE
 # Accept delayed write under current authority.
 movb $0,AP_ACCEPTED
 movb AUTH_RIGHTS,%al; testb $2,%al; jz ap_wait_apply
 movb AUTH_GEN,%al; movb %al,AP_ACCEPT_GEN; movb $1,AP_ACCEPTED
ap_wait_apply:
19: cmpb $1,APPLY_GO; jne 19b
 movb $'U',DELAY_RESULT
 movb AP_ACCEPT_GEN,%al; cmpb AUTH_GEN,%al; jne ap_after_apply
 movb AUTH_RIGHTS,%al; testb $2,%al; jz ap_after_apply
 movb $0x55,RESOURCE_VAL; movb $'W',DELAY_RESULT
ap_after_apply:
 movb $-1,%al; lock xaddb %al,USERS; movb $1,AP_USE_DONE
20: cmpb $3,PHASE; jne 20b
 movb $1,AP_DONE
21: hlt; jmp 21b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P19\n"
lab_ready:.asciz "AP_READY="
lab_retry:.asciz "READ_RETRY="
lab_accept:.asciz "READ_ACCEPT="
lab_reada:.asciz "READ_A="
lab_readb:.asciz "READ_B="
lab_usersduring:.asciz "USERS_DURING="
lab_reclaimduring:.asciz "RECLAIM_DURING="
lab_authgen:.asciz "AUTH_REVOKE_GEN="
lab_delay:.asciz "DELAYED_APPLY="
lab_value:.asciz "VALUE_AFTER="
lab_usersafter:.asciz "USERS_AFTER="
lab_reclaimafter:.asciz "RECLAIM_AFTER="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P19_FAIL\n"
lab_done:.asciz "DONE\n"
