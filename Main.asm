#include p18f87k22.inc
    

 

;extern ADC_Setup, ADC_Read
    ;extern  Keyboard_Setup, Keyboard_Read, Store_Decode, Keyboard_Initial, Delay_Time
    ;extern  LCD_Setup, LCD_Write_Message, LCD_Write_Hex
    ;extern  LCD_Clear, LCD_Write_Line1, LCD_Write_Line2, LCD_Send_Byte_D, LCD_Preset, LCD_Delay_Write 
    ;extern  LCD_delay_ms, Converted_Delay_Time
    
    extern  FRAM_Init, SPI_FRAM_Write, SPI_FRAM_Read
    extern  ADC_Setup, ADC_Read
    
    
    org 0x00
    goto start
    
main code
 
 
;start	;bsf	TRISJ, 3	    ;This initialises PORTJ such that RJ7 is our switch
;	
;	clrf	TRISH
;	
;	call	LCD_Setup
;	call	LCD_Preset
;	call	Keyboard_Setup
;	call	Keyboard_Initial
;	btfsc	PORTJ, 7
;	call	Keyboard_Read
;	movff	Converted_Delay_Time, PORTH
;	call	LCD_Delay_Write	    ; This allows us to output the delay time when the switch is down  
;	goto	start 

start	clrf INTCON
	
	call FRAM_Init
	call ADC_Setup
	clrf TRISH
	
	call ADC_Read
	lfsr FSR2, 0xFF
	lfsr FSR1, 0xFA
	movff ADRESL, INDF1
	call SPI_FRAM_Write
	
	lfsr FSR0, 0xFF
	call SPI_FRAM_Read
	
	movff SSP1BUF, PORTH
	
	goto start
	
	
	
	
    end