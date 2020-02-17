#include p18f87k22.inc

	 extern Delay_Time
    
    
;acs0    udata_acs ;permanent variables

;acs_ovr	access_ovr  ;temporary varibales

Symbol CS_F_Port = PORTE	;not surte if it likes symbols- check how to use them for pic18
Symbol CS_F_tri = TRISE		;CS is on port E
	    
	    Constant CS_F_Pin_1 = 0
	    Constant CD_F_Pin_2 = 1
	    
	    Constant F_WRSR = .1	;These are the opcodes set out in pg 6, data sheet.
	    Constant F_WRITE = .2
	    Constant F_READ = .3
	    Constant F_WRDI = .4
	    Constant F_RDSR = .5
	    Constant F_WREN = .6
	    Constant F_FSTRD = .11
	      
FRAM code

 
FRAM_Setup
    SSPCON1 = 0		;clearing config registers- is there a better way to do this
    SSPSTAT = 0
    SSPBUF  = 0
 
;25 ms delay in