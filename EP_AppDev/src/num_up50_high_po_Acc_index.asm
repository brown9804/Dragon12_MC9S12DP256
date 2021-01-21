;       Autor:
; Brown Ramírez, Belinda 
; timna.brown@ucr.ac.cr


;Using indexed 
;accumulator addressing.
;PD: The value of the 
;pointers remains unchanged
;after the execution of 
;the program.

; num > -50 -> stored high positions

begin:     
    CLRB         ; clean B as counter 
    CLRA         ; clean A
    LDX  # DATOS
    LDAA # -50   ;load value in A as limit
    LDY  # MAYORES

forloop:
    INCB       ; B + 1 
    LDAA B,X   ; load DATOS + B
    CMPA 1, X+ ; compare - if > -50 -> bool output 
    BLE  ifend ; branch if less than or equal signed if output ==1 
    IDAB $1301 ; load number of stored values 
    STAA B, Y  ; store value MAYORES
    STAB $1301 ; store number of stored values 

ifend:
    DBNE B, forloop ; if not 200 continue looping 

end:
    JMP end





