; =============================================================================
; World 1-1 Level Data — 224 columns x 14 rows (row-major)
; V2 Step 1: Only TILE_EMPTY, TILE_GROUND, TILE_BRICK
; =============================================================================

EM = $00     ; Empty (sky)
GR = $01     ; Ground
BK = $02     ; Brick
CB = $03     ; Coin block

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
; Row 1 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 2 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 3 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 4 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 5 (high bricks — matching V1 brick positions)
; cols 20,24,26,28: bricks   cols 77-79: bricks   cols 118-120: bricks
; ============================================================
.repeat 20
    .byte EM
.endrepeat
.byte BK                        ; col 20
.repeat 3
    .byte EM
.endrepeat
.byte BK                        ; col 24
.byte EM                        ; col 25
.byte BK                        ; col 26
.byte EM                        ; col 27
.byte BK                        ; col 28
.repeat 48
    .byte EM
.endrepeat
.byte BK, BK, BK               ; col 77-79
.repeat 38
    .byte EM
.endrepeat
.byte BK, BK, BK               ; col 118-120
.repeat 8
    .byte EM                    ; cols 121-128
.endrepeat
.byte CB, CB                   ; cols 129-130: coin blocks
.repeat 93
    .byte EM                    ; cols 131-223
.endrepeat

; ============================================================
; Row 6 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 7 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 8 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 9 (low bricks + coin blocks)
; Coin blocks at: 16, 23, 77, 94, 101, 109, 112
; Bricks at: 22, 96, 102, 118
; ============================================================
.repeat 16
    .byte EM                    ; cols 0-15
.endrepeat
.byte CB                        ; col 16: coin block
.repeat 5
    .byte EM                    ; cols 17-21
.endrepeat
.byte BK                        ; col 22: brick
.byte CB                        ; col 23: coin block
.repeat 53
    .byte EM                    ; cols 24-76
.endrepeat
.byte CB                        ; col 77: coin block
.repeat 16
    .byte EM                    ; cols 78-93
.endrepeat
.byte CB, EM, BK               ; col 94: coin, 95: empty, 96: brick
.repeat 4
    .byte EM                    ; cols 97-100
.endrepeat
.byte CB, BK                   ; col 101: coin, 102: brick
.repeat 6
    .byte EM                    ; cols 103-108
.endrepeat
.byte CB                        ; col 109: coin block
.repeat 2
    .byte EM                    ; cols 110-111
.endrepeat
.byte CB                        ; col 112: coin block
.repeat 5
    .byte EM                    ; cols 113-117
.endrepeat
.byte BK                        ; col 118: brick
.repeat 105
    .byte EM                    ; cols 119-223
.endrepeat

; ============================================================
; Row 10 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 11 (all sky)
; ============================================================
.repeat 224
    .byte EM
.endrepeat

; ============================================================
; Row 12 (ground level with gaps for pits)
; ============================================================
.repeat 69
    .byte GR
.endrepeat
.byte EM, EM                   ; col 69-70: pit
.repeat 15
    .byte GR
.endrepeat
.byte EM, EM                   ; col 86-87: pit
.repeat 66
    .byte GR
.endrepeat
.byte EM, EM                   ; col 153-154: pit
.repeat 68
    .byte GR
.endrepeat

; ============================================================
; Row 13 (bottom row — same pattern as row 12)
; ============================================================
.repeat 69
    .byte GR
.endrepeat
.byte EM, EM                   ; col 69-70
.repeat 15
    .byte GR
.endrepeat
.byte EM, EM                   ; col 86-87
.repeat 66
    .byte GR
.endrepeat
.byte EM, EM                   ; col 153-154
.repeat 68
    .byte GR
.endrepeat

level_data_end:
