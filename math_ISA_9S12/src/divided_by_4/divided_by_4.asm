;       Autor:
; Brown Ramírez, Belinda 
; timna.brown@ucr.ac.cr
; Jan, 2021

; To calculate if a number is divided by four 
; we need to consider the last two digit of a number 
; if it's divided by four or if this two digit are zero.

;##--------------------------------  DEFINITIONS ------------------------------------
        ORG $1000
L: DB 8 ; because are 8 samples 
CANT4: DS $1
        ORG $1100
DATOS: DB $FF,$FE,$87,$38,$7,$58,$34,$47
        ORG $1200
DIV4: DS 255


;##-------------------------------- MAIN ------------------------------------
        ORG $2000
_init:       
       CLR CANT4   ; cant 4 -> 0
       LDX #DATOS
       LDY #DIV4
       LDAA L
       CLRB

forloop:       
        LDAA 0,X
        CMPA #0             ; compare with zero after rotate
        BGE analyze_carry   ; analyze
        NEGA ; negate value 

analyze_carry:
        LSRA
        BLO query ; go to next item 
        LSRA
        BLO query ; go to next item 
        INC  CANT4; + 1 count  
        MOVB 0,X,1,Y+        ; ->> array

query:
        INCB
        CMPB L ; is the last item?
        BHS end 
        INX 
        JMP forloop
        
end:           
        JMP end

