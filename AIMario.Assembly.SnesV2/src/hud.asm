; =============================================================================
; HUD — Score, Coins, World, Timer display on BG3
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp score, coins, lives, timer, timer_tick, hud_dirty
.importzp frame_counter
.importzp temp0, temp1, temp2, temp3, temp4, temp5

.import hud_font_data, HUD_FONT_SIZE

.export HUD_Init, HUD_Upload, Timer_Update, AddScore, AddCoin

; HUD font tile indices (must match hud_tiles.asm order)
HUD_BLANK   = $00
HUD_0       = $01
HUD_M       = $0B
HUD_A       = $0C
HUD_R       = $0D
HUD_I       = $0E
HUD_O       = $0F
HUD_W       = $10
HUD_L       = $11
HUD_D       = $12
HUD_T       = $13
HUD_E       = $14
HUD_X       = $15
HUD_DASH    = $16
HUD_COIN    = $17

.segment "CODE"

; =============================================================================
; HUD_Init — upload font tiles to VRAM, write static HUD text to BG3 tilemap
; =============================================================================
.proc HUD_Init
    ; --- Upload 2bpp font tiles to VRAM at HUD_FONT_VRAM ($2000) ---
    lda #$80
    sta VMAIN
    lda #<HUD_FONT_VRAM
    sta VMADDL
    lda #>HUD_FONT_VRAM
    sta VMADDH

    ; DMA channel 0: word transfer
    lda #$01
    sta DMAP0
    lda #$18                    ; VMDATAL
    sta BBAD0
    lda #<hud_font_data
    sta A1T0L
    lda #>hud_font_data
    sta A1T0H
    lda #^hud_font_data
    sta A1B0
    lda #<HUD_FONT_SIZE
    sta DAS0L
    lda #>HUD_FONT_SIZE
    sta DAS0H
    lda #$01
    sta MDMAEN

    ; --- Clear entire BG3 tilemap (32x32 = 1024 entries) ---
    lda #$80
    sta VMAIN
    rep #$30                    ; A=16, XY=16
    .a16
    .i16
    lda #HUD_MAP_VRAM
    sta VMADDL
    lda #$0000
    ldx #0
@clear_map:
    sta VMDATAL
    inx
    cpx #1024
    bne @clear_map

    ; --- Write static HUD text to BG3 tilemap ---
    ; BG3 tilemap at VRAM $2800 (word address), 32 tiles wide
    ; Row 2: MARIO          xCC    WORLD    TIME
    ; Row 3: 000000         00     1-1      400
    ; (rows 0-1 are blank for spacing at top)

    ; --- Row 2 (headers) ---
    lda #HUD_MAP_VRAM + 64      ; Row 2, col 0 (skip 2 blank rows)
    sta VMADDL

    ; "MARIO" at cols 3-7
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    lda #$2000 | HUD_M
    sta VMDATAL
    lda #$2000 | HUD_A
    sta VMDATAL
    lda #$2000 | HUD_R
    sta VMDATAL
    lda #$2000 | HUD_I
    sta VMDATAL
    lda #$2000 | HUD_O
    sta VMDATAL

    ; Cols 8-10: blank
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; "x" at col 11, coin icon at col 12
    lda #$2000 | HUD_X
    sta VMDATAL
    lda #$2000 | HUD_COIN
    sta VMDATAL

    ; Cols 13-18: blank
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; "WORLD" at cols 19-23
    lda #$2000 | HUD_W
    sta VMDATAL
    lda #$2000 | HUD_O
    sta VMDATAL
    lda #$2000 | HUD_R
    sta VMDATAL
    lda #$2000 | HUD_L
    sta VMDATAL
    lda #$2000 | HUD_D
    sta VMDATAL

    ; Col 24: blank
    lda #$2000 | HUD_BLANK
    sta VMDATAL

    ; "TIME" at cols 25-28
    lda #$2000 | HUD_T
    sta VMDATAL
    lda #$2000 | HUD_I
    sta VMDATAL
    lda #$2000 | HUD_M
    sta VMDATAL
    lda #$2000 | HUD_E
    sta VMDATAL

    ; Fill rest of row 0 (cols 29-31)
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; --- Row 3: dynamic values (written as initial values) ---
    lda #HUD_MAP_VRAM + 96      ; Row 3 (32*3 = 96)
    sta VMADDL

    ; Cols 0-2: blank
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; Score: "000000" at cols 3-8
    lda #$2000 | HUD_0
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; Cols 9-11: blank
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; Coins: "00" at cols 12-13
    lda #$2000 | HUD_0
    sta VMDATAL
    sta VMDATAL

    ; Cols 14-19: blank
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; World: "1-1" at cols 20-22
    lda #$2000 | HUD_0 + 1     ; '1'
    sta VMDATAL
    lda #$2000 | HUD_DASH
    sta VMDATAL
    lda #$2000 | HUD_0 + 1     ; '1'
    sta VMDATAL

    ; Cols 23-25: blank
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    ; Timer: "400" at cols 26-28
    lda #$2000 | HUD_0 + 4     ; '4'
    sta VMDATAL
    lda #$2000 | HUD_0         ; '0'
    sta VMDATAL
    lda #$2000 | HUD_0         ; '0'
    sta VMDATAL

    ; Fill rest
    lda #$2000 | HUD_BLANK
    sta VMDATAL
    sta VMDATAL
    sta VMDATAL

    SetA8
    rts
.endproc

; =============================================================================
; HUD_Upload — update dynamic HUD values in VRAM (called during VBlank)
; Only writes when hud_dirty is nonzero
; =============================================================================
.proc HUD_Upload
    lda hud_dirty
    bne @dirty
    rts
@dirty:

    ; --- Update score (BCD, 3 bytes = 6 digits) ---
    lda #$80
    sta VMAIN

    SetA16
    lda #HUD_MAP_VRAM + 96 + 3  ; Row 3, col 3
    sta VMADDL
    SetA8

    ; Digit 1 (hundred thousands): high nibble of score+2
    lda score+2
    lsr
    lsr
    lsr
    lsr
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    ; Digit 2 (ten thousands): low nibble of score+2
    lda score+2
    and #$0F
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    ; Digit 3 (thousands): high nibble of score+1
    lda score+1
    lsr
    lsr
    lsr
    lsr
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    ; Digit 4 (hundreds): low nibble of score+1
    lda score+1
    and #$0F
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    ; Digit 5 (tens): high nibble of score+0
    lda score
    lsr
    lsr
    lsr
    lsr
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    ; Digit 6 (ones): low nibble of score+0
    lda score
    and #$0F
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    ; --- Update coins (binary, 2 digits) at Row 3, cols 12-13 ---
    SetA16
    lda #HUD_MAP_VRAM + 96 + 12
    sta VMADDL
    SetA8

    ; Tens digit: coins / 10
    lda coins
    sta temp0
    lda #0
    sta temp1
@div10:
    lda temp0
    cmp #10
    bcc @div10_done
    sec
    sbc #10
    sta temp0
    inc temp1
    bra @div10
@div10_done:
    lda temp1
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    lda temp0
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    ; --- Update timer (binary 16-bit, 3 digits) at Row 3, cols 26-28 ---
    SetA16
    lda #HUD_MAP_VRAM + 96 + 26
    sta VMADDL
    SetA8

    ; Convert timer to 3 digits (0-400)
    lda timer+1
    sta temp1
    lda timer
    sta temp0
    lda #0
    sta temp2                   ; hundreds
@div100:
    lda temp1
    bne @sub100
    lda temp0
    cmp #100
    bcc @div100_done
@sub100:
    lda temp0
    sec
    sbc #100
    sta temp0
    lda temp1
    sbc #0
    sta temp1
    inc temp2
    bra @div100
@div100_done:
    lda #0
    sta temp3
@div10_t:
    lda temp0
    cmp #10
    bcc @div10_t_done
    sec
    sbc #10
    sta temp0
    inc temp3
    bra @div10_t
@div10_t_done:

    lda temp2
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    lda temp3
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    lda temp0
    clc
    adc #HUD_0
    sta VMDATAL
    lda #$20
    sta VMDATAH

    stz hud_dirty

    rts
.endproc

; =============================================================================
; Timer_Update — decrement timer each ~0.4 seconds (called in main loop)
; =============================================================================
.proc Timer_Update
    inc timer_tick
    lda timer_tick
    cmp #TIMER_TICK_MAX
    bcc @done

    stz timer_tick

    ; Decrement 16-bit timer
    lda timer
    bne @no_borrow
    lda timer+1
    beq @timer_zero             ; already 0
    dec timer+1
@no_borrow:
    dec timer

    lda #$01
    sta hud_dirty

    ; Check if timer reached 0
    lda timer
    ora timer+1
    bne @done

@timer_zero:
    ; Timer expired — for now just reset position
    ; TODO: trigger death animation

@done:
    rts
.endproc

; =============================================================================
; AddScore — add BCD value to score
; Input: A = BCD value to add to score+1 (hundreds place)
; =============================================================================
.proc AddScore
    sed                         ; decimal mode for BCD
    clc
    adc score+1
    sta score+1
    lda score+2
    adc #$00
    sta score+2
    cld                         ; clear decimal mode
    lda #$01
    sta hud_dirty
    rts
.endproc

; =============================================================================
; AddCoin — increment coin counter and add 200 to score
; =============================================================================
.proc AddCoin
    inc coins
    lda coins
    cmp #100
    bcc @no_wrap
    stz coins
@no_wrap:
    lda #SCORE_COIN
    jsr AddScore
    rts
.endproc
