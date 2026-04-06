; =============================================================================
; Background CHR Data — 4bpp tiles for BG1
; Each 8x8 tile = 32 bytes (4bpp SNES format)
; 4bpp format: 8 rows, each row = 2 bytes (bitplanes 0-1) then 2 bytes (bp 2-3)
; Layout: bp0 row0, bp1 row0, bp0 row1, bp1 row1... (16 bytes for bp0-1)
;         bp2 row0, bp3 row0, bp2 row1, bp3 row1... (16 bytes for bp2-3)
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.export Upload_BG_Tiles

.segment "RODATA"

bg_chr_data:

; --- Tile $00: Empty/Sky (transparent = color 0 → shows backdrop) ---
; All pixels transparent so the backdrop color (sky blue) shows through
.repeat 8
    .byte $00, $00              ; bp0-1: all 0
.endrepeat
.repeat 8
    .byte $00, $00              ; bp2-3: all 0
.endrepeat

; --- Tile $01: Ground top-left (surface with bright edge) ---
; Color 2 = %0010 (bp0=0,bp1=1), Color 3 = %0011 (bp0=1,bp1=1)
; Row 0: bright neon edge (all color 3)
; Rows 1-7: dithered ground (colors 2/3 checkerboard)
    .byte $FF, $FF              ; row 0: all color 3 (bright surface edge)
    .byte $FF, $FF              ; row 1: all color 3
    .byte $55, $FF              ; row 2: 3,2,3,2,3,2,3,2 dithered
    .byte $FF, $FF              ; row 3: all color 3
    .byte $55, $FF              ; row 4: dithered
    .byte $FF, $FF              ; row 5
    .byte $55, $FF              ; row 6
    .byte $FF, $FF              ; row 7
.repeat 8
    .byte $00, $00              ; bp2-3: all 0
.endrepeat

; --- Tile $02: Ground top-right (surface with bright edge) ---
    .byte $FF, $FF              ; row 0: bright edge
    .byte $FF, $FF              ; row 1: bright edge
    .byte $FF, $FF              ; row 2: all color 3
    .byte $55, $FF              ; row 3: dithered
    .byte $FF, $FF              ; row 4
    .byte $55, $FF              ; row 5
    .byte $FF, $FF              ; row 6
    .byte $55, $FF              ; row 7
.repeat 8
    .byte $00, $00
.endrepeat

; --- Tile $03: Ground bottom-left (solid underground) ---
; All color 2 (dark ground) — solid fill, no pattern
    .byte $00, $FF              ; row 0: all color 2
    .byte $00, $FF              ; row 1
    .byte $00, $FF              ; row 2
    .byte $00, $FF              ; row 3
    .byte $00, $FF              ; row 4
    .byte $00, $FF              ; row 5
    .byte $00, $FF              ; row 6
    .byte $00, $FF              ; row 7
.repeat 8
    .byte $00, $00
.endrepeat

; --- Tile $04: Ground bottom-right (solid underground) ---
    .byte $00, $FF              ; all color 2
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
.repeat 8
    .byte $00, $00
.endrepeat

; --- Tile $05: Brick top-left (color 4=dark brick, 5=light brick) ---
; Color 4 = %0100 (bp0=0,bp1=0,bp2=1,bp3=0)
; Color 5 = %0101 (bp0=1,bp1=0,bp2=1,bp3=0)
; Brick pattern: horizontal lines with mortar
    ; bp0-1 (bp0 varies, bp1=0)
    .byte $FE, $00              ; row 0: mostly color 5, left edge color 4
    .byte $FE, $00              ; row 1
    .byte $FE, $00              ; row 2
    .byte $00, $00              ; row 3: mortar line (color 4)
    .byte $EF, $00              ; row 4: offset brick
    .byte $EF, $00              ; row 5
    .byte $EF, $00              ; row 6
    .byte $00, $00              ; row 7: mortar line
    ; bp2-3 (bp2=1 for all, bp3=0)
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00

; --- Tile $06: Brick top-right ---
    .byte $7F, $00
    .byte $7F, $00
    .byte $7F, $00
    .byte $00, $00
    .byte $F7, $00
    .byte $F7, $00
    .byte $F7, $00
    .byte $00, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00

; --- Tile $07: Brick bottom-left (same as top for repeating) ---
    .byte $EF, $00
    .byte $EF, $00
    .byte $EF, $00
    .byte $00, $00
    .byte $FE, $00
    .byte $FE, $00
    .byte $FE, $00
    .byte $00, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00

; --- Tile $08: Brick bottom-right ---
    .byte $F7, $00
    .byte $F7, $00
    .byte $F7, $00
    .byte $00, $00
    .byte $7F, $00
    .byte $7F, $00
    .byte $7F, $00
    .byte $00, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00
    .byte $FF, $00

; --- Tile $09: Question block top-left (color 6=neon cyan) ---
; Color 6 = %0110 (bp0=0,bp1=1,bp2=1,bp3=0)
; Border in color 6, interior lighter
    .byte $00, $FF              ; row 0: all color 2 (bp0=0,bp1=1) = outline
    .byte $00, $81              ; row 1: edges only
    .byte $00, $A5              ; row 2: ? mark top
    .byte $00, $A5              ; row 3
    .byte $00, $85              ; row 4: ? middle
    .byte $00, $81              ; row 5
    .byte $00, $85              ; row 6: ? dot
    .byte $00, $FF              ; row 7: bottom border
    ; bp2-3
    .byte $FF, $00
    .byte $81, $00
    .byte $A5, $00
    .byte $A5, $00
    .byte $85, $00
    .byte $81, $00
    .byte $85, $00
    .byte $FF, $00

; --- Tile $0A: Question block top-right ---
    .byte $00, $FF
    .byte $00, $81
    .byte $00, $A5
    .byte $00, $85
    .byte $00, $A5
    .byte $00, $81
    .byte $00, $85
    .byte $00, $FF
    .byte $FF, $00
    .byte $81, $00
    .byte $A5, $00
    .byte $85, $00
    .byte $A5, $00
    .byte $81, $00
    .byte $85, $00
    .byte $FF, $00

; --- Tile $0B: Question block bottom-left ---
    .byte $00, $FF
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $FF
    .byte $FF, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $FF, $00

; --- Tile $0C: Question block bottom-right ---
    .byte $00, $FF
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $81
    .byte $00, $FF
    .byte $FF, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $81, $00
    .byte $FF, $00

; --- Tile $0D: Pipe top-left (color 12=pipe green) ---
; Color 12 = %1100 (bp0=0,bp1=0,bp2=1,bp3=1)
; Color 13 = %1101 (bp0=1,bp1=0,bp2=1,bp3=1)
    .byte $00, $00              ; bp0-1: mostly 0 (colors 12/13 use bp2-3)
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    ; bp2-3: both set for pipe colors
    .byte $FF, $FF              ; row 0: pipe cap
    .byte $FF, $FF
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $FF

; --- Tile $0E: Pipe top-right ---
    .byte $00, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $FF, $FF
    .byte $FF, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $FF, $FF

; --- Tile $0F: Pipe body left ---
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E
    .byte $FF, $7E

; --- Tile $10: Pipe body right ---
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $00
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF
    .byte $7E, $FF

; --- Tile $11: Stair block (color 8=mid gray, 9=light gray) ---
; Color 8 = %1000, Color 9 = %1001
    .byte $55, $00              ; bp0 pattern, bp1=0
    .byte $AA, $00
    .byte $55, $00
    .byte $AA, $00
    .byte $55, $00
    .byte $AA, $00
    .byte $55, $00
    .byte $AA, $00
    .byte $00, $FF              ; bp2=0, bp3=FF (color 8-9 range)
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF
    .byte $00, $FF

; --- Tile $12: Hit question block (dark dither pattern, color 10) ---
    ; bp0/bp1 rows (upper bitplanes)
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    ; bp2/bp3 rows (lower bitplanes)
    .byte $55, $00
    .byte $AA, $00
    .byte $55, $00
    .byte $AA, $00
    .byte $55, $00
    .byte $AA, $00
    .byte $55, $00
    .byte $AA, $00

; --- Tile $13: Flagpole (thin vertical line, color 9) ---
    .byte $18, $00              ; thin center column
    .byte $18, $00
    .byte $18, $00
    .byte $18, $00
    .byte $18, $00
    .byte $18, $00
    .byte $18, $00
    .byte $18, $00
    .byte $00, $18              ; bp2=0, bp3=has pole
    .byte $00, $18
    .byte $00, $18
    .byte $00, $18
    .byte $00, $18
    .byte $00, $18
    .byte $00, $18
    .byte $00, $18

bg_chr_data_end:
BG_CHR_SIZE = bg_chr_data_end - bg_chr_data


; =============================================================================
; Upload_BG_Tiles — DMA background CHR to VRAM $0000
; =============================================================================
.segment "CODE"

.proc Upload_BG_Tiles
    ; VRAM destination: $0000
    lda #$80
    sta VMAIN                   ; increment on high byte write
    stz VMADDL
    stz VMADDH

    ; DMA channel 0
    lda #$01                    ; A->B, increment, 2-byte (word)
    sta DMAP0
    lda #$18                    ; B-bus: VMDATAL ($2118)
    sta BBAD0
    lda #<bg_chr_data
    sta A1T0L
    lda #>bg_chr_data
    sta A1T0H
    lda #^bg_chr_data
    sta A1B0
    lda #<BG_CHR_SIZE
    sta DAS0L
    lda #>BG_CHR_SIZE
    sta DAS0H
    lda #$01
    sta MDMAEN

    rts
.endproc
