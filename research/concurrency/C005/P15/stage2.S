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
.equ WRITER_EPOCH,0x6002
.equ PAIR_A,0x6003
.equ PAIR_B,0x6004
.equ RECOVERY_AUTH,0x6005
.equ WRITER_STALLED,0x6006
.equ AP_RECOVERED,0x6007
.equ RESUME_WRITER,0x6008
.equ APPLY_RESULT,0x6009
.equ PHASE_DONE,0x600a
.equ AP_DONE,0x600b
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $12,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $1,WRITER_EPOCH; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $1,RECOVERY_AUTH; movb $0,AP_RECOVERED; movb $0,PHASE_DONE
 # BSP writer begins under cached epoch1 and stalls after A33.
 movb $1,%bl
 movb $0x33,PAIR_A; movb $1,WRITER_STALLED; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,AP_RECOVERED; je badresume; decl %ecx; jnz 2b; jmp fail
badresume:
 movw $lab_badauth,%si; call puts; movb RECOVERY_AUTH,%al; call bit; call nl
 movw $lab_badepoch,%si; call puts; movb WRITER_EPOCH,%al; call hex8; call nl
 movb $1,RESUME_WRITER
 # BAD: pending old writer effect ignores cached epoch1 vs current epoch2.
 movb $0x44,PAIR_B; movb $'W',APPLY_RESULT; movb $1,PHASE_DONE
 movw $lab_badapply,%si; call puts; movb APPLY_RESULT,%al; call putc; call nl
 movw $lab_bada,%si; call puts; movb PAIR_A,%al; call hex8; call nl
 movw $lab_badb,%si; call puts; movb PAIR_B,%al; call hex8; call nl
 # Good reset.
 movb $1,WRITER_EPOCH; movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $1,RECOVERY_AUTH; movb $0,WRITER_STALLED; movb $0,AP_RECOVERED; movb $0,RESUME_WRITER; movb $0,PHASE_DONE
 movb $1,%bl
 movb $0x33,PAIR_A; movb $1,WRITER_STALLED; movb $2,PHASE
 movl $0x04000000,%ecx
3: cmpb $1,AP_RECOVERED; je goodresume; decl %ecx; jnz 3b; jmp fail
goodresume:
 movw $lab_goodauth,%si; call puts; movb RECOVERY_AUTH,%al; call bit; call nl
 movw $lab_goodepoch,%si; call puts; movb WRITER_EPOCH,%al; call hex8; call nl
 movb $1,RESUME_WRITER
 # GOOD: revalidate cached epoch1 before pending B44 effect.
 movb $'R',APPLY_RESULT
 cmpb WRITER_EPOCH,%bl
 jne goodrejected
 movb $0x44,PAIR_B; movb $'W',APPLY_RESULT
goodrejected:
 movb $1,PHASE_DONE
 movw $lab_goodapply,%si; call puts; movb APPLY_RESULT,%al; call putc; call nl
 movw $lab_gooda,%si; call puts; movb PAIR_A,%al; call hex8; call nl
 movw $lab_goodb,%si; call puts; movb PAIR_B,%al; call hex8; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,AP_DONE; je done; decl %ecx; jnz 4b; jmp fail
done: movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl; movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
5: hlt; jmp 5b
fail: movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
6: hlt; jmp 6b
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_HI,%edi; movl %eax,(%edi)
 movl $0xc500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call dl
 movl $0x8500,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; call ds
 movl $0x609,%eax; movl $LAPIC_LO,%edi; movl %eax,(%edi); call waiticr; ret
waiticr: movl $LAPIC_LO,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz waiticr; ret
ds: movl $0x40000,%ecx
7: pause; decl %ecx; jnz 7b; ret
dl: movl $0x400000,%ecx
8: pause; decl %ecx; jnz 8b; ret
puts: lodsb; testb %al,%al; jz 9f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
9: ret
bit: andb $1,%al; addb $'0',%al
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 10f; addb $('A'-10),%al; jmp putc
10: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
11: cmpb $1,PHASE; je ap_bad; cmpb $2,PHASE; je ap_good; pause; jmp 11b
ap_bad:
12: cmpb $1,WRITER_STALLED; jne 12b
 cmpb $1,RECOVERY_AUTH; jne ap_bad
 # Authorized recovery: restore last stable pair and advance epoch.
 movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $2,WRITER_EPOCH; movb $1,AP_RECOVERED
13: cmpb $1,PHASE_DONE; jne 13b
14: cmpb $2,PHASE; jne 14b
ap_good:
15: cmpb $1,WRITER_STALLED; jne 15b
 cmpb $1,RECOVERY_AUTH; jne ap_good
 movb $0x11,PAIR_A; movb $0x22,PAIR_B; movb $2,WRITER_EPOCH; movb $1,AP_RECOVERED
16: cmpb $1,PHASE_DONE; jne 16b
17: cmpb $3,PHASE; jne 17b
 movb $1,AP_DONE
18: hlt; jmp 18b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P15\n"
lab_ready:.asciz "AP_READY="
lab_badauth:.asciz "BAD_RECOVERY_AUTH="
lab_badepoch:.asciz "BAD_RECOVERY_EPOCH="
lab_badapply:.asciz "BAD_OLD_WRITER_APPLY="
lab_bada:.asciz "BAD_AFTER_A="
lab_badb:.asciz "BAD_AFTER_B="
lab_goodauth:.asciz "GOOD_RECOVERY_AUTH="
lab_goodepoch:.asciz "GOOD_RECOVERY_EPOCH="
lab_goodapply:.asciz "GOOD_OLD_WRITER_APPLY="
lab_gooda:.asciz "GOOD_AFTER_A="
lab_goodb:.asciz "GOOD_AFTER_B="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P15_FAIL\n"
lab_done:.asciz "DONE\n"
