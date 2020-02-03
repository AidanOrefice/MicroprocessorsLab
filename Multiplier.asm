#include p18f87k22.inc

acs0    udata_acs 
eight res 1
sixteen res 2
sixteen1 res 2
sixteen2 res 2
twenty_four_result res 3
 
thirty_two_result  res 4
  
temp1 res 1
temp2 res 1


;sixtenn ~ lower byte, sixteen + 1 ~ upper byte
 
Multiply    code

goto start 
    
eight_steen_multi   ;routine to multiply 8bit by 16bit number
    ;whats in w is 'eight'.
    movwf eight
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
    btfsc STATUS, C	;check for carry from addition. If carry, add 1 t upper byte.
    addwf twenty_four_result
    return
    
steen_multi
    movf sixteen1 + 1, W
    
    call eight_steen_multi
    


start
    movlw 0xAB ;0x321A
    movwf sixteen1
    movlw 0xC3
    movwf sixteen1 + 1
    
    movlw 0x46	;0x46F4
    movwf sixteen2
    movlw 0xF4
    movwf sixteen2 + 1
    
    call eight_steen_multi
    
    goto start
    
    end