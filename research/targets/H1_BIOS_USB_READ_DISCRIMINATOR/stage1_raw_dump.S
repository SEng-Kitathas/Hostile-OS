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

 # Zero destination buffer before AH=42.
 xorw %ax,%ax
 movw %ax,%es
 movw $0x6000,%di
 movw $256,%cx
 rep stosw

 movw $read_dap,%si
 movb boot_drive,%dl
 movb $0x42,%ah
 int $0x13
 jc read_fail
 movb $0,read_status
 jmp build_result
read_fail:
 movb $1,read_status

build_result:
 # Build forensic result sector at 0000:5000.
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
 # fixed metadata at offset 16
 movw $0x5010,%di
 movb read_status,%al
 stosb
 movw read_dap+2,%ax
 stosw
 # copy first 128 returned bytes at offset 32
 movw $0x6000,%si
 movw $0x5020,%di
 movw $128,%cx
copy_raw:
 lodsb
 stosb
 loop copy_raw

 # Persist result only after read.
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

header: .asciz "H1READ4_RAW"
read_status: .byte 0xff
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
