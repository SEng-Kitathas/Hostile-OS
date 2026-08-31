OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)
SECTIONS {
  . = 0x8000;
  __image_start = .;
  .text : { *(.text*) }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  .bss : { *(.bss*) *(COMMON) }
  __image_end = .;
}
ASSERT((__image_end - __image_start) <= 8192, "H1 probe exceeds 8 KiB stage2 envelope")
