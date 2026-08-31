OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)
SECTIONS {
  . = 0x6000;
  __loader_start = .;
  .text : { *(.text*) }
  .rodata : { *(.rodata*) }
  .data : { *(.data*) }
  .bss : { *(.bss*) *(COMMON) }
  __loader_end = .;
}
ASSERT((__loader_end - __loader_start) <= 4096, "splash loader exceeds reserved 4 KiB envelope")
