; =============================================================================
; Physics — Move and Collide (2-pass: X then Y)
;
; Position: 24-bit (sub + lo + hi) — sub=fraction, lo+hi=16-bit pixel
; Velocity: 16-bit signed 8.8 (hi=pixel delta, lo=sub-pixel delta)
;
; IMPORTANT: CheckTileCollision corrupts temp1 and temp3 (they are adjacent
; to temp0 and temp2, so "temp0+1" and "temp2+1" are NOT preserved).
; All pushback calculations use 16-bit math from mario position directly.
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp mario_x_sub, mario_x_lo, mario_x_hi
.importzp mario_y_sub, mario_y_lo, mario_y_hi
.importzp mario_vx_lo, mario_vx_hi
.importzp mario_vy_lo, mario_vy_hi
.importzp mario_on_ground, mario_jump_held, mario_state
.importzp temp0, temp1, temp2, temp3, temp4, temp5, temp6

.import CheckTileCollision
.import HitBlock

.export MoveAndCollide

.segment "CODE"

.proc MoveAndCollide
    ; Determine mario height based on state
    lda mario_state
    beq @small_h
    lda #MARIO_HEIGHT_BG
    bra @store_h
@small_h:
    lda #MARIO_HEIGHT_SM
@store_h:
    sta temp6                   ; temp6 = current mario height

    ; === Pass 1: Move X ===
    clc
    lda mario_x_sub
    adc mario_vx_lo
    sta mario_x_sub

    lda mario_x_lo
    adc mario_vx_hi
    sta mario_x_lo

    ; Sign-extend into hi byte
    lda mario_vx_hi
    bmi @vx_neg
    lda mario_x_hi
    adc #$00
    sta mario_x_hi
    bra @x_clamp
@vx_neg:
    lda mario_x_hi
    adc #$FF
    sta mario_x_hi

@x_clamp:
    ; Clamp X left boundary
    lda mario_x_hi
    bpl @x_not_neg
    stz mario_x_hi
    stz mario_x_lo
    stz mario_x_sub
    stz mario_vx_lo
    stz mario_vx_hi
    jmp @x_done

@x_not_neg:
    ; Check X tile collision based on velocity direction
    lda mario_vx_hi
    bmi @check_left_col
    ora mario_vx_lo
    bne @check_right_col
    jmp @x_done

@check_right_col:
    ; Moving right: check right edge at head height
    SetA16
    lda mario_x_lo
    clc
    adc #MARIO_WIDTH
    sta temp0
    lda mario_y_lo
    clc
    adc #2                      ; slightly below top
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcs @pushback_right

    ; Check right edge at foot height
    SetA16
    lda mario_x_lo
    clc
    adc #MARIO_WIDTH
    sta temp0
    lda temp6
    and #$00FF
    sec
    sbc #2                      ; height - 2
    clc
    adc mario_y_lo
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcc @x_done

@pushback_right:
    ; Recompute in 16-bit to avoid corrupted temp0+1
    SetA16
    lda mario_x_lo              ; 16-bit mario_x
    clc
    adc #MARIO_WIDTH            ; right edge
    and #$FFF0                  ; align to tile boundary
    sec
    sbc #MARIO_WIDTH            ; new mario_x
    sta mario_x_lo              ; 16-bit store (lo + hi)
    SetA8
    stz mario_x_sub
    stz mario_vx_lo
    stz mario_vx_hi
    jmp @x_done

@check_left_col:
    ; Moving left: check left edge at head height
    SetA16
    lda mario_x_lo
    sta temp0
    lda mario_y_lo
    clc
    adc #2
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcs @pushback_left

    ; Check left edge at foot height
    SetA16
    lda mario_x_lo
    sta temp0
    lda temp6
    and #$00FF
    sec
    sbc #2
    clc
    adc mario_y_lo
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcc @x_done

@pushback_left:
    ; Recompute in 16-bit
    SetA16
    lda mario_x_lo              ; 16-bit mario_x (left edge)
    and #$FFF0                  ; align to tile boundary
    clc
    adc #$0010                  ; push to right side of tile
    sta mario_x_lo              ; 16-bit store
    SetA8
    stz mario_x_sub
    stz mario_vx_lo
    stz mario_vx_hi

@x_done:

    ; === Pass 2: Move Y ===
    clc
    lda mario_y_sub
    adc mario_vy_lo
    sta mario_y_sub

    lda mario_y_lo
    adc mario_vy_hi
    sta mario_y_lo

    lda mario_vy_hi
    bmi @vy_neg
    lda mario_y_hi
    adc #$00
    sta mario_y_hi
    bra @y_check
@vy_neg:
    lda mario_y_hi
    adc #$FF
    sta mario_y_hi

@y_check:
    lda mario_vy_hi
    bmi @check_up_col
    ora mario_vy_lo
    bne @check_down
    jmp @y_done

@check_down:
    stz mario_on_ground

    ; Left foot
    SetA16
    lda mario_x_lo
    clc
    adc #2
    sta temp0
    lda temp6
    and #$00FF
    clc
    adc mario_y_lo
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcs @land

    ; Right foot
    SetA16
    lda mario_x_lo
    clc
    adc #(MARIO_WIDTH - 2)
    sta temp0
    lda temp6
    and #$00FF
    clc
    adc mario_y_lo
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcs @land
    jmp @y_done

@land:
    ; Recompute landing position in 16-bit (temp2+1 is corrupted)
    ; new_y = ((mario_y + height) & $FFF0) - height
    SetA16
    lda temp6
    and #$00FF
    sta temp4                   ; temp4 = 16-bit height (temp4 is 2 bytes)
    clc
    adc mario_y_lo              ; foot position
    and #$FFF0                  ; align to tile top
    sec
    sbc temp4                   ; subtract height
    sta mario_y_lo              ; 16-bit store (lo + hi)
    SetA8
    stz mario_y_sub
    stz mario_vy_lo
    stz mario_vy_hi
    lda #$01
    sta mario_on_ground
    bra @y_done

@check_up_col:
    ; Moving up: check head (left side)
    SetA16
    lda mario_x_lo
    clc
    adc #2
    sta temp0
    lda mario_y_lo
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcs @hit_ceiling

    ; Head (right side)
    SetA16
    lda mario_x_lo
    clc
    adc #(MARIO_WIDTH - 2)
    sta temp0
    lda mario_y_lo
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcc @y_done

@hit_ceiling:
    ; Compute the hit tile coordinates for block interaction
    ; Hit center X = mario_x + MARIO_WIDTH/2
    SetA16
    lda mario_x_lo
    clc
    adc #(MARIO_WIDTH / 2)
    lsr
    lsr
    lsr
    lsr                         ; /16 = metatile column
    SetA8
    sta temp1                   ; metatile column

    ; Hit Y = mario_y (head position)
    SetA16
    lda mario_y_lo
    lsr
    lsr
    lsr
    lsr                         ; /16 = metatile row
    SetA8
    sta temp3                   ; metatile row

    ; Recompute ceiling pushback in 16-bit
    SetA16
    lda mario_y_lo              ; 16-bit mario_y (head position)
    and #$FFF0                  ; align to tile top
    clc
    adc #$0010                  ; push below tile bottom
    sta mario_y_lo              ; 16-bit store (lo + hi)
    SetA8
    stz mario_y_sub
    stz mario_vy_lo
    stz mario_vy_hi
    stz mario_jump_held

    ; Process block hit (temp1=col, temp3=row)
    jsr HitBlock

@y_done:
    ; Fall death check
    lda mario_y_hi
    beq @check_y_lo
    cmp #$FF
    beq @y_wrapped_neg
    bra @fall_death             ; hi is some other value (fell off)

@y_wrapped_neg:
    ; Y wrapped negative (jumped above screen top), clamp to 0
    stz mario_y_hi
    stz mario_y_lo
    stz mario_y_sub
    bra @no_fall_death

@check_y_lo:
    lda mario_y_lo
    cmp #240
    bcc @no_fall_death

@fall_death:
    stz mario_x_sub
    lda #MARIO_START_X
    sta mario_x_lo
    stz mario_x_hi
    stz mario_y_sub
    lda #MARIO_START_Y
    sta mario_y_lo
    stz mario_y_hi
    stz mario_vx_lo
    stz mario_vx_hi
    stz mario_vy_lo
    stz mario_vy_hi
    lda #$01
    sta mario_on_ground

@no_fall_death:
    rts
.endproc
