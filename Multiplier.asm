#include p18f87k22.inc

acs0    udata_acs 
eight res 1
sixteen res 2
sixteen1 res 2
sixteen2 res 2
 
twenty_four_result res 3

twenty_four_result1 res 3
twenty_four_result2 res 3
 
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
    movf sixteen1 + 1, W	;using lower byte of 16bit
    movff sixteen2, sixteen	;storing other 16bit for subroutine. - HERE
    movff sixteen2 + 1, sixteen + 1
    call eight_steen_multi	
    movff twenty_four_result, twenty_four_result1   ;storing 24bit. = HERE
    movff twenty_four_result + 1 , twenty_four_result1 + 1
    movff twenty_four_result + 2, twenty_four_result1 + 2
    
    movf sixteen1, W		;using upper byte of 16bit
    
    movff sixteen2, sixteen	;storing other 16bit for subroutine. - HERE
    movff sixteen2 + 1, sixteen + 1
    
    call eight_steen_multi
    movff twenty_four_result, twenty_four_result2 ; storing 24bit.  -HERE
    movff twenty_four_result + 1 , twenty_four_result2 + 1
    movff twenty_four_result + 2, twenty_four_result2 + 2
    
    movff twenty_four_result1 + 2, thirty_two_result + 3    ;Storing lowest byte
    movff twenty_four_result2, thirty_two_result	    ;storing highest byte
    
    movff twenty_four_result1, temp1	 
    movf twenty_four_result2 + 1, W
    addwf temp1
    movff temp1, thirty_two_result + 1
    movlw .1
    btfsc STATUS, C 
    addwf thirty_two_result
    
    movff twenty_four_result1 + 1, temp1
    movf twenty_four_result2 + 2, W
    addwf temp1
    movff temp1, thirty_two_result + 2
    movlw .1
    btfsc STATUS, C 
    addwf thirty_two_result + 1
    
    movlw .1		;checks for the double carry when addting to mid-upper byte.
    btfsc STATUS, C
    addwf thirty_two_result

    return
    
    
steen_shift
twenty_fourt_shift
    
    
start
    movlw 0xAB ;0xABC3
    movwf sixteen1
    movlw 0xC3
    movwf sixteen1 + 1
    
    movlw 0x46	;0x46F4
    movwf sixteen2
    movlw 0xF4
    movwf sixteen2 + 1
    
    call steen_multi
    
    goto start
    
    end