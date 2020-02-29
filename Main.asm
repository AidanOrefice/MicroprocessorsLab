#include p18f87k22.inc
 
;******************************************************************************
;     
;   Main script bringing together all of the modules to create a digital delay.
;     
;******************************************************************************
     
     
     ;routines from different modules.
     extern  Keyboard_Setup, Keyboard_Read, Keyboard_Initial
     extern  LCD_Setup, LCD_Clear
     extern  Converted_Delay_Time
     extern  ADC_Setup, ADC_Read, ADC_Signal
     extern  time_set,  reset_int_values, TimeInt_Setup
     extern  delay_ms, sample_delay
 
acs0    udata_acs	; named variables in access ram
RAM_Position res 2
Initial_RAM_Position res 2 
     
    
rst code    0	;reset vector
    goto Setup   
     
main code
 
Setup
    banksel ANCON0	    ;Setting RA0- analogue, RA3 and RA4 - digital.
    bsf	    ANCON0, ANSEL0
    bcf	    ANCON0, ANSEL3
    bcf	    ANCON0, ANSEL4
    banksel 0
    clrf    TRISD	    ;set PORTD to otput
    bsf	    TRISA, 0	    ;input for ADC.
    bsf	    TRISA, 3	    ;input- switch for keyboard changes
    bcf	    TRISA, 5	    ;output
    bsf	    PORTA, 5	    ;set high- write pin for DAC.
    
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
    
    call    Keyboard_Read	
        
    movlw   .25 
    call    delay_ms   
    
    call    Reset_System	;Reset RAM positions.
        
    movlw   .25 
    call    delay_ms   
    call    TimeInt_Setup	;Setting up timer0 interrupt.
       
Initial_Loop
    call    ADC_Read		;Take ADC measurement
    movff   ADC_Signal, POSTINC0    ;Store in RAM.
    
    btfsc   PORTA, 3	 ;Testing if switch has been flicked to input new delay time.
    goto    Key_Reset    ;If switch is set, reset system with new input.
    
    call    sample_delay   ;delays to fix Sampling rate to allow longer delays.
    nop	   
    nop
    
    btfss   time_set, 0
    goto    Initial_Loop    ;Keep forming buffer.
    movff   FSR0H, RAM_Position	;If delay time reached. Store RAM position.
    movff   FSR0L, RAM_Position + 1 ;This forms the buffer.
    call    Reset_System	;reset values
    goto    Main_Delay		;go to main section.
Main_Delay
    
    bcf	    PORTA, 5	;Diabling WR- hold low for 40ns
    movff   INDF0,PORTD	;Output delayed signal through PORTD.
    bsf	    PORTA, 5	;Enabling WR- driving through DAC.
    call    ADC_Read
    movff   ADC_Signal, POSTINC0    ;Get new measurement and increment RAM.
    
    call sample_delay	    ;fix sampling rate.
    
    btfsc   PORTA, 3	    ;Check for new delay time.
    goto    Key_Reset
    
    movf    RAM_Position + 1, W	;Check if we have reached end of Circular Buffer.
    cpfseq  FSR0L
    goto    Main_Delay
    movf    RAM_Position, W
    cpfseq  FSR0H		
    goto    Main_Delay		;No- keep looping around
  
    call    Reset_System	;Yes- reset Ram and start from beggining of buffer.
    
    goto    Main_Delay		
    
    
           
    
Key_Reset  
    bcf	    INTCON, GIE ;turning off interrupts for an input
    call    Keyboard_Initial ;Complete reset of system with new delay.
    call    Keyboard_Read
    call    Reset_System
    bsf	    INTCON, GIE	;enabling interrupts again.
    goto    Initial_Loop	;Define buffer again.
    
Reset_System	;Full reset of pins and RAM
    banksel ANCON0
    bsf	    ANCON0, ANSEL0	;Stop pins defaulting to analogue.
    bcf	    ANCON0, ANSEL3
    bcf	    ANCON0, ANSEL4
    banksel 0
    
    movlw   0x60    ;sets initial position- away from FSRs
    movwf   Initial_RAM_Position + 1
    clrf    Initial_RAM_Position
    movff   Initial_RAM_Position + 1, FSR0L
    movff   Initial_RAM_Position, FSR0H ;Setting start point of memory reading
    bcf	    time_set,0
    call    reset_int_values	;reseting interupt counter.
    return
    
    end


