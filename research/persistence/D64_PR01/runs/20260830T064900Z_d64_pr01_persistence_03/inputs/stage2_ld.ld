ENTRY(_start)
SECTIONS
{
 . = 0x8000;
 .text : { *(.text*) }
 .rodata : { *(.rodata*) }
 .data : { *(.data*) }
 .bss : { *(.bss*) *(COMMON) }
 ASSERT(. <= 0xa000, "D64 PR01 stage2 exceeds 8 KiB envelope")
}
