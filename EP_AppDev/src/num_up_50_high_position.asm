;       Autor:
; Brown Ramírez, Belinda 
; timna.brown@ucr.ac.cr


; num > -50 -> stored high positions

begin: 
    CLRB ; clean B 
    CLRA ; clean A
    LDAB # 200 ; load in B
    LDX  # DATOS
    LDAA # -50 ;load value in A
    LDY  # MAYORES

forloop:
    CMPA 1, X+ ; compare - if > -50 -> bool output 
    BLE  ifend ; branch if less than or equal signed if output ==1 
    MOVA -1, X, Y ; byte move 
    INY ; + 1 index of reg Y     

ifend:
    DBNE B, forloop ; if not 200 continue looping 

end:
    JMP end



