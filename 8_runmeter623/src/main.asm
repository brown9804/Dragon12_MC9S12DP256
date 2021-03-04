;======================================================================================================
;                                      UNIVERSIDAD DE COSTA RICA                                      *
;                                   ESCUEA DE INGENIERÍA ELÉCTRICA                                    *
;                                      IE-0623 MICROPROCESADORES                                      *
;                                      JOSE LÓPEZ PICADO B43869                                       *
;                                 TIMNA BELINDA BROWN RAMIREZ B61254                                  *
;======================================================================================================
;                                        PROYECTO: RUNMETER 623                                       * 
;======================================================================================================


;                                 ====================================
;---------------------------------            INCLUSIONES             ---------------------------------
;                                 ====================================

#include  registers.inc 

;                                 ====================================
;---------------------------------        ESTRUCTURAS DE DATOS        ---------------------------------
;                                 ====================================

;                                                                   ===================================
;-------------------------------------------------------------------              MACROS 
;                                                                   ===================================   

SP:              Equ  $3bff   ; SP <- $3bff [debug] | SP <- $4000 
BYTE:            Equ  1       ; Byte = 1 Byte    
WORD:            Equ  2       ; Word = 2 Bytes
VUELTAS_MINIMAS: Equ  3       ; Cantida de vueltas minimas
VUELTAS_MAXIMAS: Equ  23      ; Cantidad de vueltas máximas
V_MIN:           Equ  35      ; Velocidad minima medida por el sensor
V_MAX:           Equ  95      ; Velocidad maxima medida por el sensor

;========                                                                                            --
; ASCII  ----------------------------------------------------------------------------------------------
;========                                                                                            --
CR:         Equ  $0D    ; Carriage Return
LF:         Equ  $0A    ; Line Feed
EOM:        Equ  $FF    ; Final de string
BS:         Equ  $08    ; BackSpace
CP:         Equ  $1A    ; Substitute

;                                                                   ===================================
;-------------------------------------------------------------------              VARIABLES 
;                                                                   ===================================   
                                         
                                         
                                         Org  $1000

BANDERAS:         dS  BYTE  ; [ X:X: CALC_TICKS :X: PANT_FLAG : ARRAY_OK : TCL_LEIDA : TCL_LISTA]
NumVueltas:       dS  BYTE  ; Cantidad de vueltas máximas que se sensaran
ValorVueltas:     dS  BYTE  ; Numero de vueltas introducido via teclado matricial
MAX_TCL:          dB  2     ; Longitud de la secuencia
Tecla:            dS  BYTE  ; Tecla pulsada
Tecla_IN          dS  BYTE  ; tecla a ingresar "libre de ruido"
Cont_Reb:         dS  BYTE  ; contador de rebotes
Cont_TCL:         dS  BYTE  ; contador de teclas ingresadas
Patron:           dS  BYTE  ; patron para la lectura del teclado metricial
Num_Array:        dS  WORD  ; Secuencia ingresada
BRILLO:           dS  BYTE  ; Brillo de los display de 7 segmentos y LED's
POT:              dS  BYTE  ; Lectura promedio del potenciometro
TICK_EN:          dS  WORD  ; Contador que permite desactivar la informacipon mostrada al ciclista
TICK_DIS:         dS  WORD  ; Contador que permite ¿activas la informacipon mostrada al ciclista
Veloc:            dS  BYTE  ; Velocidad calculada del ciclista
Vueltas:          dS  BYTE  ; Vueltas que ha dado el ciclista
VelProm:          dS  BYTE  ; Velocidad promedio del ciclista
TICK_MED:         dS  WORD  ; Tiempo medido entre los sensores S1 y S2
BIN1:             dS  BYTE  ; Valor en binario a desplegar en DSP1 y DSP2
BIN2:             dS  BYTE  ; Valor en binario a desplegar en DSP3 y DSP4
BCD1:             dS  BYTE  ; Valor en BCD a desplegar en DSP1 y DSP2
BCD2:             dS  BYTE  ; Valor en BCD a desplegar en DSP3 y DSP4
BCD_L:            dS  BYTE  ; Almacena la parte baja de un valor convertido a BCD
BCD_H:            dS  BYTE  ; Almacena la parte alta de un valor convertido a BCD
TEMP:             dS  BYTE  ; Variable temporal de la subrutina BIN_BCD
LOW:              dS  BYTE  ;
DISP1:            dS  BYTE  ; Numero en codificación de 7 segmentos a mostrar en DSP1
DISP2:            dS  BYTE  ; Numero en codificación de 7 segmentos a mostrar en DSP2
DISP3:            dS  BYTE  ; Numero en codificación de 7 segmentos a mostrar en DSP3
DISP4:            dS  BYTE  ; Numero en codificación de 7 segmentos a mostrar en DSP4
LEDS:             dS  BYTE  ; Los bits en alto indican que LED's que se encenderan
CONT_DIG:         dS  BYTE  ; Indica que display (o LED's) deben encenderse al realizar la multiplexacion
CONT_TICKS:       dS  BYTE  ; Contador que lleva los tiempos de multiplaxacion
DT:               dS  BYTE  ; Define el ciclo de trabajo (duty cycle) para controlar el brillo del display de 7 segmentos y de los LED's 
CONT_7SEG:        dS  WORD  ; Contador para refrescar los display de 7 segmentos y los LED's
CONT_200:         dS  BYTE  ; Contador para llevar los periodos de conversión de ATD
Cont_Delay:       dS  BYTE  ; Permite detener la ejecución de una seccion de código
D2mS:             dB  100   ;
D240uS:           dB  12    ;
D60uS:            dB  3     ;
Clear_LCD:        dB  $01   ; Comando de limpieza para la pantalla LCD
ADD_L1:           dB  $80   ; Puntero a la linea 1 de la pantalla LCD
ADD_L2:           dB  $C0   ; Puntero a la linea 2 de la pantalla LCD

;=========                                                                                            --
; TABLAS  ----------------------------------------------------------------------------------------------
;=========                                                                                            --
                  Org  $1040
Teclas:     dB   $01,$02,$03,$04,$05,$06,$07,$08,$09,$0B,$00,$0E 

                  Org  $1050
SEGMET:     dB   $3f,$06,$5b,$4f,$66,$6d,$7d,$07,$7f,$6f,$40,$00
                  
                  Org  $1060
initDisp:   db   $28,$28,$06,$0C
                 db  EOM

;============                                                                                         --
; MENSAJES   -------------------------------------------------------------------------------------------
;============                                                                                         --
                  Org  $1070

;------------------------------------------------- [MODO LIBRE]
MSJ_LIBRE_1:     fcc "  RunMeter 623  "   
                                          db EOM
MSJ_LIBRE_2:     fcc "   MODO LIBRE   "   
                                          db EOM

;------------------------------------------------- [MODO CONFIG]
MSJ_CONF_1:      fcc "   MODO CONFIG  "   
                                          db EOM
MSJ_CONF_2:      fcc "   NUM VUELTAS  "   
                                          db EOM

;------------------------------------------------- [MODO COMPETENCIA]
MSJ_RUNMETER:    fcc "  RunMeter 623  "   
                                          db EOM
MSJ_INICIAL:     fcc "  ESPERANDO...  "   
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

;------------------------------------------------- [MODO RESUMEN]
MSJ_RES_1:       fcc "  MODO RESUMEN  "   
                                          db EOM
MSJ_RES_2:       fcc "VUELTAS    VELOC"   
                                          db EOM


;===========================                                                                          --
; VECTORES DE INTERRUPCIÓN  ----------------------------------------------------------------------------
;===========================                                                                          --
           
                  
                        Org    $3E70       ; Vector de interrupcion RTI
                        dW     RTI_ISR      

                        Org    $3E66       ; Vector de interrupción OC4 
                        dW     OC4_ISR

                        Org    $3E5E       ; Vector de intrrupción TCNT
                        dW     TCNT_ISR

                        Org    $3E4C       ; Vector de interrupción PTH
                        dW     CALCULAR

                        Org    $3E52       ; Vector interrupcion ATD0
                        dw     ATD_ISR

;                                 ====================================
;---------------------------------      CONFIGURACION DE HARWARE      ----------------------------------
;                                 ====================================


                                           Org   $2000            
      
            LDS   #SP              ; Se coloca el puntero de pila en $4000

;=======================                                                                              ==
; Configuración de RTI  --------------------------------------------------------------------------------
;=======================                                                                              ==
                
            MOVB  #$17,RTICTL      ; M=1, N=7 rti = 1ms                                                 
            BSET  CRGINT,$80       ; Se activa la interrupcion por RTI

;==========================                                                                           ==
; CONFIGURACION DS7 Y LEDS -----------------------------------------------------------------------------
;==========================                                                                           ==

;[ PB3     | PB2         | PB1           | PB0   ]
;[ RESUMEN | COMPETENCIA | CONFIGURACION | LIBRE ]

            MOVB  #$FF,DDRB        ; PB7-PB0 -> salidas
            BSET  DDRJ,$02         ; LED enable                                   
            MOVB  #$0F,DDRP        ; PP3-PP0 -> salidas

;=============================                                                                        --
; Configuración del puerto H  --------------------------------------------------------------------------
;=============================                                                                        --
            BCLR  DDRH,%11001001   ; PH7, PH1-PH0 -> entradas 
            BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH

;=====================================                                                                --
;   CONFIGURACIÓN DE PANTALLA LCD     ------------------------------------------------------------------
;=====================================                                                                --
            MOVB #$FF, DDRK        ; PK7-PK0 -> salidas       

;========================                                                                             --
; Configuración del ADC  -------------------------------------------------------------------------------
;========================                                                                             --
; ATD0CTL2 [ADPU : AFFC : AWAI : ETRIGLE : ETRIGP : ETRGE : ASCIE : ASCIF]
;           --> ADPU  = 1 : habilita el módulo de ATD
;           --> AFFC  = 1 : Fast Flag Clear All
;           --> ANSIE = 1 : habilita las interrupciones
;
; ATD0CTL3 [0 : S8C : S4C : S2C : S1C : FIFO : FRZ1 : FRZ0] 
;           --> ATD0CTL3 = %00000000
;
; ATD0CTL4 [SRES8: SMP1: SMP0: PRS4   : PRS3  :PRS2 :PRS1 :PRS0 ]
;           -->  PRS = %10011 = 19   BUS_CLK /[(PRS+1)*2] => 600 KHz
;           -->  SMP1 = 0 , SMP0 = 1 => 4 periodos de ATD
;
; ATD0CTL5 [DJM  : DSGN: SCAN: MULT   : 0     :CC   :CB   :CA   ]
;           --> DJM = 1 : justifica el resultado a la derecha
         
            movb  #%11000010,ATD0CTL2  
            ldaa  #240
RETARDO:    dbne A, RETARDO                       
            movb  #%00110000,ATD0CTL3        
            movb  #%10110011,ATD0CTL4  

;==========                                                                                           --
; TIMER 4  ---------------------------------------------------------------------------------------------
;==========                                                                                           --
            BSET  TSCR1,%10010000  ; TEN = 1 ; TFFCA = 1.
            BSET  TSCR2,%00000011  ; Prescaler en 8
            movb  #$00,TCTL1       ; se apagan las salidas asincronas
            MOVB  #%00010000,TIOS  ; Se asigna como salida el canal 4
            MOVB  #%00010000,TIE   ; enable interrupcion OC4    

            ldd  TCNT
            addd #60
            std  TC4

;======================================                                                               --
; CONFIGURACIÓN DE TECLADO MATRICIAL   -----------------------------------------------------------------
;======================================                                                               --
PORTA_CONF: MOVB  #$F0,DDRA    ; Parte alta salida, parte baja entrada             
            BSET  PUCR,1    
                 
;                                                                    ===================================
;--------------------------------------------------------------------    INICIALIZACION DE VARIABLES 
;                                                                    ===================================
            CLR   BANDERAS
            CLR   Veloc
            CLR   Vueltas
            CLR   VelProm
            CLR   NumVueltas
            CLR   ValorVueltas

;----------------------------------------------------------- [TEREA_TECLADO]
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

;------------------------------------------------------------ [OC4_ISR]
            CLR   LEDS
            MOVB  #$BB,BIN1
            MOVB  #$BB,BIN2   
            CLR   CONT_DIG 
            CLR   CONT_TICKS 
            CLR   CONT_200 
            CLR   DT        
            MOVW  #$00,CONT_7SEG
            movb  #$00,Cont_Delay     

;------------------------------------------------------------ [cli]
            cli 

;=======================================================================================================
;                                 ====================================
;---------------------------------         PROGRAMA PRINCIPAL         ----------------------------------
;                                 ====================================
;=======================================================================================================

            JSR   LCD
INIT_CONF:  
            JSR   CONFIG
            tst   NumVueltas
            beq   INIT_CONF
MAIN_LOOP:    
            BRSET PTIH,%11000000,JUMP_COMP
            BRSET PTIH,%10000000,JUMP_RESUMEN
              
            CLR   Veloc
            CLR   Vueltas
            CLR   VelProm
            BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH
            BCLR  TSCR2,%10000000  ; Se desactiva la Interrupcion TCNT
             
            BRSET PTIH,%01000000,JUMP_CONFIG
JUMP_LIBRE:   
            JSR   LIBRE
            BRA   MAIN_LOOP
JUMP_CONFIG:  
            JSR   CONFIG
            BRA   MAIN_LOOP
JUMP_COMP:    
            ldaa NumVueltas
            cmpa Vueltas
            bne  SENSANDO  
            BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH
            MOVB #$BB,BIN1                             
            MOVB #$BB,BIN2
            MOVB #$00,TICK_EN
            MOVB #$00,TICK_DIS
            BCLR BANDERAS,$10                                 
            LDX  #MSJ_RUNMETER 
            LDY  #MSJ_INICIAL 
            JSR Cargar_LCD
            BRA MAIN_LOOP                                 
SENSANDO:     
            BSET  PIEH,%00001001   ; Se activa la Interrupcion PTH
            BSET  TSCR2,%10000000  ; Se activa la Interrupcion TCNT
            JSR   COMPETENCIA
            BRA   MAIN_LOOP

JUMP_RESUMEN: 
            BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH
            JSR  RESUMEN
            BRA  MAIN_LOOP

;=======================================================================================================
;                                 ====================================
;---------------------------------             SUBRUTINAS             ----------------------------------
;                                 ====================================
;=======================================================================================================

;                                 ====================================
;---------------------------------     SUBRUTINAS DE INTERRUPCION     ----------------------------------
;                                 ====================================


;                                                                    ===================================
;--------------------------------------------------------------------               RTI_ISR 
;                                                                    ===================================
;
; Esta subrutina de interrupcion se encarga de iniciar un ciclo de conversion cada 200 ms mediante la 
; escritura en ATD0CTL5. Por otro lado tambien maneja el filtro anti rebotes para el teclado matricial
; y los botones PTH0 y PTH3. La RTI se configuró para activarse cada 1 ms.
;
;     Salidas:
;                             - Cont_Reb
;                             - CONT_200
;-------------------------------------------------------------------------------------------------------

RTI_ISR:            
            BSET  CRGFLG, %10000000
            TST   Cont_Reb
            BEQ   CHECK_ADC
            DEC   Cont_Reb
CHECK_ADC:          
            TST  CONT_200
            BEQ   INIT_CONV
            DEC   CONT_200
            BRA   RETURN_RTI   
INIT_CONV:         
            movb  #200,CONT_200
            movb  #%10000111,ATD0CTL5 
RETURN_RTI: 
            rti

;                                                                    ===================================
;--------------------------------------------------------------------               ATD_ISR 
;                                                                    ===================================
;
; Esta subrutina lee ya almacena en la variable POT la tension proveniente del potenciometro tomando 6
; mediciones y calculando su promedio. Luego calcula la variable BRILLO mediante la formula :
;
;                             BRILLO = (100 * POT)/ 255        
;
;     Salidas:
;                             - POT     	 
;					- BRILLO 
;-------------------------------------------------------------------------------------------------------
ATD_ISR:    
            ; Se hacen las 6 sumas de los registros de resultados  
            ; D = (ADR00H)+(ADR01H)+(ADR02H)+(ADR03H)+(ADR04H)+(ADR05H) 
            ldd   ADR00H   
            addd  ADR01H   
            addd  ADR02H   
            addd  ADR03H   
            addd  ADR04H  
            addd  ADR05H
            ; Se saca el promedio dividiendo por 6
            ldx    #6
            idiv
            xgdx
            ; Se guarda el valor medido en POT          
            stab   POT    
            ldy    #100     ; Y <-- 100
            emul            ; Y <-- POT * 100
            ldx    #255     ; X <-- 255
            ediv            ; X <-- (POT * 100) / 255 
            xgdy
            stab   BRILLO   
RTN_ATD:     
            RTI


;                                                                    ===================================
;--------------------------------------------------------------------             TCNT_ISR 
;                                                                    ===================================
;
; Esta subrutina da atencion a la interrupcion de timmer overflow, decrementar las variables TICK_DIS,
; TICK_EN y TICK_MED, que manejan algunos mensajes mostrados en la pantalla LCD.
;   
;   Salidas:
;                      - TICK_MED       
;                      - TICK_EN      
;                      - TICK_DIS        
;                      - Banderas      
;-------------------------------------------------------------------------------------------------------
TCNT_ISR:         
            LDD   TCNT
            LDX   TICK_MED
            INX
            STX   TICK_MED  
CHECK_TICK_EN:    
            LDX   TICK_EN
            BEQ   SET_PANT_FLG
            DEX
            STX   TICK_EN
            BRA   CHECK_TICK_DIS
SET_PANT_FLG:  
            LDD   TICK_DIS
            BEQ   CHECK_TICK_DIS
            BSET  BANDERAS,%00001000  
CHECK_TICK_DIS:   
            LDX   TICK_DIS
            BEQ   CLR_PANT_FLG
            DEX
            STX   TICK_DIS
            BRA   RTN_TCNT
CLR_PANT_FLG:     
            BCLR  BANDERAS,%00001000 
RTN_TCNT:         
            RTI


;                                                                    ===================================
;--------------------------------------------------------------------             CALCULAR
;                                                                    ===================================

; Esta rutina calcula la velocidad del ciclista al medir el tiempo TICK_MED entre la interrupcion 
; provocada por los sensores S1 (PTH3) y S2 (PTH0). Ademas incrementa el numero de vueltas y calcula la
; velocidad promedio. La velocidad se calcula mediante la formula:
;
;                       Velocidad = factor / TICK_MED  = 9063/TICK_MED
;
;                       factor    = (55 * 3.6)/(T_toi)
;
;                       T_toi     = (PRS * 2^16 )/BUS_CLK 
;
;                       BUS_CLK   = 24MHz   :   PRS = 8
;    
;     Entradas:
;                         - Cont_Reb        	
;
;     Salidas:
;                         - Vueltas	
;                         - Veloc	
;                         - VelProm      
;-------------------------------------------------------------------------------------------------------

CALCULAR:   
            tst     Cont_Reb
            beq     PROC_PH0
            BSET PIFH,%00001001  
            LBRA    RETURN_PH0
PROC_PH0:   
            MOVB    #6,Cont_Reb  
            brset   PIFH,%00001000,PH3_S1 
            brset   PIFH,%00000001,PH0_S2
            LBRA    RETURN_PH0
PH3_S1:     
            bset  PIFH,%00001000
            BRCLR PIEH,$08,PH0_S2 
            MOVB #$01,PIEH 
            
            INC Vueltas

            LDX   #MSJ_RUNMETER
            LDY   #MSJ_CALC
            CLI
            JSR CARGAR_LCD

            MOVW  #0,TICK_MED

            BRA   RETURN_PH0
PH0_S2:     
            bset  PIFH,%00000001
            BRCLR PIEH,$01,PH3_S1
            MOVB #$08,PIEH
            
            
            ; Calculo Velocidad
            LDD   #9063   
            LDX   TICK_MED
            IDIV            ; Veloc = factor/ TICK_MED
            TFR X,D
            STAB  Veloc 

            CPD #V_MIN
            BLO VELOCIDAD_INVALIDA
            CPD #V_MAX
            BHI VELOCIDAD_INVALIDA

            CLRA
            LDAB Vueltas
            TFR D,X
            LDAA VelProm
            DECB
            BEQ  PRIMERA_VUELTA

            MUL
            ADDB Veloc 
            ADCA #0 
            IDIV
            XGDX
            STAB VelProm
            BRA   RETURN_PH0
PRIMERA_VUELTA:  
            MOVB Veloc,VelProm           
            BRA   RETURN_PH0
VELOCIDAD_INVALIDA: 
            DEC Vueltas
            MOVB #1,Veloc 
RETURN_PH0: 
            rti


;                                                                    ===================================
;--------------------------------------------------------------------              OC4_ISR
;                                                                    ===================================
; 
; La subrutina de interrupción por comparacion de salida del canal 4 se encarga de llevar a cabo la 
; multiplezación de los LED's y los display's de siete segments. La interrupción frecuencia de 
; iterrupción es de 50khz o 20us, para lo que se usa un prescaler de 8. Para obtener la tasa de refrescamiento
; de los datos sea de 100ms Se establece CONT_7SEG en 5000 ya que :
;                              
;                              5000*20us = 100ms
;
;     Entradas:
;                             - CONT_7SEG
;                             - Cont_Delay    
;                             - CONT_TICKS	
;                             - BRILLO 	
;                             - CONT_DIG     
;                             - TCNT         
;     Salidas:
;                             - DT          
;                             - TC4           

;-------------------------------------------------------------------------------------------------------
   
OC4_ISR:    
            ; Se reinicia         
            ldd  TCNT
            addd #60
            std  TC4

            ; Si CONT_7SEG llega a 5000 (cada 100 ms) se actualiza la información
            ; de las variables DISP1, DISP2, DISP3 y DISP4.
            ldd   CONT_7SEG
            cpd   #5000
            beq   UPDATE_DISPN
INC_CONT_7SEG:
            ; Se incrementa CONT_7SEG
            addd  #1
            std   CONT_7SEG
            ; Se actualiza CONT_DELAY
            bra   UPDATE_CONT_DELAY
UPDATE_DISPN:       
            movw  #0,CONT_7SEG
            jsr   CONV_BIN_BCD
            jsr   BCD_7SEG
UPDATE_CONT_DELAY:  
            tst   Cont_Delay
            beq   MULTIPLEXER
DEC_CONT_DELAY:     
            dec   Cont_Delay
MULTIPLEXER:        
            ldaa  CONT_TICKS
            cmpa  #100
            beq   SELECT_DISPLAY
RT_BRILLO:          
            ldab  #100
            subb  BRILLO
            stab  DT
            cmpb  CONT_TICKS
            bne   INC_CONT_TICKS
            movb  #$FF,PTP          
            bset  PTJ,$02 
INC_CONT_TICKS:     
            inc   CONT_TICKS
            rti
SELECT_DISPLAY:   
            ldaa  CONT_DIG
            cmpa  #4        
            beq   SELECT_LEDS
            bset  PTJ,$02
            cmpa  #3        
            beq   SELECT_DISP4
            cmpa  #2        
            beq   SELECT_DISP3
            cmpa  #1        
            beq   SELECT_DISP2             
SELECT_DISP1:     
            movb  #$FE,PTP
            movb  DISP1,PORTB                     
            bra   INC_CONT_DIG
SELECT_DISP2:     
            movb  #$FD,PTP
            movb  DISP2,PORTB  
            bra   INC_CONT_DIG
SELECT_DISP3:     
            movb  #$FB,PTP
            movb  DISP3,PORTB  
            bra   INC_CONT_DIG
SELECT_DISP4:    
            movb  #$F7,PTP
            movb  DISP4,PORTB  
            bra   INC_CONT_DIG
SELECT_LEDS:      
            movb  #$0F,PTP                
            movb  LEDS,PORTB           
            bclr  PTJ,$02
            bra   INC_CONT_DIG     
M_CONF:           
            movb  #$FF,PTP
            bra   INC_CONT_DIG
INC_CONT_DIG:     
            movb  #0,CONT_TICKS
            ldaa  CONT_DIG
            cmpa  #4
            beq   RST_CONT_DIG
            inc   CONT_DIG
            bra   RETURN_OC4
RST_CONT_DIG:     
            movb  #$00,CONT_DIG
RETURN_OC4:       
            rti
;                                 ====================================
;---------------------------------        SUBRUTINAS GENERALES        ----------------------------------
;                                 ====================================

;                                                                    ===================================
;--------------------------------------------------------------------              LIBRE 
;                                                                    ===================================
;
; En esta subrutina no se hace nada, solo mostrar el mensaje de modo libre en el display LCD     
;
;     Salidas:
;                             - LEDS
;                             - BIN1         
;                             - BIN2          
;-------------------------------------------------------------------------------------------------------

LIBRE:      
            MOVB  #$01,LEDS
            ; Se carga en BIN1 Y BIN2 el valor $BB para que [DISP1-DISP2] [DISP3-DISP4] se apaguen
            MOVB  #$BB,BIN2
            MOVB  #$BB,BIN1
            ; Se enciende el bit del LED correspondiente al modo LIBRE
            MOVB  #$01,LEDS
            ; Se cargan el los registros indices los mensajes del modo LIBRE
            LDX   #MSJ_LIBRE_1
            LDY   #MSJ_LIBRE_2
            ; Se actualiza el display LCD con los mensajes
            JSR   CARGAR_LCD  
            RTS


;                                                                    ===================================
;--------------------------------------------------------------------              CONFIG
;                                                                    ===================================
; Esta subrutina establece el valor de la variable NumVueltas, el numero de vueltas que serán sensadas
; en modo competencia. Para establecer este valor se lee el valor de  la variable ValorVUeltas ingresado
; via teclado matricial por el usuario, si está en el rango valido se guarda en NumVueltas.
;
;     Entradas:
;                             - Banderas      
;     Salidas:
;                             - ValorVueltas
;                             - NumVueltas
;-------------------------------------------------------------------------------------------------------
CONFIG:     
            MOVB  #$02,LEDS
            ; Se limpian TICKS_EN y TICK_DIS
            MOVW   #0,TICK_EN  
            MOVW   #0,TICK_DIS
            ; Se coloca NumVueltas en BIN1. Esto permitira mostrar el valor en [DISP3-DISP4]
            MOVB   NumVueltas,BIN1
            ; Se coloca en BIN2 el valor $BB para que [DISP1-DISP2] esten apagados
            MOVB   #$BB,BIN2
            ; Se cargan los mensajes del modo connfig y se llama a CARGAR_LCD para que
            ; se muestren en la pantalla LCD
            LDX    #MSJ_CONF_1
            LDY    #MSJ_CONF_2
            JSR    CARGAR_LCD  
            ; Si ARRAY_OK es cero entonces se salta a SET_VALORVUELTAS, para que el usuario 
            ; continue ingresando en digitos NUM_ARRAY.
            BRCLR  BANDERAS,%00000100,SET_VALORVUELTAS
            ; Se convierte el valor de NumArray a binario y se almacena en ValorVueltas 
            JSR    BCD_BIN
            ; Se comprueba que ValorVUeltas esté entre 3 y 23.
            LDAA   ValorVueltas
            CMPA   #VUELTAS_MINIMAS
            ; Si es menor a 3 se salta a VV_INVALID
            BLO    VV_INVALID
            CMPA   #VUELTAS_MAXIMAS
            ; Si es mayor a 23 se salta a VV_INVALID
            BHI    VV_INVALID

VV_VALID:   
            ; Se limpia ARRAY_OK
            BCLR   BANDERAS,%00000100
            ; Se copia ValorVueltas en NumVuletas
            MOVB   ValorVueltas,NumVueltas
            ; Se copia Numvueltas en BIN1
            MOVB   NumVueltas,BIN1
            RTS
VV_INVALID: 
            ; Se limpia ARRAY_OK
            BCLR   BANDERAS,%00000100
            ; Se borra NumVueltas
            CLR    NumVueltas
            ; Se borra ValorVueltas
            CLR    ValorVueltas
            RTS
SET_VALORVUELTAS: 
            ; Se llama a la subrrutina TAREA_TECLADO para cuntinuar ingresando 
            ; dígitos en NUM_ARRAY
            JSR    TAREA_TECLADO
            RTS
;                                                                    ===================================
;--------------------------------------------------------------------            COMPETENCIA
;                                                                    ===================================
;
; Esta subrutina se encarga de la logica de llamar a la subrutina PANT_CTRL que es la que se encarga de
; manejar la información suministrada al usuario en la pantalla LCD. Tambien se encarga de mostrar el
; mensaje inicial del modo competencia. Se utiliza la variable LEDS para solo mandar una vez el 
; mensaje inicial y no interferir con los mesajes de PANT_CTRL
;
;     Entradas:
;                             - Veloc
;
;     Salidas:
;                             - LEDS
;                             - TICK_EN
;                             - TICK_DIS
;                             - BIN1
;                             - BIN2         
;
;-------------------------------------------------------------------------------------------------------
COMPETENCIA: 
            BRSET LEDS,$04,CHECK_VELOC
            BRSET LEDS,$01,CHECK_VELOC
            MOVB  #$04,LEDS
            CLR Veloc
            MOVW #0,TICK_EN
            MOVW #0,TICK_DIS
            BCLR BANDERAS,$10 
            MOVB  #$BB,BIN1 
            MOVB  #$BB,BIN2
            LDX   #MSJ_RUNMETER 
            LDY   #MSJ_INICIAL 
            JSR   CARGAR_LCD

CHECK_VELOC: 
            TST   Veloc
            BEQ   RTN_COMP   
            JSR   PANT_CTRL 
RTN_COMP:   
            RTS

;                                                                    ===================================
;--------------------------------------------------------------------            RESUMEN
;                                                                    ===================================
;
; Esta subrutina se encarga de mostrar la cantidad de vueltas y la velocidad priomedio del ciclista.
; Se encarga de encender el LED correspondiente PB0 y cargar los mesajes del modo RESUMEN.
;
;     Entradas:
;                             - LEDS         
;                             - Vueltas      
;                             - VelProm      
;     Salidas:
;                             - BIN1              
;                             - BIN2                    
;
;-------------------------------------------------------------------------------------------------------

RESUMEN:    
            MOVB  #$08,LEDS
            MOVB  VelProm,BIN1
            MOVB  Vueltas,BIN2
            LDX   #MSJ_RES_1
            LDY   #MSJ_RES_2
            JSR   CARGAR_LCD   
            RTS

;                                                                    ===================================
;--------------------------------------------------------------------            PANT_CTRL
;                                                                    ===================================
;
; Esta subrutina se encarga de desplegar los mensajes informativos al ciclista para que cuando pase
; por la linea de meta se le muestre el numero de vueltas y su velosidad. Además si su velocidad no 
; este dentro del rengo se le mostrará un mensage de alerta paara controlar los tiempos en que aparece
; y desaparecen los mensajes se utilizan las variables TICK_EN y TICK_DIS. Que se calculan de la 
; siguiente forma:
;
;                             Ticks     =  distancia/(velocidad * T_toi)
;            
;                             Tick_EN   = ((200 *3.6)/0.0218)/veloc  = 33028/Veloc
;
;                             Tick_DIS  = ((300 *3.6)/0.0218)/veloc  = 49541/Veloc
;
;                             T_toi     = (PRS * 2^16 )/BUS_CLK 
;
;                             BUS_CLK   = 24MHz   :   PRS = 8
;
;     Entradas:
;                             - Veloc         
;                             - Vueltas       
;
;     Salidas:
;                             - BIN1  
;                             - BIN2
;                             - Banderas                         
;-------------------------------------------------------------------------------------------------------

PANT_CTRL:  
            BCLR  PIEH,%00001001   ; Se desactiva la Interrupcion PTH
            ldaa  Veloc
            cmpa  #V_MIN
            blo   FUERA_DE_RANGO
            cmpa  #V_MAX
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
            BSET  BANDERAS,%00001000
            LDX   #MSJ_ALERT_1
            LDY   #MSJ_ALERT_2
            JSR   CARGAR_LCD   
            RTS
CHECK_FLAG: 
            BRCLR BANDERAS,%00001000,nodo
            RTS
EN_RANGO:   
            BRCLR BANDERAS,%00010000,CALC_TICKS_0 
            BRSET BANDERAS,%00001000,PANT_FLG_1
PANT_FLG_0: 
            LDAA  BIN1
            CMPA  #$BB 
            BEQ   RTN_PANT
nodo:       
            MOVB  #$BB,BIN1
            MOVB  #$BB,BIN2
            LDX   #MSJ_RUNMETER
            LDY   #MSJ_INICIAL
            JSR   CARGAR_LCD

            LDAA  Vueltas
            CMPA  NumVueltas
            BEQ   RSET_VELOC  
            BSET  PIEH,%00001001   ; Se activa la Interrupcion PTH
            MOVB #$08,PIEH 
RSET_VELOC: 
            BCLR  BANDERAS,%00010000
            CLR   Veloc
            RTS
PANT_FLG_1: 
            LDAA  BIN1
            CMPA  #$BB
            BNE   RTN_PANT
            ; Enviar mensaje de competencia
            LDX   #MSJ_COMP_1
            LDY   #MSJ_COMP_2
            JSR   CARGAR_LCD   
            MOVB  Veloc,BIN1
            MOVB  Vueltas,BIN2
            RTS

CALC_TICKS_0: 
            BSET  BANDERAS,%00010000
            CLRA
            LDAB Veloc
            TFR D,X                                      
            LDD #33028
            IDIV
            STX TICK_EN

            CLRA
            LDAB Veloc
            TFR D,X
            LDD #49541
            IDIV
            STX TICK_DIS
RTN_PANT:   
            RTS

;                                                                    ===================================
;--------------------------------------------------------------------                LCD
;                                                                    ===================================
;
; Esta subrutina inicializa la pantalla LCD llamando a la rutina SEND_COMMAND enviando los comandos
; que estan en la tabla initDSP. Entre cada commando se establece un retardo de 60 US, llamando a la
; subrutina DELAY, ESTABLECIENDO Cont_Delay en el valor de la constante D60us. Por último se limpia 
; la pantalla LCD con el comando que está en la constante Clear_LCD.
;
;     Entradas:
;                             - intiDSP	
;
;     Salidas:
;                             - Cont_Delay   
;
;-------------------------------------------------------------------------------------------------------

LCD:        
            ldx   #initDisp
SEND_CMD:   
            ldaa  1,X+
            cmpa  #EOM
            beq   RTN_LCD  
            jsr   Send_Command              
            movb  D60uS,Cont_Delay
            jsr   DELAY                     
            bra   SEND_CMD                   
RTN_LCD:    
            ldaa  Clear_LCD                 
            jsr   Send_Command
            movb  D2mS,Cont_Delay           
            jsr   DELAY
            rts

;                                                                    ===================================
;--------------------------------------------------------------------             CARGAR_LCD
;                                                                    ===================================
; Esta subrutina carga los mensajes de las lineas 1 y 2 de la pantalla de 7 segmentos. El string de la 
;linea 1 se  pasa en el indice X y la linea 2 en el Y. 
;
;     Entradas:
;                             - X direccion de comienzo string de la linea 1  
;                             - Y direccion de comienzo string de la linea 2
;
;     Salidas:
;                             - Cont_Delay           
;
;-------------------------------------------------------------------------------------------------------

CARGAR_LCD:    
SET_L1:         
            ldaa  ADD_L1                     
            jsr   Send_Command
            movb  D60uS,Cont_Delay
            jsr   DELAY
SEND_L1_MSG:    
            ldaa  1,X+                       
            cmpa  #EOM
            beq   SET_L2
            jsr   Send_Data
            movb  D60uS,Cont_Delay           
            jsr   DELAY
            bra   SEND_L1_MSG
SET_L2:         
            ldaa  ADD_L2
            jsr   Send_Command              
            movb  D60uS,Cont_Delay
            jsr   DELAY
SEND_L2_MSG:    
            ldaa  1,Y+                      
            cmpa  #EOM
            beq   RTN_CARGAR_LCD
            jsr   Send_Data
            movb  D60uS,Cont_Delay 
            jsr   DELAY
            bra   SEND_L2_MSG
RTN_CARGAR_LCD: rts

;                                                                    ===================================
;--------------------------------------------------------------------             SEND_COMMAND
;                                                                    ===================================
;
; Subrutinas Send_Command y Send_Data: Se encargan de enviar los comando a pantalla LCD.
; Reciben los comandos  como parametro en acumulador A. Los comandos se envian en dos paquetes, cada uno
; de 4 bits.
;
;     Entradas:
;                             - A Comando enviar	
;
;     Salidas:
;                             - Cont_Delay          
;
;-------------------------------------------------------------------------------------------------------

SEND_COMMAND:   
            psha                      ; Se apila a
            anda  #$F0                ; Se seleccionan el nibble superrior
            lsra
            lsra                      ; X2 : 0 -> (A) -> C    
            staa  PORTK               ; Se pone la parte alta del cmd en PK   
            bclr  PORTK,%00000001                 
            bset  PORTK,%00000010                
            movb  D240uS,Cont_Delay
            jsr   DELAY               ; Se aguardan los 240us del protocolo     
            bclr  PORTK,%00000010                  
            pula                      ; Se desapila a
            anda  #$0F
            lsla
            lsla                      ; X2 : 0 << (A) << C
            staa  PORTK               ; Se pone la parte baja del cmd en PK        
            bclr  PORTK,%00000001                   
            bset  PORTK,%00000010                  
            movb  D240uS,Cont_Delay         
            jsr   DELAY               ; Se aguardan los 240us del protocolo  
            bclr  PORTK,%00000010                    
            rts

;                                                                    ===================================
;--------------------------------------------------------------------             SEND_DATA
;                                                                    ===================================
;
; Subrutinas Send_Command y Send_Data: Se encargan de enviar los comando a pantalla LCD.
; Reciben los  datos como parametro en acumulador A. Los comandos se envian en dos paquetes, cada uno 
; de 4 bits.
;
;     Entradas:
;                             - A dato enviar	
;
;     Salidas:
;                             - Cont_Delay          
;
;-------------------------------------------------------------------------------------------------------

SEND_DATA:      
            psha                      ; Se apila a
            anda  #$F0                ; Se seleccionan el nibble superrior
            lsra
            lsra                      ; X2 : 0 >> (A) >> C
            staa  PORTK               ; Se pone la parte alta del cmd en PK    
            bset  PORTK,%00000001       
            bset  PORTK,%00000010                  
            movb  D240uS,Cont_Delay     
            jsr   DELAY               ; Se aguardan los 260us del protocolo  
            bclr  PORTK,%00000010                    
            pula                      ; Se desapila a
            anda  #$0F
            lsla
            lsla                      ; X2 : 0 << (A) << C
            staa  PORTK               ; Se pone la parte baja del cmd en PK          
            bset  PORTK,%00000001                 
            bset  PORTK,%00000010                    
            movb  D240uS,Cont_Delay        
            jsr   DELAY               ; Se aguardan los 260us del protocolo  
            bclr  PORTK,%00000010                  
            rts

;                                                                    ===================================
;--------------------------------------------------------------------               DELAY
;                                                                    ===================================
;
; Subrutina Delay: Crea un delay en la ejecucion del codigo. La subrutina RTI decrementa Cont_Delay
; y cuando esta variable es cero retorna
;
;     Entradas:
;                             - Cont_Delay    (Direccionamiento directo a memoria)
;
;-------------------------------------------------------------------------------------------------------
DELAY:      tst  Cont_Delay
            bne  DELAY
            rts

;                                                                    ===================================
;--------------------------------------------------------------------            CONV_BIN_BCD
;                                                                    ===================================
;
; Subrutina CONV_BIN_BCD: Toma los valores BIN1 y BIN2 y los convierte en BCD1 y BCD2 respectivamente.
; Si recibe $BB o $AA no realiza la conversión a BCD simplemente coloca este valor en BCD1 o BCD2,
; segun corresponda. $BB hace que el display se apague y $AA que muestre guines. Además la rutina,
; coloca $B en el nibble de las decenas si el numero en binario es menor a diez.
;
;     Entradas:
;                             - BIN1
;                             - BIN2
;
;     Salidas:
;                             - BCD1
;                             - BCD2

;-------------------------------------------------------------------------------------------------------

CONV_BIN_BCD:   
            LDAA BIN1
            CMPA #$BB
            bne  BIN1_AA
            movb #$BB,BCD1
            bra BIN2_BB
BIN1_AA:    
            cmpa #$AA
            bne BIN1_BCD
            movb #$AA,BCD1
            bra  BIN2_BB
BIN1_BCD:   
            JSR BIN_BCD                                     
            MOVB BCD_L,BCD1                                 
            LDAB #$F0                                      
            ANDB BCD1                                       
            BNE BIN2_BB                         
            LDAA BCD1                                       
            ADDA #$B0                                       
            STAA BCD1 
BIN2_BB:    
            LDAA BIN2
            CMPA #$BB
            bne  BIN2_AA
            movb #$BB,BCD2
            bra RETURN_CONV_BIN_BCD
BIN2_AA:    
            cmpa #$AA
            bne BIN2_BCD
            movb #$AA,BCD2
            bra RETURN_CONV_BIN_BCD
BIN2_BCD:   
            JSR BIN_BCD                                     
            MOVB BCD_L,BCD2                                 
            LDAB #$F0                                      
            ANDB BCD2                                       
            BNE  RETURN_CONV_BIN_BCD                      
            LDAA BCD2                                       
            ADDA #$B0                                       
            STAA BCD2 

RETURN_CONV_BIN_BCD: rts


;                                                                    ===================================
;--------------------------------------------------------------------               BIN_BCD
;                                                                    ===================================
;
; Convierte el valor contenido an el acumulador A de binario a BCD lo convierte convierte
; a BCD y lo almacena en variables BCD_H y BCD_L. Esta subrutina utiliza el algoritmo XS3
;
;     Entradas:
;                             - A Byte a convertir   
;
;     Salidas:
;                             - BCD_L        
;                             - BCD_h        
;-------------------------------------------------------------------------------------------------------

BIN_BCD:        
            ldy   #7
            CLR   BCD_L
BIN_BCD_LOOP:   
            lsla
            rol   BCD_L             
            staa  TEMP
NIBBLES_CHECK:  
            ldaa  #$0F              
            anda  BCD_L
            cmpa  #$5
            blo   NOT_ADD_TO_N0     ; Nibbe inferior < 5  salta
            adda  #$3               ; se sube 3 al nibble inferior
NOT_ADD_TO_N0:  
            staa  LOW
            ldaa  #$F0
            anda  BCD_L
            cmpa  #$50
            blo   NOT_ADD_TO_N1     ; Nibbe superior < 5  salta
            adda  #$30              ; se suba 3 al nibble superior
NOT_ADD_TO_N1:  
            adda  LOW
            staa  BCD_L
            ldaa  TEMP
            dbne  Y,BIN_BCD_LOOP    ; Y != 0 salta
            lsla
            rol   BCD_L            
            rts

;                                                                    ===================================
;--------------------------------------------------------------------              BCD_7SEG
;                                                                    ===================================
;                                                                        [DSP1][DSP2] | [DSP3][DSP4]
;                                                                        [   BCD2   ] | [   BCD1   ]
;
; Convierte a codigo 7 segmentos las Variables BCD1 Y BCD2 y las almacena en DISP1, DISP2, DISP3 y 
; DISP4. Para codificar a formato 7 segmentos se utiliza la tabla SEGMENT.
;
;     Entradas:
;                             - SEGMENT       
;
;     Salidas:
;                             - DISP1
;                             - DISP2
;                             - DISP3
;                             - DISP4

;-------------------------------------------------------------------------------------------------------
BCD_7SEG:       
            ldx  #SEGMET 
SET_DISP1:      
            movb #0,DISP1   ; Por defecto DISP1 = 0
            ldaa BCD2
            anda #$F0
            cmpa #$B0
            beq  SET_DISP2  ; si no es cero se carga su valor indexando en
            lsra            ; SEGMENT
            lsra
            lsra
            lsra
            movb A,X,DISP1  ; Se carga DISP1
SET_DISP2:      
            ldaa BCD2
            anda #$0F
            movb A,X,DISP2  ; Se carga DISP2
SET_DISP3:      
            movb #0,DISP3   ; Por defecto DISP3 = 0
            ldaa BCD1
            anda #$F0
            cmpa #$B0
            beq  SET_DISP4  ; si no es cero se carga su valor indexando en
            lsra            ; SEGMENT
            lsra
            lsra
            lsra
            movb A,X,DISP3  ; Se carga DISP3
SET_DISP4:      
            ldaa #$0F
            anda BCD1
            movb A,X,DISP4  ; Se carga DISP4
RTN_BCD_7SEG:   
            rts

;                                                                    ===================================
;--------------------------------------------------------------------               BCD_BIN 
;                                                                    ===================================
;
; Convierte el contenido de Num_Array de BCD a binario y lo coloca en Valor vueltas. Para ello se usa
; la técnica de multiplicacion por decadas.
;
;     Entradas:
;                             - NumArray     
;     Salidas:
;                             - ValorVueltas	

;-------------------------------------------------------------------------------------------------------

BCD_BIN:    
      ldx   #Num_Array
      ldab  1,X+    
      ldaa  #10                       
      mul                 ; Se multiplica por 10 el digito de las decenas    
      addb  1,X+          ; Se suma el digito de las unidades                   
      stab  ValorVueltas  ; Se guarda el valor en  ValorVueltas
      rts 




;                                                                    ===================================
;--------------------------------------------------------------------            TAREA_TECLADO 
;                                                                    ===================================
;  
; Esta tarea coordina la creación de un arreglo de bytes ingresados por el usuario via teclado
; matricial. Para ello llama a las subrutina MUX_TECLADO que lee el teclado y obtiene la tecla 
; presionada y luego a FORMAR_ARRAY para procesar la tecla leida.
;
;     Entradas:
;                             - Cont_Reb 
;                             - Tecla    
;                             - Tecla_IN 
;                             - Banderas 
;     Salidas:
;                             - Banderas

;-------------------------------------------------------------------------------------------------------

TAREA_TECLADO:      
            tst    Cont_Reb
            bne    TAREA_RETURN                    
            jsr    MUX_TECLADO
            ldaa   #$FF
            cmpa   Tecla
            bne    TECLA_PRESIONADA      
            brset  BANDERAS,%00000001,AGREGAR_TECLA    
            bra    TAREA_RETURN
TECLA_PRESIONADA:   
            brset  BANDERAS,%00000010,TECLA_PROCESADA  
            movb   Tecla,Tecla_IN
            bset   BANDERAS,%00000010                  ; Tecla leida
            movb   #$0A,Cont_Reb
            bra    TAREA_RETURN
TECLA_PROCESADA:    
            ldab   Tecla
            cmpb   Tecla_IN
            beq    TECLA_LISTA
ERROR_DE_LECTURA:   
            movb   #$FF,Tecla
            movb   #$FF,Tecla_IN
            bclr   BANDERAS,%00000011
            bra    TAREA_RETURN
TECLA_LISTA:        
            bset   BANDERAS,%00000001                  ; Tecla lista
            bra    TAREA_RETURN
AGREGAR_TECLA:      
            bclr   BANDERAS,%00000011
            jsr    FORMAR_ARRAY
            bra    TAREA_RETURN
TAREA_RETURN:       
            rts


;                                                                    ===================================
;--------------------------------------------------------------------            MUX_TECLADO 
;                                                                    ===================================

; La subrutuna lee el teclado matricial y almacena la tecla leida en la variable Tecla. Para leer el
; teclado se hace 0 uno de los bits del nible más significativo del puerto A (mapean las columnas)
; y se revisa cual bit del nible inferior se hizo cero, si ninguno se hizo cero la tecla presionada 
; no está en esa columna y se prueba hacer cero otro bit del nible superior. 
;
;     Entradas:
;                             - Teclas
;
;     Salidas:
;                             - Tecla 
;                             - Patron
;-------------------------------------------------------------------------------------------------------

MUX_TECLADO:    
            ldx    #Teclas
            ldaa   #$00
            ldab   #$F0
            movb   #$EF,Patron
SCAN_MATRIZ:    
            movb   Patron, PORTA
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
COL_3:      INCA      ; como el la columna 3 se suman dos unidades
COL_2:      INCA      ; columna 2 se suma una unidad
COL_1:      movb A,X,Tecla ; se guarda en Tecla el valor correspondiente
RETURN_MUX: rts       

;                                                                    ===================================
;--------------------------------------------------------------------            FORMAR_ARRAY 
;                                                                    ===================================
; Se encarga de ingresar las teclas al arreglo, o bien borrar datos ya ingresados. Cuando el arreglo
; esta listo se recibe un $0E y se levanta la bandera ARRAY_OK.
;
;     Entradas:
;                             - Num_Array
;                             - Tecla_IN 
;                             - Cont_TCL 
;     Salidas: 
;                             - Num_Array         
;                             - Banderas
;
;-------------------------------------------------------------------------------------------------------
FORMAR_ARRAY:       
            ldaa  Cont_TCL
            cmpa  MAX_TCL
            bne   NO_ULTIMA_TCL                   
ULTIMA_TCL:         
            ldaa  #$0B
            cmpa  Tecla_IN    
            beq   BORRAR 
            ldaa  #$0E
            cmpa  Tecla_IN 
            beq   ENTER
            bra   RETURN_FORMAR
NO_ULTIMA_TCL:      
            tst   Cont_TCL
            beq   PRIMERA_TCL
NO_PRIMERA_TCL:     
            ldaa  #$0B
            cmpa  Tecla_IN    
            beq   BORRAR 
            ldaa  #$0E
            cmpa  Tecla_IN    
            beq   ENTER
            bra   GUARDAR_TCL
PRIMERA_TCL:        
            ldaa  #$0B
            cmpa  Tecla_IN 
            beq   RETURN_FORMAR 
            ldaa  #$0E
            cmpa  Tecla_IN    
            beq   RETURN_FORMAR
            bra   GUARDAR_TCL
BORRAR:     
            dec   Cont_TCL
            ldx   #Num_Array
            ldaa  Cont_TCL
            movb  #$FF,A,X
            bra   RETURN_FORMAR
ENTER:              
            bset  BANDERAS,%00000100                  ; Array Ok
            movb  #$00,Cont_TCL
            bra   RETURN_FORMAR
GUARDAR_TCL:        
            ldaa  Cont_TCL
            ldx   #Num_Array
            movb  Tecla_IN,A,X 
            inc   Cont_TCL
RETURN_FORMAR:      
            movb  #$FF,Tecla_IN
            rts

