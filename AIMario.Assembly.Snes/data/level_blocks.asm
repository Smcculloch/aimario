; =============================================================================
; Block Contents Table — maps (col, row) to item type for question blocks
; Format: col (byte), row (byte), item_type (byte), terminated by $FF
; Based on World 1-1 layout
; =============================================================================

.include "constants.inc"

.export block_contents

.segment "RODATA2"

block_contents:
    ; Row 9 question blocks (lower row)
    .byte 16,  9, ITEM_COIN        ; col 16 row 9
    .byte 22,  9, ITEM_MUSHROOM    ; col 22 row 9 (power-up)
    .byte 77,  9, ITEM_COIN        ; col 77 row 9
    .byte 95,  9, ITEM_COIN        ; col 95 row 9
    .byte 101, 9, ITEM_COIN        ; col 101 row 9
    .byte 102, 9, ITEM_COIN        ; col 102 row 9
    .byte 118, 9, ITEM_COIN        ; col 118 row 9

    ; Row 5 question blocks (upper row)
    .byte 20,  5, ITEM_COIN        ; col 20 row 5
    .byte 25,  5, ITEM_MUSHROOM    ; col 25 row 5 (power-up)
    .byte 27,  5, ITEM_COIN        ; col 27 row 5

    .byte $FF                       ; terminator
