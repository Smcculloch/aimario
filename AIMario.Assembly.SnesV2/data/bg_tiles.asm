; =============================================================================
; Background CHR Data — 4bpp tiles for BG1
; Only tiles $00-$08: empty, ground (4 tiles), brick (4 tiles)
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.export Upload_BG_Tiles

.segment "RODATA"

bg_chr_data:

; --- Tile $00: Empty/Sky (transparent) ---
.repeat 8
    .byte $00, $00
.endrepeat
.repeat 8
    .byte $00, $00
.endrepeat

; --- Tile $01: Ground top-left ---
    .byte $FF, $FF              ; row 0: bright surface edge
    .byte $FF, $FF              ; row 1
    .byte $55, $FF              ; row 2: dithered
    .byte $FF, $FF              ; row 3
    .byte $55, $FF              ; row 4
    .byte $FF, $FF              ; row 5
    .byte $55, $FF              ; row 6
    .byte $FF, $FF              ; row 7
.repeat 8
    .byte $00, $00
.endrepeat

; --- Tile $02: Ground top-right ---
    .byte $FF, $FF
    .byte $FF, $FF
    .byte $FF, $FF
    .byte $55, $FF
    .byte $FF, $FF
    .byte $55, $FF
    .byte $FF, $FF
    .byte $55, $FF
.repeat 8
    .byte $00, $00
.endrepeat

; --- Tile $03: Ground bottom-left ---
    .byte $00, $FF
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

; --- Tile $04: Ground bottom-right ---
    .byte $00, $FF
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

; --- Tile $05: Brick top-left ---
    .byte $FE, $00
    .byte $FE, $00
    .byte $FE, $00
    .byte $00, $00
    .byte $EF, $00
    .byte $EF, $00
    .byte $EF, $00
    .byte $00, $00
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

; --- Tile $07: Brick bottom-left ---
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

bg_chr_data_end:
BG_CHR_SIZE = bg_chr_data_end - bg_chr_data

; =============================================================================
; Upload_BG_Tiles — DMA background CHR to VRAM $0000
; =============================================================================
.segment "CODE"

.proc Upload_BG_Tiles
    lda #$80
    sta VMAIN
    stz VMADDL
    stz VMADDH

    lda #$01                    ; word transfer, increment
    sta DMAP0
    lda #$18
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
