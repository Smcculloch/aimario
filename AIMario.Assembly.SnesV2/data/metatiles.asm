; =============================================================================
; Metatile Definitions — maps 16x16 metatile types to 4 x 8x8 tile IDs
; Each entry: TL, TR, BL, BR
; =============================================================================

.export metatile_map, metatile_palette

.segment "RODATA"

metatile_map:
    ; $00 TILE_EMPTY: sky
    .byte $00, $00, $00, $00

    ; $01 TILE_GROUND: ground block
    .byte $01, $02, $03, $04

    ; $02 TILE_BRICK: brick block
    .byte $05, $06, $07, $08

    ; $03 TILE_COIN_BLOCK: question/coin block
    .byte $09, $0A, $0B, $0C

    ; $04 TILE_USED_BLOCK: spent block (dark)
    .byte $0D, $0E, $0F, $10

; =============================================================================
; Metatile Palette Table — VMDATAH value (palette bits) per tile type
; Palette N → bits 2-4 of tilemap high byte → value = N << 2
; =============================================================================
metatile_palette:
    .byte $00                       ; $00 TILE_EMPTY:      palette 0
    .byte $00                       ; $01 TILE_GROUND:     palette 0
    .byte $00                       ; $02 TILE_BRICK:      palette 0
    .byte $04                       ; $03 TILE_COIN_BLOCK: palette 1
    .byte $00                       ; $04 TILE_USED_BLOCK: palette 0
