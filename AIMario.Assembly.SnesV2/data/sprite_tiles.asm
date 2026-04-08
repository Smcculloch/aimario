; =============================================================================
; Sprite CHR Data — 4bpp tiles for OBJ layer
;
; 16x16 sprite layout: base N → N(TL), N+1(TR), N+16(BL), N+17(BR)
;   Standing: base $00    Walk1: base $02    Walk2: base $04
;   Walk3:    base $06    Jump:  base $08
;
; Sprite palette 0 colors (and their bitplane decomposition):
;   0 trans:    bp 0000    4 skin:     bp 0100
;   1 red:      bp 0001    5 white:    bp 0101
;   2 cyan:     bp 0010    6 dk gray:  bp 0110
;   3 dark red: bp 0011    7 md gray:  bp 0111
;
; Improved cyberpunk Mario (10px wide, cols 0-9):
;
;   TOP HALF (TL tile cols 0-7, TR tile cols 8-9):
;        Col: 0 1 2 3 4 5 6 7 | 8 9
;   Row 0:    . . . 1 1 1 1 1 | 1 .    helmet narrow
;   Row 1:    . . 1 1 1 5 1 1 | 1 1    helmet + white highlight
;   Row 2:    . 3 2 2 5 2 2 2 | 2 3    visor: dark frame, shine, cyan glow
;   Row 3:    . 3 4 4 4 4 4 4 | 3 .    face bordered by dark hair
;   Row 4:    . 4 5 3 4 4 3 5 | 4 .    eyes: white + dark pupil pairs
;   Row 5:    . . 4 4 4 4 4 . | . .    chin
;   Row 6:    . 1 1 2 1 1 2 1 | 1 .    suit + 2 cyan panel accents
;   Row 7:    . 1 1 1 1 1 1 1 | 1 .    suit body
;
;   STANDING BOTTOM HALF (BL tile):
;   Row 0:    . 3 1 1 5 1 1 3 | . .    belt + white buckle
;   Row 1:    . . 1 1 . 1 1 . | . .    legs apart
;   Row 2:    . . 1 1 . 1 1 . | . .    legs
;   Row 3:    . . 1 1 . 1 1 . | . .    legs
;   Row 4:    . . 3 3 . 3 3 . | . .    boots
;   Row 5:    . 3 3 3 . 3 3 3 | . .    boots wide base
;   Rows 6-7: empty
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.export Upload_Sprite_Tiles

.segment "RODATA"

spr_chr_data:

; =============================================================================
; Top-half TL macro (cols 0-7) — shared across all poses
;
; Byte layout per tile: 16 bytes bp0/bp1 interleaved, 16 bytes bp2/bp3
; Each row: bp_low_byte (bit7=col0..bit0=col7), bp_high_byte
; =============================================================================

.macro MARIO_TL
    ; --- bp0 / bp1 (rows 0-7) ---
    .byte $1F, $00              ; R0: ...11111  helmet
    .byte $3F, $00              ; R1: ..111_11  helmet + white highlight at col5
    .byte $48, $77              ; R2: .3__5___  visor (dark frame + cyan + white shine)
    .byte $40, $40              ; R3: .3444443  face framed by dark hair
    .byte $33, $12              ; R4: .4_34_3_  eyes: white/dark pupil pattern
    .byte $00, $00              ; R5: ..44444.  chin (all skin, bp2 only)
    .byte $6D, $12              ; R6: .11_11_1  suit + cyan panel lines
    .byte $7F, $00              ; R7: .1111111  suit body
    ; --- bp2 / bp3 (rows 0-7) ---
    .byte $00, $00              ; R0: no skin/white
    .byte $04, $00              ; R1: white highlight at col5
    .byte $08, $00              ; R2: white shine at col4
    .byte $3F, $00              ; R3: skin at cols 2-7
    .byte $6D, $00              ; R4: skin at 1,2,4,5,7
    .byte $3E, $00              ; R5: skin at cols 2-6
    .byte $00, $00              ; R6: no skin
    .byte $00, $00              ; R7: no skin
.endmacro

.macro MARIO_TR
    ; --- bp0 / bp1 (rows 0-7) ---
    .byte $80, $00              ; R0: 1.......  helmet right edge
    .byte $C0, $00              ; R1: 11......  helmet continues
    .byte $40, $C0              ; R2: _3......  visor: cyan(8) + dark(9)
    .byte $80, $80              ; R3: 3.......  dark hair edge
    .byte $00, $00              ; R4: 4.......  (skin via bp2)
    .byte $00, $00              ; R5: empty
    .byte $80, $00              ; R6: 1.......  suit continues
    .byte $80, $00              ; R7: 1.......  suit continues
    ; --- bp2 / bp3 (rows 0-7) ---
    .byte $00, $00              ; R0
    .byte $00, $00              ; R1
    .byte $00, $00              ; R2
    .byte $00, $00              ; R3
    .byte $80, $00              ; R4: skin at col 8
    .byte $00, $00              ; R5
    .byte $00, $00              ; R6
    .byte $00, $00              ; R7
.endmacro

.macro EMPTY_TILE
    .res 32, $00
.endmacro

; Belt row macro (shared by all bottom-half poses)
; Row: . 3 1 1 5 1 1 3  = belt with white buckle at col4
;   bp0=$7F bp1=$41 bp2=$08 bp3=$00
.macro BELT_ROW_BP01
    .byte $7F, $41
.endmacro

; =============================================================================
; Tiles $00-$01: Standing top half
; =============================================================================
MARIO_TL                        ; Tile $00
MARIO_TR                        ; Tile $01

; =============================================================================
; Tiles $02-$03: Walk1 top half (shared)
; =============================================================================
MARIO_TL                        ; Tile $02
MARIO_TR                        ; Tile $03

; =============================================================================
; Tiles $04-$05: Walk2 top half (shared)
; =============================================================================
MARIO_TL                        ; Tile $04
MARIO_TR                        ; Tile $05

; =============================================================================
; Tiles $06-$07: Walk3 top half (shared)
; =============================================================================
MARIO_TL                        ; Tile $06
MARIO_TR                        ; Tile $07

; =============================================================================
; Tiles $08-$09: Jump top half (shared)
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
; Tile $10: Standing BL — neutral, legs shoulder-width apart
;   R0: . 3 1 1 5 1 1 3    belt + white buckle
;   R1: . . 1 1 . 1 1 .    legs apart
;   R2: . . 1 1 . 1 1 .    legs
;   R3: . . 1 1 . 1 1 .    legs
;   R4: . . 3 3 . 3 3 .    boots
;   R5: . 3 3 3 . 3 3 3    boots wide base
;   R6-7: empty
; =============================================================================
    ; bp0/bp1
    BELT_ROW_BP01               ; R0: belt
    .byte $36, $00              ; R1: ..11.11. legs
    .byte $36, $00              ; R2: legs
    .byte $36, $00              ; R3: legs
    .byte $36, $36              ; R4: ..33.33. boots (color 3)
    .byte $77, $77              ; R5: .333.333 boots wide
    .byte $00, $00              ; R6: empty
    .byte $00, $00              ; R7: empty
    ; bp2/bp3
    .byte $08, $00              ; R0: white buckle (col 4)
    .byte $00, $00              ; R1
    .byte $00, $00              ; R2
    .byte $00, $00              ; R3
    .byte $00, $00              ; R4
    .byte $00, $00              ; R5
    .byte $00, $00              ; R6
    .byte $00, $00              ; R7

; =============================================================================
; Tile $11: Standing BR (empty — character fits in cols 0-7)
; =============================================================================
EMPTY_TILE

; =============================================================================
; Tile $12: Walk1 BL — right leg forward, left leg trailing
;   R0: . 3 1 1 5 1 1 3    belt
;   R1: . . 1 1 . . 1 1    legs separating
;   R2: . . 1 . . . 1 1    right leg extends forward
;   R3: . . 3 . . . 1 .    left boot behind, right leg
;   R4: . 3 3 . . 3 3 .    boots separated
;   R5: . . . . . 3 3 .    right foot ahead
;   R6-7: empty
; =============================================================================
    ; bp0/bp1
    BELT_ROW_BP01               ; R0: belt
    .byte $33, $00              ; R1: ..11..11
    .byte $23, $00              ; R2: ..1...11
    .byte $22, $20              ; R3: ..3...1.  (col2=dark bp0+bp1, col6=red bp0)
    .byte $66, $66              ; R4: .33..33.
    .byte $06, $06              ; R5: .....33.
    .byte $00, $00              ; R6: empty
    .byte $00, $00              ; R7: empty
    ; bp2/bp3
    .byte $08, $00              ; R0: white buckle
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
; Tile $14: Walk2 BL — contact position, legs close together
;   R0: . 3 1 1 5 1 1 3    belt
;   R1: . . . 1 1 1 . .    legs together
;   R2: . . . 1 1 1 . .    legs
;   R3: . . . 1 1 1 . .    legs
;   R4: . . . 3 3 3 . .    boots compact
;   R5: . . 3 3 3 3 . .    boots base
;   R6-7: empty
; =============================================================================
    ; bp0/bp1
    BELT_ROW_BP01               ; R0: belt
    .byte $1C, $00              ; R1: ...111..
    .byte $1C, $00              ; R2: legs
    .byte $1C, $00              ; R3: legs
    .byte $1C, $1C              ; R4: ...333..
    .byte $3C, $3C              ; R5: ..3333..
    .byte $00, $00              ; R6: empty
    .byte $00, $00              ; R7: empty
    ; bp2/bp3
    .byte $08, $00              ; R0: white buckle
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
; Tile $16: Walk3 BL — left leg forward, right leg trailing (mirror of Walk1)
;   R0: . 3 1 1 5 1 1 3    belt
;   R1: . 1 1 . . 1 1 .    legs separating
;   R2: . 1 1 . . . 1 .    left leg extends forward
;   R3: . . 1 . . . 3 .    left leg, right boot behind
;   R4: . . 3 3 . . 3 3    boots separated
;   R5: . . 3 3 . . . .    left foot ahead
;   R6-7: empty
; =============================================================================
    ; bp0/bp1
    BELT_ROW_BP01               ; R0: belt
    .byte $66, $00              ; R1: .11..11.
    .byte $62, $00              ; R2: .11...1.
    .byte $22, $02              ; R3: ..1...3.  (col6=dark bp0+bp1, col2=red bp0)
    .byte $33, $33              ; R4: ..33..33
    .byte $30, $30              ; R5: ..33....
    .byte $00, $00              ; R6: empty
    .byte $00, $00              ; R7: empty
    ; bp2/bp3
    .byte $08, $00              ; R0: white buckle
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
; Tile $18: Jump BL — legs tucked forward, compact airborne pose
;   R0: . 3 1 1 5 1 1 3    belt
;   R1: . . 1 1 1 1 1 .    legs forward
;   R2: . . . 1 1 1 . .    legs tucked
;   R3: . . . 3 3 3 . .    boots compact
;   R4-7: empty (airborne)
; =============================================================================
    ; bp0/bp1
    BELT_ROW_BP01               ; R0: belt
    .byte $3E, $00              ; R1: ..11111.
    .byte $1C, $00              ; R2: ...111..
    .byte $1C, $1C              ; R3: ...333..
    .byte $00, $00              ; R4: empty
    .byte $00, $00              ; R5: empty
    .byte $00, $00              ; R6: empty
    .byte $00, $00              ; R7: empty
    ; bp2/bp3
    .byte $08, $00              ; R0: white buckle
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
