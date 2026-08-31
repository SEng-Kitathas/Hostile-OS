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
.equ BAD_HELD,0x6002
.equ BAD_CYCLE_DONE,0x6003
.equ GOOD_WORD,0x6004
.equ GOOD_CYCLE_DONE,0x6006
.equ AP_DONE,0x6007
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $8,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je bad; decl %ecx; jnz 1b; jmp fail
bad:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 movb $0,BAD_HELD
 movb BAD_HELD,%bl
 movw $lab_badsnap,%si; call puts; movb %bl,%al; call hex8; call nl
 movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,BAD_CYCLE_DONE; je badclaim; decl %ecx; jnz 2b; jmp fail
badclaim:
 movw $lab_badcycle,%si; call puts; movb BAD_CYCLE_DONE,%al; call bit; call nl
 movb $1,%al
 xchgb %al,BAD_HELD
 # old0 means stale claim accepted.
 testb %al,%al
 setz %al
 movb %al,%bl
 movw $lab_badaccept,%si; call puts; movb %bl,%al; call bit; call nl
 # Good packed epoch:held. Low byte held, high byte epoch.
 movw $0,GOOD_WORD
 movw GOOD_WORD,%bx
 movw $lab_goodsnap,%si; call puts; movw %bx,%ax; call hex16; call nl
 movb $2,PHASE
 movl $0x04000000,%ecx
3: cmpb $1,GOOD_CYCLE_DONE; je goodclaim; decl %ecx; jnz 3b; jmp fail
goodclaim:
 movw $lab_goodcycle,%si; call puts; movb GOOD_CYCLE_DONE,%al; call bit; call nl
 movw $lab_epoch,%si; call puts; movb GOOD_WORD+1,%al; call hex8; call nl
 # stale expected0000, desired0001; must fail against0100.
 xorw %ax,%ax
 movw $0x0001,%dx
 lock cmpxchgw %dx,GOOD_WORD
 setz %cl
 movw $lab_stale,%si; call puts; movb %cl,%al; call bit; call nl
 # fresh expected0100 -> desired0101 succeeds.
 movw $0x0100,%ax
 movw $0x0101,%dx
 lock cmpxchgw %dx,GOOD_WORD
 setz %cl
 movw $lab_fresh,%si; call puts; movb %cl,%al; call bit; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,AP_DONE; je done; decl %ecx; jnz 4b; jmp fail
done:
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
5: hlt; jmp 5b
fail:
 movw $lab_fail,%si; call puts; movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
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
hex16: pushw %ax; movb %ah,%al; call hex8; popw %ax; call hex8; ret
nib: cmpb $9,%al; jbe 10f; addb $('A'-10),%al; jmp putc
10: addb $'0',%al; jmp putc
ap_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp; movb $1,AP_READY
aploop:
 cmpb $1,PHASE; je apbad
 cmpb $2,PHASE; je apgood
 cmpb $3,PHASE; je apfinish
 pause; jmp aploop
apbad:
 movb $1,%al
 xchgb %al,BAD_HELD
 # immediately release to same visible0.
 movb $0,BAD_HELD
 movb $1,BAD_CYCLE_DONE
11: cmpb $2,PHASE; je apgood; pause; jmp 11b
apgood:
 # acquire initial0000 ->0001 then release with epoch advance ->0100.
 xorw %ax,%ax
 movw $0x0001,%dx
 lock cmpxchgw %dx,GOOD_WORD
 movw $0x0100,GOOD_WORD
 movb $1,GOOD_CYCLE_DONE
12: cmpb $3,PHASE; je apfinish; pause; jmp 12b
apfinish:
 movb $1,AP_DONE
13: hlt; jmp 13b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P05\n"
lab_ready:.asciz "AP_READY="
lab_badsnap:.asciz "BAD_SNAPSHOT="
lab_badcycle:.asciz "BAD_CYCLE_DONE="
lab_badaccept:.asciz "BAD_STALE_ACCEPT="
lab_goodsnap:.asciz "GOOD_SNAPSHOT="
lab_goodcycle:.asciz "GOOD_CYCLE_DONE="
lab_epoch:.asciz "GOOD_EPOCH="
lab_stale:.asciz "GOOD_STALE_ACCEPT="
lab_fresh:.asciz "GOOD_FRESH_ACCEPT="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P05_FAIL\n"
lab_done:.asciz "DONE\n"
