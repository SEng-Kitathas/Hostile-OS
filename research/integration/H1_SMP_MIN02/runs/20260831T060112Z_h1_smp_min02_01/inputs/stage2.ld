ENTRY(_start)
SECTIONS
{
  . = 0x8000;
  __image_start = .;
  .text : { *(.text*) }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  __state_begin = .;
  .bss : { *(.bss*) *(COMMON) }
  __state_end = .;
  __image_end = .;
  ASSERT(. <= 0xa000, "D64 reference v2 exceeds qualified 8 KiB stage2 envelope")
}
