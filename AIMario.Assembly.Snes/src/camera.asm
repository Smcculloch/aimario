; =============================================================================
; Camera — scroll tracking, follows Mario
; Camera X = 16-bit pixel position (camera_x_lo + camera_x_hi)
; Mario X = 16-bit pixel position (mario_x_lo + mario_x_hi)
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp mario_x_lo, mario_x_hi
.importzp camera_x_lo, camera_x_hi

.export Camera_Update

.segment "CODE"

; =============================================================================
; Camera_Update — camera_x = clamp(mario_x - 120, 0, 3328)
; =============================================================================
.proc Camera_Update
    SetA16
    lda mario_x_lo              ; 16-bit mario X (lo + hi)
    sec
    sbc #120                    ; center Mario ~120px from left edge
    bcs @not_neg
    lda #$0000                  ; clamp to 0 (Mario near left edge)
@not_neg:
    cmp #(LEVEL_WIDTH_PX - SCREEN_WIDTH)
    bcc @not_max
    lda #(LEVEL_WIDTH_PX - SCREEN_WIDTH) ; clamp to max scroll (3328)
@not_max:
    sta camera_x_lo             ; 16-bit store (lo + hi)
    SetA8
    rts
.endproc
