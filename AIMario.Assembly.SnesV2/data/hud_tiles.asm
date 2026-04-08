; =============================================================================
; HUD Font Tiles — 2bpp tiles for BG3 (8x8 each, 16 bytes per tile)
; 2bpp format: 8 rows, each row = 2 bytes (bp0, bp1)
; Color 0 = transparent, Color 3 = white text
; Tile indices: 0=blank, 1-10='0'-'9', 11='M', 12='A', 13='R', 14='I',
;   15='O', 16='W', 17='L', 18='D', 19='T', 20='E', 21='x', 22='-',
;   23=coin icon
; =============================================================================

.export hud_font_data, HUD_FONT_SIZE

.segment "RODATA"

hud_font_data:

; Tile $00: Blank
.repeat 8
    .byte $00, $00
.endrepeat

; Tile $01: '0'
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $6E, $6E         ; ##.###
    .byte $76, $76         ; ###.##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $00, $00

; Tile $02: '1'
    .byte $18, $18         ; ..##..
    .byte $38, $38         ; .###..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $7E, $7E         ; .#####
    .byte $00, $00

; Tile $03: '2'
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $06, $06         ; ....##
    .byte $1C, $1C         ; ..###.
    .byte $30, $30         ; .##...
    .byte $60, $60         ; ##....
    .byte $7E, $7E         ; ######
    .byte $00, $00

; Tile $04: '3'
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $06, $06         ; ....##
    .byte $1C, $1C         ; ..###.
    .byte $06, $06         ; ....##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $00, $00

; Tile $05: '4'
    .byte $0C, $0C         ; ....##
    .byte $1C, $1C         ; ..###.
    .byte $3C, $3C         ; .####.
    .byte $6C, $6C         ; ##.##.
    .byte $7E, $7E         ; ######
    .byte $0C, $0C         ; ....##
    .byte $0C, $0C         ; ....##
    .byte $00, $00

; Tile $06: '5'
    .byte $7E, $7E         ; ######
    .byte $60, $60         ; ##....
    .byte $7C, $7C         ; #####.
    .byte $06, $06         ; ....##
    .byte $06, $06         ; ....##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $00, $00

; Tile $07: '6'
    .byte $3C, $3C         ; .####.
    .byte $60, $60         ; ##....
    .byte $7C, $7C         ; #####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $00, $00

; Tile $08: '7'
    .byte $7E, $7E         ; ######
    .byte $06, $06         ; ....##
    .byte $0C, $0C         ; ...##.
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $00, $00

; Tile $09: '8'
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $00, $00

; Tile $0A: '9'
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $3E, $3E         ; .#####
    .byte $06, $06         ; ....##
    .byte $0C, $0C         ; ...##.
    .byte $38, $38         ; .###..
    .byte $00, $00

; Tile $0B: 'M'
    .byte $C6, $C6         ; ##...##
    .byte $EE, $EE         ; ###.###
    .byte $FE, $FE         ; #######
    .byte $D6, $D6         ; ##.#.##
    .byte $C6, $C6         ; ##...##
    .byte $C6, $C6         ; ##...##
    .byte $C6, $C6         ; ##...##
    .byte $00, $00

; Tile $0C: 'A'
    .byte $18, $18         ; ..##..
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $7E, $7E         ; ######
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $00, $00

; Tile $0D: 'R'
    .byte $7C, $7C         ; #####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $7C, $7C         ; #####.
    .byte $6C, $6C         ; ##.##.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $00, $00

; Tile $0E: 'I'
    .byte $7E, $7E         ; ######
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $7E, $7E         ; ######
    .byte $00, $00

; Tile $0F: 'O'
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $00, $00

; Tile $10: 'W'
    .byte $C6, $C6         ; ##...##
    .byte $C6, $C6         ; ##...##
    .byte $C6, $C6         ; ##...##
    .byte $D6, $D6         ; ##.#.##
    .byte $FE, $FE         ; #######
    .byte $EE, $EE         ; ###.###
    .byte $C6, $C6         ; ##...##
    .byte $00, $00

; Tile $11: 'L'
    .byte $60, $60         ; ##....
    .byte $60, $60         ; ##....
    .byte $60, $60         ; ##....
    .byte $60, $60         ; ##....
    .byte $60, $60         ; ##....
    .byte $60, $60         ; ##....
    .byte $7E, $7E         ; ######
    .byte $00, $00

; Tile $12: 'D'
    .byte $78, $78         ; ####..
    .byte $6C, $6C         ; ##.##.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $6C, $6C         ; ##.##.
    .byte $78, $78         ; ####..
    .byte $00, $00

; Tile $13: 'T'
    .byte $7E, $7E         ; ######
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $18, $18         ; ..##..
    .byte $00, $00

; Tile $14: 'E'
    .byte $7E, $7E         ; ######
    .byte $60, $60         ; ##....
    .byte $60, $60         ; ##....
    .byte $7C, $7C         ; #####.
    .byte $60, $60         ; ##....
    .byte $60, $60         ; ##....
    .byte $7E, $7E         ; ######
    .byte $00, $00

; Tile $15: 'x' (multiply symbol)
    .byte $00, $00
    .byte $00, $00
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $18, $18         ; ..##..
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $00, $00

; Tile $16: '-' (dash)
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $7E, $7E         ; ######
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00
    .byte $00, $00

; Tile $17: coin icon (small circle)
    .byte $3C, $3C         ; .####.
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $66, $66         ; ##..##
    .byte $3C, $3C         ; .####.
    .byte $00, $00

hud_font_data_end:
HUD_FONT_SIZE = hud_font_data_end - hud_font_data
