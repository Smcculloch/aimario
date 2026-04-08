; =============================================================================
; Tiles — Block hit detection + VRAM tile update queue
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7
.importzp ptr0, ptr0h
.importzp tile_upd_col, tile_upd_row, tile_upd_type, tile_upd_pending
.importzp camera_x_lo, camera_x_hi

.import level_ram, row_offsets, metatile_map, metatile_palette
.import AddCoin

.export HitBlock, TileUpdate_Apply

.segment "CODE"

; =============================================================================
; HitBlock — called when Mario hits a ceiling tile
; Input: temp1 = metatile column, temp3 = metatile row (from collision check)
; =============================================================================
.proc HitBlock
    ; Read tile at the hit position from RAM
    jsr ReadLevelTile           ; A = tile type, X = level_ram offset

    cmp #TILE_COIN_BLOCK
    beq @hit_coin_block
    ; Other solid tiles (brick, ground, used) — just bump
    rts

@hit_coin_block:
    ; Change tile to TILE_USED_BLOCK in RAM
    lda #TILE_USED_BLOCK
    sta f:level_ram,x

    ; Queue VRAM update
    lda temp1
    sta tile_upd_col
    lda temp3
    sta tile_upd_row
    lda #TILE_USED_BLOCK
    sta tile_upd_type
    lda #$01
    sta tile_upd_pending

    ; Add coin + score
    jsr AddCoin
    rts
.endproc

; =============================================================================
; ReadLevelTile — read tile from level_ram at (temp1, temp3)
; Output: A = tile type, X = offset into level_ram
; =============================================================================
.proc ReadLevelTile
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
    rts
.endproc

; =============================================================================
; TileUpdate_Apply — write changed metatile to BG1 VRAM (during VBlank)
; =============================================================================
.proc TileUpdate_Apply
    lda tile_upd_pending
    bne @pending
    rts
@pending:
    stz tile_upd_pending

    ; Compute the metatile's 4 hardware tiles
    lda tile_upd_type
    SetA16
    and #$00FF
    asl
    asl                         ; x 4
    sta temp6                   ; metatile_map offset (16-bit write: temp6+temp7)
    SetA8                       ; A = type*4, B = 0

    ; Look up palette (A = type*4, B = 0 from above)
    lsr
    lsr                         ; A = tile type
    tax                         ; X = $00:type (clean, B=0)
    lda f:metatile_palette,x
    sta temp1                   ; palette byte for VMDATAH

    ; Hardware column = (tile_upd_col * 2) mod 64
    lda tile_upd_col
    asl
    and #$3F
    sta temp3                   ; hw column (left tile)

    ; Hardware row = tile_upd_row * 2
    lda tile_upd_row
    asl
    sta temp5                   ; hw row (top tile)

    ; Set VRAM increment to +1 (write across a row)
    lda #$80
    sta VMAIN

    ; --- Write top-left tile ---
    jsr CalcVRAMAddr
    SetA16
    lda temp4
    sta VMADDL
    SetA8
    ldx temp6
    lda f:metatile_map,x
    sta VMDATAL
    lda temp1
    sta VMDATAH

    ; --- Write top-right tile ---
    inc temp3
    lda temp3
    and #$3F
    sta temp3
    jsr CalcVRAMAddr
    SetA16
    lda temp4
    sta VMADDL
    SetA8
    ldx temp6
    lda f:metatile_map+1,x
    sta VMDATAL
    lda temp1
    sta VMDATAH

    ; --- Write bottom-left tile ---
    dec temp3
    lda temp3
    and #$3F
    sta temp3
    inc temp5
    jsr CalcVRAMAddr
    SetA16
    lda temp4
    sta VMADDL
    SetA8
    ldx temp6
    lda f:metatile_map+2,x
    sta VMDATAL
    lda temp1
    sta VMDATAH

    ; --- Write bottom-right tile ---
    inc temp3
    lda temp3
    and #$3F
    sta temp3
    jsr CalcVRAMAddr
    SetA16
    lda temp4
    sta VMADDL
    SetA8
    ldx temp6
    lda f:metatile_map+3,x
    sta VMDATAL
    lda temp1
    sta VMDATAH

    rts
.endproc

; =============================================================================
; CalcVRAMAddr — compute VRAM address for hw tile at (temp3=col, temp5=row)
; Output: temp4 (16-bit) = VRAM word address
; =============================================================================
.proc CalcVRAMAddr
    SetA16
    lda temp3
    and #$00FF
    cmp #32
    bcs @second_nt

    ; First nametable: $4000 + row*32 + col
    pha
    lda temp5
    and #$00FF
    asl
    asl
    asl
    asl
    asl                         ; x 32
    clc
    adc #$4000
    sta temp4
    pla
    clc
    adc temp4
    sta temp4
    SetA8
    rts

@second_nt:
    .a16
    ; Second nametable: $4400 + row*32 + (col - 32)
    sec
    sbc #32
    pha
    lda temp5
    and #$00FF
    asl
    asl
    asl
    asl
    asl
    clc
    adc #$4400
    sta temp4
    pla
    clc
    adc temp4
    sta temp4
    SetA8
    rts
.endproc
