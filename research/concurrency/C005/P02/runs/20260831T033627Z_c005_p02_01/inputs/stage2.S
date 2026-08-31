.code16
.section .text
.global _start
.equ DEBUG_PORT,0xe9
.equ EXIT_PORT,0xf4
.equ LAPIC_ICR_LOW,0xfee00300
.equ LAPIC_ICR_HIGH,0xfee00310
.equ AP_TRAMP,0x9000
.equ AP_VECTOR,9
.equ AP_READY,0x6000
.equ PHASE,0x6001
.equ BAD_LOCK,0x6002
.equ BAD_BSP_FREE,0x6003
.equ BAD_AP_FREE,0x6004
.equ BAD_GO,0x6005
.equ BAD_BSP_ENTER,0x6006
.equ BAD_AP_ENTER,0x6007
.equ GOOD_LOCK,0x6008
.equ GOOD_BSP_ENTER,0x6009
.equ GOOD_AP_ENTER,0x600a
.equ GOOD_AP_ATTEMPT,0x600b
.equ AP_DONE,0x600c
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7a00,%sp
 cld
 movw $AP_READY,%di
 movw $13,%cx
 xorw %ax,%ax
 rep stosb
 movw $ap_blob_start,%si
 movw $AP_TRAMP,%di
 movw $(ap_blob_end-ap_blob_start),%cx
 rep movsb
 movw $lab_test,%si
 call puts
 call start_ap
 movl $0x04000000,%ecx
wready: cmpb $1,AP_READY; je ready; decl %ecx; jnz wready; jmp fail
ready:
 movw $lab_cpu,%si; call puts; movb $2,%al; call hex8; call nl
 movw $lab_ready,%si; call puts; movb AP_READY,%al; call bit; call nl
 # Bad deterministic split check/set.
 movb $0,BAD_LOCK
 movb $1,PHASE
 cmpb $0,BAD_LOCK
 jne fail
 movb $1,BAD_BSP_FREE
 movl $0x04000000,%ecx
wapfree: cmpb $1,BAD_AP_FREE; je bothread; decl %ecx; jnz wapfree; jmp fail
bothread:
 movb $1,BAD_GO
 movb $1,BAD_LOCK
 movb $1,BAD_BSP_ENTER
 movl $0x04000000,%ecx
wapenter: cmpb $1,BAD_AP_ENTER; je badreport; decl %ecx; jnz wapenter; jmp fail
badreport:
 movw $lab_bspfree,%si; call puts; movb BAD_BSP_FREE,%al; call bit; call nl
 movw $lab_apfree,%si; call puts; movb BAD_AP_FREE,%al; call bit; call nl
 movw $lab_badentered,%si; call puts
 movb BAD_BSP_ENTER,%al; addb BAD_AP_ENTER,%al; call hex8; call nl
 # Good: same topology, one xchg attempt each, no release until both attempted.
 movb $0,GOOD_LOCK
 movb $2,PHASE
 movb $1,%al
 xchgb %al,GOOD_LOCK
 testb %al,%al
 jnz bsp_lost
 movb $1,GOOD_BSP_ENTER
bsp_lost:
 movl $0x04000000,%ecx
wgood: cmpb $1,GOOD_AP_ATTEMPT; je goodreport; decl %ecx; jnz wgood; jmp fail
goodreport:
 movw $lab_goodentered,%si; call puts
 movb GOOD_BSP_ENTER,%al; addb GOOD_AP_ENTER,%al; call hex8; call nl
 movb $3,PHASE
 movl $0x04000000,%ecx
wdone: cmpb $1,AP_DONE; je done; decl %ecx; jnz wdone; jmp fail
done:
 movw $lab_apdone,%si; call puts; movb AP_DONE,%al; call bit; call nl
 movw $lab_done,%si; call puts
 movw $EXIT_PORT,%dx; movb $0x10,%al; outb %al,%dx
1: hlt; jmp 1b
fail:
 movw $lab_fail,%si; call puts
 movw $EXIT_PORT,%dx; movb $0x12,%al; outb %al,%dx
2: hlt; jmp 2b
start_ap:
 movl $0x01000000,%eax; movl $LAPIC_ICR_HIGH,%edi; movl %eax,(%edi)
 movl $0x0000c500,%eax; movl $LAPIC_ICR_LOW,%edi; movl %eax,(%edi); call icr_wait; call delay_long
 movl $0x00008500,%eax; movl $LAPIC_ICR_LOW,%edi; movl %eax,(%edi); call icr_wait; call delay_short
 movl $(0x600+AP_VECTOR),%eax; movl $LAPIC_ICR_LOW,%edi; movl %eax,(%edi); call icr_wait; call delay_short
 movl $(0x600+AP_VECTOR),%eax; movl $LAPIC_ICR_LOW,%edi; movl %eax,(%edi); call icr_wait
 ret
icr_wait: movl $LAPIC_ICR_LOW,%edi; movl (%edi),%eax; testl $0x1000,%eax; jnz icr_wait; ret
delay_short: movl $0x40000,%ecx
3: pause; decl %ecx; jnz 3b; ret
delay_long: movl $0x400000,%ecx
4: pause; decl %ecx; jnz 4b; ret
puts: lodsb; testb %al,%al; jz 5f; movw $DEBUG_PORT,%dx; outb %al,%dx; jmp puts
5: ret
bit: andb $1,%al; addb $'0',%al; jmp putc
putc: movw $DEBUG_PORT,%dx; outb %al,%dx; ret
nl: pushw %ax; movb $'\n',%al; call putc; popw %ax; ret
hex8: pushw %ax; movb %al,%ah; shrb $4,%al; call nib; movb %ah,%al; andb $15,%al; call nib; popw %ax; ret
nib: cmpb $9,%al; jbe 6f; addb $('A'-10),%al; jmp putc
6: addb $'0',%al; jmp putc
ap_blob_start:
 cli
 xorw %ax,%ax; movw %ax,%ds; movw %ax,%es; movw %ax,%ss; movw $0x6800,%sp
 movb $1,AP_READY
aploop:
 movb PHASE,%al
 cmpb $1,%al; je ap_bad
 cmpb $2,%al; je ap_good
 cmpb $3,%al; je ap_finish
 pause; jmp aploop
ap_bad:
 cmpb $0,BAD_LOCK
 jne aploop
 movb $1,BAD_AP_FREE
7: cmpb $1,BAD_GO; je ap_bad_store; pause; jmp 7b
ap_bad_store:
 movb $1,BAD_LOCK
 movb $1,BAD_AP_ENTER
 jmp aploop
ap_good:
 movb $1,%al
 xchgb %al,GOOD_LOCK
 testb %al,%al
 jnz ap_good_mark
 movb $1,GOOD_AP_ENTER
ap_good_mark:
 movb $1,GOOD_AP_ATTEMPT
8: cmpb $3,PHASE; je ap_finish; pause; jmp 8b
ap_finish:
 movb $1,AP_DONE
9: hlt; jmp 9b
ap_blob_end:
.section .rodata
lab_test:.asciz "TEST=C005_P02\n"
lab_cpu:.asciz "CPU_COUNT="
lab_ready:.asciz "AP_READY="
lab_bspfree:.asciz "BAD_BSP_SAW_FREE="
lab_apfree:.asciz "BAD_AP_SAW_FREE="
lab_badentered:.asciz "BAD_ENTERED="
lab_goodentered:.asciz "GOOD_ENTERED="
lab_apdone:.asciz "AP_DONE="
lab_fail:.asciz "C005_P02_FAIL\n"
lab_done:.asciz "DONE\n"
