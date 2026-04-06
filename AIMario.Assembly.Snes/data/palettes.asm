; =============================================================================
; Palette Data — 15-bit BGR ($0bbbbbgggggrrrrr)
; Cyberpunk theme: dark blues, neon cyan/magenta, dark ground
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.export Upload_Palette

.segment "RODATA"

; --- BG Palettes (8 palettes × 16 colors = 256 colors, 512 bytes) ---
; We define palette 0 (sky/ground) for now

bg_palette:
    ; Palette 0: Sky + Ground
    .word $0000                 ; Color 0: transparent (black)
    .word $5400                 ; Color 1: dark blue sky     (r=0,  g=0,  b=10) = 0_01010_00000_00000
    .word $7C00                 ; Color 2: deep blue         (r=0,  g=0,  b=15)
    .word $03FF                 ; Color 3: neon cyan          (r=31, g=15, b=0) actually...
    ; Let me use proper 15-bit BGR: %0bbbbbgggggrrrrr
    ; Sky blue:     r=8,  g=16, b=28 = %0_11100_10000_01000 = $7108
    ; Ground dark:  r=6,  g=4,  b=3  = %0_00011_00100_00110 = $0C86
    ; Ground lite:  r=10, g=7,  b=5  = %0_00101_00111_01010 = $14EA
    ; Brick dark:   r=12, g=4,  b=8  = %0_01000_00100_01100 = $210C
    ; Neon cyan:    r=0,  g=31, b=31 = %0_11111_11111_00000 = $7FE0
    ; Neon magenta: r=31, g=0,  b=24 = %0_11000_00000_11111 = $601F

; Redo palette 0 cleanly
bg_palette_actual:

; Palette 0: Sky + terrain
sky_pal:
    .word $7108                 ; 0: backdrop = sky blue (r=8,g=16,b=28)
    .word $7108                 ; 1: sky blue (same, for compat)
    .word $0C86                 ; 2: ground dark
    .word $14EA                 ; 3: ground light
    .word $210C                 ; 4: brick dark
    .word $2D4E                 ; 5: brick light
    .word $7FE0                 ; 6: neon cyan (question block glow)
    .word $601F                 ; 7: neon magenta
    .word $4210                 ; 8: mid gray
    .word $6318                 ; 9: light gray
    .word $294A                 ; 10: dark gray
    .word $2508                 ; 11: pipe dark green (r=8,g=8,b=4) = $1108... redo
    .word $01C4                 ; 12: pipe green
    .word $02A8                 ; 13: pipe light green
    .word $7FFF                 ; 14: white
    .word $0000                 ; 15: black

; Palettes 1-7: copy of palette 0 for now (pad to 256 colors)
; Total BG palette = 128 words = 256 bytes
.repeat 7
    .word $7108, $7108, $0C86, $14EA, $210C, $2D4E, $7FE0, $601F
    .word $4210, $6318, $294A, $1108, $01C4, $02A8, $7FFF, $0000
.endrepeat

; --- Sprite Palettes (8 palettes × 16 colors = 128 words) ---
; Palette 128-255 in CGRAM
spr_palette:
    ; Sprite palette 0: Mario
    .word $0000                 ; 0: transparent
    .word $001F                 ; 1: red (r=31,g=0,b=0)
    .word $7FE0                 ; 2: neon cyan (visor/accents)
    .word $0200                 ; 3: dark red
    .word $02BF                 ; 4: skin/orange
    .word $7FFF                 ; 5: white
    .word $294A                 ; 6: dark gray (boots)
    .word $4210                 ; 7: mid gray
    .word $601F                 ; 8: neon magenta
    .word $6318                 ; 9: light gray
    .word $0000                 ; 10-15: unused
    .word $0000
    .word $0000
    .word $0000
    .word $0000
    .word $0000

; Sprite palettes 1-7: fill with zeros for now
.repeat 7
    .word $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
.endrepeat

bg_palette_end:
spr_palette_end:

.segment "CODE"

; =============================================================================
; Upload_Palette — DMA palette data to CGRAM
; =============================================================================
.proc Upload_Palette
    ; BG palette: CGRAM address 0 (colors 0-127)
    stz CGADD                   ; start at color 0

    lda #$00                    ; DMA: A->B, increment
    sta DMAP0
    lda #$22                    ; B-bus: CGDATA ($2122)
    sta BBAD0
    lda #<bg_palette_actual
    sta A1T0L
    lda #>bg_palette_actual
    sta A1T0H
    lda #^bg_palette_actual
    sta A1B0
    ; 256 bytes = 128 colors
    lda #<256
    sta DAS0L
    lda #>256
    sta DAS0H
    lda #$01
    sta MDMAEN

    ; Sprite palette: CGRAM address 128 (colors 128-255)
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
