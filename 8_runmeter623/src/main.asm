;       Autor:
; Brown Ramírez, Belinda 
; López, José
; timna.brown@ucr.ac.cr
; jose.lopezpicado@ucr.ac.cr
; Feb, 2021

;                   ====================================
;*******************            INCLUSIONES             ************************
;                   ====================================

#include  registers.inc 

;                   ====================================
;*******************        ESTRUCTURAS DE DATOS        ************************
;                   ====================================

;                                            ===================================
;=*******************************************              MACROS 
;                                            ===================================   
SP:         Equ  $3bff  ; SP <- $3bff [debug] | SP <- $4000 
BYTE:       Equ  1      ; Byte = 1 Byte    
WORD:       Equ  2      ; Word = 2 Bytes

;========                                                                     ==
; ASCII  ***********************************************************************
;========                                                                     ==
CR:         Equ  $0D    ; Carriage Return
LF:         Equ  $0A    ; Line Feed
EOM:        Equ  $FF    ; Final de string
BS:         Equ  $08    ; BackSpace
CP:         Equ  $1A    ; Substitute


;                                            ===================================
;********************************************        VARIABLES PRINCIPALES 
;                                            ===================================  
                  Org  $1000                               

;BADERA =  [ X:X: CALC_TICKS :X: PANT_FLAG : ARRAY_OK : TCL_LEIDA : TCL_LISTA]
BANDERAS:         dS  BYTE  

;************************** [MODO_CONFIG]
NumVueltas:       dS  BYTE
ValorVueltas:     dS  BYTE

;************************** [TEREA_TECLADO]

MAX_TCL:          dB  2    ; Longitud de la secuencia
Tecla:            dS  BYTE ; Tecla pulsada
Tecla_IN          dS  BYTE ; tecla a ingresar
Cont_Reb:         dS  BYTE ; contador de rebotes
Cont_TCL:         dS  BYTE ; contador de teclas ingresadas
Patron:           dS  BYTE ; patron para la lectura del teclado metricial
Num_Array:        dS  WORD ; Secuencia ingresada
;************************** [ADT_ISR]
BRILLO:           dS  BYTE

;************************** [PANT_CTRL]
POT:              dS  BYTE
TICK_EN:          dS  WORD
TICK_DIS:         dS  WORD

;************************** [CALCULAR]
Veloc:            dS  BYTE
Vueltas:          dS  BYTE
VelProm:          dS  WORD

;************************** [TCNT_ISR]
TICK_MED:         Ds  WORD

;************************** [CONV_BIN_BCD]
BIN1:             dS  BYTE 
BIN2:             dS  BYTE 
BCD1:             dS  BYTE 
BCD2:             dS  BYTE 

;************************** [BIN_BCD]
BCD_L:            dS  BYTE 
BCD_H:            dS  BYTE 
TEMP:             dS  BYTE 
LOW:              dS  BYTE 

;************************** [BCD_7SEG]
DISP1:            dS  BYTE 
DISP2:            dS  BYTE 
DISP3:            dS  BYTE 
DISP4:            dS  BYTE 

;************************** [OC4_ISR]
LEDS:             dS  BYTE 
CONT_DIG:         dS  BYTE 
CONT_TICKS:       dS  BYTE 
DT:               dS  BYTE 
CONT_7SEG:        dS  WORD

;************************** [RTI_ISR]
CONT_200:         dS  BYTE

;************************** [SUBRUTINAS LCD]
Cont_Delay:       dS  BYTE 
D2mS:             dB  100
D260uS:           dB  13
D40uS:            dB  2
Clear_LCD:        dB  $01
ADD_L1:           dB  $80
ADD_L2:           dB  $C0

;************************** []
VelPromAnt:       dS  BYTE
MSJ_L1:           dS  WORD
MSJ_L2:           dS  WORD

;                                            ===================================
;********************************************              TABLAS
;                                            ===================================  

                  Org  $1040
Teclas:     dB   $01,$02,$03,$04,$05,$06,$07,$08,$09,$0B,$00,$0E 

                  Org  $1050
SEGMET:     dB   $3f,$06,$5b,$4f,$66,$6d,$7d,$07,$7f,$6f,$40,$00
                  
                  Org  $1060
initDisp:   db   $28,$28,$06,$0C
                 db  EOM

;                                            ===================================
;********************************************              MENSAJES 
;                                            ===================================  
                  Org  $1070

;**************************************** [MODO LIBRE]
MSJ_LIBRE_1:     fcc "  RunMeter 623  "
                 db EOM
MSJ_LIBRE_2:     fcc "   MODO LIBRE   "
                 db EOM

;**************************************** [MODO CONFIG]
MSJ_CONF_1:      fcc "   MODO CONFIG  "
                 db EOM
MSJ_CONF_2:      fcc "   NUM VUELTAS  "
                 db EOM

;**************************************** [MODO COMPETENCIA]
MSJ_RUNMETER:    fcc "  RunMeter 623  "
                 db EOM
MSJ_INICIAL:    fcc "  ESPERANDO...  "
                 db EOM
MSJ_COMP_1:      fcc " M.COMPETENCIA  "
                 db EOM
MSJ_COMP_2:      fcc "VUELTA    VELOC "
                 db EOM

MSJ_CALC:        fcc "  CALCULANDO... "
                 db EOM
MSJ_ALERT_1:     fcc "**  VELOCIDAD **"
                 db EOM
MSJ_ALERT_2:     fcc "*FUERA DE RANGO*"
                 db EOM
;**************************************** [MODO RESUMEN]
MSJ_RES_1:       fcc "  MODO RESUMEN  "
                 db EOM
MSJ_RES_2:       fcc "VUELTAS    VELOC"
                 db EOM

;                                            ===================================
;********************************************      VECTORES DE INTERRUPCION 
;                                            ===================================                
                  
                  Org    $3E70       ; Vector interrupcion RTI
                  dW     RTI_ISR      

                  Org    $3E66
                  dW     OC4_ISR

                  Org    $3E5E
                  dW     TCNT_ISR

                  Org    $3E4C
                  dW     CALCULAR

                  ;Org    $FFD2       ; Vector interrupcion ATD0
                  ;dw     ATD_ISR

;                   ====================================
;*******************        PROGRAMA PRINCIPAL          ************************
;                   ====================================

;                                            ===================================
;********************************************      CONFIGURACION DE HARWARE 
;                                            ===================================  
            Org   $2000            
      LDS   #SP              ; Se coloca el puntero de pila en $4000

;=======================                                                      ==
; Configuración de RTI  ********************************************************
;=======================                                                      ==
      BSET  CRGINT,$80       ; Se activa la interrupcion por RTI
      MOVB  #$17,RTICTL      ; M=1, N=7 rti = 1ms

;==========================
; CONFIGURACION DS7 Y LEDS *****************************************************
;========================== 

;[ PB3     | PB2         | PB1           | PB0   ]
;[ RESUMEN | COMPETENCIA | CONFIGURACION | LIBRE ]

      MOVB  #$FF,DDRB        ; PB7-PB0 -> salidas
      BSET  DDRJ,$02         ; LED enable                                   
      MOVB  #$0F,DDRP        ; PP3-PP0 -> salidas

;*****************************
; Configuración del puerto H ***************************************************
;*****************************
      bclr  DDRH,%11001001   ; PH7, PH1-PH0 -> entradas        

;=====================================                
;   CONFIGURACIÓN DE PANTALLA LCD     ******************************************
;=====================================
      MOVB #$FF, DDRK        ; PK7-PK0 -> salidas       

;========================                                                     
; Configuración del ADC  *******************************************************
;========================                                                     
; ATD0CTL2 [ADPU : AFFC : AWAI : ETRIGLE : ETRIGP : ETRGE : ASCIE : ASCIF]
;  --> ADPU  = 1 : habilita el módulo de ATD
;  --> AFFC  = 1 :
;  --> ANSIE = 1 : habilita las interrupciones
;===============================================================================
; ATD0CTL3 [0 : S8C : S4C : S2C : S1C : FIFO : FRZ1 : FRZ0] 
;  ---> ATD0CTL3 = %00000000
;===============================================================================
; ATD0CTL4 [SRES8: SMP1: SMP0: PRS4   : PRS3  :PRS2 :PRS1 :PRS0 ]
;  -->  PRS = %10011 = 19   BUS_CLK /[(PRS+1)*2] => 600 KHz
;  -->  SMP1 = 0 , SMP0 = 1 => 4 periodos de ATD
;===============================================================================
; ATD0CTL5 [DJM  : DSGN: SCAN: MULT   : 0     :CC   :CB   :CA   ]
;  --> DJM = 1 : justifica el resultado a la derecha
;===============================================================================
         
;         movb  #%11000010,ATD0CTL2  
;         ldaa  #160
;RETARDO: deca                             
;         tsta
;         bne   RETARDO
;         movb  #%00000000,ATD0CTL3        
;         movb  #%00110011,ATD0CTL4   
;         movb  #%10000000,ATD0CTL5    

;==========               
; TIMER 4  *********************************************************************
;==========
      BSET  TSCR1,%10010000  ; TEN = 1 ; TFFCA = 1.
      BSET  TSCR2,%00000011  ; Prescaler en 8
      MOVB  #%00010000,TIOS  ; Se asigna como salida el canal 4
      MOVB  #%00010000,TIE   ; enable interrupcion OC4    

;======================================                                       
; CONFIGURACIÓN DE TECLADO MATRICIAL   *****************************************
;======================================                                       
PORTA_CONF: MOVB  #$F0,DDRA    ; Parte alta salida, parte baja entrada             
            BSET  PUCR,1    
                 
;                                            ===================================
;********************************************    INICIALIZACION DE VARIABLES 
;                                            ===================================
            CLR   BANDERAS
            MOVB  #50,BRILLO

;************************************************************ [CALCULAR]
            CLR   Veloc
            CLR   Vueltas
            MOVW  #$00,VelProm

;************************************************************ [CONFIG]
            CLR  NumVueltas
            CLR  ValorVueltas

;************************************************************ [TEREA_TECLADO]
            LDX   #Num_Array    ; Se setea Num_Array
            LDAA  MAX_TCL
INIT_NUM_ARRAY: 
            DECA
            MOVB  #$FF, A,X
            TSTA
            BNE   INIT_NUM_ARRAY

            CLR   Tecla            
            MOVB  #$FF, Tecla_IN  
            CLR   Cont_Reb        
            CLR   Cont_TCL        
            CLR   Patron          

;************************************************************ [DS7]
            MOVB  #$BB,BIN1
            MOVB  #$BB,BIN2

;************************************************************ [OC4_ISR]
            CLR   LEDS   
            CLR   CONT_DIG  
            CLR   CONT_TICKS 
            CLR   DT        
            MOVW  #$00,CONT_7SEG
            movb  #$00,Cont_Delay     

            ldd  TCNT
            addd #60
            std  TC4
            cli 

;                                            ===================================
;********************************************        PROGRAMA PRINCIPAL
;                                            ===================================

              JSR   LCD
INIT_CONF:    JSR   CONFIG
              tst   NumVueltas
              beq   INIT_CONF

MAIN_LOOP:    BRSET PTIH,%01100000,JUMP_COMP
              BRSET PTIH,%01000000,JUMP_RESUMEN
              
              CLR   Veloc
              CLR   Vueltas
              CLR   VelProm
              BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH
              BCLR  TSCR2,%10000000  ; Se desactiva la Interrupcion TCNT
             
              BRSET PTIH,%00100000,JUMP_CONFIG
JUMP_LIBRE:   JSR   LIBRE
              BRA   MAIN_LOOP
JUMP_CONFIG:  MOVB  #$02,LEDS
              JSR   CONFIG
              BRA   MAIN_LOOP
JUMP_COMP:    BSET  PIEH,%00001001   ; Se activa la Interrupcion PTH
              BSET  TSCR2,%10000000  ; Se activa la Interrupcion TCNT

              MOVB  #$04,LEDS
              JSR   COMPETENCIA
              BRA   MAIN_LOOP
JUMP_RESUMEN: BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH
              JSR  RESUMEN
              BRA  MAIN_LOOP



;===============================================================================
;                   ====================================
;*******************            SUBRUTINAS              ************************
;                   ====================================
;===============================================================================


;                   ====================================
;*******************       SUBRUTINAS PRINCIPALES       ************************
;                   ====================================

;                                            ===================================
;********************************************              LIBRE 
;                                            ===================================

LIBRE:      MOVB  #$BB,BIN1
            MOVB  #$BB,BIN2
            MOVB  #$01,LEDS
            LDX   #MSJ_LIBRE_1
            LDY   #MSJ_LIBRE_2
            JSR   CARGAR_LCD  
            RTS

;                                            ===================================
;********************************************              CONFIG 
;                                            ===================================

CONFIG:     MOVW   #0,TICK_EN  
            MOVW   #0,TICK_DIS
            MOVB   NumVueltas,BIN1
            MOVB   #$BB,BIN2
            LDX    #MSJ_CONF_1
            LDY    #MSJ_CONF_2
            JSR    CARGAR_LCD  
            BRCLR  BANDERAS,%00000100,SET_VALORVUELTAS
            JSR    BCD_BIN
            LDAA   ValorVueltas
            CMPA   #5
            BLO    VV_INVALID
            CMPA   #25
            BHI    VV_INVALID
VV_VALID:   BCLR   BANDERAS,%00000100
            MOVB   ValorVueltas,NumVueltas
            MOVB   NumVueltas,BIN1
            RTS
VV_INVALID: BCLR   BANDERAS,%00000100
            CLR    NumVueltas
            CLR    ValorVueltas
            RTS
SET_VALORVUELTAS:
            JSR    TAREA_TECLADO
            RTS
;                                            ===================================
;********************************************            COMPETENCIA
;                                            ===================================

COMPETENCIA: BRSET BANDERAS,%00010000,CHECK_VELOC
             BSET  BANDERAS,%00010000
             MOVB  #$BB,BIN1 
             MOVB  #$BB,BIN2 
             LDX   #MSJ_RUNMETER 
             LDY   #MSJ_INICIAL 
             JSR   CARGAR_LCD  
CHECK_VELOC: TST   Veloc
             BEQ   RTN_COMP   
             JSR   PANT_CTRL 
RTN_COMP:    RTS
;                                            ===================================
;********************************************              RESUMEN 
;                                            ===================================
RESUMEN:    MOVB  VelProm,BIN1
            MOVB  Vueltas,BIN2
            MOVB  #$08,LEDS
            LDX   #MSJ_RES_1
            LDY   #MSJ_RES_2
            JSR   CARGAR_LCD   
            RTS

;                                            ===================================
;********************************************             PANT_CTRL 
;                                            ===================================

PANT_CTRL:  BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH
            ldaa  Veloc
            cmpa  #35
            blo   FUERA_DE_RANGO
            cmpa  #95
            bhi   FUERA_DE_RANGO
            BRA   EN_RANGO
FUERA_DE_RANGO:
            LDAA  BIN1
            CMPA  #$AA
            BEQ   CHECK_FLAG
            MOVW  #0,TICK_EN  
            MOVW  #138,TICK_DIS  
            MOVB  #$AA,BIN1
            MOVB  #$AA,BIN2
            ;BSET  BANDERAS,%00100000
            LDX   #MSJ_ALERT_1
            LDY   #MSJ_ALERT_2
            JSR   CARGAR_LCD   
            RTS
CHECK_FLAG: BRCLR BANDERAS,%00001000,nodo
            RTS
EN_RANGO:   BRCLR BANDERAS,%00100000,CALC_TICKS_0 
            BRSET BANDERAS,%00001000,PANT_FLG_1
PANT_FLG_0: LDAA  BIN1
            CMPA  #$BB 
            BEQ   RTN_PANT
nodo:       MOVB  #$BB,BIN1
            MOVB  #$BB,BIN2
            LDX   #MSJ_RUNMETER
            LDY   #MSJ_INICIAL
            JSR   CARGAR_LCD   
            LDAA  Vueltas
            CMPA  NumVueltas
            BEQ   RSET_VELOC  
            BSET  PIEH,%00001001   ; Se activa la Interrupcion PTH
PANT_FLG_1: LDAA  BIN1
            CMPA  #$BB
            BNE   RTN_PANT
            ; Enviar mensaje de competencia
            LDX   #MSJ_COMP_1
            LDY   #MSJ_COMP_2
            JSR   CARGAR_LCD   

            MOVB  Vueltas,BIN1
            MOVB  Veloc,BIN2
            RTS
RSET_VELOC: BCLR  BANDERAS,%00100000
            CLR   Veloc
            RTS
CALC_TICKS_0: 
            BSET  BANDERAS,%00100000
            ;CALCULAR TICKS_EN
            LDD   #33000    ; factor
            LDX   Veloc
            EDIV            ; Veloc = factor/ Veloc
            STY  TICK_EN
            ;CALCULAR TICKS_DIS
            LDD   #49500    ; factor
            LDX   Veloc
            EDIV            ; Veloc = factor/ Veloc
            STY   TICK_DIS
RTN_PANT:   RTS


;                   ====================================
;*******************    SUBRUTINAS DE LA PANTALLA LCD    ***********************
;                   ====================================


;                                            ===================================
;********************************************                LCD
;                                            ===================================
LCD:        ldx   #initDisp
SEND_CMD:   ldaa  1,X+
            cmpa  #EOM
            beq   RTN_LCD  
            jsr   Send_Command              
            movb  D40uS,Cont_Delay
            jsr   DELAY                     
            bra   SEND_CMD                   
RTN_LCD:    ldaa  Clear_LCD                 
            jsr   Send_Command
            movb  D2mS,Cont_Delay           
            jsr   DELAY
            rts

;                                            ===================================
;********************************************             CARGAR_LCD
;                                            ===================================
CARGAR_LCD:    
SET_L1:         ldaa  ADD_L1                     
                jsr   Send_Command
                movb  D40uS,Cont_Delay
                jsr   DELAY
SEND_L1_MSG:    ldaa  1,X+                       
                cmpa  #EOM
                beq   SET_L2
                jsr   Send_Data
                movb  D40uS,Cont_Delay           
                jsr   DELAY
                bra   SEND_L1_MSG
SET_L2:         ldaa  ADD_L2
                jsr   Send_Command              
                movb  D40uS,Cont_Delay
                jsr   DELAY
SEND_L2_MSG:    ldaa  1,Y+                      
                cmpa  #EOM
                beq   RTN_CARGAR_LCD
                jsr   Send_Data
                movb  D40uS,Cont_Delay 
                jsr   DELAY
                bra   SEND_L2_MSG
RTN_CARGAR_LCD: rts
;                                            ===================================
;********************************************            SEND_COMMAND
;                                            ===================================
SEND_COMMAND:   psha                      ; Se apila a
                anda  #$F0                ; Se seleccionan el nibble superrior
                lsra
                lsra                      ; X2 : 0 -> (A) -> C    
                staa  PORTK               ; Se pone la parte alta del cmd en PK   
                bclr  PORTK,%00000001                 
                bset  PORTK,%00000010                
                movb  D260uS,Cont_Delay
                jsr   DELAY               ; Se aguardan los 260us del protocolo     
                bclr  PORTK,%00000010                  
                pula                      ; Se desapila a
                anda  #$0F
                lsla
                lsla                      ; X2 : 0 << (A) << C
                staa  PORTK               ; Se pone la parte baja del cmd en PK        
                bclr  PORTK,%00000001                   
                bset  PORTK,%00000010                  
                movb  D260uS,Cont_Delay         
                jsr   DELAY               ; Se aguardan los 260us del protocolo  
                bclr  PORTK,%00000010                    
                rts
;                                            ===================================
;********************************************             SEND_DATA
;                                            ===================================
SEND_DATA:      psha                      ; Se apila a
                anda  #$F0                ; Se seleccionan el nibble superrior
                lsra
                lsra                      ; X2 : 0 >> (A) >> C
                staa  PORTK               ; Se pone la parte alta del cmd en PK    
                bset  PORTK,%00000001       
                bset  PORTK,%00000010                  
                movb  D260uS,Cont_Delay     
                jsr   DELAY               ; Se aguardan los 260us del protocolo  
                bclr  PORTK,%00000010                    
                pula                      ; Se desapila a
                anda  #$0F
                lsla
                lsla                      ; X2 : 0 << (A) << C
                staa  PORTK               ; Se pone la parte baja del cmd en PK          
                bset  PORTK,%00000001                 
                bset  PORTK,%00000010                    
                movb  D260uS,Cont_Delay        
                jsr   DELAY               ; Se aguardan los 260us del protocolo  
                bclr  PORTK,%00000010                  
                rts

;                                            ===================================
;********************************************               DELAY
;                                            ===================================
DELAY:      tst  Cont_Delay
            bne  DELAY
            rts

;                   ====================================
;*******************       SUBRUTINAS DE LOS DS7        ************************
;                   ====================================


;                                            ===================================
;********************************************           CONV_BIN_BCD
;                                            ===================================
CONV_BIN_BCD:   ldaa  BIN1
                cmpa  #99
                bhi   BIN1_P_99
                jsr   BIN_BCD
                ldaa  BCD_L
                anda  #$F0
                bne   STORE_BCD1
                ldaa  BCD_L
                adda  #$B0
                staa  BCD_L
                BRA   STORE_BCD1           
BIN1_P_99:      MOVB  BIN1,BCD_L
STORE_BCD1:     movb  BCD_L,BCD1
                ldaa  BIN2
                cmpa  #99
                bhi   BIN2_P_99
                jsr   BIN_BCD
                ldaa  BCD_L
                anda  #$F0
                bne   STORE_BCD2
                ldaa  BCD_L
                adda  #$B0
                staa  BCD_L
                BRA   STORE_BCD2
BIN2_P_99:      MOVB  BIN2,BCD_L
STORE_BCD2:     movb  BCD_L,BCD2
                rts

;                                            ===================================
;********************************************             BIN_BCD
;                                            ===================================
BIN_BCD:        ldy   #7
                CLR   BCD_L
BIN_BCD_LOOP:   lsla
                rol   BCD_L             
                staa  TEMP
NIBBLES_CHECK:  ldaa  #$0F              
                anda  BCD_L
                cmpa  #$5
                blo   NOT_ADD_TO_N0     ; Nibbe inferior < 5  salta
                adda  #$3               ; se sube 3 al nibble inferior
NOT_ADD_TO_N0:  staa  LOW
                ldaa  #$F0
                anda  BCD_L
                cmpa  #$50
                blo   NOT_ADD_TO_N1     ; Nibbe superior < 5  salta
                adda  #$30              ; se suba 3 al nibble superior
NOT_ADD_TO_N1:  adda  LOW
                staa  BCD_L
                ldaa  TEMP
                dbne  Y,BIN_BCD_LOOP    ; Y != 0 salta
                lsla
                rol   BCD_L            
                rts

;                                            ***********************************
;********************************************* BCD_7SEG
;                                            ***********************************
;                                                   [DSP1][DSP2] | [DSP3][DSP4]
;                                                   [   BCD2   ] | [   BCD1   ]
BCD_7SEG:       ldx  #SEGMET 
SET_DISP1:      movb #0,DISP1   ; Por defecto DISP1 = 0
                ldaa BCD2
                anda #$F0
                cmpa #$B0
                beq  SET_DISP2  ; si no es cero se carga su valor indexando en
                lsra            ; SEGMENT
                lsra
                lsra
                lsra
                movb A,X,DISP1  ; Se carga DISP1
SET_DISP2:      ldaa BCD2
                anda #$0F
                movb A,X,DISP2  ; Se carga DISP2
SET_DISP3:      movb #0,DISP3   ; Por defecto DISP3 = 0
                ldaa BCD1
                anda #$F0
                cmpa #$B0
                beq  SET_DISP4  ; si no es cero se carga su valor indexando en
                lsra            ; SEGMENT
                lsra
                lsra
                lsra
                movb A,X,DISP3  ; Se carga DISP3
SET_DISP4:      ldaa #$0F
                anda BCD1
                movb A,X,DISP4  ; Se carga DISP4
RTN_BCD_7SEG:   rts


;                   ====================================
;*******************  SUBRUTINAS DEL TECLADO MATRICIAL  ************************
;                   ====================================

;                                            ===================================
;********************************************           TAREA_TECLADO 
;                                            ===================================
; TAREA_TECLADO:  Esta subrutina  será  la  encargada  de  llamar  a  la  
; subrutina MUX_TECLADO para  que  capture  una  tecla  presionada.  Además  
; esta  subrutina realizará  las  acciones  para  suprimir  los  rebotes  y para
; definir el  concepto  de  tecla retenida, leyendo la tecla hasta que la misma
; sea liberada. En esta subrutina se carga el Cont_Reb cuando se detecta una 
; tecla presionada, se valida si la tecla presionada es válida,  comparando  dos  
; lecturas  de  la  misma  luego  de  la  supresión  de  rebotes. Finalmente  
; la  Tarea_Teclado  debe  llamar  a  la  subrutina  FORMAR_ARRAY  cuando 
; determine  que  una  tecla  ha  sido  leída  de  manera  correcta  
; (TCL_LISTA  =1). Esta subrutina debe ser implementada según el diseño 
; discutido en el video.

TAREA_TECLADO:      tst    Cont_Reb
                    bne    TAREA_RETURN                    
                    jsr    MUX_TECLADO
                    ldaa   #$FF
                    cmpa   Tecla
                    bne    TECLA_PRESIONADA      
                    brset  BANDERAS,%00000001,AGREGAR_TECLA    
                    bra    TAREA_RETURN
TECLA_PRESIONADA:   brset  BANDERAS,%00000010,TECLA_PROCESADA  
                    movb   Tecla,Tecla_IN
                    bset   BANDERAS,%00000010                  ; Tecla leida
                    movb   #$0A,Cont_Reb
                    bra    TAREA_RETURN
TECLA_PROCESADA:    ldab   Tecla
                    cmpb   Tecla_IN
                    beq    TECLA_LISTA
ERROR_DE_LECTURA:   movb   #$FF,Tecla
                    movb   #$FF,Tecla_IN
                    bclr   BANDERAS,%00000011
                    bra    TAREA_RETURN
TECLA_LISTA:        bset   BANDERAS,%00000001                  ; Tecla lista
                    bra    TAREA_RETURN
AGREGAR_TECLA:      bclr   BANDERAS,%00000011
                    jsr    FORMAR_ARRAY
                    bra    TAREA_RETURN
TAREA_RETURN:       rts


;                                            ===================================
;********************************************             MUX_TECLADO 
;                                            ===================================
; MUX_TECLADO: Esta subrutina es la encargada de leer el teclado propiamente.
; El teclado matricial deberá leerse de manera iterativa enviando uno de los 4
; patrones ($EF, $DF, $BF, $7F) al  puerto A. Se una variable denominada PATRON
; que  se  cargará  con  el  patrón inicial  y  se  irá  desplazando  la  
; posición  del  cero  hasta cubrir todos los patrones. Para la lectura del 
; teclado NO se debe leer los patrones, en su lugar  se  debe  buscar  cuál  
; bit  de  la  parte  baja  del  puerto  A  está en  cero  para identificar la
; tecla presionada, de esta manera solo hay 3 posibilidades. El valor de la 
; tecla presionada deberá ser devuelto, al procedimiento que ha llamado esta
; subrutina, por medio de la variable Tecla. Esta subrutina no recibe ningún 
; parámetro. Subrutina  

MUX_TECLADO:    ldx    #Teclas
                ldaa   #$00
                ldab   #$F0
                movb   #$EF,Patron
SCAN_MATRIZ:    movb   Patron, PORTA
                brclr  PORTA,%00000010, COL_1 ; Se examina para ver si alguna
                brclr  PORTA,%00000100, COL_2 ; de las columnas de la fila 
                brclr  PORTA,%00001000, COL_3 ; selecionada esta en bajo
                adda   #3            ;  se corre 3 espacios para indexar             
                lsl    Patron        ;  correctamente en Teclas
                ldab   #$F0
                cmpb   Patron
                bne    SCAN_MATRIZ    
                movb   #$FF, Tecla   ; ninguna tecla fue pulsada
                bra    RETURN_MUX
COL_3:          INCA      ; como el la columna 3 se suman dos unidades
COL_2:          INCA      ; columna 2 se suma una unidad
COL_1:          movb A,X,Tecla ; se guarda en Tecla el valor correspondiente
RETURN_MUX:     rts       
;                                            ===================================
;********************************************            FORMAR_ARRAY 
;                                            ===================================
; FORMAR_ARRAY: Esta subrutina recibe el valor de la tecla presionada válida en 
; la variable Tecla_IN. Además cuenta con el valor de la constante que define 
; cuál es la longitud  máxima  de  la  secuencia  de  teclas  almacenado  en  
; MAX_TCL, esta constante  podrá  tener  un  valor  entre  1  y  6. La  
; subrutina debe  colocar  de  manera ordenada  los  valores  de  las  teclas  
; recibidas  en  Tecla_IN  en  un  arreglo  denominado Num_Array.  La  
; subrutina  utilizará  una  variable  llamada  Cont_TCL  para  almacenar  el
; número de tecla en Num_Array. Este arreglo debe ser accesado por 
; direccionamiento indexado por acumular B (cargando en B el contenido de 
; Cont_TCL). Cada vez que se ingrese a FORMAR_ARRAY se debe validar primero si
; se alcanzó MAX_TCL de ser así se  valida  si  la  nueva  tecla  recibida  
; en  Tecla_IN  es  $0E  (Enter)  en  cuyo  caso  se  hace ARRAY_OK =1   
; indicando que se finalizó el Num_Array y se repone Cont_TCL=0, para que 
; quede listo para una nueva secuencia de entrada. Si lo que se recibió en
; Tecla_IN es $0B se deberá poner $FF en la actual posición de Num_Array y
; descontar Cont_TCL, solo si este no es cero, para que en la próxima 
; iteración (nuevo ingreso de una tecla) esta  sea  almacenada  en  la  
; posición  anterior  (función  de  borrado).  Lo  indicado, respecto  a  
; recepción  en  FORMAR_ARRAY  de  una  tecla  E  o  B,  aplica  en  
; cualquier momento que se reciba una tecla en Tecla_IN, excepto con la 
; primera tecla, pues si se recibe como primera tecla $0B o $0E estás deben
; ser ignoradas. Debe recordarse que cuando Cont_TCL alcance el valor de 
; MAX_TCL las únicas teclas válidas a procesar son E y B, cualquier otra 
; tecla presionada debe ser ignorada. Finalmente debe notarse que la 
; secuencia ingresada se termina con una tecla E y su longitud puede ser
; cualquiera entre 1 y MAX_TCL. Además cuando se termina la secuencia de
; teclas se pone en 1 la bandera ARRAY_OK.

FORMAR_ARRAY:       ldaa  Cont_TCL
                    cmpa  MAX_TCL
                    bne   NO_ULTIMA_TCL                   
ULTIMA_TCL:         ldaa  #$0B
                    cmpa  Tecla_IN    
                    beq   BORRAR 
                    ldaa  #$0E
                    cmpa  Tecla_IN 
                    beq   ENTER
                    bra   RETURN_FORMAR
NO_ULTIMA_TCL:      tst   Cont_TCL
                    beq   PRIMERA_TCL
NO_PRIMERA_TCL:     ldaa  #$0B
                    cmpa  Tecla_IN    
                    beq   BORRAR 
                    ldaa  #$0E
                    cmpa  Tecla_IN    
                    beq   ENTER
                    bra   GUARDAR_TCL
PRIMERA_TCL:        ldaa  #$0B
                    cmpa  Tecla_IN 
                    beq   RETURN_FORMAR 
                    ldaa  #$0E
                    cmpa  Tecla_IN    
                    beq   RETURN_FORMAR
                    bra   GUARDAR_TCL
BORRAR:             dec   Cont_TCL
                    ldx   #Num_Array
                    ldaa  Cont_TCL
                    movb  #$FF,A,X
                    bra   RETURN_FORMAR
ENTER:              bset  BANDERAS,%00000100                  ; Array Ok
                    movb  #$00,Cont_TCL
                    bra   RETURN_FORMAR
GUARDAR_TCL:        ldaa  Cont_TCL
                    ldx   #Num_Array
                    movb  Tecla_IN,A,X 
                    inc   Cont_TCL
RETURN_FORMAR:      movb  #$FF,Tecla_IN
                    rts

;                                            ===================================
;********************************************             BCD_BIN  
;                                            ===================================

BCD_BIN:    ldx   #Num_Array
            ldab  1,X+    
            ldaa  #10                       
            mul                 ; Se multiplica por 10 el digito de las decenas    
            addb  1,X+          ; Se suma el digito de las unidades                   
            stab  ValorVueltas  ; Se guarda el valor en  ValorVueltas
            rts 



;                   ====================================
;*******************     SUBRUTINAS DE INTERRUPCION     ************************
;                   ====================================


;                                            ===================================
;********************************************             RTI_ISR 
;                                            ===================================


RTI_ISR:            BSET  CRGFLG, %10000000
                    TST   Cont_Reb
                    BEQ   CHECK_ADC
                    DEC   Cont_Reb
CHECK_ADC:          LDAA  CONT_200
                    CMPA  #200
                    BEQ   INIT_CONV
                    INC   CONT_200
                    BRA   RETURN_RTI   
INIT_CONV:          CLR   CONT_200
                    movb  #%10000000,ATD0CTL5 
RETURN_RTI:         rti

;                                            ===================================
;********************************************             ATD_ISR 
;                                            ===================================

;                                            ===================================
;********************************************             ATD0_ISR 
;                                            ===================================
ATD0_ISR:     ldd   ADR00H   
              addd  ADR01H   
              addd  ADR02H   
              addd  ADR03H   
              addd  ADR04H  
              addd  ADR05H
              ; D = (ADR00H)+(ADR01H)+(ADR02H)+(ADR03H)+(ADR04H)+(ADR05H) 
              ldx   #6
              idiv
              STX   POT
              XGDX          ; D <-- POT
              LDY   #20     ; Y <-- 20
              EMUL          ; Y <-- POT * 20 
              XGDY          ; D <-- POT * 20
              LDX   #255    ; X <-- 255
              IDIV          ; X <-- (POT * 20) / 255 
              STX   BRILLO  ; (BRILLO) <-  (POT * 20) / 255
RTN_ATD0:     RTI

;                                            ===================================
;********************************************             TCNT_ISR 
;                                            ===================================

TCNT_ISR:         LDD   TCNT
                  LDX   TICK_MED
                  INX
                  STX   TICK_MED  
CHECK_TICK_EN:    LDX   TICK_EN
                  BEQ   SET_PANT_FLG
                  DEX
                  STX   TICK_EN
                  BRA   CHECK_TICK_DIS
SET_PANT_FLG:     BSET  BANDERAS,%00001000  
CHECK_TICK_DIS:   LDX   TICK_DIS
                  BEQ   CLR_PANT_FLG
                  DEX
                  STX   TICK_DIS
                  BRA   RTN_TCNT
CLR_PANT_FLG:     BCLR  BANDERAS,%00001000 
RTN_TCNT:         RTI


;
;                                            ===================================
;********************************************             CALCULAR 
;                                            ===================================

CALCULAR:   tst     Cont_Reb
            beq     PROC_PH0
            MOVB    #10,Cont_Reb  
;***********************
; SUPRECION DE REBOTES *********************************************************
;***********************
PROC_REB:   brset  PIFH,%00000001,REB_PH0 
            brset  PIFH,%00001000,REB_PH3
REB_PH0:    bset  PIFH,%00000001

            bra   RETURN_PH0
REB_PH3:    bset  PIFH,%00001000
            bra   RETURN_PH0
;********************************
; PROCESAMIENTO DE INTERRUPCION ************************************************
;******************************** 
PROC_PH0:   brset   PIFH,%00001000,PH3_S1 
            brset   PIFH,%00000001,PH0_S2
PH0_S2:     bset  PIFH,%00000001
            ; Calculo Veloc
            LDY   #0
            LDD   #9082     ; factor =(55*5000)/109
            LDX   TICK_MED
            EDIV            ; Veloc = factor/ TICK_MED
            XGDY
            STAB  Veloc 
            ; Calculo de VelProm
            LDAA  Vueltas
            cmpa  #1
            BEQ   VUELTA_0 
            LDY   Vueltas
            LDD   VelPromAnt
            DEY
            EMUL 
            ADDA  Veloc
            LDX   Vueltas
            EDIV
            XGDY
            STAB  VelProm
            STAB  VelPromAnt
            MOVB  #45,VelProm
            MOVB  #36,Veloc
            BRA   RETURN_PH0
VUELTA_0:   MOVB  Veloc,VelProm
            MOVB  #45,VelProm
            MOVB  #36,Veloc

PH3_S1:     bset  PIFH,%00001000
            MOVW  #0,TICK_MED
            INC   Vueltas
            CLI
            LDX   #MSJ_RUNMETER
            LDY   #MSJ_CALC
            JSR   CARGAR_LCD  
RETURN_PH0: rti

;                                            ===================================
;********************************************             OC4_ISR
;                                            ===================================
   
OC4_ISR:            ldd   CONT_7SEG
                    cpd   #5000
                    beq   UPDATE_DISPN
INC_CONT_7SEG:      addd  #1
                    std   CONT_7SEG
                    bra   UPDATE_CONT_DELAY
UPDATE_DISPN:       movw  #0,CONT_7SEG
                    jsr   CONV_BIN_BCD
                    jsr   BCD_7SEG
UPDATE_CONT_DELAY:  tst   Cont_Delay
                    beq   MULTIPLEXER
DEC_CONT_DELAY:     dec   Cont_Delay
MULTIPLEXER:        ldaa  CONT_TICKS
                    cmpa  #100
                    beq   SELECT_DISPLAY
RT_BRILLO:          ldab  #100
                    subb  BRILLO
                    stab  DT
                    cmpb  CONT_TICKS
                    bne   INC_CONT_TICKS
                    movb  #$FF,PTP          
                    bset  PTJ,$02 
INC_CONT_TICKS:     inc   CONT_TICKS
                    ldd   TCNT
                    addd  #60
                    std   TC4
                    rti
SELECT_DISPLAY:     ldaa  CONT_DIG
                    cmpa  #4        
                    beq   SELECT_LEDS
                    bset  PTJ,$02
                    cmpa  #3        
                    beq   SELECT_DISP4
                    cmpa  #2        
                    beq   SELECT_DISP3
                    brset BANDERAS,%00001000,M_CONF
                    cmpa  #1        
                    beq   SELECT_DISP2             
SELECT_DISP1:       movb  #$FE,PTP
                    movb  DISP1,PORTB                     
                    bra   INC_CONT_DIG
SELECT_DISP2:       movb  #$FD,PTP
                    movb  DISP2,PORTB  
                    bra   INC_CONT_DIG
SELECT_DISP3:       movb  #$FB,PTP
                    movb  DISP3,PORTB  
                    bra   INC_CONT_DIG
SELECT_DISP4:       movb  #$F7,PTP
                    movb  DISP4,PORTB  
                    bra   INC_CONT_DIG
SELECT_LEDS:        movb  #$0F,PTP                
                    movb  LEDS,PORTB           
                    bclr  PTJ,$02
                    bra   INC_CONT_DIG     
M_CONF:             movb  #$FF,PTP
                    bra   INC_CONT_DIG
INC_CONT_DIG:       movb  #0,CONT_TICKS
                    ldaa  CONT_DIG
                    cmpa  #4
                    beq   RST_CONT_DIG
                    inc   CONT_DIG
                    bra   RETURN_OC4
RST_CONT_DIG:       movb  #$00,CONT_DIG
RETURN_OC4:         ldd  TCNT
                    addd #60
                    std  TC4
                    rti
