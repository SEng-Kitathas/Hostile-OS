.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ LAPIC_ICR_LOW,0xfee00300
.equ LAPIC_ICR_HIGH,0xfee00310
.equ AP_TRAMP,0x9000
.equ AP_VECTOR,0x09
.equ AP_READY,0x6000
.equ PHASE,0x6001
.equ BAD_A,0x6002
.equ BAD_B,0x6003
.equ BAD_MIXED,0x6004
.equ BAD_FINAL,0x6005
.equ XLOCK,0x6006
.equ GOOD_A,0x6007
.equ GOOD_B,0x6008
.equ GOOD_MIXED,0x6009
.equ GOOD_FINAL,0x600a
.equ AP_DONE,0x600b
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7a00,%sp
 cld
 # Clear shared fixture bytes.
 movw $AP_READY,%di
 movw $12,%cx
 xorw %ax,%ax
 rep stosb
 # Copy AP real-mode trampoline to SIPI vector 0x9000.
 movw $ap_blob_start,%si
 movw $AP_TRAMP,%di
 movw $(ap_blob_end-ap_blob_start),%cx
 rep movsb
 movw $lab_test,%si
 call puts
 # Target APIC ID1 in ICR high.
 movl $0x01000000,%eax
 movl $LAPIC_ICR_HIGH,%edi
 movl %eax,(%edi)
 # INIT assert then deassert.
 movl $0x0000c500,%eax
 movl $LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call icr_wait
 call delay_long
 movl $0x00008500,%eax
 movl $LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call icr_wait
 call delay_short
 # SIPI twice, vector09 -> physical0x9000.
 movl $(0x00000600+AP_VECTOR),%eax
 movl $LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call icr_wait
 call delay_short
 movl $(0x00000600+AP_VECTOR),%eax
 movl $LAPIC_ICR_LOW,%edi
 movl %eax,(%edi)
 call icr_wait
 # Wait AP ready with bounded counter; fail trace if absent.
 movl $0x04000000,%ecx
wait_ap:
 cmpb $1,AP_READY
 je ap_started
 decl %ecx
 jnz wait_ap
 movw $lab_ap_fail,%si
 call puts
 jmp exit_fail
ap_started:
 movw $lab_cpu_count,%si
 call puts
 movb $2,%al
 call hex8
 call nl
 movw $lab_ap_ready,%si
 call puts
 movb AP_READY,%al
 call bit
 call nl
 # BAD: local CLI only. AP remains free to observe.
 movb $0x11,BAD_A
 movb $0x22,BAD_B
 movb $1,PHASE
 cli
 movb $0x33,BAD_A
 movl $0x00800000,%ecx
bad_window:
 pause
 decl %ecx
 jnz bad_window
 movb $0x44,BAD_B
 sti
 # Wait AP confirms final state, bounded.
 movl $0x04000000,%ecx
wait_bad_final:
 cmpb $1,BAD_FINAL
 je bad_done
 decl %ecx
 jnz wait_bad_final
 jmp exit_fail
bad_done:
 movw $lab_bad_mixed,%si
 call puts
 movb BAD_MIXED,%al
 call bit
 call nl
 movw $lab_bad_final,%si
 call puts
 movb BAD_FINAL,%al
 call bit
 call nl
 # GOOD: shared atomic exclusion, same coupled values/window.
 movb $0x11,GOOD_A
 movb $0x22,GOOD_B
 movb $0,XLOCK
 movb $2,PHASE
 call lock_acquire
 cli
 movb $0x33,GOOD_A
 movl $0x00800000,%ecx
good_window:
 pause
 decl %ecx
 jnz good_window
 movb $0x44,GOOD_B
 sti
 call lock_release
 movl $0x04000000,%ecx
wait_good_final:
 cmpb $1,GOOD_FINAL
 je good_done
 decl %ecx
 jnz wait_good_final
 jmp exit_fail
good_done:
 movb $3,PHASE
 movl $0x04000000,%ecx
wait_ap_done:
 cmpb $1,AP_DONE
 je report_good
 decl %ecx
 jnz wait_ap_done
 jmp exit_fail
report_good:
 movw $lab_good_mixed,%si
 call puts
 movb GOOD_MIXED,%al
 call bit
 call nl
 movw $lab_good_final,%si
 call puts
 movb GOOD_FINAL,%al
 call bit
 call nl
 movw $lab_ap_done,%si
 call puts
 movb AP_DONE,%al
 call bit
 call nl
 movw $lab_done,%si
 call puts
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
exit_fail:
 movw $lab_fail,%si
 call puts
 movw $EXIT_PORT,%dx
 movb $0x12,%al
 outb %al,%dx
2: hlt
 jmp 2b
# Poll APIC ICR delivery-status bit12 clear.
icr_wait:
 movl $LAPIC_ICR_LOW,%edi
 movl (%edi),%eax
 testl $0x1000,%eax
 jnz icr_wait
 ret
delay_short:
 movl $0x00040000,%ecx
3: pause
 decl %ecx
 jnz 3b
 ret
delay_long:
 movl $0x00400000,%ecx
4: pause
 decl %ecx
 jnz 4b
 ret
lock_acquire:
 movb $1,%al
5: xchgb %al,XLOCK
 testb %al,%al
 jz 6f
 pause
 movb $1,%al
 jmp 5b
6: ret
lock_release:
 movb $0,XLOCK
 ret
puts:
 lodsb
 testb %al,%al
 jz 7f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp puts
7: ret
bit:
 andb $1,%al
 addb $'0',%al
 jmp putc
putc:
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 ret
nl:
 pushw %ax
 movb $'\n',%al
 call putc
 popw %ax
 ret
hex8:
 pushw %ax
 movb %al,%ah
 shrb $4,%al
 call nib
 movb %ah,%al
 andb $15,%al
 call nib
 popw %ax
 ret
nib:
 cmpb $9,%al
 jbe 8f
 addb $('A'-10),%al
 jmp putc
8: addb $'0',%al
 jmp putc
# AP starts real mode here at CS=0x900, IP=0. DS=0 for shared physical addresses.
ap_blob_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x6800,%sp
 movb $1,AP_READY
ap_phase_loop:
 movb PHASE,%al
 cmpb $1,%al
 je ap_bad
 cmpb $2,%al
 je ap_good
 cmpb $3,%al
 je ap_finish
 pause
 jmp ap_phase_loop
ap_bad:
 movb BAD_A,%al
 movb BAD_B,%bl
 cmpb $0x33,%al
 jne ap_bad_final_check
 cmpb $0x22,%bl
 jne ap_bad_final_check
 movb $1,BAD_MIXED
ap_bad_final_check:
 cmpb $0x33,%al
 jne ap_phase_loop
 cmpb $0x44,%bl
 jne ap_phase_loop
 movb $1,BAD_FINAL
 jmp ap_phase_loop
ap_good:
 # acquire same exclusion byte with atomic xchg
 movb $1,%al
ap_good_lock:
 xchgb %al,XLOCK
 testb %al,%al
 jz ap_good_have
 pause
 movb $1,%al
 jmp ap_good_lock
ap_good_have:
 movb GOOD_A,%al
 movb GOOD_B,%bl
 cmpb $0x33,%al
 jne ap_good_final_check
 cmpb $0x22,%bl
 jne ap_good_final_check
 movb $1,GOOD_MIXED
ap_good_final_check:
 cmpb $0x33,%al
 jne ap_good_release
 cmpb $0x44,%bl
 jne ap_good_release
 movb $1,GOOD_FINAL
ap_good_release:
 movb $0,XLOCK
 jmp ap_phase_loop
ap_finish:
 movb $1,AP_DONE
9: hlt
 jmp 9b
ap_blob_end:
.section .rodata
lab_test:.asciz "TEST=C005_P01\n"
lab_cpu_count:.asciz "CPU_COUNT="
lab_ap_ready:.asciz "AP_READY="
lab_bad_mixed:.asciz "BAD_MIXED="
lab_bad_final:.asciz "BAD_FINAL="
lab_good_mixed:.asciz "GOOD_MIXED="
lab_good_final:.asciz "GOOD_FINAL="
lab_ap_done:.asciz "AP_DONE="
lab_ap_fail:.asciz "AP_START_FAIL\n"
lab_fail:.asciz "C005_P01_FAIL\n"
lab_done:.asciz "DONE\n"
