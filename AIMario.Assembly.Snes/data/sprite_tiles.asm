; =============================================================================
; Sprite CHR Data — 4bpp tiles for OBJ layer
; Each 8x8 tile = 32 bytes (4bpp: 16 bytes bp0/bp1, 16 bytes bp2/bp3)
;
; 16x16 sprite layout: base tile N uses N(TL), N+1(TR), N+16(BL), N+17(BR)
;   Standing: base $00    Walk1: base $02    Walk2: base $04
;   Walk3:    base $06    Jump:  base $08
;
; Sprite palette 0 colors:
;   0=transparent  1=red(hat/body)  2=cyan(eyes/accents)
;   3=dark_red(boots/belt)  4=skin(face)  5=white
;
; Color → bitplanes (bp3,bp2,bp1,bp0):
;   0: 0000    1(red): 0001    2(cyan): 0010    3(dark): 0011
;   4(skin): 0100    5(white): 0101
;
; Mario design (16x16, cols 1-9):
;   Row 0:  . . . 1 1 1 1 1 | 1 . . . . . . .   hat
;   Row 1:  . . 1 1 1 1 1 1 | 1 1 . . . . . .   hat brim
;   Row 2:  . . 3 3 4 4 4 3 | 3 . . . . . . .   hair/face
;   Row 3:  . 4 4 2 4 4 2 4 | 4 4 . . . . . .   face + cyan eyes
;   Row 4:  . 4 4 4 4 4 4 4 | 4 4 . . . . . .   chin
;   Row 5:  . . 1 2 1 1 2 1 | . . . . . . . .   body + accents
;   Row 6:  . . 1 1 1 1 1 1 | 1 . . . . . . .   body
;   Row 7:  . . 1 1 1 1 1 1 | 1 . . . . . . .   body
;   Row 8:  . . 3 1 1 1 1 3 | . . . . . . . .   belt
;   Row 9:  . . . 1 1 . 1 1 | . . . . . . . .   legs
;   Row10:  . . . 1 1 . 1 1 | . . . . . . . .   legs
;   Row11:  . . 3 3 . . 3 3 | . . . . . . . .   boots
;   Row12:  . 3 3 3 . . 3 3 | . . . . . . . .   boots wide
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.export Upload_Sprite_Tiles

.segment "RODATA"

spr_chr_data:

; =============================================================================
; Top-half macro — identical for all 5 poses
; =============================================================================

.macro MARIO_TL
    ; bp0/bp1 interleaved (rows 0-7)
    .byte $1F, $00              ; row 0: ...11111 (hat, red)
    .byte $3F, $00              ; row 1: ..111111 (hat brim)
    .byte $31, $31              ; row 2: ..33..43 (hair=dark, bp0+bp1=color3)
    .byte $00, $12              ; row 3: .44244.2 → bp0=0, bp1 at eye positions
    .byte $00, $00              ; row 4: .4444444 (all skin, bp0/bp1 = 0)
    .byte $2D, $12              ; row 5: ..121121 (body: 1=bp0, 2=bp1)
    .byte $3F, $00              ; row 6: ..111111 (body)
    .byte $3F, $00              ; row 7: ..111111 (body)
    ; bp2/bp3 interleaved (rows 0-7)
    .byte $00, $00              ; row 0: no skin
    .byte $00, $00              ; row 1: no skin
    .byte $0E, $00              ; row 2: skin at cols 4-6 (..00111.)
    .byte $6D, $00              ; row 3: skin at cols 1-2,4-5,7 (.11.11.1)
    .byte $7F, $00              ; row 4: skin at cols 1-7 (.1111111)
    .byte $00, $00              ; row 5: no skin
    .byte $00, $00              ; row 6: no skin
    .byte $00, $00              ; row 7: no skin
.endmacro

.macro MARIO_TR
    ; bp0/bp1 interleaved (rows 0-7)
    .byte $80, $00              ; row 0: hat continues (1.......)
    .byte $C0, $00              ; row 1: hat continues (11......)
    .byte $80, $80              ; row 2: dark_red (3) at col 8 → bp0+bp1
    .byte $00, $00              ; row 3: skin at cols 8-9 → bp0/bp1=0
    .byte $00, $00              ; row 4: skin at cols 8-9
    .byte $00, $00              ; row 5: empty
    .byte $80, $00              ; row 6: body red at col 8
    .byte $80, $00              ; row 7: body red at col 8
    ; bp2/bp3 interleaved (rows 0-7)
    .byte $00, $00              ; row 0
    .byte $00, $00              ; row 1
    .byte $00, $00              ; row 2: col 8 is dark_red(3), not skin
    .byte $C0, $00              ; row 3: skin at cols 8-9
    .byte $C0, $00              ; row 4: skin at cols 8-9
    .byte $00, $00              ; row 5
    .byte $00, $00              ; row 6
    .byte $00, $00              ; row 7
.endmacro

.macro EMPTY_TILE
    .res 32, $00
.endmacro

; =============================================================================
; Tiles $00-$01: Standing top half
; =============================================================================
MARIO_TL                        ; Tile $00
MARIO_TR                        ; Tile $01

; =============================================================================
; Tiles $02-$03: Walk1 top half (same as standing)
; =============================================================================
MARIO_TL                        ; Tile $02
MARIO_TR                        ; Tile $03

; =============================================================================
; Tiles $04-$05: Walk2 top half (same)
; =============================================================================
MARIO_TL                        ; Tile $04
MARIO_TR                        ; Tile $05

; =============================================================================
; Tiles $06-$07: Walk3 top half (same)
; =============================================================================
MARIO_TL                        ; Tile $06
MARIO_TR                        ; Tile $07

; =============================================================================
; Tiles $08-$09: Jump top half (same)
; =============================================================================
MARIO_TL                        ; Tile $08
MARIO_TR                        ; Tile $09

; =============================================================================
; Tiles $0A-$0F: Padding (6 empty tiles to reach $10)
; =============================================================================
.repeat 6
    EMPTY_TILE
.endrepeat

; =============================================================================
; Tile $10: Standing BL (legs apart)
;   Row 8: . . 3 1 1 1 1 3   belt
;   Row 9: . . . 1 1 . 1 1   legs
;   Row10: . . . 1 1 . 1 1   legs
;   Row11: . . 3 3 . . 3 3   boots
;   Row12: . 3 3 3 . . 3 3   boots wide
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; row 0: belt (..311113 → bp0=all, bp1=3 positions)
    .byte $1B, $00              ; row 1: legs (..011.11)
    .byte $1B, $00              ; row 2: legs
    .byte $33, $33              ; row 3: boots (..33..33 → bp0+bp1 = color 3)
    .byte $73, $73              ; row 4: boots (.333..33)
    .byte $00, $00              ; row 5: empty
    .byte $00, $00              ; row 6: empty
    .byte $00, $00              ; row 7: empty
    ; bp2/bp3
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00

; =============================================================================
; Tile $11: Standing BR (empty — character fits in left 8 cols)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $12: Walk1 BL (legs shifted right)
;   Row 8: . . 3 1 1 1 1 3   belt
;   Row 9: . . . . 1 1 1 .   right leg forward
;   Row10: . . . . 1 1 1 .   right leg
;   Row11: . . . 3 3 3 . .   right boot
;   Row12: . . . 3 3 3 . .   right boot
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $0E, $00              ; legs right (....111.)
    .byte $0E, $00              ; legs right
    .byte $1C, $1C              ; boot (...333..)
    .byte $1C, $1C              ; boot
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00

; =============================================================================
; Tile $13: Walk1 BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $14: Walk2 BL (legs together, centered)
;   Row 8: . . 3 1 1 1 1 3   belt
;   Row 9: . . . 1 1 1 . .   legs center
;   Row10: . . . 1 1 1 . .   legs
;   Row11: . . 3 3 3 3 . .   boots
;   Row12: . . 3 3 3 3 . .   boots
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $1C, $00              ; legs center (...111..)
    .byte $1C, $00              ; legs
    .byte $3C, $3C              ; boots (..3333..)
    .byte $3C, $3C              ; boots
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00

; =============================================================================
; Tile $15: Walk2 BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $16: Walk3 BL (legs shifted left)
;   Row 8: . . 3 1 1 1 1 3   belt
;   Row 9: . 1 1 1 . . . .   left leg forward
;   Row10: . 1 1 1 . . . .   left leg
;   Row11: . . 3 3 . . . .   left boot
;   Row12: . . 3 3 . . . .   left boot
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $70, $00              ; legs left (.111....)
    .byte $70, $00              ; legs
    .byte $30, $30              ; boot (..33....)
    .byte $30, $30              ; boot
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00

; =============================================================================
; Tile $17: Walk3 BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $18: Jump BL (legs tucked forward)
;   Row 8: . . 3 1 1 1 1 3   belt
;   Row 9: . . . 1 1 1 1 .   legs forward
;   Row10: . . . 3 3 3 3 .   boots tucked
;   (rows 11-15 empty — in the air)
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $1E, $00              ; legs (...1111.)
    .byte $1E, $1E              ; boots (...3333.)
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00

; =============================================================================
; Tile $19: Jump BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tiles $1A-$1F: Padding (6 empty tiles)
; =============================================================================
.repeat 6
    EMPTY_TILE
.endrepeat

; =============================================================================
; Tiles $20-$21: Mushroom TL/TR (16x16 sprite at base $20)
; Red cap (color 1), white spots (color 5), skin stem (color 4)
;   Row 0: . . . 1 1 1 1 1    cap
;   Row 1: . . 1 1 5 1 5 1    cap with spots
;   Row 2: . 1 1 1 1 1 1 1    wide cap
;   Row 3: . 1 5 1 1 1 5 1    cap with spots
;   Row 4: 1 1 1 1 1 1 1 1    full cap
;   Row 5: . . 4 4 4 4 4 .    stem
;   Row 6: . . . 4 4 4 . .    narrow stem
;   Row 7: . . 4 4 4 4 4 .    stem base
; =============================================================================
    ; Tile $20: Mushroom TL
    ; bp0/bp1
    .byte $1F, $00              ; row 0: ...11111 (red cap)
    .byte $3F, $04              ; row 1: ..1151.1 (white spots use bp0+bp2=color5)
    .byte $7F, $00              ; row 2: .1111111
    .byte $7F, $04              ; row 3: .1511151
    .byte $FF, $00              ; row 4: 11111111
    .byte $3E, $00              ; row 5: ..41114. → stem pixels: bp0=0,bp1=0
    .byte $1C, $00              ; row 6: ...444..
    .byte $3E, $00              ; row 7: ..44444.
    ; bp2/bp3
    .byte $00, $00              ; row 0: no skin
    .byte $24, $00              ; row 1: spots (bp2=1 at spot positions = color 5)
    .byte $00, $00              ; row 2
    .byte $24, $00              ; row 3: spots
    .byte $00, $00              ; row 4
    .byte $3E, $00              ; row 5: skin (bp2=1 = color 4)
    .byte $1C, $00              ; row 6: skin
    .byte $3E, $00              ; row 7: skin

    ; Tile $21: Mushroom TR (mostly empty, character fits in left 8)
    EMPTY_TILE

    ; Padding tiles $22-$23 (to keep alignment for 16x16 sprites)
    EMPTY_TILE
    EMPTY_TILE

; =============================================================================
; Tiles $24-$25: Coin popup TL/TR
; Simple spinning coin design using cyan (color 2)
;   Row 0: . . . 2 2 . . .
;   Row 1: . . 2 2 2 2 . .
;   Row 2: . . 2 . . 2 . .
;   Row 3: . . 2 2 2 2 . .
;   Row 4: . . 2 . . 2 . .
;   Row 5: . . 2 2 2 2 . .
;   Row 6: . . . 2 2 . . .
;   Row 7: . . . . . . . .
; =============================================================================
    ; Tile $24: Coin TL
    ; bp0/bp1
    .byte $00, $18              ; row 0: ...22... (color 2 = bp1 only)
    .byte $00, $3C              ; row 1: ..2222..
    .byte $00, $24              ; row 2: ..2..2..
    .byte $00, $3C              ; row 3: ..2222..
    .byte $00, $24              ; row 4: ..2..2..
    .byte $00, $3C              ; row 5: ..2222..
    .byte $00, $18              ; row 6: ...22...
    .byte $00, $00              ; row 7: empty
    ; bp2/bp3
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00

    ; Tile $25: Coin TR (empty)
    EMPTY_TILE

    ; Padding tiles $26-$2F
    .repeat 10
        EMPTY_TILE
    .endrepeat

; =============================================================================
; Tiles $30-$31: Mushroom BL/BR (lower half — stem continues)
; =============================================================================
    ; Tile $30: Mushroom BL (empty — mushroom fits in top 8 rows)
    EMPTY_TILE
    ; Tile $31: Mushroom BR (empty)
    EMPTY_TILE

    ; Padding $32-$33
    EMPTY_TILE
    EMPTY_TILE

; =============================================================================
; Tiles $34-$35: Coin popup BL/BR (empty — coin fits in top 8 rows)
; =============================================================================
    EMPTY_TILE
    EMPTY_TILE

    ; Padding $36-$3F
    .repeat 10
        EMPTY_TILE
    .endrepeat

; =============================================================================
; Big Mario bottom-half sprites
; Big Mario's top half REUSES the small Mario sprites (base $00/$02/$04/$06/$08)
; Bottom halves are new 16x16 sprites at tiles $40+
;
; Layout (each 16x16 sprite uses base, base+1, base+16, base+17):
;   Standing bottom: base $40 → $40(TL), $41(TR), $50(BL), $51(BR)
;   Walk1 bottom:    base $42 → $42(TL), $43(TR), $52(BL), $53(BR)
;   Walk2 bottom:    base $44 → $44(TL), $45(TR), $54(BL), $55(BR)
;   Walk3 bottom:    base $46 → $46(TL), $47(TR), $56(BL), $57(BR)
;   Jump bottom:     base $48 → $48(TL), $49(TR), $58(BL), $59(BR)
;
; TL tiles (top row of bottom sprite = belt + upper legs, rows 0-7)
; BL tiles (bottom row = lower legs + boots, rows 8-15)
; =============================================================================

; --- Tile $40: Big Standing Bottom TL (belt + upper legs) ---
    ; bp0/bp1
    .byte $3F, $21              ; row 0: belt (..311113)
    .byte $3F, $00              ; row 1: body (..111111)
    .byte $1B, $00              ; row 2: legs apart (..011.11)
    .byte $1B, $00              ; row 3: legs
    .byte $1B, $00              ; row 4: legs
    .byte $1B, $00              ; row 5: legs
    .byte $33, $33              ; row 6: boots (..33..33)
    .byte $73, $73              ; row 7: boots (.333..33)
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; --- Tile $41: Big Standing Bottom TR (empty) ---
    EMPTY_TILE

; --- Tile $42: Big Walk1 Bottom TL (belt + right leg forward) ---
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $3F, $00              ; body
    .byte $0E, $00              ; right leg (....111.)
    .byte $0E, $00
    .byte $0E, $00
    .byte $0E, $00
    .byte $1C, $1C              ; right boot (...333..)
    .byte $1C, $1C
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; --- Tile $43: Big Walk1 Bottom TR (empty) ---
    EMPTY_TILE

; --- Tile $44: Big Walk2 Bottom TL (belt + legs center) ---
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $3F, $00              ; body
    .byte $1C, $00              ; legs center (...111..)
    .byte $1C, $00
    .byte $1C, $00
    .byte $1C, $00
    .byte $3C, $3C              ; boots (..3333..)
    .byte $3C, $3C
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; --- Tile $45: Big Walk2 Bottom TR (empty) ---
    EMPTY_TILE

; --- Tile $46: Big Walk3 Bottom TL (belt + left leg forward) ---
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $3F, $00              ; body
    .byte $70, $00              ; left leg (.111....)
    .byte $70, $00
    .byte $70, $00
    .byte $70, $00
    .byte $30, $30              ; left boot (..33....)
    .byte $30, $30
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; --- Tile $47: Big Walk3 Bottom TR (empty) ---
    EMPTY_TILE

; --- Tile $48: Big Jump Bottom TL (belt + legs tucked) ---
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $3F, $00              ; body
    .byte $1E, $00              ; legs tucked (...1111.)
    .byte $1E, $1E              ; boots (...3333.)
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; --- Tile $49: Big Jump Bottom TR (empty) ---
    EMPTY_TILE

; --- Tiles $4A-$4F: Padding to reach $50 ---
.repeat 6
    EMPTY_TILE
.endrepeat

; --- Tiles $50-$59: BL/BR tiles for bottom sprites (lower 8 rows) ---
; These are all empty because the bottom sprite data fits in TL tiles above
.repeat 10
    EMPTY_TILE
.endrepeat

; --- Tiles $5A-$5F: Padding ---
.repeat 6
    EMPTY_TILE
.endrepeat

spr_chr_data_end:
SPR_CHR_SIZE = spr_chr_data_end - spr_chr_data


; =============================================================================
; Upload_Sprite_Tiles — DMA sprite CHR to VRAM $6000
; =============================================================================
.segment "CODE"

.proc Upload_Sprite_Tiles
    lda #$80
    sta VMAIN
    lda #$00
    sta VMADDL
    lda #$60
    sta VMADDH

    lda #$01                    ; word transfer, increment
    sta DMAP0
    lda #$18
    sta BBAD0
    lda #<spr_chr_data
    sta A1T0L
    lda #>spr_chr_data
    sta A1T0H
    lda #^spr_chr_data
    sta A1B0
    lda #<SPR_CHR_SIZE
    sta DAS0L
    lda #>SPR_CHR_SIZE
    sta DAS0H
    lda #$01
    sta MDMAEN

    rts
.endproc
