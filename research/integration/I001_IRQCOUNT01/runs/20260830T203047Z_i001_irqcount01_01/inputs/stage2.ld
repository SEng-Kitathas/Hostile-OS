ENTRY(_start)
SECTIONS
{
 . = 0x8000;
 .payload : { *(.text*) *(.rodata*) *(.data*) *(.bss*) }
 ASSERT(. <= 0x9000, "IRQCOUNT01 stage2 exceeds eight-sector envelope")
}
