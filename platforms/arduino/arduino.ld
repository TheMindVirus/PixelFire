MEMORY
{
	flash : ORIGIN = 0x0000000000000000, LENGTH = 0x0000000010000000
}
SECTIONS
{
	.text : { *(.text*) } > flash
	.rodata : { *(.rodata*) } > flash
	.bss : { *(.bss*) } > flash
	__bss_start = . ;
	__bss_end = . ;
	__data_start = . ;
	__data_load_start = . ;
	__data_end = . ;
	__heap_start = . ;
	__heap_end = . ;
}
