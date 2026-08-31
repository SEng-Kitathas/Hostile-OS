ENTRY(_start)
SECTIONS
{
 . = 0x7c00;
 .payload : { *(.text*) *(.rodata*) *(.data*) }
 ASSERT(. <= 0x7dfe, "stage1 exceeds one boot sector")
 .sig 0x7dfe : { SHORT(0xaa55) }
}
