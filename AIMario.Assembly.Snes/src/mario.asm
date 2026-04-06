; =============================================================================
; Mario — Input, Physics, Animation
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp joy1_raw, joy1_press
.importzp mario_x_sub, mario_x_lo, mario_x_hi
.importzp mario_y_sub, mario_y_lo, mario_y_hi
.importzp mario_vx_lo, mario_vx_hi
.importzp mario_vy_lo, mario_vy_hi
.importzp mario_state, mario_anim, mario_dir, mario_on_ground
.importzp mario_anim_frame, mario_anim_timer, mario_jump_held
.importzp temp0, temp1, temp2, temp3

.import MoveAndCollide

.export Mario_Update, Mario_PowerUp

.segment "CODE"

.proc Mario_Update
    jsr Mario_HandleInput
    jsr Mario_ApplyPhysics
    jsr MoveAndCollide
    jsr Mario_Animate
    rts
.endproc

; =============================================================================
; Mario_PowerUp — set Mario to big state
; Adjust Y so feet stay in place (subtract 14 pixels for taller hitbox)
; =============================================================================
.proc Mario_PowerUp
    lda mario_state
    cmp #MSTATE_BIG
    bcs @already_big            ; already big or fire

    lda #MSTATE_BIG
    sta mario_state

    ; Move Y up by 14 pixels (difference between big and small height)
    lda mario_y_lo
    sec
    sbc #(MARIO_HEIGHT_BG - MARIO_HEIGHT_SM)
    sta mario_y_lo
    lda mario_y_hi
    sbc #$00
    sta mario_y_hi

@already_big:
    rts
.endproc

; =============================================================================
; Mario_HandleInput — process joypad for movement + jump
; =============================================================================
.proc Mario_HandleInput
    SetA16

    ; Determine acceleration and max speed based on Y button (run)
    lda joy1_raw
    and #JOY_Y
    bne @use_run
    ; Walk mode
    lda #WALK_ACCEL
    sta temp0                   ; accel
    lda #WALK_MAX_SPEED
    sta temp2                   ; max speed
    bra @check_dir
@use_run:
    lda #RUN_ACCEL
    sta temp0
    lda #RUN_MAX_SPEED
    sta temp2

@check_dir:
    ; --- Check Right ---
    lda joy1_raw
    and #JOY_RIGHT
    beq @check_left

    ; Accelerate right: vx += accel
    lda mario_vx_lo
    clc
    adc temp0
    bmi @store_vx               ; still negative (decelerating from left), no cap
    cmp temp2                   ; compare to max speed
    bcc @store_vx               ; under max, store
    lda temp2                   ; cap at max
    bra @store_vx

@check_left:
    lda joy1_raw
    and #JOY_LEFT
    beq @no_dir

    ; Accelerate left: vx -= accel
    lda mario_vx_lo
    sec
    sbc temp0
    bpl @store_vx               ; still positive (decelerating from right), no cap
    ; A is negative. Check if past -max speed.
    pha                         ; save result
    lda #$0000
    sec
    sbc temp2                   ; A = -max_speed (e.g. $FE00 for max=$0200)
    sta temp0                   ; reuse temp0 for -max
    pla                         ; restore result
    cmp temp0                   ; unsigned: result >= -max means in range
    bcs @store_vx
    lda temp0                   ; cap at -max
    bra @store_vx

@no_dir:
    ; No direction — apply friction toward 0
    lda mario_vx_lo
    beq @store_vx               ; already zero

    bpl @fric_pos
    ; Negative velocity: add friction
    clc
    adc #FRICTION
    bpl @zero_vx                ; crossed zero
    bra @store_vx

@fric_pos:
    ; Positive velocity: subtract friction
    sec
    sbc #FRICTION
    bmi @zero_vx                ; crossed zero
    bra @store_vx

@zero_vx:
    lda #$0000

@store_vx:
    sta mario_vx_lo

    ; --- Update facing direction ---
    beq @no_dir_change          ; Z flag still set from sta
    bpl @face_right
    SetA8
    lda #DIR_LEFT
    sta mario_dir
    bra @do_jump
@face_right:
    SetA8
    lda #DIR_RIGHT
    sta mario_dir
    bra @do_jump
@no_dir_change:
    SetA8

    ; --- Jump ---
@do_jump:
    SetA16
    lda joy1_press
    and #JOY_B
    beq @check_jump_hold
    SetA8
    lda mario_on_ground
    beq @jump_done_8

    ; Start jump — velocity depends on horizontal speed
    SetA16
    lda mario_vx_lo
    bpl @chk_abs
    eor #$FFFF
    inc a
@chk_abs:
    cmp #WALK_MAX_SPEED
    bcc @walk_jump
    lda #JUMP_VEL_RUN
    bra @set_jump
@walk_jump:
    lda #JUMP_VEL_WALK
@set_jump:
    sta mario_vy_lo
    SetA8
    stz mario_on_ground
    lda #$01
    sta mario_jump_held
    bra @jump_done_8

@check_jump_hold:
    SetA16
    lda joy1_raw
    and #JOY_B
    bne @jump_done
    SetA8
    stz mario_jump_held
    bra @jump_done_8

@jump_done:
    SetA8
@jump_done_8:
    rts
.endproc

; =============================================================================
; Mario_ApplyPhysics — gravity and velocity limits
; =============================================================================
.proc Mario_ApplyPhysics
    SetA16

    lda mario_on_ground
    and #$00FF
    bne @no_gravity

    lda mario_jump_held
    and #$00FF
    beq @full_gravity

    ; Reduced gravity while holding jump and moving up
    lda mario_vy_lo
    bpl @full_gravity
    clc
    adc #JUMP_HOLD_GRAV
    sta mario_vy_lo
    bra @clamp_vy

@full_gravity:
    lda mario_vy_lo
    clc
    adc #GRAVITY
    sta mario_vy_lo

@clamp_vy:
    lda mario_vy_lo
    bmi @no_gravity             ; negative = moving up, don't clamp
    cmp #MAX_FALL_SPEED
    bcc @no_gravity
    lda #MAX_FALL_SPEED
    sta mario_vy_lo

@no_gravity:
    SetA8
    rts
.endproc

; =============================================================================
; Mario_Animate — update animation state and frame
; =============================================================================
.proc Mario_Animate
    lda mario_on_ground
    beq @airborne

    ; On ground
    SetA16
    lda mario_vx_lo
    SetA8
    beq @standing

    lda #MANIM_WALK
    sta mario_anim

    dec mario_anim_timer
    bne @anim_done
    lda #WALK_ANIM_SPEED
    sta mario_anim_timer
    lda mario_anim_frame
    inc a
    cmp #$03
    bcc @set_frame
    lda #$00
@set_frame:
    sta mario_anim_frame
    bra @anim_done

@standing:
    lda #MANIM_STAND
    sta mario_anim
    stz mario_anim_frame
    lda #WALK_ANIM_SPEED
    sta mario_anim_timer
    bra @anim_done

@airborne:
    lda #MANIM_JUMP
    sta mario_anim

@anim_done:
    rts
.endproc
