; =============================================================================
; Level — Loading, Column Streaming to VRAM
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp camera_x_lo, camera_x_hi
.importzp scroll_col_drawn
.importzp temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7
.importzp ptr0, ptr0h

.import level_data, metatile_map, level_ram

.export Level_Init, Level_StreamColumn, Upload_Initial_Tilemap, row_offsets
.export Level_CopyToRAM

.segment "CODE"

.proc Level_Init
    rts
.endproc

; =============================================================================
; Upload_Initial_Tilemap — hardcoded ground for both nametables
; =============================================================================
.proc Upload_Initial_Tilemap
    lda #$80
    sta VMAIN

    SetAXY_16

    ; --- Nametable 0 ($4000): clear to sky ---
    lda #$4000
    sta VMADDL
    ldx #$0000
@sky0:
    lda #$0000
    sta VMDATAL
    inx
    cpx #$0400
    bne @sky0

    ; Ground rows 24-25: tile $01 (ground TL/TR)
    lda #$4000 + (24 * 32)
    sta VMADDL
    ldx #$0000
@gnd0_24:
    lda #$0001
    sta VMDATAL
    inx
    cpx #64
    bne @gnd0_24

    ; Ground rows 26-27: tile $03 (ground BL/BR)
    lda #$4000 + (26 * 32)
    sta VMADDL
    ldx #$0000
@gnd0_26:
    lda #$0003
    sta VMDATAL
    inx
    cpx #64
    bne @gnd0_26

    ; --- Nametable 1 ($4400): same pattern ---
    lda #$4400
    sta VMADDL
    ldx #$0000
@sky1:
    lda #$0000
    sta VMDATAL
    inx
    cpx #$0400
    bne @sky1

    lda #$4400 + (24 * 32)
    sta VMADDL
    ldx #$0000
@gnd1_24:
    lda #$0001
    sta VMDATAL
    inx
    cpx #64
    bne @gnd1_24

    lda #$4400 + (26 * 32)
    sta VMADDL
    ldx #$0000
@gnd1_26:
    lda #$0003
    sta VMDATAL
    inx
    cpx #64
    bne @gnd1_26

    SetAXY_8_16
    rts
.endproc

; =============================================================================
; Level_StreamColumn — upload new column as camera scrolls
; =============================================================================
.proc Level_StreamColumn
    SetA16
    lda camera_x_lo
    clc
    adc #256
    lsr
    lsr
    lsr
    lsr                         ; /16 = metatile column
    SetA8
    sta temp0

    cmp scroll_col_drawn
    beq @done
    bcc @done

    ; Draw next column
    lda scroll_col_drawn
    inc a
    sta scroll_col_drawn
    jsr UploadOneColumn

@done:
    rts
.endproc

; =============================================================================
; UploadOneColumn — write one metatile column to BG1 tilemap in VRAM
; Input: A = metatile column index (0-223)
; =============================================================================
.proc UploadOneColumn
    sta temp2                   ; metatile column

    ; Hardware column = metatile_col * 2
    asl
    and #$3F                    ; mod 64 for circular buffer
    sta temp3                   ; hw column (left tile)

    ; VRAM address for this column
    SetA16
    lda temp3
    and #$00FF
    cmp #32
    bcs @second_nt
    clc
    adc #$4000
    sta temp4
    bra @nt_done
@second_nt:
    sec
    sbc #32
    clc
    adc #$4400
    sta temp4
@nt_done:
    SetA8

    ; Set VRAM increment to +32 (write down a column)
    lda #$81
    sta VMAIN

    ; --- Write left tile column ---
    SetA16
    lda temp4
    sta VMADDL
    SetA8

    stz temp5                   ; row counter
@left_col_loop:
    jsr GetMetatile
    jsr GetMetatileTiles

    ; Write top-left tile
    ldx temp6
    lda f:metatile_map,x
    sta VMDATAL
    stz VMDATAH

    ; Write bottom-left tile (offset +2)
    lda f:metatile_map+2,x
    sta VMDATAL
    stz VMDATAH

    inc temp5
    lda temp5
    cmp #LEVEL_HEIGHT_TILES
    bcc @left_col_loop

    ; --- Write right tile column ---
    SetA16
    lda temp4
    inc a
    sta VMADDL
    SetA8

    stz temp5
@right_col_loop:
    jsr GetMetatile
    jsr GetMetatileTiles

    ldx temp6
    lda f:metatile_map+1,x
    sta VMDATAL
    stz VMDATAH

    lda f:metatile_map+3,x
    sta VMDATAL
    stz VMDATAH

    inc temp5
    lda temp5
    cmp #LEVEL_HEIGHT_TILES
    bcc @right_col_loop

    ; Restore VRAM increment
    lda #$80
    sta VMAIN
    rts
.endproc

; =============================================================================
; Row offset lookup table — row * 224, precomputed
; =============================================================================
row_offsets:
    .word 0, 224, 448, 672, 896, 1120, 1344, 1568
    .word 1792, 2016, 2240, 2464, 2688, 2912

; =============================================================================
; GetMetatile — read metatile from level data
; Input: temp2 = column (8-bit), temp5 = row (8-bit)
; Output: A = metatile type
; =============================================================================
.proc GetMetatile
    SetA16
    lda temp5
    and #$00FF
    asl
    tax
    lda f:row_offsets,x
    clc
    pha
    lda temp2
    and #$00FF
    sta ptr0
    pla
    adc ptr0
    tax
    SetA8
    lda f:level_ram,x
    rts
.endproc

; =============================================================================
; Level_CopyToRAM — copy level_data from ROM to level_ram in WRAM
; =============================================================================
.proc Level_CopyToRAM
    SetAXY_16
    ldx #$0000
@copy_loop:
    lda f:level_data,x
    sta f:level_ram,x
    inx
    inx
    cpx #3136
    bcc @copy_loop
    SetAXY_8_16
    rts
.endproc

; =============================================================================
; GetMetatileTiles — compute metatile_map index from tile type
; Input: A = metatile type
; Output: temp6 (16-bit) = metatile_type * 4
; =============================================================================
.proc GetMetatileTiles
    SetA16
    and #$00FF
    asl
    asl
    sta temp6
    SetA8
    rts
.endproc
