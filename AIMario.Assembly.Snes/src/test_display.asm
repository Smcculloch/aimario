; =============================================================================
; Test — add Level_Init + Upload_Initial_Tilemap
; =============================================================================

.include "registers.inc"

.import Upload_Palette, Upload_BG_Tiles, Upload_Sprite_Tiles
.import Level_Init, Upload_Initial_Tilemap

.segment "CODE"

.export Reset_Handler, NMI_Handler

.proc NMI_Handler
    pha
    lda $4210
    pla
    rti
.endproc

.proc Reset_Handler
    sei
    clc
    xce
    sep #$20
    .a8
    rep #$10
    .i16

    lda #$80
    sta $2100

    lda #$00
    pha
    plb

    ldx #$01FF
    txs

    rep #$20
    .a16
    lda #$0000
    tcd
    sep #$20
    .a8

    ; Clear VRAM
    lda #$80
    sta $2115
    ldx #$0000
    stx $2116
@clr:
    stz $2118
    stz $2119
    inx
    cpx #$8000
    bne @clr

    jsr Upload_BG_Tiles
    jsr Upload_Sprite_Tiles
    jsr Upload_Palette

    ; PPU Mode 1
    lda #$01
    sta $2105
    lda #$41
    sta $2107           ; BG1 tilemap at $4000, 64 wide
    lda #$00
    sta $210B           ; BG1 chr at $0000
    lda #$03
    sta $2101           ; sprite chr at $6000
    lda #$11
    sta $212C           ; BG1 + OBJ

    ; Level + tilemap
    jsr Level_Init
    jsr Upload_Initial_Tilemap

    ; Survived? Show magenta
    stz $2121
    lda #$1F
    sta $2122
    lda #$7C
    sta $2122

    lda #$81
    sta $4200
    lda #$0F
    sta $2100

@loop:
    wai
    jmp @loop
.endproc
