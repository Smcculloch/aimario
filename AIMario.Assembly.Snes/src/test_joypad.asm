; =============================================================================
; Diagnostic test — verify main loop runs + joypad works
; Blue = idle, Green = any button pressed, Red = right, Cyan = left
; =============================================================================

.include "registers.inc"

.segment "ZEROPAGE"
nmi_flag: .res 1
joy_lo:   .res 1
joy_hi:   .res 1
counter:  .res 1

.segment "CODE"

.export Reset_Handler, NMI_Handler

.proc NMI_Handler
    pha
    lda $4210               ; acknowledge NMI
    stz nmi_flag            ; signal main loop
    pla
    rti
.endproc

.proc Reset_Handler
    sei
    clc
    xce                     ; native mode
    sep #$20
    .a8
    rep #$10
    .i16

    lda #$80
    sta $2100               ; force blank

    lda #$00
    pha
    plb                     ; data bank = 0

    ldx #$01FF
    txs                     ; stack pointer

    rep #$20
    .a16
    lda #$0000
    tcd                     ; direct page = 0
    sep #$20
    .a8

    ; Set bg color to blue initially
    stz $2121
    lda #$00
    sta $2122
    lda #$7C                ; blue = $7C00
    sta $2122

    ; Enable NMI + auto-joypad
    lda #$81
    sta $4200

    ; Screen on
    lda #$0F
    sta $2100

    ; Main loop
@main_loop:
    lda #$01
    sta nmi_flag
@wait:
    wai
    lda nmi_flag
    bne @wait

    ; Wait for auto-read to finish
@joy_wait:
    lda $4212
    and #$01
    bne @joy_wait

    ; Read joypad
    lda $4218               ; low byte (A/X/L/R)
    sta joy_lo
    lda $4219               ; high byte (B/Y/Sel/Start/UDLR)
    sta joy_hi

    ; Increment counter (proves loop runs — use as flicker test)
    inc counter

    ; Change color based on input
    lda joy_hi
    ora joy_lo
    beq @no_input

    ; Something pressed — check specifics
    lda joy_hi
    and #$01                ; bit 0 of $4219 = right
    bne @color_red

    lda joy_hi
    and #$02                ; bit 1 of $4219 = left
    bne @color_cyan

    ; Some other button — green
    stz $2121
    lda #$E0
    sta $2122
    lda #$03
    sta $2122
    bra @main_loop

@color_red:
    stz $2121
    lda #$1F
    sta $2122
    lda #$00
    sta $2122
    bra @main_loop

@color_cyan:
    stz $2121
    lda #$E0
    sta $2122
    lda #$7F
    sta $2122
    bra @main_loop

@no_input:
    ; No input — blue (proves loop is running if we see blue)
    stz $2121
    lda #$00
    sta $2122
    lda #$7C
    sta $2122
    bra @main_loop

.endproc
