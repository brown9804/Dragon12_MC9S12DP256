;       Autor:
; Brown Ramírez, Belinda 
; López, José
; timna.brown@ucr.ac.cr
; jose.lopezpicado@ucr.ac.cr
; Feb, 2021

;##--------------------------------  INCLUDE ------------------------------------
#include  registers.inc 

; ;##--------------------------------  EXPLANING ------------------------------------
; SP <- $3bff [debug] | SP <- $4000 
; Byte = 1 Byte    
; Word = 2 Bytes
; For BANDERAS -> ; [X:X:X:X:ALERT:EMPTYING:TRANSMIT:MSJ_ID]    
;##--------- SERIAL PORT SETUP ----------------------------------------
; M = 0: 8-bit frame || M = 1: 9-bit frame
; PE = 0: parity bit is not used || PE = 1: parity bit is used
; PT = 1: odd parity || PT = 0: for even parity
; TE = 1: Enables data transmission
; TIE = 1: interrupt when Transmit Data Register Empty (TDRE) is activated.
; ## --------- ADC SETUP ------------------------------------ ----
; ATD0CTL2 [ADPU: AFFC: AWAI: ETRIGLE: ETRIGP: ETRGE: ASCIE: ASCIF]
; -> ADPU = 1: enables the ATD module
; -> AFFC = 1:
; -> ANSIE = 1: enable interrupts
; _______________________________________________________________________________
; ATD0CTL3 [0: S8C: S4C: S2C: S1C: FIFO: FRZ1: FRZ0]
; ---> ATD0CTL3 =% 00000000
; _______________________________________________________________________________
; ATD0CTL4 [SRES8: SMP1: SMP0: PRS4: PRS3: PRS2: PRS1: PRS0]
; -> PRS =% 10000 => 700 KHz
; _______________________________________________________________________________
; ATD0CTL5 [DJM: DSGN: SCAN: MULT: 0: CC: CB: CA]
; -> DJM = 1: justify the result to the right
; _______________________________________________________________________________


;##--------------------------------  DEFINITIONS ------------------------------------
;##------------  STRUCT VARIABLES --------------------------------------
SP:         EQU  $4000  
BYTE:       EQU  1      
WORD:       EQU  2     

;##------------  ASCII VARIABLES --------------------------------------                                                                   ==                                                                   ==
CarriageReturn:         EQU  $0D   
LineFeed:         EQU  $0A    
FinalStr:        EQU  $FF   
Substitute:         EQU  $1A   

;##------------  MAIN VARIABLES -----------------------------------------------------
                              ORG  $1000                          
BANDERAS:     DS  BYTE  
                              ORG  $1010
NIVEL_PROM:   DS  WORD
NIVEL:        DS  BYTE
VOLUMEN:      DS  BYTE
CONT_RTI:     DS  BYTE
BCD_H:        DS  BYTE
BCD_L:        DS  BYTE
LOW:          DS  WORD
TEMP:         DS  BYTE
PUNTERO:      DS  WORD
PTR_MSJ1:     DS  WORD
PTR_MSJ2:     DS  WORD

;##------------ TERMINAL MESSAGES ---------------------------------------------------------
PRINT_MSJ_VACIO:        DB    FinalStr

PRINT_MSJ_OPERACION:    DB    Substitute
                  FCC   "   UNIVERSIDAD DE COSTA RICA   "
                  DB    CarriageReturn,LineFeed
                  FCC   "ESCUELA DE INGENIERIA ELECTRICA"
                  DB    CarriageReturn,LineFeed
                  FCC   "       MICROPROCESADORES       "
                  DB    CarriageReturn,LineFeed
                  FCC   "            IE0623             "
                  DB    CarriageReturn,LineFeed
                  FCC   "                               "
                  DB    CarriageReturn,LineFeed
                  FCC   "VOLUMEN CALCULADO: "
PRINT_VOLUMEN_ASCII:    DS    3
                  DB    FinalStr

PRINT_MSJ_ALARMA:       DB    CarriageReturn,LineFeed,CarriageReturn,LineFeed
                  FCC   "Alarma: El Nivel esta Bajo"
                  DB    FinalStr

PRINT_MSJ_VACIADO:     DB    CarriageReturn,LineFeed,CarriageReturn,LineFeed
                  FCC   "Tanque vaciando, Bomba Apagada"
                  DB    FinalStr

;##------------ FLAG INTERRUPTION VECTORS  ---------------------------------------------------------                          
                  ORG $FFF0      ;RTI
                  DW  RTI_ISR   
                  
                  ORG $FFD4      ;RDRE
                  DW  SC1_ISR

                  ORG $FFD2      ;ATD0
                  DW  ATD0_ISR
                

;##--------- HARDWARE  SETUP ----------------------------------------
                              ORG   $2000            
      LDS   #SP              ; Stack pointer is placed at $ 4000

;##--------- RTI  SETUP ----------------------------------------
      BSET  CRGINT,$80       ; RTI interrupt is activated
      MOVB  #$54,RTICTL    ; M=9 , N=4 RTI = 10ms

;##--------- LEDS  SETUP ----------------------------------------
      MOVB  #$01,DDRB        ; PB0 -> outputs
      BSET  DDRJ,$02         ; LED enable                                   

;##--------- SERIAL PORT SETUP ----------------------------------------
      MOVW  #$27,SC1BDH  ; SC1BDH []   
      MOVB  #$00,SC1CR1  ; SC1CR1 [LOOPS:SCISWAI:RSRC:M:WAKE:ILT:PE:PT]   
      MOVB  #$88,SC1CR2  ; SC1CR2 [TIE:TCIE:RIE:ILIE:TE:RE:RWU:SBK]   

;##--------- ADC SETUP ----------------------------------------
      MOVB  #%11000010,ATD0CTL2  
      LDAA  #160
Delay:
      DECA                             
      TSTA
      BNE   Delay
      MOVB  #%00000000,ATD0CTL3        
      MOVB  #%00010000,ATD0CTL4   
      MOVB  #%10000000,ATD0CTL5   
                 
;##--------- INIT VARIABLES ----------------------------------------
      MOVB  #0,BANDERAS             ; BANDERAS   = 0
      MOVW  #0,Nivel_PROM           ; NIVEL_PROM = 0
      MOVB  #0,NIVEL                ; NIVEL      = 0
      MOVB  #0,VOLUMEN              ; VOLUMEN    = 0
      MOVW  #100,CONT_RTI           ; CONT_RTI   = 100
      MOVW  #PRINT_MSJ_OPERACION,PTR_MSJ1 ; MSJ1       = PRINT_MSJ_OPERACION
      MOVW  #PRINT_MSJ_VACIO,PTR_MSJ2     ; MSJ2       = MSJ_VACIO
      MOVW  PTR_MSJ1,PUNTERO        ; PUNTERO    = PTR_MSJ1
      CLI      

;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##-------------------------------- MAIN ------------------------------------
;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
BUCLE_PRINCIPAL:
      BRCLR  BANDERAS,%00000010,BUCLE_PRINCIPAL
CARGAR_INFO:
      BCLR   BANDERAS,%00000010 ; TRANSMIT <-- 0
      JSR    CALCULO
      JSR    BIN_BCD
      JSR    BCD_ASCII
      LDAA   VOLUMEN
      CMPA   #16
      BCS    MSJ2_ALARMA
      BRSET  BANDERAS,%00000100,MSJ2_VACIANDO
      CMPA   #95
      BHI    MSJ2_VACIANDO
      CMPA   #32
      BHI    MSJ2_COMUN
      BRSET  BANDERAS,%00001000,MSJ2_ALARMA
MSJ2_COMUN:
      BCLR  BANDERAS,%00001000
      MOVW  #PRINT_MSJ_VACIO, PTR_MSJ2
      JMP   TRANSMITIR
MSJ2_ALARMA:
      BSET  BANDERAS,%00001000    ; ALERT    <-- 1
      BCLR  BANDERAS,%00000100    ; EMPTYING <-- 0
      BSET  PORTB,%00000001
      MOVW  #PRINT_MSJ_ALARMA, PTR_MSJ2
      JMP   TRANSMITIR
MSJ2_VACIANDO:
      BSET  BANDERAS,%00000100    ; EMPTYING <-- 1
      BCLR  PORTB,%00000001
      MOVW  #PRINT_MSJ_VACIADO, PTR_MSJ2
TRANSMITIR:
      MOVB  #$88,SC1CR2
      LDAA  SC1SR1
      MOVB  #$0C,SC1DRL           ; init transmition
      JMP   BUCLE_PRINCIPAL


;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##-------------------------------- SUBROUTINES ------------------------------------
;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##--------- CALCULO ----------------------------------------
CALCULO:
      LDD   Nivel_PROM
      LDY   #15
      EMUL
      LDX   #767
      IDIV
      TFR   X,D
      STAB  NIVEL         ; (NIVEL)   <- ((Nivel_PROM)*15)/20
      LDAA  #7
      MUL
      STAB  VOLUMEN       ; (VOLUMEN) <- 7*(NIVEL)
RT_CALCULO:
      RTS

;##--------- BCD_ASCII ----------------------------------------
BCD_ASCII:
      LDX   #PRINT_VOLUMEN_ASCII
      LDAB  #0
HUNDREDS:
      LDAA  BCD_H
      ANDA  #$0F
      BEQ   LESS_100
      ADDA  #48
      STAA  B,X
      INCB
      JMP   TENS
LESS_100:
      MOVB  #$0C,B,X
      INCB
TENS:
      LDAA  BCD_L
      ANDA  #$F0
      LSRA
      LSRA
      LSRA
      LSRA
      ADDA  #48
      STAA  B,X
      INCB
UNITS:
      LDAA  BCD_L
      ANDA  #$0F
      ADDA  #48
      STAA  B,X
RT_BCD_ASCII:
      RTS

;##--------- BIN_BCD ----------------------------------------
BIN_BCD:
      LDAA   VOLUMEN
      LDY   #7
      MOVB  #0,BCD_L
      MOVB  #0,BCD_H
BIN_BCD_LOOP:
      LSLA
      ROL   BCD_L
      ROL   BCD_H
      STAA  TEMP
NIBBLES_CHECK:
      LDAA  #$0F
      ANDA  BCD_L
      CMPA  #$5
      BCS   NOT_ADD_TO_N0     ; Nibbe  inf < 5  JUMPS
      ADDA  #$3              ; climb 3 to the lower nibble
NOT_ADD_TO_N0:
      STAA  LOW
      LDAA  #$F0
      ANDA  BCD_L
      CMPA  #$50
      BCS   NOT_ADD_TO_N1     ; Top nibbe <5 jump
      ADDA  #$30            ; climb 3 to the top nibble
NOT_ADD_TO_N1:
      ADDA  LOW
      STAA  BCD_L
      LDAA  TEMP
      DBNE  Y,BIN_BCD_LOOP   ; Y! = 0 jumps
      LSLA
      ROL   BCD_L
      ROL   BCD_H
      RTS

;##---------RTI_ISR (INTERRUPTION) ----------------------------------------
RTI_ISR:
      BSET CRGFLG,$80         ; [OFF] RTI
      TST  CONT_RTI
      BEQ  RS_CONT_RTI        ; Jumps if (CONT_RTI) == 0
      DEC  CONT_RTI           ; (CONT_RTI) minus minus
      JMP  RT_ISR
RS_CONT_RTI:
      MOVB #100,CONT_RTI      ; CONT_RTI <- 100
      BSET BANDERAS,%00000010 ; TRANSMIT <- 1
RT_ISR:
      RTI                     ; Return


;##--------- SC1_ISR  (INTERRUPTION) ----------------------------------------
SC1_ISR:
      LDAA  SC1SR1
      LDX   PUNTERO
      LDAA  1,X+
      CMPA  #FinalStr
      BEQ   CHECK_FIN_T
      STAA  SC1DRL
      STX   PUNTERO
      JMP   RTN_SC1
CHECK_FIN_T:
      BRSET BANDERAS,%00000001,FIN_TRANS
      BSET  Banderas,%00000001
      MOVW  PTR_MSJ2,PUNTERO
      JMP   RTN_SC1
FIN_TRANS:
      MOVB  #$08,SC1CR2
      BCLR  Banderas,%00000001
      MOVW  PTR_MSJ1,PUNTERO
RTN_SC1:
      BSET  CRGINT,%10000000
      RTI


;##--------- ATD0_ISR  (INTERRUPTION) ----------------------------------------
ATD0_ISR:
      LDD   ADR00H
      ADDD  ADR01H
      ADDD  ADR02H
      ADDD  ADR03H
      ADDD  ADR04H
      ADDD  ADR05H ; D = (ADR00H)+(ADR01H)+(ADR02H)+(ADR03H)+(ADR04H)+(ADR05H)
      LDX #6
      IDIV
      STX Nivel_PROM    ; Nivel_PROM <-  D/6
      MOVB  #$80,ATD0CTL5
RETURN_ATD0:
      RTI