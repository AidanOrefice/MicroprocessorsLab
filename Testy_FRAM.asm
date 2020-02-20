#include p18f87k22.inc

    ;extern  Delay_Time
    extern  delay_ms, delay_x4us
    
    global  FRAM_Init, SPI_FRAM_Write, SPI_FRAM_Read
    
;ONLY TRYING TO WRITE TO ONE         
    
;acs0    udata_acs ;permanent variables

;acs_ovr	access_ovr  ;temporary varibales

;************ FRAM PORT ASSIGNMENTS **************************************	    
	    Constant CS_FRAM1_Pin = 0	;Chip select is on C.
	    Constant CD_FRAM2_Pin = 2
	    
;************ FRAM CHIP OPCODES **************************************	    
	    Constant F_WRSR = .1	;These are the opcodes set out in pg 6, data sheet.
	    Constant F_WRITE = .2
	    Constant F_READ = .3
	    Constant F_WRDI = .4
	    Constant F_RDSR = .5
	    Constant F_WREN = .6
	    Constant F_FSTRD = .11
	    
;************ MSSP Functions  **************************************	

;   Don't need to call these, just good to know where they are.
	    
	    ;Constant SDO1 = 5	    ;PORTC
	    ;Constant SDI1 = 4	    ;PORTC	    
	    ;Constant SDCK1 = 3	    ;PORTC	
	    
	    ;Constant SDO1 = 4	    ;PORTD
	    ;Constant SDI1 = 5	    ;PORTD
	    ;Constant SDCK1 = 6	    ;PORTD

	   	    
FRAM code

 
FRAM_Init  ;Clearing all configuration registers.
    clrf    SSP1CON1
    clrf    SSP1CON2
    clrf    SSP1STAT
    clrf    SSP1BUF
    
    clrf    SSP2CON1		;control register1
    clrf    SSP2CON2		;control register2
    clrf    SSP2STAT		;status register
    clrf    SSP2BUF		;buffers
    
    movlw   .25			;Allow system to setup
    call    delay_ms
    
    bcf	    TRISE, CS_FRAM1_Pin	;Chip select pin is now an output
    bsf	    PORTE, CS_FRAM1_Pin	;deselects port
    
    bcf	    TRISC, SCK1		;clock is output
    bsf	    TRISC, SDI1		;SDI is an input
    bcf	    TRISC, SDO1		;SDO is an output 
    
    bcf	    SSP1STAT, CKE		;idle to active clock state transmission.
    bsf	    SSP1STAT, SMP
    
    ;MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)- check FRAM can use these settings
    movlw   (1<<SSPEN)|(1<<CKP)|(0x02)
    movwf   SSP1CON1
    return

SPI_FRAM_Write
    ;FSR1 - Data we want written- set as ADRESL for now.
    ;FSR2 - Address where we want to put on FRAM- set as next available.
    
    bcf	    PORTE, CS_FRAM1_Pin	;selects chip.
    bcf    PIR1, SSP1IF		;Reading buffer to W- Reading to clear

    
	    movlw   F_WREN		;write enable command
	    movwf   SSP1BUF
WEOP_Loop   btfss   PIR1, SSP1IF
	    bra	    WEOP_Loop
	    bcf    PIR1, SSP1IF			;clearing status flag
    
    ;bsf	    PORTE, CS_FRAM1_Pin	;Toggling CS so we can send a new opcode.
    ;bcf	    PORTE, CS_FRAM1_Pin
    
	    movlw   F_WRITE
	    movwf   SSP1BUF
WOP_Loop    btfss   PIR1, SSP1IF
	    bra	    WOP_Loop
	    bcf    PIR1, SSP1IF		;clearing status flag
    
;	    movff   POSTDEC2, SSP1BUF		;MSB of addres to output buffer.
;Reg1_Loop   btfss   PIR1, SSP1IF
;	    bra	    Reg1_Loop
;	    bcf    PIR1, SSP1IF			;clearing status flag

	    movff   INDF2, SSP1BUF		;LSB of address to output buffer
Reg2_Loop   btfss   PIR1, SSP1IF
	    bra	    Reg2_Loop
	    bcf    PIR1, SSP1IF			;clearing status flag


	    movff   INDF1, SSP1BUF
W_Loop	    btfss   PIR1, SSP1IF
	    bra	    W_Loop
	    bcf    PIR1, SSP1IF			;clearing status flag


    bsf   PORTE,CS_FRAM1_Pin      ;Deselect device

    return
    
SPI_FRAM_Read
    ;FSR0- address to read from FRAM (+1- 2byte address)
    
	    bcf	  PORTE, CS_FRAM1_Pin		;select the chip
	    bcf    PIR1, SSP1IF			;clearing status flag

	    movlw   F_READ
	    movwf   SSP1BUF
ROP_Loop    btfss   PIR1, SSP1IF
	    bra	    ROP_Loop
	    bcf    PIR1, SSP1IF

;	    movff   POSTDEC0, SSP1BUF		;MSB of addres to output buffer.
;R_Reg1_Loop btfss   PIR1, SSP1IF
;	    bra	    R_Reg1_Loop
;	    bcf    PIR1, SSP1IF			;clearing status flag

	    movff   INDF0, SSP1BUF		;LSB of address to output buffer
R_Reg2_Loop btfss   PIR1, SSP1IF
	    bra	    R_Reg2_Loop
	    bcf    PIR1, SSP1IF			;clearing status flag

	    movwf   SSPBUF, W
R_Loop	    btfss   PIR1, SSP1IF
	    bra	    R_Loop

    bsf   PORTE,CS_FRAM1_Pin      ;Deselect device
    return

    end


