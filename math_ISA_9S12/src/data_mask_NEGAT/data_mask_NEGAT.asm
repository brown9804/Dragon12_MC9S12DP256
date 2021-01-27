;       Autor:
; Brown Ram?rez, Belinda
; timna.brown@ucr.ac.cr
; Jan, 2021


;##--------------------------------  DEFINITIONS ------------------------------------
temp_NEGAT: DW $1300
        ORG $1000
J: DS 2
K: DS temp_NEGAT
temp: EQU 2

        ORG $1050 ; Flash ROM address for Dragon12+
DATOS: DB -8,-68,$28,$71,$39,$82,$91,-19
    DB $93,-80,$60,$71,-3,1,-1,$80

        ORG $1150 ; Flash ROM address for Dragon12+
MASCARAS: DB $1,$2,$1,$98,-2,$35,$87,-4
    DB $93,$4,$80,-36,$31,$25,$0,$FE

        ORG $1300 ; Flash ROM address for Dragon12+
NEGAT: DS 1000

;##-------------------------------- MAIN ------------------------------------
        ORG $2000 ; Flash ROM address for Dragon12+
_init:
    	LDY #MASCARAS
    	STY J
    	LDX  #DATOS
    	MOVW #NEGAT, K ; save result NEGAT
    	MOVW #DATOS-1, temp

loopValue:  ; Find value and move to selected
    	LDAA #$80
    	CMPA 1,X+
    	BNE loopValue
   	DEX   ; -1
    	DEX   ; -1     ---> last data

forloop:
	LDAB #$FE
	CMPB $0,Y               ; skip if end mask
	BEQ end
	CPX temp
	BEQ end                 ; skip if end data
	LDAA 1,X-
	EORA 1,Y+             	; Mask applied -> XOR
	TAB                     ; A -> B
	ASLB
	BHS forloop
	STY J
	LDY K
	STAA 1,Y+               ; store negat
	STY K
	LDY J
	JMP forloop

end:
    JMP end