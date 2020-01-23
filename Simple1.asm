	#include p18f87k22.inc

    code
    org 0x0 ;reset point

    goto DecRunSeq

    org 0x100    ; Main code starts here at address 0x100

Run     call Initial    ;Run Program
	call Write2
	call Read2
	return
	
DecRunSeq  movlw high(0xFFFF)
	   movwf 0x300
	   movlw low(0xFFFF)
	   movwf 0x301
	   movlw 0xFF
       	   movwf 0x90, ACCESS
	   call Initial
DecLoop	   ;call Delay_16
	   call Write1
	   call Read1
	   decfsz 0x90
	   bra DecLoop
	   return

Initial    ;Choosing pins on PORTD and set to high
	    ;4 pins required for control/address bus (Eo,Cp)
	movlw 0x00    ;Setting all bits to 0. Only using 0 to 3
	movwf TRISD, ACCESS    ;Sets TRISD to zeroes
	movlw .15    ;Sets RD0 through to RD3 to 1s
	movwf PORTD, ACCESS    ;Sends this to PORTD
	call TriE    ;TriState PORTE- for safety
	return

Read1	;OE* of desires address to low, other stays high
        ;PORTE to tristate
	call TriE    ;Set PORTE to tri-state
	bsf PORTD, 1    ;Hard set bit 1 to 1
	bcf PORTD, 0    ;Sets bit 0 to 0 in PORTD
	call Output    ;outputs to PORT C
	return
   
Read2    ;OE* of desires address to low, other stays high
	;PORTE to tristate
	call TriE    ;Set PORTE to tri-state
	bsf PORTD, 0    ;Hard set bit 0 to 1
	bcf PORTD, 1    ;Sets bit 1 to 0 in PORTD
	call Output    ;outputs to PORT C
	return
   
Write1    ;Both OE* high
	;set PORTE to zeros- output
	;place data on PORTE
	;drive clock to write to specific address- on leading edge.
	bsf PORTD, 0    ;set EO1* high  
	bsf PORTD, 1    ;set E02* high
	clrf TRISE    ;set PORTE to output
	;call DataSet    ;sending data to PORTE
	call DecDataSet	 ;different type of data
	bcf PORTD, 2    ;set cp1 to low
	call Delay    ;delay for 250ns
	bsf PORTD, 2    ;set cp1 to high- memory written on leading edge
	call TriE    ;set PORTE to tri-state
	;clrf PORTE
	return

Write2   
	bsf PORTD, 0    ;set EO1* high  
	bsf PORTD, 1    ;set E02* high
	clrf TRISE    ;set PORTE to output
	call DataSet    ;sending data to PORTE
	bcf PORTD, 3    ;set cp2 to low
	call Delay    ;delay for 250ns
	bsf PORTD, 3    ;set cp2 to high- memory written on leading edge
	call TriE    ;set PORTE to tri-state
	return    

DataSet     
	clrf PORTE    ;clearing PORTE 
	movlw .219    ;some arbitary value to read and output
        movwf PORTE, ACCESS ;sent data to PORTE
	return
	

DecDataSet
	clrf PORTE
	movff 0x90, PORTE
	return
	

   
Delay   movlw .3    ;delays 3 for 3 operations
	movwf 0x60    ;data location
    Loop    decfsz  0x60   ;decrementing value at data location.
	    bra Loop       
	    return
	return
	
Delay_16    movlw 0x00
dloop	    decf 0x301, f
	    subwfb 0x300, f
	    bc dloop
	    return

TriE 
	setf TRISE    ;rotuine to set PORTE to tri-state
	banksel PADCFG1    
	bsf PADCFG1, REPU, BANKED
	movlb 0x00
	return

Output 
	clrf TRISC ;output to PORTC
	movff PORTE, PORTC
	return

end

