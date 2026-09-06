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

 # AH=08 geometry
 movb boot_drive,%dl
 movb $0x08,%ah
 int $0x13
 jc ah08_fail
 movb $0,ah08_status
 jmp ah08_store
ah08_fail:
 movb $1,ah08_status
ah08_store:
 movw %ax,ah08_ax
 movw %bx,ah08_bx
 movw %cx,ah08_cx
 movw %dx,ah08_dx
 movw %es,ah08_es
 movw %di,ah08_di

 # AH=48 EDD params. Buffer starts with size 0x42.
 xorw %ax,%ax
 movw %ax,%es
 movw $edd_params,%di
 movw $0x0021,%cx
 rep stosw
 movw $0x0042,edd_params
 movw $edd_params,%si
 movb boot_drive,%dl
 movb $0x48,%ah
 int $0x13
 jc ah48_fail
 movb $0,ah48_status
 jmp build_result
ah48_fail:
 movb $1,ah48_status

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

 # metadata at fixed offsets
 movw $0x5010,%di
 movb boot_drive,%al
 stosb
 movb ah08_status,%al
 stosb
 movb ah48_status,%al
 stosb
 incw %di
 movw ah08_ax,%ax
 stosw
 movw ah08_bx,%ax
 stosw
 movw ah08_cx,%ax
 stosw
 movw ah08_dx,%ax
 stosw
 movw ah08_es,%ax
 stosw
 movw ah08_di,%ax
 stosw

 # raw EDD params at offset 0x40, 0x42 bytes
 movw $edd_params,%si
 movw $0x5040,%di
 movw $0x0042,%cx
copy_params:
 lodsb
 stosb
 loop copy_params

 # Persist result after introspection.
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

header: .asciz "H1READ9_PARAMS"
boot_drive: .byte 0
ah08_status: .byte 0xff
ah48_status: .byte 0xff
ah08_ax: .word 0
ah08_bx: .word 0
ah08_cx: .word 0
ah08_dx: .word 0
ah08_es: .word 0
ah08_di: .word 0
.balign 4
edd_params: .space 0x42
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
