#include p18f87k22.inc
    
    
    org 0x00
    code
    
    goto	Start
    
Start
    bsf	    TRISH, 0
    clrf    TRISJ
    movlw   .255
    btfss   PORTH,0
    movwf   PORTJ
    
    
    end
    
    


