ENTRY(_start)
SECTIONS
{
 . = 0x8000;
 .text : { *(.text*) }
 .rodata : { *(.rodata*) }
 .data : { *(.data*) }
 .bss : { *(.bss*) *(COMMON) }
 ASSERT(. <= 0xa000, "WT01 writer exceeds 8 KiB envelope")
}
