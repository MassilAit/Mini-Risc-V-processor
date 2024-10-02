/******************************************************************************
 * Project  ELE8304 : Circuits intégrés à très grande échelle
 ******************************************************************************
 * File     riscv.ld
 * Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
 * Lab      GRM - Polytechnique Montreal
 * Date     <2019-08-15 Thu>
 ******************************************************************************
 * Brief    Linker script pour le mini-riscv
 ******************************************************************************/

OUTPUT_ARCH( "riscv" )

MEMORY
{
    IMEM  : ORIGIN = 0,  LENGTH = 1K
    DMEM  : ORIGIN = 1K, LENGTH = 1K
}

   _HEAP  = ORIGIN(DMEM) - 4;
   _STACK = ORIGIN(DMEM) + LENGTH(DMEM) - 4;

ENTRY(start)

SECTIONS
{
    . = ORIGIN(IMEM);
    .text ALIGN(4):
    {
        *(.text .text*)
    } > IMEM

    . = ORIGIN(DMEM);
    .data ALIGN(4):
    {
        *(.data .data*)
    } > DMEM
}
