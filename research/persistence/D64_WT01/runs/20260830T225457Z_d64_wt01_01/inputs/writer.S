.code16
.section .text
.global _start
.global writer_int13_site
.global writer_after_int13
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
.equ WRITE_BUF,0x7000
.equ QUAL_STAGE1_BOOT_DRIVE_MEM,0x7c4b

_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7a00,%sp
 movb QUAL_STAGE1_BOOT_DRIVE_MEM,%al
 movb %al,boot_drive
 # zero full write sector
 movw $WRITE_BUF,%di
 xorw %ax,%ax
 movw $512,%cx
 rep stosb
 # copy exactly 30-byte FR01 B record
 movw $record_b,%si
 movw $WRITE_BUF,%di
 movw $30,%cx
 rep movsb
 movw $lab_ready,%si
 call print_string
 # BIOS write C0/H1/S1 = LBA18 (record B)
 xorw %ax,%ax
 movw %ax,%es
 movw $WRITE_BUF,%bx
 movb $0x03,%ah
 movb $0x01,%al
 movb $0x00,%ch
 movb $0x01,%cl
 movb $0x01,%dh
 movb boot_drive,%dl
writer_int13_site:
 int $0x13
 jc write_fail
writer_after_int13:
 movw $lab_return,%si
 call print_string
 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b
write_fail:
 movw $lab_fail,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x11,%al
 outb %al,%dx
2: hlt
 jmp 2b

print_string:
 pushw %ax
 pushw %dx
3: lodsb
 testb %al,%al
 jz 4f
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 jmp 3b
4: popw %dx
 popw %ax
 ret

.section .rodata
record_b:.byte 0x48,0x34,0x46,0x31,0x51,0x72,0x02,0x02,0x00,0x01,0x02,0x00,0x01,0x00,0x01,0x02,0x34,0x12,0x01,0x00,0x02,0x00,0x00,0x00,0x6c,0x36,0x43,0x4d,0x49,0x54
lab_ready:.asciz "WRITE_READY\n"
lab_return:.asciz "WRITE_RETURN\n"
lab_done:.asciz "DONE\n"
lab_fail:.asciz "WRITE_FAIL\n"

.section .bss
boot_drive:.byte 0
