; =============================================================================
; World 1-1 Level Data — 224 columns × 14 rows (row-major)
; Each byte = metatile type (see constants.inc for TILE_* values)
; Row 0 = top of level, Row 13 = ground level
; =============================================================================

; Shorthand aliases — avoid single letters that conflict with 65816 registers
EM = $00     ; Empty (sky)
GR = $01     ; Ground
BK = $02     ; Brick
QB = $03     ; Question block
HQ = $04     ; Hit question block (used at runtime)
PT = $05     ; Pipe top-left
PR = $06     ; Pipe top-right
PB = $07     ; Pipe body-left
PD = $08     ; Pipe body-right
SB = $09     ; Solid block
SR = $0A     ; Stair block
FP = $0B     ; Flagpole
FT = $0C     ; Flagpole top
CL = $0D     ; Castle

.export level_data

.segment "RODATA"

level_data:

; ============================================================
; Row 0 (topmost — all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 1 (sky, flagpole top near end)
; ============================================================
.repeat 198
    .byte EM
.endrepeat
.byte FT    ; col 198: flagpole top
.repeat 25
    .byte EM
.endrepeat

; ============================================================
; Row 2 (sky, flagpole)
; ============================================================
.repeat 198
    .byte EM
.endrepeat
.byte FP
.repeat 25
    .byte EM
.endrepeat

; ============================================================
; Row 3 (sky, flagpole)
; ============================================================
.repeat 198
    .byte EM
.endrepeat
.byte FP
.repeat 25
    .byte EM
.endrepeat

; ============================================================
; Row 4 (sky, flagpole, castle top)
; ============================================================
.repeat 198
    .byte EM
.endrepeat
.byte FP
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 5 (high bricks/qblocks, flagpole, castle)
; ============================================================
.repeat 20
    .byte EM
.endrepeat
.byte QB                        ; col 20
.byte EM, EM, EM                ; 21-23
.byte BK                        ; col 24
.byte QB                        ; col 25
.byte BK                        ; col 26
.byte QB                        ; col 27
.byte BK                        ; col 28
.repeat 48
    .byte EM
.endrepeat
.byte BK, BK, BK               ; col 77-79
.repeat 38
    .byte EM
.endrepeat
.byte BK, BK, BK               ; col 118-120
.repeat 77
    .byte EM
.endrepeat
.byte FP                        ; col 198
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 6 (sky, flagpole, castle)
; ============================================================
.repeat 198
    .byte EM
.endrepeat
.byte FP
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 7 (sky, flagpole, castle)
; ============================================================
.repeat 198
    .byte EM
.endrepeat
.byte FP
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 8 (sky, flagpole, castle)
; ============================================================
.repeat 198
    .byte EM
.endrepeat
.byte FP
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 9 (question blocks, flagpole, castle)
; ============================================================
.repeat 16
    .byte EM
.endrepeat
.byte QB                        ; col 16
.repeat 5
    .byte EM
.endrepeat
.byte QB                        ; col 22
.repeat 54
    .byte EM
.endrepeat
.byte QB                        ; col 77
.repeat 16
    .byte EM
.endrepeat
.byte BK, QB, BK               ; col 94-96
.repeat 4
    .byte EM
.endrepeat
.byte QB, QB                    ; col 101-102
.repeat 15
    .byte EM
.endrepeat
.byte QB                        ; col 118
.repeat 79
    .byte EM
.endrepeat
.byte FP                        ; col 198
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 10 (pipe tops, stair starts, flagpole)
; ============================================================
.repeat 28
    .byte EM
.endrepeat
.byte PT, PR                    ; pipe 1 col 28-29
.repeat 8
    .byte EM
.endrepeat
.byte PT, PR                    ; pipe 2 col 38-39
.repeat 6
    .byte EM
.endrepeat
.byte PT, PR                    ; pipe 3 col 46-47
.repeat 9
    .byte EM
.endrepeat
.byte PT, PR                    ; pipe 4 col 57-58
.repeat 75
    .byte EM
.endrepeat
.byte EM, EM, EM, EM           ; col 134-137
.byte SR                        ; col 138
.repeat 10
    .byte EM
.endrepeat
.byte EM, EM, EM, SR           ; col 149-152
.repeat 10
    .byte EM
.endrepeat
.byte EM, EM, EM, EM, EM       ; col 163-167
.repeat 30
    .byte EM
.endrepeat
.byte FP                        ; col 198
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 11 (pipes body, stairs grow, flagpole)
; ============================================================
.repeat 28
    .byte EM
.endrepeat
.byte PB, PD                    ; pipe 1 body
.repeat 8
    .byte EM
.endrepeat
.byte PB, PD                    ; pipe 2 body
.repeat 6
    .byte EM
.endrepeat
.byte PB, PD                    ; pipe 3 body
.repeat 9
    .byte EM
.endrepeat
.byte PB, PD                    ; pipe 4 body
.repeat 75
    .byte EM
.endrepeat
.byte EM, EM, EM, SR, SR       ; col 134-138
.repeat 10
    .byte EM
.endrepeat
.byte EM, EM, SR, SR           ; col 149-152
.repeat 10
    .byte EM
.endrepeat
.byte EM, EM, EM, EM, SR       ; col 163-167
.repeat 30
    .byte EM
.endrepeat
.byte FP
.repeat 3
    .byte EM
.endrepeat
.byte CL, CL, CL, CL, CL, CL
.repeat 16
    .byte EM
.endrepeat

; ============================================================
; Row 12 (ground level with gaps, pipe bases, stairs)
; ============================================================
.repeat 28
    .byte GR
.endrepeat
.byte PB, PD                    ; pipe 1 base
.repeat 8
    .byte GR
.endrepeat
.byte PB, PD                    ; pipe 2 base
.repeat 6
    .byte GR
.endrepeat
.byte PB, PD                    ; pipe 3 base
.repeat 9
    .byte GR
.endrepeat
.byte PB, PD                    ; pipe 4 base
.repeat 10
    .byte GR
.endrepeat
.byte EM, EM                   ; col 69-70: pit
.repeat 15
    .byte GR
.endrepeat
.byte EM, EM                   ; col 86-87: pit
.repeat 46
    .byte GR
.endrepeat
.byte EM, EM, SR, SR, SR       ; col 134-138
.repeat 10
    .byte GR
.endrepeat
.byte EM, SR, SR, SR           ; col 149-152
.repeat 10
    .byte GR
.endrepeat
.byte EM, EM, EM, SR, SR       ; col 163-167
.repeat 30
    .byte GR
.endrepeat
.byte GR                        ; col 198
.repeat 3
    .byte GR
.endrepeat
.byte GR, GR, GR, GR, GR, GR
.repeat 16
    .byte GR
.endrepeat

; ============================================================
; Row 13 (bottom row — all ground except gaps)
; ============================================================
.repeat 69
    .byte GR
.endrepeat
.byte EM, EM                   ; col 69-70: pit extends down
.repeat 15
    .byte GR
.endrepeat
.byte EM, EM                   ; col 86-87
.repeat 46
    .byte GR
.endrepeat
.byte EM, SR, SR, SR, SR       ; col 134-138
.repeat 10
    .byte GR
.endrepeat
.byte SR, SR, SR, SR           ; col 149-152
.repeat 10
    .byte GR
.endrepeat
.byte EM, EM, SR, SR, SR       ; col 163-167
.repeat 30
    .byte GR
.endrepeat
.byte GR
.repeat 3
    .byte GR
.endrepeat
.byte GR, GR, GR, GR, GR, GR
.repeat 16
    .byte GR
.endrepeat

level_data_end:
