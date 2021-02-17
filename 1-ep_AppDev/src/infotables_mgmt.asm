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
    CLRB 
    LDX  # DIRECCIONES
    LDY  # BUFFER
    LDD  # NODO ;because for 2500 need more than 8 bits 
    DECD        ; reloc -> D - 1 ... 0, 1, 2, 3, 4, 5, 6 

move:
    LSLD        ; shift left 
    DECD        ; D - 1
    DECD        ; 2*(nodo-1)
    LDX [D,X]   ; node number -> buffer 
    LDAB #4
    
forloop:
    MOVW 2, X-, 2, Y+ ; moving two above and two below
    DBNE B, forloop
    STY D,X     
    PULY        ; pull nodo num 

end:
    JMP end
