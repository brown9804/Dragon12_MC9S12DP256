;       Autor:
; Brown Ramírez, Belinda 
; López, José
; timna.brown@ucr.ac.cr
; jose.lopezpicado@ucr.ac.cr
; Feb, 2021

;##--------------------------------  EXPLANATION ------------------------------------
; This algorithm reads the key values in BCD and creates an array with the
; key sequence entered. The key sequence has a length
; defined by means of a constant and its value is between 1 and 6.
; You can read a key or up to 6 keys can be read. The user can enter a
; key sequence at the defined interval until the key is pressed
; E (enter). The pressed key sequence is stored in an array
; as discussed later. During the input of the sequence of
; keys the user can press the B key (delete) in which case the
; the last key pressed placed in the array. When it comes to the last
; algorithm sequence data only accepts the E key or the B key. Any
; another pressed key should be ignored. If in a key sequence the
; The first key that is pressed is the E key or the B key is not considered.
; "Rollover" is NOT implemented.

; ABOUT HARDWARE:
; The keyboard is implemented with the Dragon 12+ button matrix connected 
; to port A. Using the first 12 buttons from right to left and top to bottom 
; (the first column of buttons is not used).

; ABOUT SOFTWARE:
; - MAIN:
; The main program declares and initializes the data structures and
; configures RTI and PH0 interrupts. Also calls way
; recurring to the Keyboard_Task, whenever the ARRAY_OK flag is
; zero. This flag is set to 1 when a key sequence is finished
; and is cleared by the procedure using the read key sequence.
; In this case, for testing purposes, this flag will be cleared by
; middle of the PH0 interrupt.

; - RTI_ISR Subroutine:
; The RTI interrupt service subroutine only discounts
; the bounce counter (Cont_Reb) only if it is different from zero.
; If this counter is zero, this subroutine does not execute any 
; action and returns. This interrupt is generated at a rate of 1 mS.

; - TAREA_TECLADO:
; This subroutine is in charge of calling the
; subroutine MUX_TECLADO to capture a pressed key. further
; This subroutine performs the actions to suppress the bounces and to
; define the concept of a held key, reading the key until it
; be released. In this subroutine, the Cont_Reb is loaded when a
; pressed key, it is validated if the pressed key is valid, comparing two
; readings of the same after the bounce suppression. Finally
; the Keyboard_Task should call the FORMAR_ARRAY subroutine when
; determine that a key has been read correctly
; (TCL_LISTA = 1). This subroutine must be implemented according to the
; design discussed in the video.

; - MUX_TECLADO: 
; This subroutine is in charge of reading the keyboard itself.
; The matrix keyboard is read iteratively by sending one of the 4
; patterns ($ EF, $ DF, $ BF, $ 7F) to port A. A variable named PATTERN is used
; which is loaded with the initial pattern and shifts the
; zero position until all patterns are covered. For reading the
; keyboard should NOT read the patterns, instead look for which one
; low bit of port A is set to zero to identify the
; key pressed, this way there are only 3 possibilities. The value of the
; pressed key is returned, to the procedure that called this
; subroutine, through the variable Key. This subroutine does not receive any
; parameter.

; - FORMAR_ARRAY Subroutine:
; This subroutine receives the value of the valid key pressed in
; the variable IN_key. It also has the value of the constant that defines
; what is the maximum length of the key sequence stored in
; MAX_TCL, this constant can have a value between 1 and 6. The
; subroutine places key values ​​in an orderly fashion
; received at Key_IN in an array named Num_Array. 
; Uses a variable called Cont_TCL to store the key number in Num_Array. 
; This arrangement must be accessed by indexed addressing by accumulating 
; B (loading in B the content of Cont_TCL). Every time FORMAR_ARRAY is entered, 
; it is validated first if MAX_TCL was reached, if so, it is validated if 
; the new key received in Key_IN is $ 0E (Enter) in which case ARRAY_OK = 1
; indicating that the Num_Array was completed and Cont_TCL = 0 is reset, so that
; be ready for a new input sequence. If what was received in
; Key_IN is $ 0B, put $ FF at the current position of Num_Array and
; discount Cont_TCL, only if this is not zero, so that in the next
; iteration (new entry of a key) this is stored in the
; previous position (erase function). The indicated, regarding
; reception in FORMAR_ARRAY of an E or B key, applies in
; any time a key is received on the IN_key, except with the
; first key, because if $ 0B or $ 0E is received as the first key, you must
; be ignored. When Cont_TCL reaches the value of
; MAX_TCL the only valid keys to process are E and B, any other
; key pressed should be ignored. The entered sequence is terminated 
; with an E key and its length can be anything between 1 and MAX_TCL. 
; Also when the sequence of keys the ARRAY_OK flag is set to 1.

; - PHO_ISR Subroutine:
; This is the PH0 interrupt service subroutine. In this subroutine
; all you do is clear the ARRAY_OK flag and it clears
; Num_Array putting all its values in $ FF, to allow the entry of a
; new key sequence. 


;##--------------------------------  INCLUDE ------------------------------------
#include  registers.inc 

;##--------------------------------  DEFINITIONS ------------------------------------
;##------------  MAIN VARIABLES -----------------------------------------------------
                ORG   $1000
MAX_TCL:        DB 6    ; How many digits has
Tecla:          DS 1    ; key entered
Tecla_IN:       DS 1    ; valid entered key
Cont_Reb:       DS 1    ; bounce counter
Cont_TCL:       DS 1    ; entered key counter
PATRON:         DS 1    ; keyboard's read path
BANDERAS:       DS 1    ; flags
Num_Array:      DS 6    ; Sequence entered
Teclas:         DB $01,$02,$03,$04,$05,$06,$07,$08,$09,$0B,$00,$0E 
 
;##------------  FLAG INTRP VARIABLES ------------------------------------------------
    ORG    $3E4C
    DW     PHO_ISR
    
    ORG    $3E70
    DW     RTI_ISR

;##--------- HARDWARE VARIABLES SETUP ----------------------------------------
    ORG   $2000
    LDS   #$3BFF
_init_RTI:       
    BSET  CRGINT,$80         ; RTI interrupt is activated
    MOVB  #$17,RTICTL        ; M=1, N=7 RTI = 1ms
_init_PHO:       
    BCLR  DDRH,$01           ; bit 0 of Port H as input          
    BSET  PIEH,$01           ; PHO Interrupt is activated
config_PORT_A:     
    MOVB  #$F0,DDRA                 
    BSET  PUCR,1       

;##--------- INIT VARIABLES ----------------------------------------
_init_struct:    
    MOVB  #$FF, Tecla
    MOVB  #$FF, Tecla_IN
    MOVB  #$00, Cont_Reb
    MOVB  #$00, Cont_TCL
    MOVB  #$00, PATRON    
    MOVB  #$00, BANDERAS
    LDX   #Num_Array           ; set Num_Array
    LDAA  #6

_init_NUM_ARRAY: 
    DECA
    MOVB  #$FF, A,X
    TSTA
    BNE   _init_NUM_ARRAY
    CLI                         ; Maskable interrupts are enabled 

;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##-------------------------------- MAIN ------------------------------------
;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
_init_main:                                      ; read TECLA
    BRSET  BANDERAS,%00000100, _init_main
    JSR   TAREA_TECLADO
    JMP   _init_main

;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##-------------------------------- SUBROUTINES ------------------------------------
;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@;@@@@@@@@@@@@@
;##--------- RTI_ISR ----------------------------------------
RTI_ISR:            
    BSET  CRGFLG, %10000000
    TST   Cont_Reb
    BEQ   return_RTI
    DEC   Cont_Reb

return_RTI:         
    RTI

;##--------- TAREA_TECLADO ----------------------------------------
TAREA_TECLADO:      
    TST    Cont_Reb
    BNE    return_TAREA                    
    JSR    MUX_TECLADO
    LDAA   #$FF
    CMPA   Tecla
    BNE    press_KEY      
    BRSET  BANDERAS,%00000001, add_KEY    
    JMP    return_TAREA

press_KEY:   
    BRSET  BANDERAS,%00000010, processed_KEY  
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
    BCLR   BANDERAS, %00000011
    JMP    return_TAREA

ready_KEY:       
    BSET   BANDERAS,%00000001                 
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

scan_MATX:    
    MOVB   PATRON, PORTA
    BRCLR  PORTA,%00000010, COL_1  ; some column  of the row selected is in low?
    BRCLR  PORTA,%00000100, COL_2 
    BRCLR  PORTA,%00001000, COL_3 
    ADDA   #3                      ; for index key
    LSL    PATRON                       
    LDAB   #$F0
    CMPB   PATRON
    BNE    scan_MATX    
    MOVB   #$FF, Tecla                  ; no key entered
    JMP    RETURN_MUX

COL_3:          
    INCA                                ; column 3 + 2

COL_2:          
    INCA                                ; column 2 + 1

COL_1:          
    MOVB A,X, Tecla                      ; save value of key enter

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
    BSET  BANDERAS,%00000100                 
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

;##--------- PHO_ISR ----------------------------------------
PHO_ISR:            
    BSET  PIFH,$01
    BCLR  BANDERAS,%00000100    ; clean ARRAY_OK
    MOVB  #$00, Cont_TCL
    LDX   #Num_Array            ; clean Num_Array
    LDAA  #6 

CLEAR_NUM_ARRAY:    
    DECA
    MOVB  #$FF, A,X
    TSTA
    BNE   CLEAR_NUM_ARRAY
    RTI
