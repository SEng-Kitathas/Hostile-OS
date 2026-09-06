.code16
.section .text
.global _start
.equ TRACE_LBA,257
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp
 movb %dl,boot_drive
 sti

 # No disk write before this read.
 movw $read_dap,%si
 movb boot_drive,%dl
 movb $0x42,%ah
 int $0x13
 jc read_fail

 movw $0x6000,%si
 movw $expected,%di
 movw $8,%cx
cmp_loop:
 movb (%si),%al
 cmpb (%di),%al
 jne mismatch
 incw %si
 incw %di
 loop cmp_loop
 movw $msg_match,%si
 call trace_write
 jmp halt
read_fail:
 movw $msg_fail,%si
 call trace_write
 jmp halt
mismatch:
 movw $msg_mismatch,%si
 call trace_write
halt:
 cli
 hlt
 jmp halt

trace_write:
 pushw %ax
 pushw %bx
 pushw %cx
 pushw %dx
 pushw %si
 pushw %di
 pushw %es
 xorw %ax,%ax
 movw %ax,%es
 movw $0x5000,%di
 movw $256,%cx
 rep stosw
 popw %es
 pushw %es
 xorw %ax,%ax
 movw %ax,%es
 movw $0x5000,%di
copyz:
 lodsb
 stosb
 testb %al,%al
 jnz copyz
 movb boot_drive,%dl
 movw $0x55aa,%bx
 movb $0x41,%ah
 int $0x13
 jc tw_done
 cmpw $0xaa55,%bx
 jne tw_done
 testw $1,%cx
 jz tw_done
 movw $write_dap,%si
 movb boot_drive,%dl
 movb $0x43,%ah
 xorb %al,%al
 int $0x13
tw_done:
 popw %es
 popw %di
 popw %si
 popw %dx
 popw %cx
 popw %bx
 popw %ax
 ret

expected: .byte 0xfa,0x31,0xc0,0x8e,0xd8,0x8e,0xc0,0x8e
msg_match: .asciz "H1READ3_LBA1_MATCH\r\n"
msg_fail: .asciz "H1READ3_AH42_FAIL\r\n"
msg_mismatch: .asciz "H1READ3_DATA_MISMATCH\r\n"
boot_drive: .byte 0
.balign 4
read_dap:
 .byte 0x10,0x00
 .word 0x0001
 .word 0x6000
 .word 0x0000
 .long 1
 .long 0
.balign 4
write_dap:
 .byte 0x10,0x00
 .word 0x0001
 .word 0x5000
 .word 0x0000
 .long TRACE_LBA
 .long 0
.org 510
.word 0xaa55
