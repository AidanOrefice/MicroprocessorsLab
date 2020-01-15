	#include p18f87k22.inc
	
	code
	org 0x0		;reset point
	
	goto	start
	
	org 0x200		    ; Main code starts here at address 0x100

start
	
	lfsr FSR0, 0x800
	bra test

loop	movff	0x06, POSTINC0
	incf 	0x06, W, ACCESS	    ;Incrementing value at data address 0x06
test	movwf	0x06, ACCESS	    ; Test for end of loop condition
	movlw 	0xFF		    ;Moving decimal value of 255 to working register
	cpfsgt 	0x06 , ACCESS	    ;Comparing if 0x06 is greater than 99. Stops when true
	bra loop
	goto 0x0
	
	
	end