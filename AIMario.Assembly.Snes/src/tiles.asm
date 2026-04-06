; =============================================================================
; Tiles — Block hit detection + VRAM tile update queue
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp mario_x_lo, mario_x_hi, mario_y_lo, mario_y_hi
.importzp mario_state
.importzp temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7
.importzp ptr0, ptr0h
.importzp tile_upd_col, tile_upd_row, tile_upd_type, tile_upd_pending
.importzp camera_x_lo, camera_x_hi
.importzp score, hud_dirty

.import level_ram, row_offsets, metatile_map
.import block_contents
.import SpawnItem
.import AddCoin, AddScore

.export HitBlock, TileUpdate_Apply

.segment "CODE"

; =============================================================================
; HitBlock — called when Mario hits a ceiling tile
; Input: temp1 = metatile column, temp3 = metatile row (set by collision check)
; =============================================================================
.proc HitBlock
    ; Read tile at the hit position from RAM
    jsr ReadLevelTile           ; A = tile type, X = level_ram offset

    cmp #TILE_QBLOCK
    beq @hit_qblock
    cmp #TILE_BRICK
    beq @hit_brick
    ; Other solid tiles — just bump, no special action
    rts

@hit_qblock:
    ; Change tile to TILE_QBLOCK_HIT in RAM
    lda #TILE_QBLOCK_HIT
    sta f:level_ram,x

    ; Queue VRAM update
    lda temp1
    sta tile_upd_col
    lda temp3
    sta tile_upd_row
    lda #TILE_QBLOCK_HIT
    sta tile_upd_type
    lda #$01
    sta tile_upd_pending

    ; Look up block contents
    jsr LookupBlockContents     ; A = item type, carry set if found
    bcc @qblock_default_coin

    ; Spawn the item
    cmp #ITEM_COIN
    bne @spawn_mushroom

    ; Coin: add coin + score immediately, spawn popup visual
    jsr AddCoin
    lda #ITEM_COIN
    jsr SpawnItem
    rts

@spawn_mushroom:
    ; Mushroom
    lda #ITEM_MUSHROOM
    jsr SpawnItem
    rts

@qblock_default_coin:
    ; Default: treat as coin if not found in table
    jsr AddCoin
    lda #ITEM_COIN
    jsr SpawnItem
    rts

@hit_brick:
    ; Check Mario state
    lda mario_state
    beq @brick_small            ; small Mario just bumps

    ; Big Mario: break brick (remove tile)
    jsr ReadLevelTile           ; re-read to get X offset
    lda #TILE_EMPTY
    sta f:level_ram,x

    ; Queue VRAM update
    lda temp1
    sta tile_upd_col
    lda temp3
    sta tile_upd_row
    lda #TILE_EMPTY
    sta tile_upd_type
    lda #$01
    sta tile_upd_pending

    ; Add 50 points (BCD: $50 in ones/tens position)
    ; 50 points = $50 in score+0 (BCD)
    sed
    lda score
    clc
    adc #$50
    sta score
    lda score+1
    adc #$00
    sta score+1
    lda score+2
    adc #$00
    sta score+2
    cld
    lda #$01
    sta tile_upd_pending        ; (already set, but ensure hud_dirty)
    .importzp hud_dirty
    sta hud_dirty

@brick_small:
    ; Small Mario: just bump (no break) — the ceiling pushback in physics handles this
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
; LookupBlockContents — search block_contents table for (temp1, temp3)
; Output: A = item type, carry set if found; carry clear if not found
; =============================================================================
.proc LookupBlockContents
    SetAXY_8_16
    ldx #$0000
@loop:
    lda f:block_contents,x
    cmp #$FF
    beq @not_found

    ; Compare column
    cmp temp1
    bne @next
    ; Compare row
    lda f:block_contents+1,x
    cmp temp3
    bne @next

    ; Found! Load item type
    lda f:block_contents+2,x
    sec
    rts

@next:
    inx
    inx
    inx
    bra @loop

@not_found:
    clc
    rts
.endproc

; =============================================================================
; TileUpdate_Apply — write changed metatile to BG1 VRAM (during VBlank)
; Uses tile_upd_col, tile_upd_row, tile_upd_type
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
    asl                         ; × 4
    sta temp6                   ; metatile_map offset
    SetA8

    ; Compute hardware column = (tile_upd_col * 2) mod 64
    lda tile_upd_col
    asl
    and #$3F
    sta temp3                   ; hw column (left tile)

    ; Compute hardware row = tile_upd_row * 2
    lda tile_upd_row
    asl
    sta temp5                   ; hw row (top tile)

    ; --- Compute VRAM base address ---
    ; Tilemap layout: 64-wide (two 32-tile nametables side by side)
    ; Nametable 0: $4000, cols 0-31
    ; Nametable 1: $4400, cols 32-63
    ; Address = base + (row * 32) + (col within nametable)

    ; Set VRAM increment to +1 (write across a row)
    lda #$80
    sta VMAIN

    ; --- Write top-left tile ---
    jsr CalcVRAMAddr            ; temp4 = VRAM address for (temp3, temp5)
    SetA16
    lda temp4
    sta VMADDL
    SetA8
    ldx temp6
    lda f:metatile_map,x        ; top-left
    sta VMDATAL
    stz VMDATAH                 ; palette 0

    ; --- Write top-right tile (temp3 + 1) ---
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
    lda f:metatile_map+1,x      ; top-right
    sta VMDATAL
    stz VMDATAH

    ; --- Write bottom-left tile ---
    dec temp3
    lda temp3
    and #$3F
    sta temp3
    inc temp5                   ; next row
    jsr CalcVRAMAddr
    SetA16
    lda temp4
    sta VMADDL
    SetA8
    ldx temp6
    lda f:metatile_map+2,x      ; bottom-left
    sta VMDATAL
    stz VMDATAH

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
    lda f:metatile_map+3,x      ; bottom-right
    sta VMDATAL
    stz VMDATAH

@done:
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
    asl                         ; × 32
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
    .a16                        ; arrived here via bcs while A=16-bit
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
