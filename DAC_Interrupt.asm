	#include p18f87k22.inc
	
	global	TimeInt_Setup, time_set, reset_int_values
	extern Converted_Delay_Time
		
acs0    udata_acs
time_set res 1
temp_count res 2
temp_delay_time res 2
	
int_hi	code	0x0008	; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	call	Delay_Check
	bcf	INTCON,TMR0IF	; clear interrupt flag
	retfie	FAST		; fast return from interrupt

DAC	code
TimeInt_Setup
	clrf	time_set
	call	reset_int_values
	clrf	TRISD		; Set PORTD as all outputs
	movlw	b'11000101'	; Set timer0 to 16-bit, Fosc/4/256
	movwf	T0CON	; = 62.5KHz clock rate, approx 1sec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	return

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
		call	reset_int_values
		return
		
reset_int_values    clrf	temp_count
		    clrf	temp_count +1
		    return
		
		end


