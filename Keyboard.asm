#include p18f87k22.inc		;Use PORTE for the keyboard

;************* Script to holding 4x4 Keypad routines **************************  
    
    global Keyboard_Setup, Keyboard_Read, Delay_Time, Keyboard_Initial
    extern LCD_Clear, LCD_High_Limit, LCD_Low_Limit, LCD_Delay_Write
    extern Dec_to_Hex_Converter_Delay, Converted_Delay_Time
    extern  delay_ms, delay_x4us 
    

acs0    udata_acs	; named variables in access ram
Row_Read res 1		; reserve 1 byte for Row value
Col_Read res 1		; reserve 1 byte for Column value
Full_Read res 1		; reserve 1 byte for the total value
 
Store_Decode res 1	; confirmed decoded value.
Decode_Value res 1	; value directly from keypad.
 
Delay_Time res 4	; delay time as a decimal stored as 4 bytes.
temp_decode res 1
temp_counter res 1
 
temp_limit res 1


Delay_Keyboard    code
    
Keyboard_Setup
    setf    TRISE			    ;rotuine to set PORTE to tri-state
    banksel PADCFG1    
    bsf	    PADCFG1, REPU, BANKED
    movlb   0x00			    
    clrf    LATE
    movlw   0x0F			    ; Sets E4-7 to output/E0-3 to input
    movwf   TRISE
    movlw   .125			    
    call    delay_x4us			    ; Delay of 0.5ms
    return
    
Keyboard_Initial
    movlw   0xEE		    ;initial value- helps to check if store decode has changed.
    ;movwf   temp_decode
    movwf   Store_Decode
    
    movlw .4			    ;So we can write 4 bytes to  Delay_Time.
    movwf temp_counter
    
    lfsr    FSR1, Delay_Time	    ;loads FSR to point to Delay_Time varibale
    return
    
Keyboard_Read			    
    call    Keyboard_Setup	    ;Checks to see if a button has been pressed.
    movlw   .15			    ;If yes- leave the loop. (Protective Layer)
    cpfslt  PORTE
    goto    $-2
    
    movff   PORTE, Row_Read	    ;See which row has been pressed.
    movlw   0xF0
    movwf   TRISE		    ;power rows to read columns.
    movlw   .50
    call    delay_ms		    ;Delay of 0.5ms
    movff   PORTE, Col_Read	    ;See which column has been pressed.
    movlw   .50
    call    delay_ms
    movf    Row_Read, W	    
    addwf   Col_Read, W
    movwf   Full_Read		    ;storing full code to one byte.
    movlw   .25
    
    call    delay_ms
    call    Keyboard_Decode ;Get decimal value of button pressed. 0xFF - Error value.
    movlw   .250	    ;This delay limits speed of pressing buttons.
    call    delay_ms
    call    Keyboard_Write ;Check for valid input and write to memory.
    
    tstfsz  temp_counter    ;Check if we have 4 valid inputs- if yes- proceed.
    goto    Keyboard_Read
 
    
    call    LCD_Delay_Write ;Write delay time to LCD.
    call    Dec_to_Hex_Converter_Delay	;Convert decimal delay time to hex.
    
    goto    Check_High_Limit	;Check if delay time is too long.
LowCheck    
    goto    Check_Low_Limit	;Check if delay time is too short.
  
Wait_Loop   btfsc   PORTA, 3	;Ensure switch is down before proceeding to Main.
	    goto    Wait_Loop
    
    
    return
    
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
	btfss	Full_Read, 3	;1
	movlw	0x01		
	btfss	Full_Read, 2	;4
	movlw	0x04
	btfss	Full_Read, 1	;7
	movlw	0x07
	btfss	Full_Read, 0	; 'A' should take no value.
	movlw	0xFF		   
	movwf	Decode_Value
	return
	
Check_2_Row
	btfss	Full_Read, 3	;2
	movlw	0x02
	btfss	Full_Read, 2	;5
	movlw	0x05
	btfss	Full_Read, 1	;8
	movlw	0x08
	btfss	Full_Read, 0	;0
	movlw	0x00
	movwf	Decode_Value
	return
	
Check_3_Row
	btfss	Full_Read, 3	;3
	movlw	0x03
	btfss	Full_Read, 2	;6
	movlw	0x06
	btfss	Full_Read, 1	;9
	movlw	0x09
	btfss	Full_Read, 0
	movlw	0xFF		    ; 'B' should take no value.
	movwf	Decode_Value
	return
	
Check_4_Row
	btfss	Full_Read, 3
	movlw	0xFF		    ; 'F' should take no value.
	btfss	Full_Read, 2
	movlw	0xFF		    ; 'E' should take no value.
	btfss	Full_Read, 1
	movlw	0xFF		    ; 'D' should take no value.
	btfss	Full_Read, 0
	movlw	0xFF		    ; 'C' should take no value.	
	movwf	Decode_Value		   
	return

Keyboard_Write		  
	movff Store_Decode, temp_decode
	
	movlw	.255		;stops no input on Keypad- defaults to FF.
	cpfslt	Full_Read
	return
	movlw	.255
	cpfslt	Decode_Value	;stops invalid answer - button we dont want pressed.
	return
	movff	Decode_Value, Store_Decode
	
	movff Store_Decode, POSTINC1	;Writes to Delay_Time, moves to next byte.
	
	decf temp_counter	;Decrements counter so we know how many values we have
	return
	
Check_High_Limit ;Check if input is greater than set value of 500ms (0x1D4)
	movff    Converted_Delay_Time, temp_limit	  
	movlw   0x01
	cpfseq	Converted_Delay_Time
	goto	Check_High_Top_Byte
	
	movlw	0xF4			;Check low byte.
	cpfsgt	Converted_Delay_Time +1
	goto	LowCheck
	call	LCD_High_Limit	;Too high- output error message and reset.
	goto	Limit_Reset


Check_High_Top_Byte
	movlw	0x01
	cpfsgt	Converted_Delay_Time
	goto	LowCheck
	
	call	LCD_High_Limit	;Too high- output error message and reset.
	goto	Limit_Reset
	
	
Check_Low_Limit	;Check if input is lower than set value of 10ms (0x0A)
	movlw	0x00
	cpfseq	Converted_Delay_Time
	goto	Check_Low_Top_Byte  
	    
	movlw   0x0A
	cpfslt	Converted_Delay_Time + 1
	goto	Wait_Loop			   
	call	LCD_Low_Limit	;too low- reset system.
	goto    Limit_Reset

Check_Low_Top_Byte
	movlw	0x00
	cpfslt	Converted_Delay_Time
	goto	Wait_Loop
	call	LCD_Low_Limit
	goto	Limit_Reset
	
Limit_Reset	;reset limits and go again
	call Keyboard_Initial
	goto Keyboard_Read
	

    end
