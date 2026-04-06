; =============================================================================
; OAM Buffer Management + Sprite Drawing
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp mario_x_lo, mario_x_hi
.importzp mario_y_lo, mario_y_hi
.importzp mario_anim, mario_anim_frame, mario_dir, mario_state
.importzp camera_x_lo, camera_x_hi
.importzp temp0, temp1, temp2

.import oam_buf, oam_buf_hi, oam_index

.export Sprites_Begin, Sprites_DrawMario, Sprites_Finish

.segment "CODE"

; =============================================================================
; Sprites_Begin — clear OAM buffer, reset index
; =============================================================================
.proc Sprites_Begin
    SetAXY_8_16
    ldx #$0000
@clear:
    stz oam_buf,x               ; byte 0: X = 0
    inx
    lda #$F0                    ; byte 1: Y = off screen
    sta oam_buf,x
    inx
    stz oam_buf,x               ; byte 2: tile = 0
    inx
    stz oam_buf,x               ; byte 3: attr = 0
    inx
    cpx #$0200
    bne @clear

    ldx #$0000
@clear_hi:
    stz oam_buf_hi,x
    inx
    cpx #$0020
    bne @clear_hi

    stz oam_index
    rts
.endproc

; =============================================================================
; Sprites_DrawMario — write Mario sprite to OAM buffer
; =============================================================================
.proc Sprites_DrawMario
    ; Calculate screen X = mario_x - camera_x (16-bit subtraction)
    SetA16
    lda mario_x_lo              ; 16-bit world X
    sec
    sbc camera_x_lo             ; 16-bit camera X
    sta temp0                   ; 16-bit screen X (could be negative or > 255)
    SetA8

    ; Check if on screen (screen X should be 0-255 and hi byte = 0)
    lda temp0+1                 ; high byte of screen X
    bne @offscreen              ; if non-zero, off screen
    bra @on_screen
@offscreen:
    rts
@on_screen:

    lda mario_state
    bne @draw_big
    jmp @draw_small

@draw_big:
    ; === Big Mario: 2 stacked 16x16 sprites ===

    ; --- Top sprite (head/body, same tiles as small Mario) ---
    lda oam_index
    tax

    lda temp0                   ; screen X
    sta oam_buf,x
    lda mario_y_lo              ; top Y
    sta oam_buf+1,x

    ; Get top tile (same as small Mario)
    jsr GetSmallTile            ; A = small Mario tile for animation
    sta oam_buf+2,x

    ; Attributes
    lda mario_dir
    cmp #DIR_LEFT
    beq @big_top_left
    lda #%00110000              ; priority 3, no flip
    bra @big_top_attr
@big_top_left:
    lda #%01110000              ; priority 3, H-flip
@big_top_attr:
    sta oam_buf+3,x
    sta temp2                   ; save attr for bottom sprite

    jsr SetOAMHighBit           ; set 16x16 size

    lda oam_index
    clc
    adc #$04
    sta oam_index

    ; --- Bottom sprite (legs/boots) ---
    lda oam_index
    tax

    lda temp0                   ; same screen X
    sta oam_buf,x
    lda mario_y_lo
    clc
    adc #16                     ; 16 pixels below top
    sta oam_buf+1,x

    ; Get bottom tile
    jsr GetBigBottomTile        ; A = bottom tile for animation
    sta oam_buf+2,x

    lda temp2                   ; same attributes
    sta oam_buf+3,x

    jsr SetOAMHighBit

    lda oam_index
    clc
    adc #$04
    sta oam_index
    rts

@draw_small:
    ; === Small Mario: single 16x16 sprite ===
    lda oam_index
    tax

    lda temp0
    sta oam_buf,x
    lda mario_y_lo
    sta oam_buf+1,x

    jsr GetSmallTile
    sta oam_buf+2,x

    lda mario_dir
    cmp #DIR_LEFT
    beq @face_left
    lda #%00110000
    bra @set_attr
@face_left:
    lda #%01110000
@set_attr:
    sta oam_buf+3,x

    jsr SetOAMHighBit

    lda oam_index
    clc
    adc #$04
    sta oam_index
    rts
.endproc

; =============================================================================
; GetSmallTile — returns small Mario tile number based on animation
; Output: A = tile number
; =============================================================================
.proc GetSmallTile
    lda mario_anim
    cmp #MANIM_JUMP
    beq @jump
    cmp #MANIM_WALK
    beq @walk
    lda #SPR_MARIO_SM_STAND
    rts
@walk:
    lda mario_anim_frame
    beq @walk0
    cmp #$01
    beq @walk1
    lda #SPR_MARIO_SM_WALK3
    rts
@walk0:
    lda #SPR_MARIO_SM_WALK1
    rts
@walk1:
    lda #SPR_MARIO_SM_WALK2
    rts
@jump:
    lda #SPR_MARIO_SM_JUMP
    rts
.endproc

; =============================================================================
; GetBigBottomTile — returns big Mario bottom-half tile based on animation
; Output: A = tile number
; =============================================================================
.proc GetBigBottomTile
    lda mario_anim
    cmp #MANIM_JUMP
    beq @jump
    cmp #MANIM_WALK
    beq @walk
    lda #SPR_MARIO_BG_STAND_BOT
    rts
@walk:
    lda mario_anim_frame
    beq @walk0
    cmp #$01
    beq @walk1
    lda #SPR_MARIO_BG_WALK3_BOT
    rts
@walk0:
    lda #SPR_MARIO_BG_WALK1_BOT
    rts
@walk1:
    lda #SPR_MARIO_BG_WALK2_BOT
    rts
@jump:
    lda #SPR_MARIO_BG_JUMP_BOT
    rts
.endproc

; =============================================================================
; SetOAMHighBit — set size=large for current OAM entry
; Input: X = OAM buffer offset of the entry just written
; =============================================================================
.proc SetOAMHighBit
    txa
    lsr
    lsr                         ; sprite number (0-127)
    pha

    lsr
    lsr                         ; high table byte index
    tay

    pla
    and #$03
    asl                         ; bit position * 2
    sta temp1

    lda #$02                    ; size=large(1), x9=0
    sep #$10
    .i8
    ldx temp1
    beq @no_shift
@shift_loop:
    asl
    dex
    bne @shift_loop
@no_shift:
    ora oam_buf_hi,y
    sta oam_buf_hi,y
    rep #$10
    .i16
    rts
.endproc

; =============================================================================
; Sprites_Finish
; =============================================================================
.proc Sprites_Finish
    rts
.endproc
