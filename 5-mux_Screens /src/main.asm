;       Autor:
; Brown Ramírez, Belinda 
; López, José
; timna.brown@ucr.ac.cr
; jose.lopezpicado@ucr.ac.cr
; Feb, 2021

;##--------------------------------  EXPLANATION ------------------------------------
;A screw production line is considered for which a dispensing 
;machine for packaging is implemented. This machine counts 
;the screws that are dispensed for packaging and when 
;the programmed count of the number of screws in the package 
;(QTYPQ) is reached, an output (SAL) is activated that dispatches 
;the package with the number of screws completed and the machine 
;is ready for a new dispensing sequence. The machine control has 
;two modes of operation: CONFIG and RUN. There is a selector 
;who has the name of MODSEL who is in charge of choosing the 
;mode in which it is being worked. Considering subroutines:
;       - MODO CONFIG:
;This is the operating mode where the number of screws that 
;go per package is configured.
;       - BCD_BIN: 
;This subroutine takes the value Num_Array and is converted 
;to binary and stored in CantPQ.
;       - MODO RUN:
;This mode is in charge of executing the action, it considers 
;TIMER_CUENTA and "CUENTA" until reaching CantPQ. The "CUENTA" 
;and AcmPQ values are stored in BIN1 and BIN2 to be displayed 
;on the 7-segment display.
;       - RTI_ISR:
; RTI of 1 mS is implemented. The value of
; TIMER_CUENTA is reduced every time
; different from zero. Subtraction Cont_Reb
; as long as it is different from zero.
;       - PTH_ISR
;It handles the PTH0 interrupt (CuentaCLR), 
;PTH1 interrupt (AcmCLR) and 
;the PTH3 / PH2 interrupt.
;       - OC4_ISR:
;It attends to the Output Compare interrupt 
;of Channel 4. Receiving the value in 7 segments 
;to be displayed (variables DISP1 to DISP4) and 
;the variable LEDs and is in charge of displaying 
;it on the 7-segment screen and the LED port in 
;a multiplexed manner, according to the multiplexing 
;technique seen in class.
;       - CONV_BIN_BCD:
;It receives two values ​​equal to or less than 99, 
;in order to assign a value of $B to designate 
;the screen positions in off
;       - BIN_BCD:
;This subroutine is responsible for converting a 
;binary number into BCD using the XS3 algorithm
;       - BCD_7SEG:
;This subroutine is in charge of converting the BCD 
;values ​​to 7 segments by means of a table and 
;the indexed addressing
;       - Cargar_LCD:
;Every time the operating mode is changed,
;by means of the CambMod flag. It is activated every 
;time the operating mode is changed in order to enable 
;screen refresh and optimize this feature.
;       - Delay: 
;It takes care of waiting the necessary delay.
;       - Send_Command & Send_Data: 
;They send both the commands and the data to the 
;LCD through accumulator A.

;##--------------------------------  INCLUDE ------------------------------------
#include  registers.inc

;##--------------------------------  DEFINITIONS ------------------------------------
;##------------  STRUCT - FLAG INTRP VARIABLES --------------------------------------
i_n_element:    EQU $FF
VMAX:   EQU $FA  

;##------------  MAIN VARIABLES -----------------------------------------------------
        ORG  $1000
MAX_TCL:        DB  2    ; How many digits has
BANDERAS:       DS  1    
Tecla:          DS  1    ; key entered
Tecla_IN:       DS  1    ; valid entered key
Cont_Reb:       DS  1    ; bounce counter
Cont_TCL:       DS  1    ; entered key counter
PATRON:         DS  1    ; keyboard's read path
Num_Array:      DS  2    ; Sequence entered
CUENTA:         DS  1   
AcmPQ:          DS  1
CantPQ:         DS  1
TIMER_CUENTA:   DS  1
LEDs:           DS  1
BRILLO:         DS  1
CONT_DIG:       DS  1
CONT_TICKS:     DS  1
DT:             DS  1 ; digits and port leds
BIN1:           DS  1
BIN2:           DS  1
BCD_L:          DS  1
LOW:            DS  1
var_temp:       DS  1
BCD1:           DS  1
BCD2:           DS  1
DISP1:          DS  1 ; var to load -> main
DISP2:          DS  1 ; var to load -> main
DISP3:          DS  1 ; var to load -> main
DISP4:          DS  1 ; var to load -> main
CONT_7SEG:      DS  2
Cont_Delay:     DS  1
clean_LCD:      DB  $01
init_L1_LCD:    DB  $80
init_L2_LCD:    DB  $C0
delay_2_ms:     DB  100
delay_260_us:   DB  13
delay_40_us:    DB  2

        ORG  $1030
Teclas: DB  $01,$02,$03,$04,$05,$06,$07,$08,$09,$0B,$00,$0E 

        ORG  $1040
SEGMET: DB  $3f,$06,$5b,$4f,$66,$6d,$7d,$07,$7f,$6f

        ORG  $1050
iniDisp: DB  $28,$28,$06,$0C
        DB  i_n_element

;##------------ TERMINAL MESSAGES ---------------------------------------------------------

        ORG $1080
PRINT_MODEConfig:     FCC "   MODO CONFIG  "
                DB i_n_element

PRINT_entrCant:     FCC " INGRESE CantPQ "
                DB i_n_element

PRINT_MODERun:      FCC "    MODO RUN    "
                DB i_n_element

PRINT_AcmPQCount:      FCC " AcmPQ   CUENTA  "
                DB i_n_element

;##------------ FLAG INTERRUPTION VECTORS  ---------------------------------------------------------
                ORG    $3E4C
                DW     PTH_ISR
                
                ORG    $3E66
                DW     OC4_ISR

                ORG    $3E70
                DW     RTI_ISR
;##--------- HARDWARE VARIABLES SETUP ----------------------------------------
        ORG   $2000            
        LDS   #$3BFF           ; stack pointer $3BFF
;##------------  KeyBoard -----------------------------------------------------
        MOVB  #$F0,DDRA        ; PH7-PH4 -> input ; PH3-PH0 -> output       
        BSET  PUCR,1           ; Pullup resistors activated 
;##------------  Screw sensor -----------------------------------------------------
        BSET  CRGINT,$80       ; On - RTI
        MOVB  #$17,RTICTL      ; M=1, N=7 RTI = 1ms
;##------------  LCD Screen -----------------------------------------------------
        MOVB #$FF, DDRK        ; PK7-PK0 -> outputs        
;##------------  7seg Screen -----------------------------------------------------
        MOVB  #$FF,DDRB        ; PB7-PB0 -> outputs (D7S config)
        BSET  DDRJ,$02         ; enable - LED                                    
        MOVB  #$0F,DDRP        ; PP3-PP0 -> outputs
;##------------  PortH (AcmCLR, CuentaCLR) -----------------------------------------------------
        BCLR  DDRH,%00001111   ; PH7, PH1-PH0 -> input    (H port)    
        BSET  PIEH,%00001100   ; on - interrupt
;##------------  TIMER4/MODOSEL -----------------------------------------------------
        BSET  TSCR1,%10010000  ; TEN = 1 ; TFFCA = 1.
        BSET  TSCR2,%00000100  ; Prescaler -> 16
        MOVB  #%00010000,TIOS  ; Output channel 4
        MOVB  #%00010000,TIE   ; enable - OC4 interruption
        CLI  
;##------------  Output SAL -----------------------------------------------------
        BSET    DDRE,%00000100 ; PE2 -> out (relé)

;##--------- INIT VARIABLES ----------------------------------------
_init_struct:  
        MOVB  #$00, BANDERAS
        MOVB  #$FF, Tecla         
        MOVB  #$FF, Tecla_IN
        MOVB  #$00, Cont_Reb
        MOVB  #$00, Cont_TCL
        MOVB  #$00, PATRON
        LDX   #Num_Array          
        MOVB  #$FF,1,X
        MOVB  #$FF,0,X
        MOVB  #$00, CUENTA                
        MOVB  #$00, AcmPQ
        MOVB  #$00, CantPQ
        MOVB  #VMAX, TIMER_CUENTA
        MOVB  #$00,LEDs 
        MOVB  #50, BRILLO  
        MOVB  #$00, CONT_DIG      
        MOVB  #$00, CONT_TICKS
        MOVB  #$00, BIN1
        MOVB  #$00, BIN2   
        MOVW  #$00, CONT_7SEG
        MOVB  #$00, Cont_Delay    
        LDD   TCNT   
        ADDD  #30
        STD   TC4   
                            
;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##-------------------------------- MAIN ------------------------------------
;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
        JSR   LCD
        BSET  BANDERAS,%00010000  ; CambMod = 1

MAIN_LOOP:
        TST   CantPQ
        BEQ   config_first
        BRSET PTIH,%10000000,MODE_1 

MODE_0:
        BRCLR BANDERAS,%00001000,Select_Mode  ; MODESEL  = ModActual
        JMP   Change_mode                     ; MODESEL != ModActual

MODE_1:
        BRSET BANDERAS,%00001000,Select_Mode  ; MODESEL  = ModActual

Change_mode:
        BSET  BANDERAS,%00010000               ; CambMod = 1
        LDAA  BANDERAS                         
        EORA  #$08
        STAA  BANDERAS                         ; ModActual = MODESEL

Select_Mode:
        BRSET PTIH,%10000000,config_LCD          ; jumps if MODESEL = 1

LCD_RUN:
        BRCLR BANDERAS,%00010000,switch_Mode  ; jumps if CambMod = 0
        BCLR  %00010000,BANDERAS              
        MOVB  #%00000001,LEDs 
        BSET  PIEH,$03
        LDX   #PRINT_MODERun
        LDY   #PRINT_AcmPQCount
        JSR   CARGAR_LCD   

switch_Mode:
        JSR   MODO_RUN                       
        JMP   MAIN_LOOP  

config_first:
        BSET  BANDERAS,%00001000               ; ModActual = 1

config_LCD:
        BRCLR BANDERAS,%00010000,switch_config_Mode ; jumps if CambMod = 0
        BCLR  BANDERAS,%00010000               ; CambMod = 0
        MOVB  #%00000010,LEDs
        MOVB  #$00,CUENTA                           
        MOVB  #$00,AcmPQ
        BSET  CRGINT,$80  
        BCLR  PIEH,$03
        LDX   #PRINT_MODEConfig
        LDY   #PRINT_entrCant
        JSR   CARGAR_LCD      

switch_config_Mode:
        JSR   MODO_CONFIG                      
        JMP   MAIN_LOOP   

;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##-------------------------------- SUBROUTINES ------------------------------------
;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##--------- MODO_CONFIG ----------------------------------------
MODO_CONFIG:
        MOVB   CantPQ,BIN1
        BRCLR  BANDERAS,%00000100,read_KeyBoard
        
valid_CANTPQ:
        JSR    BCD_BIN
        LDAA   CantPQ
        CMPA   #25 ; screws
        BCS    Notvalid_CANTPQ     
        CMPA   #85 ; screws
        BHI    Notvalid_CANTPQ  

ifvalid_CANTPQ:
        BCLR   BANDERAS,%00000100    ; clean ARRAY_OK
        MOVB   CantPQ,BIN1   
        RTS

Notvalid_CANTPQ:
        BCLR   BANDERAS,%00000100    ; clean ARRAY_OK
        MOVB   #0,CantPQ             ; CantPQ = 0
        RTS

read_KeyBoard:
        JSR    TAREA_TECLADO
        RTS

;##--------- MODO_RUN ----------------------------------------
MODO_RUN:
        TST   TIMER_CUENTA
        BNE   RTN_ModeRun

CUENTA_Increase:
        MOVB  #VMAX,TIMER_CUENTA ; set TIMER_CUENTA
        INC   CUENTA             
        LDAA  CantPQ
        CMPA  CUENTA
        BEQ   on_Rele

off_Rele:
        BCLR  PORTE,%00000100    ; off - rele
        JMP   RTN_ModeRun

on_Rele:
        INC   AcmPQ
        BSET  PORTE,%00000100    ; on - rele
        BCLR  CRGINT,%10000000   ; off -  RTI

RTN_ModeRun:
        MOVB CUENTA,BIN1         ; BIN1 <- (CUENTA)
        MOVB AcmPQ,BIN2          ; BIN2 <- (AcmPQ)
        RTS

;##--------- LCD Display ----------------------------------------  
LCD:        
        LDX   #iniDisp

send_CMD:   
        LDAA  1,X+
        CMPA  #i_n_element
        BEQ   return_LCD  
        JSR   Send_Command              
        MOVB  delay_40_us,Cont_Delay
        JSR   DELAY                     
        JMP   send_CMD   

return_LCD:    
        LDAA  clean_LCD                 
        JSR   Send_Command
        MOVB  delay_2_ms,Cont_Delay           
        JSR   DELAY
        RTS
;##--------- CARGAR_LCD ----------------------------------------  
CARGAR_LCD:    
        LDAA  init_L1_LCD   ; set l1                   
        JSR   Send_Command
        MOVB  delay_40_us,Cont_Delay
        JSR   DELAY

send_mgs_L1:
        LDAA  1,X+                       
        CMPA  #i_n_element
        BEQ   set_L2
        JSR   Send_Data
        MOVB  delay_40_us,Cont_Delay           
        JSR   DELAY
        JMP   send_mgs_L1

set_L2:
        LDAA  init_L2_LCD
        JSR   Send_Command              
        MOVB  delay_40_us,Cont_Delay
        JSR   DELAY

send_mgs_L2:
        LDAA  1,Y+                      
        CMPA  #i_n_element
        BEQ   return_load_LCD
        JSR   Send_Data
        MOVB  delay_40_us,Cont_Delay 
        JSR   DELAY
        JMP   send_mgs_L2

return_load_LCD: 
        RTS

;##--------- SEND_COMMAND ----------------------------------------  
SEND_COMMAND:
        PSHA                      ; stack A
        ANDA  #$F0                ; select up level nibble
        LSRA
        LSRA                      ; X2 : 0 -> (A) -> C    
        STAA  PORTK               ; high value  of cmd in PK   
        BCLR  PORTK,%00000001                 
        BSET  PORTK,%00000010                
        MOVB  delay_260_us,Cont_Delay
        JSR   DELAY               ; wait 260us (protocol)     
        BCLR  PORTK,%00000010                  
        PULA                      ; unStack A
        ANDA  #$0F
        LSLA
        LSLA                      ; X2 : 0 << (A) << C
        STAA  PORTK               ; low value  of cmd in PK    
        BCLR  PORTK,%00000001                   
        BSET  PORTK,%00000010                  
        MOVB  delay_260_us,Cont_Delay         
        JSR   DELAY               ; wait 260us (protocol)     
        BCLR  PORTK,%00000010                    
        RTS

;##--------- SEND_DATA ----------------------------------------  
SEND_DATA:
        PSHA                      ; Stack A
        ANDA  #$F0                ; select up level nibble
        LSRA
        LSRA                      ; X2 : 0 >> (A) >> C
        STAA  PORTK               ; high value  of cmd in PK   
        BSET  PORTK,%00000001       
        BSET  PORTK,%00000010                  
        MOVB  delay_260_us,Cont_Delay     
        JSR   DELAY               ; wait 260us (protocol)     
        BCLR  PORTK,%00000010                    
        PULA                      ;unStack A
        ANDA  #$0F
        LSLA
        LSLA                      ; X2 : 0 << (A) << C
        STAA  PORTK               ; low value  of cmd in PK          
        BSET  PORTK,%00000001                 
        BSET  PORTK,%00000010                    
        MOVB  delay_260_us,Cont_Delay        
        JSR   DELAY              ; wait 260us (protocol)     
        BCLR  PORTK,%00000010                  
        RTS

;##--------- DELAY ----------------------------------------  
DELAY:
        TST  Cont_Delay
        BNE  DELAY
        RTS

;##--------- CONV_BIN_BCD ----------------------------------------  
CONV_BIN_BCD:
        CLR   BCD1
        CLR   BCD2 
        CLR   BCD_L
        LDAA  BIN1
        JSR   BIN_BCD
        LDAA  BCD_L
        ANDA  #$F0
        BNE   save_BCD1
        LDAA  BCD_L
        ADDA  #$B0
        STAA  BCD_L

save_BCD1:
        MOVB  BCD_L,BCD1
        LDAA  BIN2
        JSR   BIN_BCD
        LDAA  BCD_L
        ANDA  #$F0
        BNE   save_BCD2
        LDAA  BCD_L
        ADDA  #$B0
        STAA  BCD_L

save_BCD2:
        MOVB  BCD_L,BCD2
        RTS


;##--------- BIN_BCD ----------------------------------------  
BIN_BCD:
        LDY   #7
        MOVB  #0,BCD_L

loop_BIN_BCD:
        LSLA
        ROL   BCD_L             
        STAA  var_temp

ifcheck_Nibbles:
        LDAA  #$0F              
        ANDA  BCD_L
        CMPA  #$5
        BCS   No_add_N0     ; jump if Nibbe_low < 5  
        ADDA  #$3               ; Nibbe_low -> up 3 

No_add_N0:
        STAA  LOW
        LDAA  #$F0
        ANDA  BCD_L
        CMPA  #$50
        BCS   No_add_N1    
        ADDA  #$30             

No_add_N1:
        ADDA  LOW
        STAA  BCD_L
        LDAA  var_temp
        DBNE  Y,loop_BIN_BCD    ; jumps if y != 0 
        LSLA
        ROL   BCD_L            
        RTS

;##--------- BCD_BIN ----------------------------------------
BCD_BIN:
        LDX   #Num_Array
        LDAB  1,X+    
        LDAA  #10                       
        MUL              ; tens dgiti * 10   
        ADDB  1,X+       ; unit + result                   
        STAB  CantPQ     ; store in CantPQ
        RTS        

;##--------- BCD_7SEG ----------------------------------------  
;       DSP1 and DSP2 ----- DSP3 and DSP4
;           BCD2      -----      BCD1 
BCD_7SEG:
        LDX  #SEGMET 

set_DISP1:
        MOVB #0,DISP1   ;  DISP1 = 0
        LDAA BCD2
        ANDA #$F0
        CMPA #$B0
        BEQ  set_DISP2  ; if != 0 load value in SEGMENT
        LSRA           
        LSRA
        LSRA
        LSRA
        MOVB A,X,DISP1  ; load DISP1

set_DISP2:
        LDAA BCD2
        ANDA #$0F
        MOVB A,X,DISP2  ; load DISP2

set_DISP3:
        MOVB #0,DISP3   ; DISP3 = 0
        LDAA BCD1
        ANDA #$F0
        CMPA #$B0
        BEQ  set_DISP4  ;  if != 0 load value in SEGMENT
        LSRA            
        LSRA
        LSRA
        LSRA
        MOVB A,X,DISP3  ;  load DISP3

set_DISP4:
        LDAA #$0F
        ANDA BCD1
        MOVB A,X,DISP4  ; load DISP4
        RTS

;##--------- TAREA_TECLADO ----------------------------------------
TAREA_TECLADO: 
        TST    Cont_Reb
        BNE    return_TAREA                    
        JSR    MUX_TECLADO
        LDAA   #$FF
        CMPA   Tecla
        BNE    press_KEY      
        BRSET  BANDERAS,%00000001,add_KEY    
        JMP    return_TAREA

press_KEY:
        BRSET  BANDERAS,%00000010,processed_KEY  
        MOVB   Tecla,Tecla_IN
        BSET   BANDERAS,%00000010                  ; read key 
        MOVB   #$0A,Cont_Reb
        JMP    return_TAREA

processed_KEY: 
        LDAB   Tecla
        CMPB   Tecla_IN
        BEQ    ready_KEY

read_ERROR:
        MOVB   #$FF,Tecla
        MOVB   #$FF,Tecla_IN
        BCLR   BANDERAS,%00000011
        JMP    return_TAREA

ready_KEY:
        BSET   BANDERAS,%00000001                  ; key ready  
        JMP    return_TAREA

add_KEY: 
        BCLR   BANDERAS,%00000011
        JSR    FORMAR_ARRAY
        JMP    return_TAREA

return_TAREA:
        RTS

;##--------- MUX_TECLADO ----------------------------------------
MUX_TECLADO:
        LDX    #Teclas
        LDAA   #$00
        LDAB   #$F0
        MOVB   #$EF,PATRON
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP

scan_MATX:
        MOVB   PATRON, PORTA
        BRCLR  PORTA,%00000010, COL_1 ; ; some column  of the row selected is in low?
        BRCLR  PORTA,%00000100, COL_2 
        BRCLR  PORTA,%00001000, COL_3 
        ADDA   #3            ; for index key            
        LSL    PATRON       
        LDAB   #$F0
        CMPB   PATRON
        BNE    scan_MATX    
        MOVB   #$FF, Tecla   ; no key entered
        JMP    RETURN_MUX
COL_3:
        INCA       ; column 3 + 2
COL_2:
        INCA       ; column 2 + 1
COL_1: 
        MOVB A,X,Tecla    ; save value of key enter

RETURN_MUX:   
        RTS   

;##--------- FORMAR_ARRAY ----------------------------------------
FORMAR_ARRAY: 
        LDAA  Cont_TCL
        CMPA  MAX_TCL
        BNE   notLast_TCL 

Last_TCL:   
        LDAA  #$0B
        CMPA  Tecla_IN    
        BEQ   BORRAR 
        LDAA  #$0E
        CMPA  Tecla_IN 
        BEQ   ENTER
        JMP   return_FORMAR_ARRAY

notLast_TCL: 
        TST   Cont_TCL
        BEQ   First_TCL

notFirst_TCL:  
        LDAA  #$0B
        CMPA  Tecla_IN    
        BEQ   BORRAR 
        LDAA  #$0E
        CMPA  Tecla_IN    
        BEQ   ENTER
        JMP   save_TCL

First_TCL:    
        LDAA  #$0B
        CMPA  Tecla_IN 
        BEQ   return_FORMAR_ARRAY 
        LDAA  #$0E
        CMPA  Tecla_IN    
        BEQ   return_FORMAR_ARRAY
        JMP   save_TCL

BORRAR:   
        DEC   Cont_TCL
        LDX   #Num_Array
        LDAA  Cont_TCL
        MOVB  #$FF,A,X
        JMP   return_FORMAR_ARRAY

ENTER:    
        BSET  BANDERAS,%00000100                  ; Array Ok
        MOVB  #$00,Cont_TCL
        JMP   return_FORMAR_ARRAY

save_TCL:  
        LDAA  Cont_TCL
        LDX   #Num_Array
        MOVB  Tecla_IN,A,X 
        INC   Cont_TCL

return_FORMAR_ARRAY:   
        MOVB  #$FF,Tecla_IN
        RTS

;##--------- RTI_ISR (INTERRUPTION) ----------------------------------------
RTI_ISR:
        BSET  CRGFLG, %10000000
        TST   TIMER_CUENTA
        BEQ   Check_Cont_Reb    
        DEC   TIMER_CUENTA   ; TIMER_CUENTA != 0 => TIMER_CUENTA--

Check_Cont_Reb:
        TST   Cont_Reb
        BEQ   return_RTI
        DEC   Cont_Reb       ; Cont_Reb != 0 => Cont_Reb

return_RTI:
        RTI


;##------- >>> -------------------- >>> ------- PTH_ISR (INTERRUPTION) ----------------------------------------
PTH_ISR:    
        TST     Cont_Reb
        BEQ     PROC_PHO
        MOVB    #10,Cont_Reb  


;##--------- BOUNCE SUPPRESSION  ----------------------------------------  
PROC_REB: 
        BRSET   PIFH,%00000001,REB_PH0 
        BRSET   PIFH,%00000010,REB_PH1
        BRSET   PIFH,%00000100,REB_PH2
        BRSET   PIFH,%00001000,REB_PH3

REB_PH0:  
        BSET  PIFH,%00000001
        JMP   return_PTH

REB_PH1:  
        BSET  PIFH,%00000010
        JMP   return_PTH

REB_PH2:   
        BSET  PIFH,%00000100
        JMP   return_PTH

REB_PH3:
        BSET  PIFH,%00001000
        JMP   return_PTH


;##---------  INTERRUPTION PROCESSING ----------------------------------------  
PROC_PHO:  
        BRSET   PIFH,%00000100,decrease_BRILLO
        BRSET   PIFH,%00001000,increase_BRILLO
        BRSET   PIFH,%00000001,push_PHO 
        BRSET   PIFH,%00000010,push_PH1
        JMP     return_PTH

push_PHO:
        BSET  PIFH,%00000001
        MOVB  #0,CUENTA                            
        BSET  CRGINT,$80                        
        JMP   return_PTH

push_PH1:
        BSET  PIFH,%00000010
        MOVB  #0,AcmPQ                         
        JMP   return_PTH

decrease_BRILLO: 
        BSET  PIFH,%00000100
        TST   BRILLO                         
        BEQ   return_PTH
        LDAA  BRILLO
        suba  #5
        STAA  BRILLO
        JMP   return_PTH

increase_BRILLO: 
        BSET  PIFH,%00001000
        LDAA  BRILLO                          
        CMPA  #100
        BEQ   return_PTH
        ADDA  #5
        STAA  BRILLO

return_PTH: 
        RTI

;##--------- OC4_ISR (INTERRUPTION) ----------------------------------------  
OC4_ISR:
        LDD   CONT_7SEG
        CPD   #5000
        BEQ   Update_DisplaySeg

CONT_7SEG_increase:
        ADDD  #1
        STD   CONT_7SEG
        JMP   Update_ContDelay

Update_DisplaySeg:
        MOVW  #0,CONT_7SEG
        JSR   CONV_BIN_BCD
        JSR   BCD_7SEG

Update_ContDelay:
        TST   Cont_Delay
        BEQ   MULTIPLEXER

decrease_ContDelay:
        DEC   Cont_Delay
 
;##---------  MULTIPLEXATION ----------------------------------------  
MULTIPLEXER: 
        LDAA  CONT_TICKS
        CMPA  #100
        BEQ   select_Display

RT_BRILLO:     
        LDAB  #100
        SUBB  BRILLO
        STAB  DT
        CMPB  CONT_TICKS
        BNE   increase_CONT_TICKS
        MOVB  #$FF,PTP          
        BSET  PTJ,$02 

increase_CONT_TICKS:
        INC   CONT_TICKS
        JMP   return_OC4

select_Display:  
        LDAA  CONT_DIG
        CMPA  #4        
        BEQ   select_LEDS
        BSET  PTJ,$02
        CMPA  #3        
        BEQ   select_DISP4
        CMPA  #2        
        BEQ   select_DISP3
        BRSET BANDERAS,%00001000,M_CONF
        CMPA  #1        
        BEQ   select_DISP2 

select_DISP1:     
        MOVB  #$FE,PTP
        MOVB  DISP1,PORTB  
        JMP   increase_contDig

select_DISP2:
        MOVB  #$FD,PTP
        MOVB  DISP2,PORTB  
        JMP   increase_contDig

select_DISP3:
        MOVB  #$FB,PTP
        MOVB  DISP3,PORTB  
        JMP   increase_contDig

select_DISP4:
        MOVB  #$F7,PTP
        MOVB  DISP4,PORTB  
        JMP   increase_contDig

select_LEDS:
        MOVB  #$0F,PTP                
        MOVB  LEDs,PORTB           
        BCLR  PTJ,$02
        JMP   increase_contDig   

M_CONF:
        MOVB  #$FF,PTP
        JMP   increase_contDig

increase_contDig:
        MOVB  #0,CONT_TICKS
        LDAA  CONT_DIG
        CMPA  #4
        BEQ   RST_CONT_DIG
        INC   CONT_DIG
        JMP   return_OC4

RST_CONT_DIG:
        MOVB  #$00,CONT_DIG

return_OC4:
        LDD  TCNT
        ADDD #30
        STD  TC4
        RTI