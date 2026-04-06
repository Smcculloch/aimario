; Simple test function in a separate file
.segment "CODE"

.export TestFunc

.proc TestFunc
    ; Just set color 0 to green and return
    stz $2121           ; CGRAM address 0
    lda #$E0            ; low byte of $03E0 (green)
    sta $2122
    lda #$03            ; high byte
    sta $2122
    rts
.endproc
