; =============================================================================
; OAM Buffer Management + Sprite Drawing
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp mario_x_lo, mario_x_hi
.importzp mario_y_lo, mario_y_hi
.importzp mario_dir
.importzp mario_anim, mario_anim_frame
.importzp camera_x_lo, camera_x_hi
.importzp temp0, temp1, temp2

.import oam_buf, oam_buf_hi, oam_index

.export Sprites_Begin, Sprites_DrawMario

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
; Sprites_DrawMario — draw Mario with animation
; =============================================================================
.proc Sprites_DrawMario
    ; Calculate screen X = mario_x - camera_x (16-bit)
    SetA16
    lda mario_x_lo
    sec
    sbc camera_x_lo
    sta temp0
    SetA8

    ; Check if on screen (high byte must be 0)
    lda temp0+1
    bne @offscreen
    bra @on_screen
@offscreen:
    rts
@on_screen:

    ; Get tile base for current animation
    jsr GetMarioTile            ; A = sprite tile base ($00,$02,$04,$06,$08)
    sta temp2                   ; save tile number

    ; Write OAM entry
    lda oam_index
    tax

    lda temp0                   ; screen X
    sta oam_buf,x
    lda mario_y_lo              ; screen Y
    sta oam_buf+1,x

    lda temp2                   ; tile base
    sta oam_buf+2,x

    ; Attributes: priority 3, palette 0, H-flip if facing left
    lda mario_dir
    cmp #DIR_LEFT
    beq @face_left
    lda #%00110000              ; priority 3, no flip
    bra @set_attr
@face_left:
    lda #%01110000              ; priority 3, H-flip
@set_attr:
    sta oam_buf+3,x

    jsr SetOAMHighBit           ; set 16x16 size

    lda oam_index
    clc
    adc #$04
    sta oam_index
    rts
.endproc

; =============================================================================
; GetMarioTile — returns sprite tile base for current animation state
; Output: A = tile base ($00, $02, $04, $06, or $08)
; =============================================================================
.proc GetMarioTile
    lda mario_anim
    cmp #MANIM_JUMP
    beq @jump
    cmp #MANIM_WALK
    beq @walk

    ; Standing
    lda #SPR_MARIO_STAND
    rts

@walk:
    ; Ping-pong cycle: frame 0→Walk1, 1→Walk2, 2→Walk3, 3→Walk2
    lda mario_anim_frame
    beq @walk0
    cmp #$01
    beq @walk1
    cmp #$02
    beq @walk2
    ; frame 3 = same as frame 1 (passing position)
    lda #SPR_MARIO_WALK2
    rts
@walk0:
    lda #SPR_MARIO_WALK1
    rts
@walk1:
    lda #SPR_MARIO_WALK2
    rts
@walk2:
    lda #SPR_MARIO_WALK3
    rts

@jump:
    lda #SPR_MARIO_JUMP
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
