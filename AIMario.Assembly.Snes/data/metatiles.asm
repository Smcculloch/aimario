; =============================================================================
; Metatile Definitions — maps 16x16 metatile types to 4 × 8x8 tile IDs
; Each entry: TL, TR, BL, BR (indices into BG CHR data)
; =============================================================================

.export metatile_map

.segment "RODATA"

; Metatile type -> 4 hardware tiles
; Index = metatile type * 4
metatile_map:
    ; $00 TILE_EMPTY: sky
    .byte $00, $00, $00, $00    ; all sky tiles

    ; $01 TILE_GROUND: ground block
    .byte $01, $02, $03, $04    ; ground pattern tiles

    ; $02 TILE_BRICK: brick block
    .byte $05, $06, $07, $08    ; brick pattern tiles

    ; $03 TILE_QBLOCK: question block
    .byte $09, $0A, $0B, $0C   ; question mark tiles

    ; $04 TILE_QBLOCK_HIT: used question block
    .byte $12, $12, $12, $12   ; dark gray block

    ; $05 TILE_PIPE_TL: pipe top-left
    .byte $0D, $0E, $0F, $10   ; pipe top

    ; $06 TILE_PIPE_TR: pipe top-right
    .byte $0E, $0D, $10, $0F   ; pipe top (mirrored conceptually)

    ; $07 TILE_PIPE_BL: pipe body-left
    .byte $0F, $10, $0F, $10   ; pipe body

    ; $08 TILE_PIPE_BR: pipe body-right
    .byte $10, $0F, $10, $0F   ; pipe body (mirrored)

    ; $09 TILE_BLOCK: solid block
    .byte $11, $11, $11, $11   ; stair/solid block tiles

    ; $0A TILE_STAIR: staircase block
    .byte $11, $11, $11, $11   ; same as solid block

    ; $0B TILE_FLAG_POLE: flagpole
    .byte $13, $00, $13, $00   ; pole + sky

    ; $0C TILE_FLAG_TOP: flagpole top
    .byte $13, $00, $13, $00   ; same for now

    ; $0D TILE_CASTLE: castle block
    .byte $11, $11, $11, $11   ; reuse solid block
