#include p18f87k22.inc

acs0    udata_acs 
eight res 1
sixteen res 2
twenty_four_result res 3

;sixtenn ~ lower byte, sixteen + 1 ~ upper byte
 
Multiply    code

eight_steen_multi
    movf eight, W
    mulwf sixteen
    

start
    movlw 0x44
    movwf eight
    movlw 0x32
    movwf sixteen
    movlw 0x1A
    movwf sixteen + 1
    
    call eight_steen_multi
    
    goto start
    
    end