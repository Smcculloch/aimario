; =============================================================================
; Joypad Reading + Edge Detection
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.importzp joy1_raw, joy1_press, joy1_held

.export ReadJoypad

.segment "CODE"

; =============================================================================
; ReadJoypad — reads controller 1, computes newly-pressed buttons
; =============================================================================
.proc ReadJoypad
    SetA16

    ; Wait for auto-read to complete
@wait:
    lda HVBJOY
    and #$0001
    bne @wait

    ; Save previous frame
    lda joy1_raw
    sta joy1_held

    ; Read current frame
    lda JOY1L                  ; 16-bit read: JOY1L + JOY1H
    sta joy1_raw

    ; Newly pressed = current AND NOT previous
    eor joy1_held              ; bits that changed
    and joy1_raw               ; of those, ones now pressed
    sta joy1_press

    SetA8
    rts
.endproc
