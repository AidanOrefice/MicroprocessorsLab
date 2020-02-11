#include p18f87k22.inc

;possible extensions: use FSRS and subroutine to check and correct carry
		    ; sort naming out
    
		    
;global steen_multi, eight_twenty_four_multi
;global sixteen1, sixteen2, twenty_four
;global twenty_four_result, thirty_two_result

    global Hex_to_dec_converter, decimal_result
		    
acs0    udata_acs 
eight res 1
sixteen res 2
sixteen1 res 2
sixteen2 res 2

twenty_four res 3
 
twenty_four_result res 3

twenty_four_result1 res 3
twenty_four_result2 res 3
 
thirty_two_result  res 4

decimal_result res 2	    ;to store the decimal result (byte per decimal)
  
temp1 res 1
temp2 res 1


;sixtenn ~ lower byte, sixteen + 1 ~ upper byte
 
Multiply    code
  
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
    
steen_multi			;need to define sixteen1 and sixteen2
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
    
eight_twenty_four_multi		;need to define twenty four 
    movwf eight			;eight is defined in w
    movf eight, W
    mulwf twenty_four + 2	;multiplt 8bit by lower byte of 24bit
    movff PRODL, thirty_two_result + 3	    ;store in lowest byte of result.
    
    movff PRODH, temp1	;keep high byte to add later.
   
    movf eight, W   ;multiply using higher byte of 16bit.
    mulwf twenty_four
    
    movff PRODH, thirty_two_result
    
    movff PRODL, temp2
   
    movf eight, W
    mulwf twenty_four +1
    
    movf PRODH, W
    addwf temp2
    movff temp2, thirty_two_result + 1
    movlw .1		
    btfsc STATUS, C
    addwf thirty_two_result
    
    movf PRODL, W
    addwf temp1
    movff temp1, thirty_two_result + 2
    
    movlw .1		
    btfsc STATUS, C
    addwf thirty_two_result + 1
    
    movlw .1		;checks for the double carry when addting to mid-upper byte.
    btfsc STATUS, C
    addwf thirty_two_result
    return
    
Hex_to_dec_converter	;two inputs: ADRESH (first four bits), ADRESL - both 8 bit
    movlw 0x00
    movwf decimal_result
    movwf decimal_result + 1
    
    movff ADRESH, sixteen1
    movff ADRESL, sixteen1 + 1
    movlw 0x41
    movwf sixteen2
    movlw 0x8a
    movwf sixteen2 + 1
    call steen_multi
    call Manipulate_Value
    addwf decimal_result
    swapf decimal_result
   
    movlw 0x0A
    call eight_twenty_four_multi
    call Manipulate_Value
    addwf decimal_result
    
    movlw 0x0A
    call eight_twenty_four_multi
    call Manipulate_Value
    addwf decimal_result + 1
    swapf decimal_result + 1

    movlw 0x0A
    call eight_twenty_four_multi
    call Manipulate_Value
    addwf decimal_result + 
    
    1
    return
    
Manipulate_Value	;To select the most significant bit and the remainder
    movff thirty_two_result + 1, twenty_four
    movff thirty_two_result + 2, twenty_four + 1
    movff thirty_two_result + 3, twenty_four + 2
    movf thirty_two_result, W
    return
  
    
    end