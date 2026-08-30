ENTRY(_start)
SECTIONS
{
  . = 0x7c00;
  .payload : { *(.text*) *(.fixture*) *(.rodata*) *(.data*) }
  ASSERT(. <= 0x7dfe, "P13 probe exceeds one boot sector")
  .sig 0x7dfe : { SHORT(0xaa55) }
}
