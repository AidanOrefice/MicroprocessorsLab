	#include p18f87k22.inc

;************* Script to intitialise timer0 interrupt **************************
	
	global	TimeInt_Setup, time_set, reset_int_values
	extern Converted_Delay_Time


;Will set first bit of time_set to one when delay time has been reached.

acs0    udata_acs
time_set res 1
temp_count res 2
temp_delay_time res 2
	
int_hi	code	0x0008		; high vector, no low vector
	btfss	INTCON,TMR0IF	; check that this is timer0 interrupt
	retfie	FAST		; if not then return
	call	Delay_Check	; Check if delay time has been reached
	bcf	INTCON,TMR0IF	; clear interrupt flag
	retfie	FAST		; fast return from interrupt

DAC	code
TimeInt_Setup
	clrf	time_set	;clear delay check bytes.
	call	reset_int_values    
	clrf	TRISD		; Set PORTD as all outputs
	movlw	b'11000101'	; Set timer0 to 8-bit, Fosc/4/64
	movwf	T0CON		; = 250KHz clock rate, approx 1 millisec rollover
	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
	bsf	INTCON,GIE	; Enable all interrupts
	return

Delay_Check	;Routine checks if we have reached the delay time.
		incf	temp_count +1	    ;increment counter
		btfsc	STATUS, C	    ;if carry, update high byte.
		incf	temp_count
		
		movff	temp_count, temp_delay_time	
		movff	temp_count + 1, temp_delay_time + 1
		
		movf	Converted_Delay_Time+1, W
		cpfseq	temp_delay_time+1
		return
		movf	Converted_Delay_Time, W
		cpfseq	temp_delay_time, W
		return
		bsf	time_set, 0	;if delay time = delay count, set this bit.
		call	reset_int_values    ;reset interrupt- go back to main loop.
		return
		
reset_int_values    clrf	temp_count	;reset counter when at delay time.
		    clrf	temp_count +1
		    return
		
		end


