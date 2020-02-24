	#include p18f87k22.inc

	extern	DAC_Setup, time_set, reset_values
	
rst	code	0x0000	; reset vector
	goto	start

main	code
start	call	DAC_Setup
loop	btfss	time_set, 0
	goto	loop
	incf	PORTD
	
	call	reset_values
	bcf	time_set, 0

	end
