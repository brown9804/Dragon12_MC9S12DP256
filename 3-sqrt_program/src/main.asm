;       Autor:
; Brown Ramírez, Belinda 
; López, José
; timna.brown@ucr.ac.cr
; jose.lopezpicado@ucr.ac.cr
; Jan, 2021

;##--------------------------------  EXPLANATION ------------------------------------
;This algorithm includes two tables:
;1. DATA -> where data is stored
;2. CUAD -> here we have just values with a int sqrt

;- CANT is a variable that sets the amount of first data to
;find that they have an integer square root (Stored in CUAD)
;The square root is calculated and the values are placed in ENTERO. 

;It has several subroutines:
; LEER_CANT: 
;This subroutine receives the CANT value from the 
;keyboard, using the; GETCHAR subroutine. The subroutine 
;must validate that the entered value is a 
;number between 1 and 99. 
; BUSCAR:
;This subroutine looks for the CANT DATA values that are in CUAD.
;Every time that finds a valid value, the BUSCAR 
;subroutine should call the RAIZ subroutine. In addition, 
;the subroutine will carry a counter of the values
;found in the variable CONT. The BUSCAR subroutine 
;passes the value to RAIZ by means of the stack and by 
;this same means RAIZ returns the result. On the other hand 
;the subroutine must put the result in the ENTERO array. 
; RAIZ:
;This subroutine calculates the square root. 
;The value to which it must be obtained the square root must 
;be passed to the subroutine by the stack and the subroutine
;will return the value calculated by the stack. 
; Print_RESULT:
;This subroutine prints the number 
;of rooted numbers and the
;array integers 

;##--------------------------------  DEFINITIONS ------------------------------------

;##------------  STORE DATA ---------------------------------------------------------
carrage_rturn:  EQU  $0D   
line_feed:      EQU  $0A 
endMessag:      EQU  $0 ; ---->  NULL
stackPointer:   EQU  $3DFF  

;##------------  DEBUGER SUBROUTINES ---------------------------------------------------------
PRINTF:         EQU  $EE88            
GETCHAR:        EQU  $EE84             
PUTCHAR:        EQU  $EE86           

;##------------ VARIABLES GLOBAL ---------------------------------------------------------
        ORG  $1000
LONG:         DB   10
CANT:         DS   1
CONT:         DS   1
LONG_CUAD:    DB   10

        ORG  $1010
ENTERO:       DS   10

        ORG  $1020
DATOS:        DB   1,4,9,9,16,25,8,49,5,64,100

        ORG  $1030
CUAD:         DB   4,9,16,25,36,49,64,81,100

;##------------ VARIABLES LOCAL ---------------------------------------------------------
        ORG  $1040
COUNTER_B0:     DS   1
COUNTER_B1:     DS   1
ITER_LOOP:      DS   2
WTEMP_1:        DS   2
ROOT_X:         DS   2      ; X
ROOT_F:         DS   2      ; F
ROOT_FA:        DS   2      ; Fn-1

;##------------ TERMINAL MESSAGES ---------------------------------------------------------
PRINT00:        DB carrage_rturn, line_feed, carrage_rturn, line_feed
                FCC "INGRESE EL VALOR DE CANT (ENTRE 1 Y 99): "
                DB endMessag

PRINT01:        FCC ""
                DB carrage_rturn, line_feed, carrage_rturn, line_feed
                DB endMessag

PRINT02:        DB carrage_rturn, line_feed, carrage_rturn, line_feed
                FCC "CANTIDAD DE NUMEROS ENCONTRADOS : %i "
                DB endMessag
        
PRINT03:        DB carrage_rturn, line_feed, carrage_rturn, line_feed
                FCC "ENTEROS : "
                DB endMessag
        
PRINT04:        FCC "%u, "
                DB endMessag
        
PRINT05:        FCC "%u"
                DB carrage_rturn, line_feed, carrage_rturn, line_feed
                DB endMessag

;##-------------------------------- MAIN ------------------------------------
        ORG   $2000
_init:
        LDS   #stackPointer       ; init stack pointer
        JSR   LEER_CANT          
        JSR   BUSCAR             
        JSR   PRINT_RESULT        
end:            
        JMP   end


;##------------- READ VALUES -------------------------------------------------------
LEER_CANT:
        LDD   #PRINT00
        LDX   #$0000
        JSR   [PRINTF,X]             ; print -> INGRESE EL VALOR DE CANT (ENTRE 1 Y 99): 
        MOVB  #0, CANT
        MOVB  #2, COUNTER_B0         

GET_CHAR:        
        LDX   #$0000                 ; get number 
        JSR   [GETCHAR,X]            ; $30  < char <  $39
        CMPB  #$30
        BCS   GET_CHAR
        CMPB  #$39
        BHI   GET_CHAR

PRINT_CHAR:
        LDX   #$0000
        JSR   [PUTCHAR,X]            ; print valid char

CALC_CANT:
        SUBD  #$30                  ; from chart to int 
        LDAA  #2
        CMPA  COUNTER_B0
        BNE   UNITS

TENTS:
        CLRA                         
        LDY   #10                    ; int* 10
        EMUL

UNITS:
        ADDB  CANT                   ; unit do not multiply
        STAB  CANT
        DEC   COUNTER_B0

IF_LOOP:
        BNE   GET_CHAR
        TST   CANT
        BEQ   LEER_CANT              ; if CANT == 0 
        RTS
                
;##------------- SEARCH -------------------------------------------------------
BUSCAR:
        MOVB  #0, CONT
        MOVB  LONG, COUNTER_B0
        MOVW  #ENTERO, ITER_LOOP
        LDX   #DATOS                ; load data

DATOS_LOOP: 
        LDAB  1,X+                  ; value per value 
        LDY   #CUAD
        MOVB  LONG_CUAD, COUNTER_B1

CUAD_LOOP:      
        LDAA  $0,Y                   ; get data
        CMPB  1,Y+                   ; compare with CUAD
        BNE   DEC_CUAD_COUNT         ; if match -> sqrt?
        INC   CONT

CALC_ROOT:       
        PSHX
        PSHB
        JSR   RAIZ                  
        PULB
        pulx

SAVE_ROOT:      ; store sqrt in ENTERO
        LDY   ITER_LOOP                 
        STAB  1,y+
        STY   ITER_LOOP 

DEC_CANT:        
        DEC   CANT
        BEQ   END_BUSCAR             ; if CANT = 0
        JMP   DEC_DATOS_COUNT

DEC_CUAD_COUNT: 
        DEC   COUNTER_B1
        BNE   CUAD_LOOP

DEC_DATOS_COUNT: 
        DEC   COUNTER_B0
        BNE   DATOS_LOOP

END_BUSCAR:      
        RTS

;##------------- SQRT -------------------------------------------------------
RAIZ:      
        PULY
        CLRA
        PULB
        STD    ROOT_X             ; X
        STD    ROOT_FA
        MOVW   #0, ROOT_F         ; F0 = 0

LOOP_RAIZ:      
        CPD    ROOT_F             ; F  = FA
        BEQ    READY
        MOVW   ROOT_FA,ROOT_F
        LDD    ROOT_X
        LDX    ROOT_FA
        IDIV
        XGDX
        ADDD   ROOT_FA
        LSRD
        STD    ROOT_FA           ; F = 1/2( X/FA + FA)
        JMP    LOOP_RAIZ

READY:          
        PSHB
        PSHY
        RTS

;##------------- PRINT_RESULT -------------------------------------------------------

PRINT_RESULT:   
        PULY                       ;  save returning address 
        STY    WTEMP_1            
        CLRA
        LDAB   CONT
        PSHD
        LDD    #PRINT02
        LDX    #$0000
        JSR    [PRINTF,X]          ; print CONT
        LDD    #PRINT03
        LDX    #$0000
        JSR    [PRINTF,X]
        MOVB   CONT, COUNTER_B0
        MOVW   #ENTERO, ITER_LOOP

PRINT_LOOP:     
        LDY    ITER_LOOP              ; print ENTERO array
        CLRA
        LDAB   1,Y+
        PSHD
        STY    ITER_LOOP
        LDAB   #1
        CMPB   COUNTER_B0
        BEQ    LAST_PRINT          ; if COUNTER_B0 = 1 
        LDD    #PRINT04
        LDX    #$0000
        JSR    [PRINTF,X]
        JMP    DEC_COUNTER

LAST_PRINT:     ; no print "," for last
        LDD    #PRINT05              
        LDX    #$0000              
        JSR    [PRINTF,X]

DEC_COUNTER:    
        DEC    COUNTER_B0
        BNE    PRINT_LOOP
        LDY    WTEMP_1             ; get stack pointer 
        PSHY
        RTS
                
