#include p18f87k22.inc
	
		extern Converted_Delay_Time
		global time_set, Delay_Trig_Setup

acs0    udata_acs
time_set res 1
temp_count res 2
temp_delay_time res 2
    
Interrupt_High	code	0x0008
		btfss	INTCON, TMR0IF
		retfie	FAST
		;call	Delay_Check
		;btfsc	time_set, 0
		;call	reset_values
		incf	PORTF
		bcf	INTCON, TMR0IF
		retfie	FAST
		
Delay_Trig	code
Delay_Trig_Setup
		;call	reset_values
		;clrf	time_set
		;movlw	b'11000101'	    ;1ms interrupt.- shoud be.
		movlw	b'10000111'
		movwf	T0CON
		;bsf	INTCON2, TMR0IP	;set as high priority
		bsf	INTCON, TMR0IE	;enabling timer interrupt
		bsf	INTCON, GIE	;enabling global interrupts
		return
	
;F_osc = 64MHz, F_osc/4 = 16Mhz, /256 interrupt every ~64kHz, so apply per-scaler of 1:64 to give 1kHz interrupt. i.e interrupt every 1ms

Delay_Check	;if Converted_Delay_Time == de;ay_count-  sets time_set <0> to one.
		;check if same length as our timer- using 1 ms delays
		incf	temp_count +1
		btfsc	STATUS, C
		incf	temp_count
		
		movff	temp_count, temp_delay_time
		movff	temp_count + 1, temp_delay_time + 1
		
		movf	Converted_Delay_Time+1, W
		cpfseq	temp_delay_time+1
		return
		movf	Converted_Delay_Time, W
		cpfseq	temp_delay_time, W
		return
		bsf	time_set, 0
		return
		
reset_values	clrf	temp_count
		clrf	temp_count +1
		return
		


    end
		
