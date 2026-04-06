; =============================================================================
; Metatile Definitions — maps 16x16 metatile types to 4 x 8x8 tile IDs
; Each entry: TL, TR, BL, BR
; =============================================================================

.export metatile_map

.segment "RODATA"

metatile_map:
    ; $00 TILE_EMPTY: sky
    .byte $00, $00, $00, $00

    ; $01 TILE_GROUND: ground block
    .byte $01, $02, $03, $04

    ; $02 TILE_BRICK: brick block
    .byte $05, $06, $07, $08
