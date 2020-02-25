#include p18f87k22.inc

    global  ADC_Setup, ADC_Read, ADC_Signal
    extern  quick_delay
    
acs0    udata_acs	; named variables in access ram
ADC_Signal  res 1
temp_shift  res 1
    
ADC    code
    
ADC_Setup
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    movlw   0x01	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    return

ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    bcf	    PIR1, ADIF
    call ADC_Reduce
    return

ADC_Reduce  ;Store ADC as a byte value.
    movff   ADRESH, ADC_Signal
    movlw   0x1F		    ;;; selecting 5 lsbs
    andwf   ADC_Signal, F	    ;;;
    bcf	    STATUS, C
    rrcf    ADC_Signal, F	; bit stored in carry bit
    swapf   ADC_Signal
    call    quick_delay
    movff   ADRESL, temp_shift
    call    quick_delay
    RRCF    temp_shift, F	;shifts through the carry register, need to clear it everytime.
    call    quick_delay		;5 shifts
    bcf	    STATUS, C
    call    quick_delay
    RRCF    temp_shift, F
    call    quick_delay
    bcf	    STATUS, C
    call    quick_delay
    RRCF    temp_shift, F
    call    quick_delay
    bcf	    STATUS, C
    call    quick_delay
    RRCF    temp_shift, F
    call    quick_delay
    bcf	    STATUS, C
    call    quick_delay
    RRCF    temp_shift, F
    call    quick_delay
    bcf	    STATUS, C
    call    quick_delay
    movf    temp_shift, W   ;stroing in 
    addwf   ADC_Signal, F
    movlw   0x80	    ;adding an offset of 128
    addwf   ADC_Signal, F
    return
    
   
    
    
    end