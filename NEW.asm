#include p18f87k22.inc
    

     extern  Keyboard_Setup, Keyboard_Read, Keyboard_Initial
     extern  LCD_Setup, LCD_Clear
     extern  Converted_Delay_Time
     extern  ADC_Setup, ADC_Read, ADC_Signal
     extern  time_set,  Delay_Trig_Setup
     extern  delay_ms
 
acs0    udata_acs	; named variables in access ram
RAM_Position res 2
Initial_RAM_Position res 2 
     
    
rst code    0	;reset vector
    goto Setup   
     
main code
 
Setup
    call    LCD_Setup		;Setup of LCD, Keyboard, ADC, Keybaord
    
    movlw   .25 
    call    delay_ms   
    
    call    LCD_Clear
        
    movlw   .25 
    call    delay_ms   
    
    call    ADC_Setup
    
    movlw   .25 
    call    delay_ms   
    
    call    Keyboard_Setup
    
    movlw   .25 
    call    delay_ms   
    
    call    Keyboard_Initial
        
    movlw   .25 
    call    delay_ms   
    
    call    Keyboard_Read	;Get initial values- initial delay time in hex in converted de;ay time - 2 bytes.
        
    movlw   .25 
    call    delay_ms   
    
    call    Reset_System
        
    movlw   .25 
    call    delay_ms   
    call    Delay_Trig_Setup
    clrf    TRISF		;PORTF is the data output.
    
    bsf	    TRISA, 3
    bcf	    TRISA, 5
    bsf	    PORTA, 5
    
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
    bcf	    PORTA, 5	;Diabling WR
    rrcf    INDF0, 0
    movwf   PORTF
    bsf	    PORTA, 5	;Enabling WR- driving through DAC.
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