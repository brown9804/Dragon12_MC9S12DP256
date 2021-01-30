;       Autor:
; Brown Ramírez, Belinda 
; timna.brown@ucr.ac.cr


; Even Toggle

; Toggle the even bits and the 
; odd bits are cleared from memory 
; location $ 2087.

begin:
    LDAA #55        ; -> Load mask - 0101 0101 
    EORA $2087      ; -> XOR mask -> toggle
    BCLR $2087, $55 ; -> Delete odd mem loc $2087 - 1010 1010
    STAA $2087      ; -> Save results at mem loc $2087