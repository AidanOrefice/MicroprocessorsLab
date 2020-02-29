#include p18f87k22.inc

;************* Some important multiplying and conversion routines **************    
    
    global Dec_to_Hex_Converter_Delay, Converted_Delay_Time
    extern  Delay_Time


acs0    udata_acs 
eight res 1
sixteen res 2		;Lots of sections of RAM reserved for multiplication.
sixteen1 res 2
sixteen2 res 2
twenty_four_result res 3
  
temp1 res 1
temp2 res 1
 
Converted_Delay_Time res 2	;A hugely important value.
 
Multiply    code
  
eight_steen_multi   ;routine to multiply 8bit by 16bit number
    ;8 bit number shoudl be stored in WREG when called. 16 bit in sixteen (2byte)
    movwf eight		;looks pointless but must store 8 bit value.
    movf eight, W
    mulwf sixteen + 1	;multiplt 8bit by lower byte of 16bit
    movff PRODL, twenty_four_result + 2	    ;store in lowest byte of result.
    
    movff PRODH, temp1	;keep high byte to add later.
   
    movf eight, W   ;multiply using higher byte of 16bit.
    mulwf sixteen   
   
    movf PRODL, W   ;going to add to compose middle byte
    
    movff PRODH, twenty_four_result ;store in upperbyte of result.
    
    addwf temp1	;add two middle bytes and set to middle
    movff temp1, twenty_four_result + 1	
    movlw .1
    btfsc STATUS, C	;check for carry from addition. If carry, add 1 to upper byte.
    addwf twenty_four_result
    return
    
Dec_to_Hex_Converter_Delay	;routine to convert decimal keypad input to hex.
    movlw   0x03			    ; multiply by 1000 (0x3e8)
    movwf   sixteen
    movlw   0xE8
    movwf   sixteen + 1
    
    movf    Delay_Time, W		   
    call    eight_steen_multi
    ;result stored in twenty_four_result
    
    movlw   0x64			    ; multiply by 100 (0x64)
    mulwf   Delay_Time + 1
    ;result is in PRODH:PRODL
    call    Delay_Add
    
    movlw   0x0A			    ;multiply by 10
    mulwf   Delay_Time	+ 2
    call    Delay_Add
    
    movlw   0x01			    ;multiply by 1 - still use Delay_Add.
    mulwf   Delay_Time	+ 3
    call    Delay_Add
    
    ;Storing Delay time in hex in 'Converted_Delay_Time'
    movff   twenty_four_result+1, Converted_Delay_Time
    movff   twenty_four_result +2, Converted_Delay_Time +1
    return
        
Delay_Add   ;routine to add PROD register to twenty_four_result. 
    movf    PRODH, W			    ;Full add routine
    addwf   twenty_four_result + 1
    movlw   .1		
    btfsc   STATUS, C			    ;Checking if there is a carry- if yes: add one to next upper byte.
    addwf   twenty_four_result
    movf    PRODL, W
    addwf   twenty_four_result + 2
    movlw   .1		
    btfsc   STATUS, C			    ;Checking if there is a carry- if yes: add one to next upper byte.
    addwf   twenty_four_result + 1
    movlw .1		;checks for the double carry when addting to mid-upper byte.
    btfsc STATUS, C
    addwf twenty_four_result
    return

    
    end