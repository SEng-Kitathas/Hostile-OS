OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)
SECTIONS {
  . = 0x6000;
  __image_start = .;
  .text : { *(.text*) }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  .bss : { *(.bss*) *(COMMON) }
  __image_end = .;
}
ASSERT((__image_end - __image_start) <= 4096, "text wrapper exceeds 4 KiB loader envelope")
