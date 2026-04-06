; =============================================================================
; Utility Macros
; =============================================================================

; --- Set A to 8-bit mode ---
.macro SetA8
    sep #$20
    .a8
.endmacro

; --- Set A to 16-bit mode ---
.macro SetA16
    rep #$20
    .a16
.endmacro

; --- Set X/Y to 16-bit mode ---
.macro SetXY16
    rep #$10
    .i16
.endmacro

; --- Set X/Y to 8-bit mode ---
.macro SetXY8
    sep #$10
    .i8
.endmacro

; --- Set A=8, XY=16 (most common mode) ---
.macro SetAXY_8_16
    sep #$20
    rep #$10
    .a8
    .i16
.endmacro

; --- Set A=16, XY=16 ---
.macro SetAXY_16
    rep #$30
    .a16
    .i16
.endmacro

; --- Set A=8, XY=8 ---
.macro SetAXY_8
    sep #$30
    .a8
    .i8
.endmacro

; --- Store 16-bit immediate to direct page address ---
.macro Store16 value, addr
    SetA16
    lda #value
    sta addr
    SetA8
.endmacro

; --- Store 8-bit value to SNES register ---
.macro StoreReg value, reg
    lda #value
    sta reg
.endmacro

; --- Negate 16-bit value in A (two's complement) ---
.macro Negate16
    eor #$FFFF
    inc a
.endmacro
