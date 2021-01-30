;       Autor:
; Brown Ramírez, Belinda 
; timna.brown@ucr.ac.cr


; Initial position of BClr is $E5

LDD #$FE3D 
LDX #$1030
LDAB #$10
STD b,X
;-
; B -> $1041 mem position ... value $FE
; A -> $1040 mem position ... value $E5
BSET b,X,$55 ; $FE | $55 = $FF (+)
BCLR a,X,$37 ; $E5 * ~($37) = $C0


LDD #$FE3D   ; 2 cycles
LDX #$1030   ; 2 cycles
LDAB #$10    ; 1 cycles
STD b,X      ; 2 cycles
BSET b,X,$55 ; 4 cycles
BCLR a,X,$37 ; 4 cycles 
;           --------------
;              15 cycles

;Time ----> 15 cycles ....
; (1/24 MHz) * 15 cycles = 6.25 ×10-9 seconds




