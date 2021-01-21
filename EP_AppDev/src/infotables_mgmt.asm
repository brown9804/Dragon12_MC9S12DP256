;       Autor:
; Brown Ramírez, Belinda 
; timna.brown@ucr.ac.cr

; Ntables Nnodos2500 Buffer 
;I.   ID number.
;II.  Location Number.
;III. Baud Rate.
;IV.  Throughput.

;ID number
;Location Number-> 2*i + nodo 
;Baud Rate  ->  4*i + nodo 
;Throughput  -> 6*i + nodo 


begin:
    LDX  # DIRECCIONES
    LDY  # BUFFER
    LDD  # NODO ;because for 2500 need more than 8 bits 
    DECD        ; reloc -> D - 1 ... 0, 1, 2, 3, 4, 5, 6 

forloop:
    LSLD        ; shift left 
    DECD        ; D - 1
    DECD        ; 2*(nodo-1)
    LDD [D,X]   ; node number -> buffer 
    MOVW 2, X-, 2, Y+ ; moving two above and two below
    STY D,X     
    PULY        ; pull nodo num 

next:
    DBNE D, forloop ; stop when is more 2500 laps
    
end:
    JMP end