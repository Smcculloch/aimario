; =============================================================================
; DMA Transfer Routines
; =============================================================================

.include "registers.inc"
.include "macros.inc"

.import oam_buf

.export DMA_TransferOAM

.segment "CODE"

; =============================================================================
; DMA_TransferOAM — upload OAM buffer to PPU during VBlank
; =============================================================================
.proc DMA_TransferOAM
    ; Set OAM address to 0
    stz OAMADDL
    stz OAMADDH

    ; DMA channel 0: CPU -> OAM
    lda #$00                    ; A->B, increment, 1-byte
    sta DMAP0
    lda #$04                    ; B-bus: $2104 (OAMDATA)
    sta BBAD0

    ; Source: oam_buf in WRAM
    lda #<oam_buf
    sta A1T0L
    lda #>oam_buf
    sta A1T0H
    lda #$7E                    ; Bank $7E (WRAM)
    sta A1B0

    ; Size: 544 bytes (512 + 32)
    lda #<544
    sta DAS0L
    lda #>544
    sta DAS0H

    ; Go
    lda #$01
    sta MDMAEN
    rts
.endproc
