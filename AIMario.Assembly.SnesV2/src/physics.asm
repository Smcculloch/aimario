; =============================================================================
; Physics — Move and Collide (2-pass: X then Y)
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp mario_x_sub, mario_x_lo, mario_x_hi
.importzp mario_y_sub, mario_y_lo, mario_y_hi
.importzp mario_vx_lo, mario_vx_hi
.importzp mario_vy_lo, mario_vy_hi
.importzp mario_on_ground, mario_jump_held
.importzp temp0, temp1, temp2, temp3, temp4, temp5, temp6

.import CheckTileCollision
.import HitBlock

.export MoveAndCollide

.segment "CODE"

.proc MoveAndCollide
    ; Always small Mario in V2 step 1
    lda #MARIO_HEIGHT
    sta temp6                   ; temp6 = mario height

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
    adc #2
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
    sbc #2
    clc
    adc mario_y_lo
    sta temp2
    SetA8
    jsr CheckTileCollision
    bcc @x_done

@pushback_right:
    SetA16
    lda mario_x_lo
    clc
    adc #MARIO_WIDTH
    and #$FFF0
    sec
    sbc #MARIO_WIDTH
    sta mario_x_lo
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
    SetA16
    lda mario_x_lo
    and #$FFF0
    clc
    adc #$0010
    sta mario_x_lo
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
    SetA16
    lda temp6
    and #$00FF
    sta temp4
    clc
    adc mario_y_lo
    and #$FFF0
    sec
    sbc temp4
    sta mario_y_lo
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
    ; Push below tile bottom
    SetA16
    lda mario_y_lo
    and #$FFF0
    clc
    adc #$0010
    sta mario_y_lo
    SetA8
    stz mario_y_sub
    stz mario_vy_lo
    stz mario_vy_hi
    stz mario_jump_held

    ; Hit the block (temp1=col, temp3=row from CheckTileCollision)
    jsr HitBlock

@y_done:
    ; Fall death check
    lda mario_y_hi
    beq @check_y_lo
    cmp #$FF
    beq @y_wrapped_neg
    bra @fall_death

@y_wrapped_neg:
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
