; =============================================================================
; Items — Spawn, Update, Draw (coins popup + mushrooms)
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp mario_x_lo, mario_x_hi, mario_y_lo, mario_y_hi
.importzp mario_state
.importzp temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7
.importzp camera_x_lo, camera_x_hi
.importzp tile_upd_col, tile_upd_row

.import item_active, item_type, item_x_lo, item_x_hi
.import item_y_lo, item_y_hi, item_vx_lo, item_vx_hi
.import item_vy_lo, item_vy_hi, item_timer, item_dir
.import oam_buf, oam_buf_hi, oam_index
.import level_ram, row_offsets
.import AddScore
.import Mario_PowerUp

.export SpawnItem, Items_Update, Sprites_DrawItems

; Sprite tile indices for items (in VRAM sprite CHR)
SPR_MUSHROOM    = $20           ; 16x16 mushroom at tile $20
SPR_COIN_POP    = $24           ; 16x16 coin popup at tile $24

.segment "CODE"

; =============================================================================
; SpawnItem — spawn an item at the block that was hit
; Input: A = item type (ITEM_COIN or ITEM_MUSHROOM)
;        tile_upd_col = block column, tile_upd_row = block row
; =============================================================================
.proc SpawnItem
    sta temp0                   ; save item type

    ; Find free item slot
    ldx #$00
@find_slot:
    lda item_active,x
    beq @found
    inx
    cpx #MAX_ITEMS
    bne @find_slot
    rts                         ; no free slot

@found:
    ; Activate slot
    lda #$01
    sta item_active,x

    lda temp0
    sta item_type,x

    ; Position = block position (col * 16, row * 16)
    ; X position: col * 16 (16-bit result needed for cols > 15)
    SetA16
    lda tile_upd_col
    and #$00FF
    asl
    asl
    asl
    asl                         ; 16-bit col * 16
    sta temp4                   ; temp4 = 16-bit X pixel
    SetA8
    lda temp4
    sta item_x_lo,x
    lda temp4+1
    sta item_x_hi,x

    ; Y position = row * 16 (fits in 8 bits for rows 0-13)
    lda tile_upd_row
    asl
    asl
    asl
    asl
    sta item_y_lo,x
    stz item_y_hi,x

    ; Set velocity and timer based on type
    lda item_type,x
    cmp #ITEM_COIN
    beq @coin_setup

    ; Mushroom: move right at 1px/frame, no initial Y velocity
    ; Start slightly above block (will rise up)
    lda item_y_lo,x
    sec
    sbc #16                     ; spawn above block
    sta item_y_lo,x
    lda #$00
    sta item_vx_hi,x
    lda #$01                    ; 1 px/frame right
    sta item_vx_lo,x            ; actually vx_lo is sub-pixel...
    ; Use the hi byte for integer pixels:
    ; We store 8.8 velocity split: vx_lo = sub, vx_hi = integer
    ; Wait — looking at item arrays, vx_lo and vx_hi are separate bytes per slot
    ; Let's use: vx_hi = integer pixel delta, vx_lo = sub-pixel
    lda #$01
    sta item_vx_hi,x            ; 1 px/frame
    stz item_vx_lo,x            ; no sub-pixel
    stz item_vy_lo,x
    stz item_vy_hi,x
    lda #DIR_RIGHT
    sta item_dir,x
    stz item_timer,x
    rts

@coin_setup:
    ; Coin: move up quickly, despawn after timer
    lda item_y_lo,x
    sec
    sbc #16                     ; start at block position
    sta item_y_lo,x
    stz item_vx_lo,x
    stz item_vx_hi,x
    lda #$FC                    ; -4 px/frame (upward)
    sta item_vy_hi,x
    stz item_vy_lo,x
    lda #COIN_POPUP_TIME
    sta item_timer,x
    stz item_dir,x
    rts
.endproc

; =============================================================================
; Items_Update — update all active items (called each frame in main loop)
; =============================================================================
.proc Items_Update
    ldx #$00
@loop:
    lda item_active,x
    bne @active
    jmp @next
@active:
    lda item_type,x
    cmp #ITEM_COIN
    beq @update_coin
    cmp #ITEM_MUSHROOM
    bne @jmp_next
    jmp @update_mushroom
@jmp_next:
    jmp @next

@update_coin:
    ; Coin popup: move up, decrement timer
    lda item_y_lo,x
    clc
    adc item_vy_hi,x            ; add integer velocity
    sta item_y_lo,x

    dec item_timer,x
    bne @jmp_next
    ; Despawn
    stz item_active,x
    jmp @next

@update_mushroom:
    ; Apply gravity to mushroom
    ; vy += MUSHROOM_GRAVITY (0.375 = $0060 in 8.8)
    ; We need 16-bit velocity: vy_hi:vy_lo
    clc
    lda item_vy_lo,x
    adc #<MUSHROOM_GRAVITY
    sta item_vy_lo,x
    lda item_vy_hi,x
    adc #>MUSHROOM_GRAVITY
    sta item_vy_hi,x

    ; Clamp downward velocity
    lda item_vy_hi,x
    bmi @no_clamp               ; negative = moving up
    cmp #$04                    ; max 4 px/frame
    bcc @no_clamp
    lda #$04
    sta item_vy_hi,x
    stz item_vy_lo,x
@no_clamp:

    ; Move X: x += vx_hi (integer only, ignore sub for simplicity)
    lda item_vx_hi,x
    bpl @move_right
    ; Moving left
    lda item_x_lo,x
    clc
    adc item_vx_hi,x
    sta item_x_lo,x
    lda item_x_hi,x
    adc #$FF                    ; sign extend
    sta item_x_hi,x
    bra @move_y
@move_right:
    lda item_x_lo,x
    clc
    adc item_vx_hi,x
    sta item_x_lo,x
    lda item_x_hi,x
    adc #$00
    sta item_x_hi,x

@move_y:
    ; Move Y: y += vy_hi (integer velocity)
    lda item_y_lo,x
    clc
    adc item_vy_hi,x
    sta item_y_lo,x
    lda item_y_hi,x
    adc #$00
    ; Sign extend for upward movement
    pha
    lda item_vy_hi,x
    bpl @vy_pos
    pla
    adc #$FF
    sta item_y_hi,x
    bra @check_ground
@vy_pos:
    pla
    sta item_y_hi,x

@check_ground:
    ; Simple ground collision: check tile below mushroom feet
    ; foot Y = item_y + 16
    stx temp7                   ; save item index

    ; Build 16-bit item X from 8-bit arrays
    lda item_x_hi,x
    sta temp0+1
    lda item_x_lo,x
    sta temp0
    SetA16
    lda temp0                   ; 16-bit X
    clc
    adc #8                      ; center X
    lsr
    lsr
    lsr
    lsr                         ; /16 = tile col
    SetA8
    sta temp1                   ; tile column

    ; Foot Y
    lda item_y_lo,x
    clc
    adc #16                     ; foot position
    lsr
    lsr
    lsr
    lsr                         ; /16 = tile row
    sta temp3

    ; Bounds check
    cmp #LEVEL_HEIGHT_TILES
    bcc @bounds_ok
    jmp @mushroom_offscreen
@bounds_ok:

    ; Read tile
    SetA16
    lda temp3
    and #$00FF
    asl
    tax
    lda f:row_offsets,x
    clc
    pha
    lda temp1
    and #$00FF
    sta temp4
    pla
    adc temp4
    tax
    SetA8
    lda f:level_ram,x

    cmp #TILE_EMPTY
    beq @no_ground
    cmp #TILE_FLAG_POLE
    beq @no_ground
    cmp #TILE_FLAG_TOP
    beq @no_ground

    ; Landed: align Y to tile top
    ldx temp7
    lda item_y_lo,x
    clc
    adc #16
    and #$F0                    ; align to tile boundary
    sec
    sbc #16
    sta item_y_lo,x
    stz item_vy_lo,x
    stz item_vy_hi,x
    bra @check_wall

@no_ground:
@check_wall:
    ; Check wall collision (simple: check tile in front)
    ldx temp7
    lda item_vx_hi,x
    beq @check_mario
    bmi @check_left_wall

    ; Moving right: check tile at right edge
    lda item_x_lo,x
    clc
    adc #16
    sta temp0
    lda item_x_hi,x
    adc #0
    sta temp0+1
    bra @wall_check_tile

@check_left_wall:
    lda item_x_lo,x
    sta temp0
    lda item_x_hi,x
    sta temp0+1

@wall_check_tile:
    SetA16
    lda temp0
    lsr
    lsr
    lsr
    lsr                         ; /16 = col
    SetA8
    sta temp1

    lda item_y_lo,x
    clc
    adc #8                      ; mid height
    lsr
    lsr
    lsr
    lsr
    sta temp3

    cmp #LEVEL_HEIGHT_TILES
    bcs @check_mario

    SetA16
    lda temp3
    and #$00FF
    asl
    tax
    lda f:row_offsets,x
    clc
    pha
    lda temp1
    and #$00FF
    sta temp4
    pla
    adc temp4
    tax
    SetA8
    lda f:level_ram,x

    cmp #TILE_EMPTY
    beq @check_mario
    cmp #TILE_FLAG_POLE
    beq @check_mario
    cmp #TILE_FLAG_TOP
    beq @check_mario

    ; Hit wall: reverse direction
    ldx temp7
    lda item_vx_hi,x
    eor #$FF
    inc a
    sta item_vx_hi,x

@check_mario:
    ldx temp7
    ; AABB overlap check: Mario vs item
    ; Mario: (mario_x_lo, mario_y_lo) with MARIO_WIDTH × MARIO_HEIGHT_SM
    ; Item:  (item_x_lo, item_y_lo) with 16 × 16
    ; Simple 8-bit check (works when both are on screen)
    ; X overlap: mario_x + width > item_x AND item_x + 16 > mario_x
    lda mario_x_lo
    clc
    adc #MARIO_WIDTH
    cmp item_x_lo,x
    bcc @next_item              ; mario right < item left
    lda item_x_lo,x
    clc
    adc #16
    cmp mario_x_lo
    bcc @next_item              ; item right < mario left

    ; Y overlap: mario_y + height > item_y AND item_y + 16 > mario_y
    lda mario_y_lo
    clc
    adc #MARIO_HEIGHT_SM        ; TODO: use big height when appropriate
    cmp item_y_lo,x
    bcc @next_item
    lda item_y_lo,x
    clc
    adc #16
    cmp mario_y_lo
    bcc @next_item

    ; Collision! Collect mushroom
    stz item_active,x
    ; Score 1000
    lda #SCORE_MUSHROOM
    jsr AddScore
    ; Power up Mario
    jsr Mario_PowerUp
    bra @next_item

@mushroom_offscreen:
    ldx temp7
    ; Deactivate if fallen off screen
    lda item_y_lo,x
    cmp #240
    bcc @next_item
    stz item_active,x

@next_item:
@next:
    inx
    cpx #MAX_ITEMS
    bne @loop_jmp
    rts
@loop_jmp:
    jmp @loop
.endproc

; =============================================================================
; Sprites_DrawItems — draw active items to OAM buffer
; =============================================================================
.proc Sprites_DrawItems
    ldx #$00
@loop:
    lda item_active,x
    beq @next

    stx temp7                   ; save item index

    ; Compute screen X = item_x - camera_x (build 16-bit from 8-bit arrays)
    lda item_x_hi,x
    sta temp0+1
    lda item_x_lo,x
    sta temp0
    SetA16
    lda temp0
    sec
    sbc camera_x_lo
    sta temp0                   ; 16-bit screen X
    SetA8

    ; Off-screen check
    lda temp0+1
    bne @skip_draw              ; off screen

    ; Get OAM slot
    lda oam_index
    tay                         ; Y = OAM buffer offset

    ; X position
    lda temp0
    sta oam_buf,y

    ; Y position
    ldx temp7
    lda item_y_lo,x
    sta oam_buf+1,y

    ; Tile number
    lda item_type,x
    cmp #ITEM_COIN
    beq @coin_tile
    ; Mushroom tile
    lda #SPR_MUSHROOM
    bra @set_tile
@coin_tile:
    lda #SPR_COIN_POP
@set_tile:
    sta oam_buf+2,y

    ; Attributes: priority 2, no flip, palette 0
    lda #%00100000
    sta oam_buf+3,y

    ; Set high table: size=large (16×16)
    tya
    lsr
    lsr                         ; sprite number
    pha

    lsr
    lsr                         ; high table byte
    sta temp1

    pla
    and #$03
    asl                         ; bit position * 2
    sta temp2

    lda #$02                    ; size bit
    sep #$10
    .i8
    ldy temp2
    beq @no_shift2
@shift2:
    asl
    dey
    bne @shift2
@no_shift2:
    ldy temp1
    ora oam_buf_hi,y
    sta oam_buf_hi,y
    rep #$10
    .i16

    ; Advance OAM index
    lda oam_index
    clc
    adc #4
    sta oam_index

@skip_draw:
    ldx temp7
@next:
    inx
    cpx #MAX_ITEMS
    bne @loop
    rts
.endproc
