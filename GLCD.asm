#include p18f87k22.inc

    extern LCD_delay_ms
		
acs0    udata_acs   ; named variables in access ram	
GLCD_tmp	    res 1   ; reserve 1 byte for temporary use

		constant GLCD_RS = 6
		constant GLCD_RW = 7
		constant GLCD_E = 8

		
GLCD	code
	
GLCD_setup
	clrf    LATD
	movlw   b'00000000'	    ; RB0:5 all outputs
	movwf	TRISD
	movlw   .40
	call	LCD_delay_ms	; wait 40ms for LCD to start up properly
	movlw	b'00111111'
	call	GLCD_Send_Byte_I
	
GLCD_Send_Byte_I		    ; Transmits byte stored in W to instruction reg
	movwf   GLCD_tmp
	swapf   GLCD_tmp,W   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATD	    ; output data bits to LCD
	bcf	LATD, GLCD_RW	;MPU to Module- set low
	bcf	LATD, GLCD_RS	; Instruction write clear RS bit
	call    GLCD_Enable  ; Pulse enable Bit 
	movf	GLCD_tmp,W   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATD	    ; output data bits to LCD
	bcf	LATD, GLCD_RW	;MPU to Module- set low
	bcf	LATD, GLCD_RS    ; Instruction write clear RS bit
        call    GLCD_Enable  ; Pulse enable Bit 
	return

GLCD_Enable ;pulse enble bit for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	    LATD, GLCD_E	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	    LATD, GLCD_E	    ; Writes data to LCD
	return

	end