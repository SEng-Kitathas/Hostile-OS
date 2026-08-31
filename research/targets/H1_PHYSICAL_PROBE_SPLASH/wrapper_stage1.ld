OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)
SECTIONS {
  . = 0x7c00;
  .text : { *(.text*) }
  .data : { *(.data*) *(.rodata*) }
  . = 0x7c00 + 510;
  .sig : { BYTE(0x55); BYTE(0xaa); }
}
ASSERT(SIZEOF(.text) + SIZEOF(.data) <= 510, "wrapper stage1 too large")
