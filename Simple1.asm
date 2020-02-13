	#include p18f87k22.inc

	extern  LCD_Setup, LCD_Write_Message, LCD_Write_Hex
	extern  LCD_Clear, LCD_Write_Line1, LCD_Write_Line2, LCD_Send_Byte_D
	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	extern  Keyboard_Setup, Keyboard_Read, Store_Decode
	;extern  steen_multi, eight_twenty_four_multi
	;extern  sixteen1, sixteen2, twenty_four
	;extern  twenty_four_result, thirty_two_result
	extern Hex_to_dec_converter, decimal_result
	
acs0	udata_acs   ; r            eserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data- in ACCESS

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    " D-TIME\n"	; message, plus carriage return
	constant    myTable_l=.8	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	clrf	TRISH
	goto	start
	
	; ******* Main programme ****************************************
start 	call	LCD_Write_Line1
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	;movlw	myTable_l-1	; output message to LCD (leave out "\n")
	;lfsr	FSR2, myArray
	;all	LCD_Write_Message
	
	;movlw	myTable_l	; output message to UART
	;lfsr	FSR2, myArray
	;call	UART_Transmit_Message
	
measure_loop
	call	ADC_Read
	call	Hex_to_dec_converter
	movf	decimal_result, W
	call	LCD_Write_Hex
	movf	decimal_result + 1,W
	call	LCD_Write_Hex
	goto	start		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	end
