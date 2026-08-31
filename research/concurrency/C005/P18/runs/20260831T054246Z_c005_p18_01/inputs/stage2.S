.code16
.section .text
.global _start
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ BOOT_DRIVE_MEM,0x7bf0
.equ BUF,0x7000
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7a00,%sp
 movw $lab_test,%si
 call puts
 # Read durable record at CHS C0/H0/S18 (LBA17).
 movw $BUF,%bx
 movb $0x02,%ah
 movb $1,%al
 movb $0,%ch
 movb $18,%cl
 movb $0,%dh
 movb BOOT_DRIVE_MEM,%dl
 int $0x13
 jc io_fail
 cmpw $0x3548,BUF
 jne bootstrap
 cmpw $0x3143,BUF+2
 jne bootstrap
 jmp recover
bootstrap:
 xorw %ax,%ax
 movw $BUF,%di
 movw $256,%cx
 rep stosw
 movw $0x3548,BUF
 movw $0x3143,BUF+2
 # bytes4..8: value7E, resource_gen05, held1, users1, concurrency_epoch1
 movb $0x7e,BUF+4
 movb $0x05,BUF+5
 movb $1,BUF+6
 movb $1,BUF+7
 movb $1,BUF+8
 movw $BUF,%bx
 movb $0x03,%ah
 movb $1,%al
 movb $0,%ch
 movb $18,%cl
 movb $0,%dh
 movb BOOT_DRIVE_MEM,%dl
 int $0x13
 jc io_fail
 movw $lab_write,%si
 call puts
 movw $lab_write_a,%si
 call puts
 jmp done
recover:
 movw $lab_recover,%si
 call puts
 # Bad reconstruction: durable runtime bits are treated as live.
 movw $lab_badheld,%si
 call puts
 movb BUF+6,%al
 call bit
 call nl
 movw $lab_badusers,%si
 call puts
 movb BUF+7,%al
 call hex8
 call nl
 movb $0,%bl
 cmpb $0,BUF+6
 jne bad_no_acquire
 movb $1,%bl
bad_no_acquire:
 movw $lab_badacq,%si
 call puts
 movb %bl,%al
 call bit
 call nl
 movb $0,%bl
 cmpb $0,BUF+7
 je bad_no_phantom
 movb $1,%bl
bad_no_phantom:
 movw $lab_badphantom,%si
 call puts
 movb %bl,%al
 call bit
 call nl
 # Good reconstruction: durable meaning survives; transient concurrency resets fresh.
 movb $0,runtime_held
 movb $0,runtime_users
 movb BUF+8,%al
 incb %al
 movb %al,runtime_epoch
 movb BUF+4,%al
 movb %al,runtime_value
 movw $lab_goodheld,%si
 call puts
 movb runtime_held,%al
 call bit
 call nl
 movw $lab_goodusers,%si
 call puts
 movb runtime_users,%al
 call hex8
 call nl
 movw $lab_goodepoch,%si
 call puts
 movb runtime_epoch,%al
 call hex8
 call nl
 movb $1,%al
 xchgb %al,runtime_held
 movb $0,%bl
 testb %al,%al
 jnz good_acq_report
 movb $1,%bl
good_acq_report:
 movw $lab_goodacq,%si
 call puts
 movb %bl,%al
 call bit
 call nl
 movw $lab_goodval,%si
 call puts
 movb runtime_value,%al
 call hex8
 call nl
done:
 movw $lab_done,%si
 call puts
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
io_fail:
 movw $lab_iofail,%si
 call puts
 movw $EXIT_PORT,%dx
 movb $0x12,%al
 outb %al,%dx
2: hlt
 jmp 2b
puts:
 lodsb
 testb %al,%al
 jz 3f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp puts
3: ret
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
 jbe 4f
 addb $('A'-10),%al
 jmp putc
4: addb $'0',%al
 jmp putc
.section .data
runtime_held:.byte 0
runtime_users:.byte 0
runtime_epoch:.byte 0
runtime_value:.byte 0
.section .rodata
lab_test:.asciz "TEST=C005_P18\n"
lab_write:.asciz "PHASE=WRITE\n"
lab_write_a:.asciz "WRITE=A\n"
lab_recover:.asciz "PHASE=RECOVER\n"
lab_badheld:.asciz "BAD_HELD="
lab_badusers:.asciz "BAD_USERS="
lab_badacq:.asciz "BAD_FRESH_ACQUIRE="
lab_badphantom:.asciz "BAD_PHANTOM_USER="
lab_goodheld:.asciz "GOOD_HELD="
lab_goodusers:.asciz "GOOD_USERS="
lab_goodepoch:.asciz "GOOD_EPOCH="
lab_goodacq:.asciz "GOOD_FRESH_ACQUIRE="
lab_goodval:.asciz "GOOD_VALUE="
lab_done:.asciz "DONE\n"
lab_iofail:.asciz "IO_FAIL\n"
