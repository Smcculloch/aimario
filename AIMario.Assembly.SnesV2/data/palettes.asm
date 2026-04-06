; =============================================================================
; Palette Data — 15-bit BGR ($0bbbbbgggggrrrrr)
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.export Upload_Palette

.segment "RODATA"

; --- BG Palettes (8 palettes x 16 colors = 256 colors, 512 bytes) ---
bg_palette_actual:

; Palette 0: Sky + terrain
    .word $7108                 ; 0: backdrop = sky blue
    .word $7108                 ; 1: sky blue
    .word $0C86                 ; 2: ground dark
    .word $14EA                 ; 3: ground light
    .word $210C                 ; 4: brick dark
    .word $2D4E                 ; 5: brick light
    .word $7FE0                 ; 6: neon cyan
    .word $601F                 ; 7: neon magenta
    .word $4210                 ; 8: mid gray
    .word $6318                 ; 9: light gray
    .word $294A                 ; 10: dark gray
    .word $1108                 ; 11: pipe dark green
    .word $01C4                 ; 12: pipe green
    .word $02A8                 ; 13: pipe light green
    .word $7FFF                 ; 14: white
    .word $0000                 ; 15: black

; Palettes 1-7: copy of palette 0
.repeat 7
    .word $7108, $7108, $0C86, $14EA, $210C, $2D4E, $7FE0, $601F
    .word $4210, $6318, $294A, $1108, $01C4, $02A8, $7FFF, $0000
.endrepeat

; --- Sprite Palettes (8 palettes x 16 colors = 128 words) ---
spr_palette:
    ; Sprite palette 0: Mario
    .word $0000                 ; 0: transparent
    .word $001F                 ; 1: red
    .word $7FE0                 ; 2: neon cyan
    .word $0200                 ; 3: dark red
    .word $02BF                 ; 4: skin/orange
    .word $7FFF                 ; 5: white
    .word $294A                 ; 6: dark gray (boots)
    .word $4210                 ; 7: mid gray
    .word $601F                 ; 8: neon magenta
    .word $6318                 ; 9: light gray
    .word $0000, $0000, $0000, $0000, $0000, $0000

; Sprite palettes 1-7: fill with zeros
.repeat 7
    .word $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
.endrepeat

.segment "CODE"

; =============================================================================
; Upload_Palette — DMA palette data to CGRAM
; =============================================================================
.proc Upload_Palette
    ; BG palette: CGRAM address 0
    stz CGADD

    lda #$00
    sta DMAP0
    lda #$22
    sta BBAD0
    lda #<bg_palette_actual
    sta A1T0L
    lda #>bg_palette_actual
    sta A1T0H
    lda #^bg_palette_actual
    sta A1B0
    lda #<256
    sta DAS0L
    lda #>256
    sta DAS0H
    lda #$01
    sta MDMAEN

    ; Sprite palette: CGRAM address 128
    lda #128
    sta CGADD

    lda #$00
    sta DMAP0
    lda #$22
    sta BBAD0
    lda #<spr_palette
    sta A1T0L
    lda #>spr_palette
    sta A1T0H
    lda #^spr_palette
    sta A1B0
    lda #<256
    sta DAS0L
    lda #>256
    sta DAS0H
    lda #$01
    sta MDMAEN

    rts
.endproc
