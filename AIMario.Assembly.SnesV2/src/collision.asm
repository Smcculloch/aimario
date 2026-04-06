; =============================================================================
; Collision — Tile collision detection
;
; Input:  temp0 (16-bit) = X pixel world coordinate
;         temp2 (16-bit) = Y pixel world coordinate
; Output: carry set = solid tile, carry clear = no collision
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp temp0, temp1, temp2, temp3, temp4, temp5
.importzp ptr0, ptr0h

.import level_data, row_offsets, level_ram

.export CheckTileCollision

.segment "CODE"

.proc CheckTileCollision
    SetA16

    ; Column = temp0 / 16
    lda temp0
    lsr
    lsr
    lsr
    lsr
    SetA8
    sta temp1                   ; metatile column (8-bit, max 223)

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

    ; Calculate offset: row_offsets[row] + col
    SetA16
    lda temp3
    and #$00FF
    asl                         ; x 2 for word index
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

    lda f:level_ram,x           ; read tile from RAM copy

    ; Anything non-empty is solid
    cmp #TILE_EMPTY
    beq @empty

@solid:
    sec
    rts

@empty:
    clc
    rts
.endproc
