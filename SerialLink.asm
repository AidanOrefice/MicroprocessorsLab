	#include p18f87k22.inc

    code
    org 0x0 ;reset point

    goto Start
    
    org 0x100    ; Main code starts here at address 0x100


Start	call SPI_MasterInit
	movlw .150		   
	call SPI_MasterTransmit
	call Wait_Transmit
	return
	
	
SPI_MasterInit 
	bcf SSP2STAT, CKE     ; Set Clock edge to negative
	movlw (1<<SSPEN)|(1<<CKP)|(0x02)  ; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movwf SSP2CON1
	bcf TRISD, SDO2    ; SDO2 output; SCK2 output
	bcf TRISD, SCK2
	return

SPI_MasterTransmit ; Start transmission of data (held in W)
	movwf SSP2BUF
	return

Wait_Transmit ; Wait for transmission to complete
	btfss PIR2, SSP2IF	    ;test 'PIR2' bit in SSP2IF, skip if 1- completed
	bra Wait_Transmit
	bcf PIR2, SSP2IF ; clear interrupt flag - waiting to transmit/ receive
	return
	
end