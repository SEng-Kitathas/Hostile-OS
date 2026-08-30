ENTRY(_start)
SECTIONS
{
 . = 0x8000;
 .payload : { *(.text*) *(.rodata*) *(.data*) *(.bss*) }
 ASSERT(. <= 0xa000, "D64 RR01 stage2 exceeds sixteen-sector envelope")
}
