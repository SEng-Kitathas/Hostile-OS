.code16
.section .text
.global _start
.equ DEBUG_PORT,0xe9
.equ EXIT_PORT,0xf4
.equ LAPIC_ID,0xfee00020
.equ LAPIC_LO,0xfee00300
.equ LAPIC_HI,0xfee00310
.equ AP_TRAMP,0x9000
.equ AP_READY,0x6000
.equ PHASE,0x6001
.equ XLOCK,0x6002
.equ OWNER,0x6003
.equ BSP_ACTIVE,0x6004
.equ BSP_ID,0x6005
.equ AP_ACTUAL,0x6006
.equ CLAIMED_ID,0x6007
.equ BAD_RELEASE,0x6008
.equ BAD_AP_ACQUIRE,0x6009
.equ BAD_DOUBLE,0x600a
.equ BAD_DONE,0x600b
.equ GOOD_RELEASE,0x600c
.equ GOOD_ACQUIRE_WHILE,0x600d
.equ GOOD_DOUBLE,0x600e
.equ GOOD_DONE,0x600f
.equ GOOD_ACQUIRE_AFTER,0x6010
.equ AP_DONE,0x6011
_start:
 cli; xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x7a00,%sp; cld
 movw $AP_READY,%di; movw $18,%cx; xorw %ax,%ax; rep stosb
 movw $ap_start,%si; movw $AP_TRAMP,%di; movw $(ap_end-ap_start),%cx; rep movsb
 movw $lab_test,%si; call puts; call start_ap
 movl $0x04000000,%ecx
1: cmpb $1,AP_READY; je ready; decl %ecx; jnz 1b; jmp fail
ready:
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 # Read BSP local APIC ID.
 movl $LAPIC_ID,%edi; movl (%edi),%eax; shrl $24,%eax; movb %al,BSP_ID
 movw $lab_bspid,%si; call puts; movb BSP_ID,%al; call hex8; call nl
 # BSP owns claim.
 movb $0,XLOCK; movb BSP_ID,%al; movb %al,OWNER; movb $1,%al; xchgb %al,XLOCK; testb %al,%al; jnz fail
 movb $1,BSP_ACTIVE; movb $1,PHASE
 movl $0x04000000,%ecx
2: cmpb $1,BAD_DONE; je badreport; decl %ecx; jnz 2b; jmp fail
badreport:
 movw $lab_apactual,%si; call puts; movb AP_ACTUAL,%al; call hex8; call nl
 movw $lab_badclaim,%si; call puts; movb CLAIMED_ID,%al; call hex8; call nl
 movw $lab_badrelease,%si; call puts; movb BAD_RELEASE,%al; call bit; call nl
 movw $lab_badacq,%si; call puts; movb BAD_AP_ACQUIRE,%al; call bit; call nl
 movw $lab_baddouble,%si; call puts; movb BAD_DOUBLE,%al; call bit; call nl
 # Good reset with BSP current owner again.
 movb $1,XLOCK; movb BSP_ID,%al; movb %al,OWNER; movb $1,BSP_ACTIVE; movb $0,CLAIMED_ID; movb $2,PHASE
 movl $0x04000000,%ecx
3: cmpb $1,GOOD_DONE; je goodreport; decl %ecx; jnz 3b; jmp fail
goodreport:
 movw $lab_goodclaim,%si; call puts; movb CLAIMED_ID,%al; call hex8; call nl
 movw $lab_goodactual,%si; call puts; movb AP_ACTUAL,%al; call hex8; call nl
 movw $lab_goodrelease,%si; call puts; movb GOOD_RELEASE,%al; call bit; call nl
 movw $lab_goodacqwhile,%si; call puts; movb GOOD_ACQUIRE_WHILE,%al; call bit; call nl
 movw $lab_gooddouble,%si; call puts; movb GOOD_DOUBLE,%al; call bit; call nl
 # Only current BSP owner explicitly releases.
 movb $0,BSP_ACTIVE; movb $0,XLOCK; movb $3,PHASE
 movl $0x04000000,%ecx
4: cmpb $1,AP_DONE; je finalreport; decl %ecx; jnz 4b; jmp fail
finalreport:
 movw $lab_goodafter,%si; call puts; movb GOOD_ACQUIRE_AFTER,%al; call bit; call nl
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts; movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
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
 # Protected provenance witness: local APIC ID.
 movl $LAPIC_ID,%edi; movl (%edi),%eax; shrl $24,%eax; movb %al,AP_ACTUAL
11: cmpb $1,PHASE; jne 11b
 # BAD: AP lies that it is owner0; release trusts supplied claim.
 movb $0,CLAIMED_ID; movb $0,BAD_RELEASE; movb $0,BAD_AP_ACQUIRE; movb $0,BAD_DOUBLE
 movb CLAIMED_ID,%al; cmpb OWNER,%al; jne bad_no_release
 movb $0,XLOCK; movb $1,BAD_RELEASE
bad_no_release:
 movb $1,%al; xchgb %al,XLOCK; testb %al,%al; jnz bad_no_acquire
 movb $1,BAD_AP_ACQUIRE
 cmpb $1,BSP_ACTIVE; jne bad_no_acquire
 movb $1,BAD_DOUBLE
bad_no_acquire:
 movb $1,BAD_DONE
12: cmpb $2,PHASE; jne 12b
 # GOOD: same lie, but release derives actual APIC ID.
 movb $0,CLAIMED_ID; movb $0,GOOD_RELEASE; movb $0,GOOD_ACQUIRE_WHILE; movb $0,GOOD_DOUBLE
 movb AP_ACTUAL,%al; cmpb OWNER,%al; jne good_release_denied
 movb $0,XLOCK; movb $1,GOOD_RELEASE
good_release_denied:
 movb $1,%al; xchgb %al,XLOCK; testb %al,%al; jnz good_no_acquire
 movb $1,GOOD_ACQUIRE_WHILE
 cmpb $1,BSP_ACTIVE; jne good_no_acquire
 movb $1,GOOD_DOUBLE
good_no_acquire:
 movb $1,GOOD_DONE
13: cmpb $3,PHASE; jne 13b
 # After real owner release, AP can acquire.
 movb $1,%al; xchgb %al,XLOCK; testb %al,%al; jnz ap_after_fail
 movb $1,GOOD_ACQUIRE_AFTER
ap_after_fail:
 movb $1,AP_DONE
14: hlt; jmp 14b
ap_end:
.section .rodata
lab_test:.asciz "TEST=C005_P20\n"
lab_ready:.asciz "AP_READY="
lab_bspid:.asciz "BSP_ID="
lab_apactual:.asciz "AP_ACTUAL_ID="
lab_badclaim:.asciz "BAD_CLAIMED_ID="
lab_badrelease:.asciz "BAD_RELEASE="
lab_badacq:.asciz "BAD_AP_ACQUIRE="
lab_baddouble:.asciz "BAD_DOUBLE_OWNER="
lab_goodclaim:.asciz "GOOD_CLAIMED_ID="
lab_goodactual:.asciz "GOOD_ACTUAL_ID="
lab_goodrelease:.asciz "GOOD_RELEASE="
lab_goodacqwhile:.asciz "GOOD_AP_ACQUIRE_WHILE="
lab_gooddouble:.asciz "GOOD_DOUBLE_OWNER="
lab_goodafter:.asciz "GOOD_AP_ACQUIRE_AFTER="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P20_FAIL\n"
lab_done:.asciz "DONE\n"
