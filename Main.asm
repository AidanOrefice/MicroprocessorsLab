#include p18f87k22.inc
    

 

;extern ADC_Setup, ADC_Read
    extern  Keyboard_Setup, Keyboard_Read, Store_Decode, Keyboard_Initial
    extern  LCD_Setup, LCD_Write_Message, LCD_Write_Hex
    extern  LCD_Clear, LCD_Write_Line1, LCD_Write_Line2, LCD_Send_Byte_D, LCD_Preset
    extern  LCD_delay_ms
    
    org 0x00
    goto start
    
main code
 
 
start	movlw b'10000000'
	movwf TRISJ
	
	call LCD_Setup
	call LCD_Preset
	call Keyboard_Setup
	call Keyboard_Initial
	btfsc PORTJ, 7
	call Keyboard_Read
    
    goto start 



    end