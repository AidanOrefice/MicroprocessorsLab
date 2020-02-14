#include p18f87k22.inc		;Use PORTJ for the keyboard
    
    global Keyboard_Setup, Keyboard_Read, Store_Decode, Delay_Time, Keyboard_Initial
    extern LCD_Clear
    extern LCD_Delay_Write
    
acs0    udata_acs	; named variables in access ram
cnt_l   res 1		; reserve 1 byte for variable cnt_l
cnt_h   res 1		; reserve 1 byte for variable cnt_h
cnt_ms   res 1		; reserve 1 byte for variable cnt_ms
Row_Read res 1		; reserve 1 byte for Row value
Col_Read res 1		; reserve 1 byte for Column value
Full_Read res 1		; reserve 1 byte for the total value
 
Store_Decode res 1
Decode_Value res 1
 
Delay_Time res 4
temp_decode res 1
temp_counter res 1


 
Delay_Keyboard    code
    
Keyboard_Setup
    setf    TRISE			    ;rotuine to set PORTJ to tri-state
    banksel PADCFG1    
    bsf	    PADCFG1, REPU, BANKED
    movlb   0x00			    
    clrf    LATE
    movlw   0x0F			    ; Sets J4-7 to output/J0-3 to input
    movwf   TRISE
    movlw   .125			    ; Delay time/4
    call    delay_x4us		    ; Delay of 0.5ms
    return
    
Keyboard_Initial
    movlw   0xEE		    ;initial value- helps to check if store decode has changed
    ;movwf   temp_decode
    movwf   Store_Decode
    
    movlw .4			    ;So we can write to 4byte Decide Value
    movwf temp_counter
    
    lfsr    FSR0, Delay_Time	    ;loads FSR to point to Delay_Time varibale
    return
    
Keyboard_Read			    ;originally set to read rows- unsure of column- diagram given in slides.
    call    Keyboard_Setup
    movff   PORTE, Row_Read	    
    movlw   0xF0
    movwf   TRISE
    movlw   .125
    call    delay_x4us		    ;Delay of 0.5ms
    movff   PORTE, Col_Read
    movlw   .05
    call    delay_ms
    movf    Row_Read, W
    addwf   Col_Read, W
    movwf   Full_Read		    ;storing to one value
    movlw   .05
    call    delay_ms
    call    Keyboard_Decode
    movlw   .05
    call    delay_ms
    
    call    Keyboard_Write ; To conplete loop.
    
    call    LCD_Delay_Write
   
    call    Wait_loop
    return
    
Wait_loop    
    btfss   PORTJ, 7
    return
    goto Wait_loop
    
    
    return
				;Check_1_row: Check rows of column 1
Keyboard_Decode			; subroutine to decode by column first - remember the keyboard follows anti-logic
	btfss	Full_Read, 7	; if column one is not set we skip. amd vice versa 
	call	Check_1_Row	; determine the value pressed in column one (1 4 7 A)
	btfss	Full_Read, 6
	call	Check_2_Row	; determine the value pressed in column two (2 5 8 0)
	btfss	Full_Read, 5
	call	Check_3_Row	; determine the value pressed in column three (3 6 9 B)
	btfss	Full_Read, 4
	call	Check_4_Row	; determine the value pressed in column four (F E D C)
	return

Check_1_Row
	btfss	Full_Read, 3	
	movlw	0x01		; numbers 0 to 9 inclusive will be the input values for the delay time
	btfss	Full_Read, 2
	movlw	0x04
	btfss	Full_Read, 1
	movlw	0x07
	btfss	Full_Read, 0	; A currently has no function in our system
	movlw	0xFF		   
	movwf	Decode_Value
	return
	
Check_2_Row
	btfss	Full_Read, 3
	movlw	0x02
	btfss	Full_Read, 2
	movlw	0x05
	btfss	Full_Read, 1
	movlw	0x08
	btfss	Full_Read, 0
	movlw	0x00
	movwf	Decode_Value
	return
	
Check_3_Row
	btfss	Full_Read, 3
	movlw	0x03
	btfss	Full_Read, 2
	movlw	0x06
	btfss	Full_Read, 1
	movlw	0x09
	btfss	Full_Read, 0
	movlw	0xFF		    ; B currently has no function in our system
	movwf	Decode_Value
	return
	
Check_4_Row
	btfss	Full_Read, 3
	movlw	0xFF		    ; F currently has no function in our system
	btfss	Full_Read, 2
	movlw	0xFF		    ; E currently has no function in our system- become the enter button
	btfss	Full_Read, 1
	movlw	0xFF
	btfss	Full_Read, 0
	goto	Keyboard_Clear	    	    ; C will clear the input value - go to C subroutine to clear adresses in the LCD, i.e. clears the delay time 
	movwf	Decode_Value
	return

Keyboard_Write		    ;Lost loop to write to successive DDRAM addresses - initialise address- send data, increment address
	movff Store_Decode, temp_decode
	
	movlw	.255		;stops no input
	cpfslt	Full_Read
	goto	Keyboard_Read
	cpfslt	Decode_Value	;stops invalid answer
	goto	Keyboard_Read
	movff	Decode_Value, Store_Decode
	
	movf	Store_Decode, W		;store_decode- wont ever be greater than ee. 
	subwf	temp_decode		;thus subtraction will give 0 or higher
	movlw	0x00			;Stops repeated answers
	cpfsgt	temp_decode		    
	goto	Keyboard_Read
	

	

	movff Store_Decode, POSTINC0
	
	dcfsnz temp_counter
	return
	goto Keyboard_Read
	
Keyboard_Clear
	call Keyboard_Initial
	call LCD_Clear
	goto Keyboard_Read
	
delay_ms			; delay given in ms in W
	movwf	cnt_ms
	call DL2
	return
DL2	movlw	.250		; 1 ms delay
	call	delay_x4us	
	decfsz	cnt_ms
	bra	DL2
	return
    
delay_x4us			; delay given in chunks of 4 microsecond in W
	movwf	cnt_l		; now need to multiply by 16
	swapf   cnt_l,F		; swap nibbles
	movlw	0x0f	   
	andwf	cnt_l,W		; move low nibble to W
	movwf	cnt_h		; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	cnt_l,F		; keep high nibble in cnt_l
	call	delay
	return    
      
delay				; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
	call DL1
	return
DL1	decf 	cnt_l,F		; no carry when 0x00 -> 0xff
	subwfb 	cnt_h,F		; no carry when 0x00 -> 0xff
	bc 	DL1		; carry, then loop again
	return			; carry reset so return


    end
