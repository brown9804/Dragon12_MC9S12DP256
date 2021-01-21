;       Autor:
; Brown Ramírez, Belinda 
; timna.brown@ucr.ac.cr


; Zeros Word Counter 

; The number of zeros contained in the Word 
; of the memory locations whose effective 
; address is Y + $ 20 is counted, where Y 
; is the index register of the programming 
; model. The result is saved in memory address 
; Y + $ EE10.


begin:
        CLR  #$EE10, Y ; clearing mem 
        STAB $16, Y ; Store B register data in memory  - aux memory 
        LDD  $20, Y ; Load D register (A:B) from memory

forloop:
        LSRD        ; local shift right D accumulator
        BCS next    ; checks carry -> branch to next if carry set C == 1
        PSHD        ; push D accumulator into Stack 
        LDD #$EE10   ; Store Double accumulator -> store result 
        INC  D, Y   ; increment memory byte 
        PULD        ; Pull D from Stack 
next:   
        DEC   $16, Y ; Decrement memory location
        MOVB $16, $EE10, $Y ; if all select bits set Y + $ EE10 = 16
end:
        JMP end     