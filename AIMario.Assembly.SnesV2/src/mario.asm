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
.importzp mario_dir, mario_on_ground
.importzp mario_anim, mario_anim_frame, mario_anim_timer
.importzp temp0, temp1, temp2, temp3

.import MoveAndCollide

.export Mario_Update

.segment "CODE"

.proc Mario_Update
    jsr Mario_HandleInput
    jsr Mario_ApplyPhysics
    jsr MoveAndCollide
    jsr Mario_Animate
    rts
.endproc

; =============================================================================
; Mario_HandleInput — D-pad movement with acceleration/friction
; =============================================================================
.proc Mario_HandleInput
    SetA16

    ; --- Check Right ---
    lda joy1_raw
    and #JOY_RIGHT
    beq @check_left

    ; Accelerate right: vx += accel
    lda mario_vx_lo
    clc
    adc #WALK_ACCEL
    bmi @store_vx               ; still negative (decelerating from left), no cap
    cmp #WALK_MAX_SPEED
    bcc @store_vx
    lda #WALK_MAX_SPEED
    bra @store_vx

@check_left:
    lda joy1_raw
    and #JOY_LEFT
    beq @no_dir

    ; Accelerate left: vx -= accel
    lda mario_vx_lo
    sec
    sbc #WALK_ACCEL
    bpl @store_vx               ; still positive, no cap
    ; A is negative. Check if past -max speed.
    pha
    lda #$0000
    sec
    sbc #WALK_MAX_SPEED         ; A = -max_speed
    sta temp0
    pla
    cmp temp0                   ; unsigned compare
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
    beq @no_dir_change
    bpl @face_right
    SetA8
    lda #DIR_LEFT
    sta mario_dir
    bra @done
@face_right:
    SetA8
    lda #DIR_RIGHT
    sta mario_dir
    bra @done
@no_dir_change:
    SetA8

@done:
    rts
.endproc

; =============================================================================
; Mario_ApplyPhysics — gravity
; =============================================================================
.proc Mario_ApplyPhysics
    SetA16

    lda mario_on_ground
    and #$00FF
    bne @no_gravity

    ; Apply full gravity
    lda mario_vy_lo
    clc
    adc #GRAVITY
    sta mario_vy_lo

    ; Clamp to max fall speed
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
; Mario_Animate — update animation state and walk frame cycling
;
; On ground + moving:  MANIM_WALK, cycle frames 0→1→2→0
; On ground + stopped: MANIM_STAND, reset frame
; In air:              MANIM_JUMP
; =============================================================================
.proc Mario_Animate
    lda mario_on_ground
    beq @airborne

    ; --- On ground ---
    ; Check if moving (16-bit velocity != 0)
    SetA16
    lda mario_vx_lo
    SetA8
    beq @standing

    ; Moving — walk animation
    lda #MANIM_WALK
    sta mario_anim

    ; Count down walk timer
    dec mario_anim_timer
    bne @anim_done
    ; Timer expired — advance frame and reset timer
    lda #WALK_ANIM_SPEED
    sta mario_anim_timer
    lda mario_anim_frame
    inc a
    cmp #$03                    ; 3 frames: 0, 1, 2
    bcc @set_frame
    lda #$00                    ; wrap back to 0
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
