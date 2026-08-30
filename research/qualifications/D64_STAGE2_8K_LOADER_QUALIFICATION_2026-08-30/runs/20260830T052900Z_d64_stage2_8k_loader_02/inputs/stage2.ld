ENTRY(_start)
SECTIONS
{
 . = 0x8000;
 .payload : { *(.text*) *(.rodata*) *(.data*) }
 . = 0x9ff0;
 .tail : { *(.tail) }
 ASSERT(. <= 0xa000, "stage2 exceeds sixteen sectors")
}
