; =============================================================================
; Sprite CHR Data — 4bpp tiles for OBJ layer
;
; 16x16 sprite layout: base N → N(TL), N+1(TR), N+16(BL), N+17(BR)
;   Standing: base $00    Walk1: base $02    Walk2: base $04
;   Walk3:    base $06    Jump:  base $08
;
; Sprite palette 0 colors:
;   0=transparent  1=red(helmet/suit)  2=cyan(visor/accents)
;   3=dark_red(hair/belt/boots)  4=skin(face)  5=white(highlights)
;
; Color → bitplanes (bp3,bp2,bp1,bp0):
;   0: 0000    1(red): 0001    2(cyan): 0010    3(dark): 0011
;   4(skin): 0100    5(white): 0101
;
; Improved cyberpunk Mario (16x16, character in cols 1-9):
;   Row 0:  . . . 1 1 1 1 1 | 1 1 . . . . . .   helmet
;   Row 1:  . . 1 1 2 2 2 1 | 1 1 . . . . . .   helmet + cyan visor band
;   Row 2:  . . 3 3 4 4 4 3 | 3 . . . . . . .   hair/face
;   Row 3:  . 4 4 2 4 4 2 4 | 4 4 . . . . . .   face + cyan eyes
;   Row 4:  . . 4 4 4 4 4 4 | 4 . . . . . . .   chin
;   Row 5:  . . 1 2 1 1 2 1 | 1 . . . . . . .   suit + cyan panel lines
;   Row 6:  . . 1 1 1 1 1 1 | 1 . . . . . . .   suit body
;   Row 7:  . . 1 1 1 1 1 1 | 1 . . . . . . .   suit body
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.export Upload_Sprite_Tiles

.segment "RODATA"

spr_chr_data:

; =============================================================================
; Shared top-half macros — identical across stand/walk poses
; =============================================================================

.macro MARIO_TL
    ; bp0/bp1 interleaved (rows 0-7)
    .byte $1F, $00              ; row 0: ...11111 (helmet)
    .byte $31, $0E              ; row 1: ..11___1 visor band (2=cyan at cols 4-6)
    .byte $31, $31              ; row 2: ..33.443 (hair/face, 3=dark_red + 4=skin)
    .byte $00, $12              ; row 3: .44_44_4 (face + 2=cyan visor eyes)
    .byte $00, $00              ; row 4: ..444444 (chin, all skin)
    .byte $2D, $12              ; row 5: ..1_11_1 (suit + 2=cyan accents)
    .byte $3F, $00              ; row 6: ..111111 (suit body)
    .byte $3F, $00              ; row 7: ..111111 (suit body)
    ; bp2/bp3 interleaved (rows 0-7)
    .byte $00, $00              ; row 0: no skin
    .byte $00, $00              ; row 1: no skin
    .byte $0E, $00              ; row 2: skin at cols 4-6
    .byte $6D, $00              ; row 3: skin at cols 1,2,4,5,7
    .byte $3F, $00              ; row 4: skin at cols 2-7
    .byte $00, $00              ; row 5: no skin
    .byte $00, $00              ; row 6: no skin
    .byte $00, $00              ; row 7: no skin
.endmacro

.macro MARIO_TR
    ; bp0/bp1 interleaved (rows 0-7)
    .byte $C0, $00              ; row 0: 11...... (helmet continues)
    .byte $C0, $00              ; row 1: 11...... (helmet continues)
    .byte $80, $80              ; row 2: 3....... (dark_red hair edge)
    .byte $00, $00              ; row 3: 44...... (face skin, bp0/bp1=0)
    .byte $00, $00              ; row 4: 4....... (chin continues)
    .byte $80, $00              ; row 5: 1....... (suit continues)
    .byte $80, $00              ; row 6: 1....... (suit continues)
    .byte $80, $00              ; row 7: 1....... (suit continues)
    ; bp2/bp3 interleaved (rows 0-7)
    .byte $00, $00              ; row 0
    .byte $00, $00              ; row 1
    .byte $00, $00              ; row 2: col 8 is dark_red(3), not skin
    .byte $C0, $00              ; row 3: skin at cols 8-9
    .byte $80, $00              ; row 4: skin at col 8
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
; Tile $10: Standing BL (legs apart, neutral stance)
;   Row 0: . . 3 1 1 1 1 3   belt (dark_red buckle edges)
;   Row 1: . . 1 1 1 1 1 1   upper legs (suit)
;   Row 2: . . . 1 1 . 1 1   legs apart
;   Row 3: . . . 1 1 . 1 1   legs
;   Row 4: . . 3 3 3 . 3 3   boots (dark_red)
;   Row 5: . . 3 3 3 . 3 3   boots
;   Row 6-7: empty
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; row 0: belt ..311113
    .byte $3F, $00              ; row 1: upper legs ..111111
    .byte $1B, $00              ; row 2: legs apart ...11.11
    .byte $1B, $00              ; row 3: legs
    .byte $37, $37              ; row 4: boots ..333.33
    .byte $37, $37              ; row 5: boots
    .byte $00, $00              ; row 6: empty
    .byte $00, $00              ; row 7: empty
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; =============================================================================
; Tile $11: Standing BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $12: Walk1 BL (right leg forward, left leg back)
;   Row 0: . . 3 1 1 1 1 3   belt
;   Row 1: . . 1 1 . 1 1 1   legs in stride
;   Row 2: . . . . . 1 1 1   right leg forward
;   Row 3: . . . . . 1 1 .   right leg lower
;   Row 4: . . . . 3 3 3 .   right boot
;   Row 5: . . . . 3 3 . .   right boot toe
;   Row 6-7: empty
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $37, $00              ; legs ..11.111
    .byte $07, $00              ; right leg .....111
    .byte $06, $00              ; right leg .....11.
    .byte $0E, $0E              ; boot ....333.
    .byte $0C, $0C              ; boot toe ....33..
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; =============================================================================
; Tile $13: Walk1 BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $14: Walk2 BL (legs passing, together in center)
;   Row 0: . . 3 1 1 1 1 3   belt
;   Row 1: . . . 1 1 1 1 .   legs together
;   Row 2: . . . 1 1 1 1 .   legs
;   Row 3: . . . 1 1 1 . .   legs narrowing
;   Row 4: . . . 3 3 3 . .   boots
;   Row 5: . . 3 3 3 3 . .   boots base
;   Row 6-7: empty
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $1E, $00              ; legs ...1111.
    .byte $1E, $00              ; legs
    .byte $1C, $00              ; legs ...111..
    .byte $1C, $1C              ; boots ...333..
    .byte $3C, $3C              ; boots base ..3333..
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; =============================================================================
; Tile $15: Walk2 BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $16: Walk3 BL (left leg forward, right leg back)
;   Row 0: . . 3 1 1 1 1 3   belt
;   Row 1: . 1 1 1 . 1 1 .   legs in stride
;   Row 2: . 1 1 1 . . . .   left leg forward
;   Row 3: . . 1 1 . . . .   left leg lower
;   Row 4: . . 3 3 3 . . .   left boot
;   Row 5: . . . 3 3 . . .   left boot toe
;   Row 6-7: empty
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $76, $00              ; legs .111.11.
    .byte $70, $00              ; left leg .111....
    .byte $30, $00              ; left leg ..11....
    .byte $38, $38              ; boot ..333...
    .byte $18, $18              ; boot toe ...33...
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; =============================================================================
; Tile $17: Walk3 BR (empty)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $18: Jump BL (legs tucked forward, airborne)
;   Row 0: . . 3 1 1 1 1 3   belt
;   Row 1: . . 1 1 1 1 1 .   legs kicked forward
;   Row 2: . . . 1 1 1 1 .   legs tucked
;   Row 3: . . . 3 3 3 3 .   boots
;   Row 4-7: empty (airborne, compact pose)
; =============================================================================
    ; bp0/bp1
    .byte $3F, $21              ; belt
    .byte $3E, $00              ; legs ..11111.
    .byte $1E, $00              ; legs ...1111.
    .byte $1E, $1E              ; boots ...3333.
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3
    .repeat 8
        .byte $00, $00
    .endrepeat

; =============================================================================
; Tile $19: Jump BR (empty)
; =============================================================================
EMPTY_TILE

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

    lda #$01
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
