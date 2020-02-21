#include p18f87k22.inc
    

     extern  Keyboard_Setup, Keyboard_Read, Keyboard_Initial
     extern  LCD_Setup 
     extern  Converted_Delay_Time
     extern  ADC_Setup, ADC_Read, ADC_Signal
     extern  time_set,  Delay_Trig_Setup
 
acs0    udata_acs	; named variables in access ram
RAM_Position res 2
Initial_RAM_Position res 2 
     
    
rst code    0	;reset vector
    goto Setup   
     
main code
 
Setup
    call    LCD_Setup		;Setup of LCD, Keyboard, ADC, Keybaord
    call    ADC_Setup
    call    Keyboard_Setup
    call    Keyboard_Initial
    call    Keyboard_Read	;Get initial values- initial delay time in hex in converted de;ay time - 2 bytes.
    call    Reset_System
    call    Delay_Trig_Setup
    clrf    TRISF		;PORTF is the data output.
    
Initial_Loop
    call    ADC_Read
    movff   ADC_Signal, POSTINC0
    
    btfsc   PORTA, 3	    ;Testing if switch has been flicked to input new delay time.
    goto    Key_Reset    ;If switch is set, reset system with new input.
    
    btfss   time_set, 0
    goto    Initial_Loop    ;Keep reading
    movff   FSR0H, RAM_Position
    movff   FSR0L, RAM_Position + 1
    call    Reset_System
    goto    Main_Delay
    
Main_Delay    
    rrcf    INDF0, 0
    movwf   PORTF
    call    ADC_Read
    movff   ADC_Signal, POSTINC0
    
    btfsc   PORTA, 3
    goto    Key_Reset
    
    movf    RAM_Position + 1
    cpfseq  FSR0L
    goto    Main_Delay
    movf    RAM_Position
    cpfseq  FSR0H
    goto    Main_Delay
    
    call    Reset_System
    goto    Main_Delay
    
    
           
    
Key_Reset   ;Don't put a return so runs down to Reset_System.
    bcf	    INTCON, GIE ;turning off interrupts for an input
    call    Keyboard_Initial
    call    Keyboard_Read
    call    Reset_System
    goto    Initial_Loop
    
Reset_System   
    movlw   0x40    ;sets initial position
    movwf   Initial_RAM_Position + 1
    clrf    Initial_RAM_Position
    movff   Initial_RAM_Position + 1, FSR0L
    movff   Initial_RAM_Position, FSR0H;Setting start point of memory reading
    bcf	    time_set,0
    call    Delay_Trig_Setup ;reset delay time counter
    return
    
    end


