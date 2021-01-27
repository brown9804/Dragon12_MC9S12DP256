;       Autor:
; Brown Ramírez, Belinda
; timna.brown@ucr.ac.cr
; Jan, 2021

; 2 routines

;BIN-BCD: 12 bits binary using XS3 algorithm, binary number is in D
;and results goes to NUM_BCD from $1010 mem position

;BCD-BIN: Multiplication of decades and addition algorithm,
;BCD >= 9999 binary number is in D. Results are saved NUM_BIN
;from $1020.

; ----
; BIN value $1000-$1001
; BCD value $1002-$1003

; FYI -> program started in $2000

; 1. BIN to D accumulador.
; 2. BIN - BCD
; 3. BCD to D accumulador.
; 4. BCD - BIN

;##--------------------------------  DEFINITIONS ------------------------------------
BIN: EQU $1000
BCD: EQU $1002
NUM_BCD: EQU $1010 ; BIN-BCD results from this position
NUM_BIN: EQU $1020 ; BCD-BIN results from this position
	ORG $1000 ; Flash ROM address for Dragon12+
	DW #5 ; send value
	ORG $1002 ; Flash ROM address for Dragon12+
	DW #8 ; send value

;##--------------------------------  SPACE storage  ------------------------------------
	ORG $1100 ; Flash ROM address for Dragon12+
tail_val: DS 2
B_val: DS 2

;##-------------------------------- MAIN ------------------------------------
_init:
    ORG         $2000
    LDY #0
    LDD BIN
    JMP _BIN_BCD

BCDtoBIN:
    LDY #0
    LDX #0
    LDD BCD
    JMP _BCD_BIN

FINAL_END:
    JMP FINAL_END

;##-------------------------------- DEF BIN-BCD ------------------------------------
;# STEPS:
;# 1. Find the decimal equivalent of the given binary number.
;# 2. Add +3 to each digit of decimal number.
;# 4. Convert the newly obtained decimal number back to binary
;# number to get required excess-3 equivalent.

_BIN_BCD:
    LDX #15
    CLR NUM_BCD
    CLR NUM_BCD+1
    LDY NUM_BCD

COMP4Bytes:
	ASLD       ; shift double
    ROL NUM_BCD+1
    ROL NUM_BCD
    STD tail_val
    LDD NUM_BCD+1
   	ANDB #$0F
   	CMPB #5
   	BCS COMP_B
	ADDB #3

COMP_B:
	STAB B_val
	LDAB NUM_BCD+1
	CLRA
    ANDB #$F0
    CMPB #$50
   	BCS  COMP_C
    ADDD #$30 ; if B is $50

COMP_C:
	ADDB B_val
	ADCA #0
    STAB NUM_BCD+1
    ADDA NUM_BCD
    STAA NUM_BCD
    LDAB NUM_BCD
    ANDB #$0F
    CMPB #5
    BCS  storeNUM_BCD
    ADDB #3
    CLRA

storeNUM_BCD:
    STAB B_val
    LDAB NUM_BCD
    ANDB #$F0
    ADDB B_val
    STAB NUM_BCD
    LDD tail_val
    DEX
    BEQ X_0_value
    JMP COMP4Bytes

X_0_value:
    ASLD
    ROL  NUM_BCD+1
    ROL  NUM_BCD
    JMP  BCDtoBIN


;##-------------------------------- DEF BCD-BIN ------------------------------------
_BCD_BIN:
    CLR  NUM_BIN
    CLR  NUM_BIN+1

_BCD_BIN_COMP4Bytes:
    ANDB #$0F
    STAB NUM_BIN+1

_BCD_BIN_COMP_B:
    LDAB BCD+1
    ANDB #$F0

_BCD_BIN_TranformB:
    LSRB ; B -> x0 to $0x
    LSRB
    LSRB
    LSRB
    LDAA #10 ; A = B * 10
    MUL ; A:B
    ADDB NUM_BIN+1
    STAB NUM_BIN+1

_BCD_BIN_COMP_C:
    LDAA BCD
    ANDA #$0F
    LDAB #100
    MUL
    ADDD NUM_BIN
    STD NUM_BIN

_BCD_BIN_LAST_COMP:
    LDAB BCD
    ANDB #$F0

_BCD_BIN_TranformA:
    LSRA ; A -> x0 to $0x
    LSRA
    LSRA
    LSRA
    CLRA
    LDY #1000 ; load index
    EMUL
    ADDD NUM_BIN
    STD NUM_BIN

_BCD_BIN_end:
    JMP FINAL_END
