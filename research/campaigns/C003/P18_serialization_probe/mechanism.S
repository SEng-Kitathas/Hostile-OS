.code16
.section .text
.global _start
.extern logical_word_fact
.equ DEBUG_PORT,0x00e9
.equ EXIT_PORT,0x00f4
_start:
 cli
 xorw %ax,%ax
 movw %ax,%ds
 movw %ax,%es
 movw %ax,%ss
 movw $0x7b00,%sp
 call encode_le
 call decode_le
 call decode_swapped
 movw $lab_enc0,%si
 call print_string
 movb encoded_bytes,%al
 call print_hex_byte
 call newline
 movw $lab_enc1,%si
 call print_string
 movb encoded_bytes+1,%al
 call print_hex_byte
 call newline
 movw $lab_good,%si
 call print_string
 movw decoded_good,%ax
 call print_hex_word
 call newline
 movw $lab_bad,%si
 call print_string
 movw decoded_bad,%ax
 call print_hex_word
 call newline
 movw $lab_done,%si
 call print_string
 movw $EXIT_PORT,%dx
 movb $0x10,%al
 outb %al,%dx
1: hlt
 jmp 1b

encode_le:
 movw logical_word_fact,%ax
 movb %al,encoded_bytes
 movb %ah,encoded_bytes+1
 ret
decode_le:
 movb encoded_bytes,%al
 movb encoded_bytes+1,%ah
 movw %ax,decoded_good
 ret
decode_swapped:
 movb encoded_bytes,%ah
 movb encoded_bytes+1,%al
 movw %ax,decoded_bad
 ret

print_hex_word:
 pushw %bx
 movw %ax,%bx
 movb %bh,%al
 call print_hex_byte
 movb %bl,%al
 call print_hex_byte
 popw %bx
 ret
print_hex_byte:
 pushw %bx
 movb %al,%bl
 shrb $4,%al
 call print_hex_nibble
 movb %bl,%al
 andb $0x0f,%al
 call print_hex_nibble
 popw %bx
 ret
print_hex_nibble:
 cmpb $9,%al
 jbe 2f
 addb $55,%al
 jmp print_char
2: addb $48,%al
 jmp print_char
newline:
 movb $'\n',%al
 jmp print_char
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
print_char:
 pushw %dx
 movw $DEBUG_PORT,%dx
 outb %al,%dx
 popw %dx
 ret
lab_enc0:.asciz "ENC0="
lab_enc1:.asciz "ENC1="
lab_good:.asciz "GOOD="
lab_bad:.asciz "BAD="
lab_done:.asciz "DONE\n"
.section .data
encoded_bytes:.byte 0,0
decoded_good:.word 0
decoded_bad:.word 0
