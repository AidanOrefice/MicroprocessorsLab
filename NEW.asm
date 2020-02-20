#include p18f87k22.inc
    

     extern  Keyboard_Setup, Keyboard_Read, Store_Decode, Keyboard_Initial, Delay_Time
     extern  LCD_Setup
     extern  LCD_Clear, LCD_Write_Line1, LCD_Write_Line2, LCD_Send_Byte_D, LCD_Preset, LCD_Delay_Write 
     extern  Converted_Delay_Time
     extern  ADC_Setup, ADC_Read, ADC_Signal
     extern  timer_set
 
    acs0    udata_acs	; named variables in access ram
    RAM_position res 2
    Initial_RAM_Position res 2 
     
    
    org 0x00
    goto start     
     
main code
 
Initialise
    call    LCD_Setup		;Setup of LCD, Keyboard, ADC, Keybaord
    call    ADC_Setup
    call    Keyboard_Setup
    call    Keyboard_Initial
    
    movlw   0x40    ;sets initial position
    movwf   Initial_RAM_Position + 1
    clrf    Initial_RAM_Position
    movff   Initial_RAM_Position + 1, FSR0L
    movff   Initial_RAM_Position, FSR0H;Setting start point of memory reading
    
    lfsr    FSR1, FSR0		;set to same address
    
    clrf    TRISF		;PORTF is the data output.
    call    Keyboard_Read	;Get initial values- initial delay time in hex in converted de;ay time - 2 bytes.
    
    
Initial_Loop
    
    
    call    ADC_Read
    movff   ADC_Signal, POSTINC0
    
    btfsc   PORTA, 3	    ;Testing if switch has been flicked to input new delay time.
    goto    Reset_System    ;If switch is set, reset system with new input.
    
    btfss   timer_set, 0
    goto    Initial_Loop    ;Keep reading
    movff   FSR0H, RAM_Position
    movff   FSR0L, RAM_Position + 1
    goto    Main_Delay
    
Main_Delay
    bcf	    timer_set,0
    rrcf    POSTINC1, 0
    movwf   PORTF
    call    ADC_Read
    movff   ADC_Signal, POSTINC0
    
Reset_System
    call    Keyboard_Read
    goto    Initialise

    

