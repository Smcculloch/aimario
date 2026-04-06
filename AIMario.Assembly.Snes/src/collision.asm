; =============================================================================
; Collision — Tile collision detection
;
; Input:  temp0 (16-bit) = X pixel world coordinate
;         temp2 (16-bit) = Y pixel world coordinate
;         (temp0 = lo byte at temp0, hi byte at temp0+1, etc.)
; Output: carry set = solid tile, carry clear = no collision
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp temp0, temp1, temp2, temp3, temp4, temp5
.importzp ptr0, ptr0h

.import level_data, row_offsets, level_ram

.export CheckTileCollision, GetTileAt

.segment "CODE"

.proc CheckTileCollision
    ; Convert pixel coords to metatile coords (divide by 16)
    ; Metatile col = X_pixel / 16
    ; Metatile row = Y_pixel / 16
    SetA16

    ; Column = temp0 / 16
    lda temp0                   ; 16-bit X pixel
    lsr
    lsr
    lsr
    lsr                         ; / 16
    sta ptr0                    ; metatile column (16-bit, but fits in 8)

    ; Row = temp2 / 16
    lda temp2                   ; 16-bit Y pixel
    lsr
    lsr
    lsr
    lsr                         ; / 16
    sta ptr0h - 1               ; temp store for row... let's use temp4

    ; Actually let's be cleaner
    lda temp0
    lsr
    lsr
    lsr
    lsr
    SetA8
    sta temp1                   ; metatile column (8-bit is fine, max 223)

    SetA16
    lda temp2
    lsr
    lsr
    lsr
    lsr
    SetA8
    sta temp3                   ; metatile row (max 13)

    ; Bounds check
    lda temp3
    cmp #LEVEL_HEIGHT_TILES
    bcc @row_ok
    jmp @empty                  ; below level = empty (fall to death)
@row_ok:
    lda temp1
    cmp #LEVEL_WIDTH_TILES
    bcc @col_ok
    jmp @empty                  ; beyond level = empty
@col_ok:

    ; Calculate offset: row_offsets[row] + col (lookup table)
    SetA16
    lda temp3
    and #$00FF
    asl                         ; × 2 for word index
    tax
    lda f:row_offsets,x         ; 16-bit row offset
    clc
    pha
    lda temp1
    and #$00FF
    sta temp4                   ; 16-bit column
    pla
    adc temp4

    tax                         ; X = offset into level_data
    SetA8

    lda f:level_ram,x           ; read tile from RAM copy

    ; Check if solid
    cmp #TILE_EMPTY
    beq @empty
    cmp #TILE_FLAG_POLE
    beq @empty
    cmp #TILE_FLAG_TOP
    beq @empty

@solid:
    sec
    rts

@empty:
    clc
    rts
.endproc

; =============================================================================
; GetTileAt — read tile type at metatile coordinates
; Input:  temp1 = metatile column, temp3 = metatile row
; Output: A = tile type, X = offset into level_ram
; =============================================================================
.proc GetTileAt
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
