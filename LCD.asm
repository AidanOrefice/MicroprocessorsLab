#include p18f87k22.inc

;******** Script holding the routines for the LCD ******************************        
    
    global  LCD_Setup, LCD_Clear, LCD_Delay_Write, LCD_High_Limit, LCD_Low_Limit 
    extern Delay_Time, delay_ms,  delay_x4us, Keyboard_Read 
    
acs0    udata_acs   ; named variables in access ram
LCD_tmp	    res 1   ; reserve 1 byte for temporary use
LCD_counter res 1   ; reserve 1 byte for counting through nessage
counter	    res 1   ; reserve one byte for a counter variable
temp_delay  res 1
	    
	    
tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data- in ACCESS

acs_ovr	access_ovr
LCD_hex_tmp res 1   ; reserve 1 byte for variable LCD_hex_tmp	

    constant    LCD_E=5		; LCD enable bit
    constant    LCD_RS=4	; LCD register select bit
    
Delay_LCD	code
    
LCD_Setup
	clrf    LATB
	movlw   b'11000000'	    ; RB0:5 all outputs
	movwf	TRISB
	movlw   .40
	call	delay_ms	; wait 40ms for LCD to start up properly
	movlw	b'00110000'	; Function set 4-bit
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00101000'	; 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00101000'	; repeat, 2 line display 5x8 dot characters
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00001111'	; display on, cursor on, blinking on
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	movlw	b'00000001'	; display clear
	call	LCD_Send_Byte_I
	movlw	.2		; wait 2ms
	call	delay_ms
	movlw	b'00000110'	; entry mode incr by 1 no shift
	call	LCD_Send_Byte_I
	movlw	.10		; wait 40us
	call	delay_x4us
	
	return

LCD_Write_Hex			; Writes byte stored in W as hex
	movwf	LCD_hex_tmp
	swapf	LCD_hex_tmp,W	; high nibble first
	call	LCD_Hex_Nib
	movf	LCD_hex_tmp,W	; then low nibble

LCD_Hex_Nib			; writes low nibble as hex character
	andlw	0x0F
	movwf	LCD_tmp
	movlw	0x0A
	cpfslt	LCD_tmp
	addlw	0x07	; number is greater than 9 
	addlw	0x26
	addwf	LCD_tmp,W
	call	LCD_Send_Byte_D ; write out ascii
	return
	
LCD_Write_Message	    ; Message stored at FSR2, length stored in W
	movwf   LCD_counter ;length of data
LCD_Loop_message	    ;loops over counter
	movf    POSTINC2, W
	call    LCD_Send_Byte_D
	decfsz  LCD_counter
	bra	LCD_Loop_message
	return

LCD_Send_Byte_I		    ; Transmits byte stored in W to instruction reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bcf	LATB, LCD_RS	; Instruction write clear RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp,W   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bcf	LATB, LCD_RS    ; Instruction write clear RS bit
        call    LCD_Enable  ; Pulse enable Bit 
	return

LCD_Send_Byte_D		    ; Transmits byte stored in W to data reg
	movwf   LCD_tmp
	swapf   LCD_tmp,W   ; swap nibbles, high nibble goes first
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bsf	LATB, LCD_RS	; Data write set RS bit
	call    LCD_Enable  ; Pulse enable Bit 
	movf	LCD_tmp,W   ; swap nibbles, now do low nibble
	andlw   0x0f	    ; select just low nibble
	movwf   LATB	    ; output data bits to LCD
	bsf	LATB, LCD_RS    ; Data write set RS bit	    
        call    LCD_Enable  ; Pulse enable Bit 
	movlw	.10	    ; delay 40us
	call	delay_x4us
	return

LCD_Enable	    ; pulse enable bit LCD_E for 500ns
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bsf	    LATB, LCD_E	    ; Take enable high
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bcf	    LATB, LCD_E	    ; Writes data to LCD
	return

LCD_Clear	;Clears LCD screen.
	movlw b'00000001'
	call LCD_Send_Byte_I
	
myTableC     data  "D-TIME:\n"	    ;default delay time message.
	     constant myTable_C1  = .8
	call LCD_Write_Line1
	    
	movlw   .25 
	call    delay_ms   
	
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTableC)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTableC)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTableC)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_C1	; bytes to read
	movwf 	counter		; our counter register
loopC 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loopC		; keep going until finished
	
	movlw	myTable_C1 -1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	return
	
LCD_High_Limit		    ;Delay Time high limit message.
myTableHL     data  "ERROR: TOO HIGH\n"
	      constant myTable_HL1  = .16
	call LCD_Write_Line2
	    
	movlw   .25 
	call    delay_ms   
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTableHL)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTableHL)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTableHL)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_HL1	; bytes to read
	movwf 	counter		; our counter register
loopHL 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loopHL		; keep going until finished
	
	movlw	myTable_HL1 -1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	
	
	
	movlw .255	    ;Stays on for 1.5 seconds.
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	
	call LCD_Clear
	return
	
LCD_Low_Limit		;Default low limit error message.
myTableLL     data  "ERROR: TOO LOW\n"
	      constant myTable_LL1  = .15
	call LCD_Write_Line2
	    
	movlw   .25 
	call    delay_ms   
	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTableLL)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTableLL)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTableLL)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_LL1	; bytes to read
	movwf 	counter		; our counter register
loopLL 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loopLL		; keep going until finished
	
	movlw	myTable_LL1 -1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message
	
	movlw .255		;Stays on for 1.5 seconds.
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	movlw .255
	call delay_ms
	
	
	call LCD_Clear
	return
	
		
LCD_Write_Line1			;Start writing to top line of LCD.    
	movlw b'10000000'	    ;Address is 1000.... for top line
	call LCD_Send_Byte_I	    
	return	
	
LCD_Write_Line2			;Start writing to bottom line of LCD.
	movlw b'11000000'	    ;Address is 1100.... for bottom line
	call LCD_Send_Byte_I
	return

LCD_Delay_Write			;Writing delay time to LCD.
	movff	Delay_Time, temp_delay	    ;Storing two bytes to one byte.
	swapf	temp_delay		    ;Both upper nibbles are 0 so trivial.
	movf	Delay_Time + 1, W
	addwf	temp_delay
	
	
	movlw b'10001000'	    ;Hard setting to specific LCD address. 
	call LCD_Send_Byte_I
	    
	movlw   .25 
	call    delay_ms  
	
	movf temp_delay, W
	call LCD_Write_Hex
	
	movff	Delay_Time + 2, temp_delay  ;2 bytes to one byte again.
	swapf	temp_delay
	movf	Delay_Time + 3, W
	addwf	temp_delay
	
	
	movlw b'10001010'	    ;Hard setting to specific LCD address. 
	call LCD_Send_Byte_I
		   
	movlw   .25 
	call    delay_ms  
	
	movf temp_delay, W
	call LCD_Write_Hex
	return

    end


