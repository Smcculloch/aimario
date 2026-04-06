; =============================================================================
; Hardware Initialization — Reset Handler
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.import Main_Init
.export Reset_Handler

.segment "CODE"

; =============================================================================
; Reset_Handler — called on power-on / reset
; =============================================================================
.proc Reset_Handler
    sei                         ; Disable IRQ
    clc
    xce                         ; Switch to native mode (clear emulation flag)

    rep #$30                    ; A=16, XY=16
    .a16
    .i16

    lda #$0000
    tcd                         ; Direct page = $0000

    ; Set stack pointer
    ldx #$01FF
    txs

    sep #$20                    ; A=8
    .a8

    ; Set data bank to $00
    lda #$00
    pha
    plb

    ; Force blank (screen off)
    lda #$80
    sta INIDISP

    ; Clear all PPU registers
    stz OBSEL
    stz BGMODE
    stz BG1SC
    stz BG2SC
    stz BG3SC
    stz BG4SC
    stz BG12NBA
    stz BG34NBA

    ; Clear scroll registers (write-twice registers)
    stz BG1HOFS
    stz BG1HOFS
    stz BG1VOFS
    stz BG1VOFS
    stz BG2HOFS
    stz BG2HOFS
    stz BG2VOFS
    stz BG2VOFS
    stz BG3HOFS
    stz BG3HOFS
    stz BG3VOFS
    stz BG3VOFS

    ; Disable windows, color math, mosaic
    stz MOSAIC
    stz W12SEL
    stz W34SEL
    stz WOBJSEL
    stz WBGLOG
    stz WOBJLOG
    stz TMW
    stz TSW
    stz CGWSEL
    stz CGADSUB
    stz SETINI

    ; VRAM increment: increment after writing high byte ($2119)
    lda #$80
    sta VMAIN

    ; Disable DMA / HDMA
    stz MDMAEN
    stz HDMAEN

    ; Disable interrupts (NMI off, joypad auto-read on)
    lda #$01
    sta NMITIMEN

    ; --- Clear WRAM zero page + low RAM first ---
    ; (So we have a known-zero source byte for VRAM/CGRAM/OAM clears)
    rep #$20
    .a16
    lda #$0000
    ldx #$0000
@clr_wram:
    sta f:$7E0000,x
    inx
    inx
    cpx #$2000                  ; clear first 8 KB of WRAM
    bne @clr_wram
    sep #$20
    .a8

    ; --- Clear VRAM (64 KB) ---
    stz VMADDL
    stz VMADDH
    lda #$18                    ; A→B, fixed source, 2-register ($2118/$2119)
    sta DMAP0
    lda #$18                    ; B-bus: VMDATAL ($2118)
    sta BBAD0
    ; Source: $7E:0000 (WRAM, now zeroed)
    stz A1T0L
    stz A1T0H
    lda #$7E
    sta A1B0
    ; Size $0000 = 65536 bytes
    stz DAS0L
    stz DAS0H
    lda #$01
    sta MDMAEN

    ; --- Clear CGRAM (512 bytes) ---
    stz CGADD
    lda #$08                    ; A→B, fixed source, 1-register
    sta DMAP0
    lda #$22                    ; B-bus: CGDATA ($2122)
    sta BBAD0
    stz A1T0L
    stz A1T0H
    lda #$7E
    sta A1B0
    lda #<512
    sta DAS0L
    lda #>512
    sta DAS0H
    lda #$01
    sta MDMAEN

    ; --- Clear OAM (544 bytes) ---
    stz OAMADDL
    stz OAMADDH
    lda #$08                    ; A→B, fixed source, 1-register
    sta DMAP0
    lda #$04                    ; B-bus: OAMDATA ($2104)
    sta BBAD0
    stz A1T0L
    stz A1T0H
    lda #$7E
    sta A1B0
    lda #<544
    sta DAS0L
    lda #>544
    sta DAS0H
    lda #$01
    sta MDMAEN

    ; Jump to game initialization
    jmp Main_Init
.endproc
