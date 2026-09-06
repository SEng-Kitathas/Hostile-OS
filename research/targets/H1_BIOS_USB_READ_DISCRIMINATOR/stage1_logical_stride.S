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

 xorw %ax,%ax
 movw %ax,%es
 movw $0x7e00,%di
 movw $256,%cx
 rep stosw

 movw $0x7e00,%bx
 movb boot_drive,%dl
 movb $0x02,%ah
 movb $0x01,%al
 movb $0x00,%ch
 movb $0x02,%cl
 movb $0x00,%dh
 int $0x13
 jc read_fail
 movb $0,read_status
 jmp build_result
read_fail:
 movb $1,read_status

build_result:
 xorw %ax,%ax
 movw %ax,%es
 movw $0x5000,%di
 movw $256,%cx
 rep stosw
 movw $header,%si
 movw $0x5000,%di
copy_hdr:
 lodsb
 stosb
 testb %al,%al
 jnz copy_hdr
 movw $0x5010,%di
 movb read_status,%al
 stosb
 movw $0x7e00,%si
 movw $0x5020,%di
 movw $128,%cx
copy_raw:
 lodsb
 stosb
 loop copy_raw

 movb boot_drive,%dl
 movw $0x55aa,%bx
 movb $0x41,%ah
 int $0x13
 jc halt
 cmpw $0xaa55,%bx
 jne halt
 testw $1,%cx
 jz halt
 movw $write_dap,%si
 movb boot_drive,%dl
 movb $0x43,%ah
 xorb %al,%al
 int $0x13
halt:
 cli
 hlt
 jmp halt

header: .asciz "H1READ8_STRIDE"
read_status: .byte 0xff
boot_drive: .byte 0
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
