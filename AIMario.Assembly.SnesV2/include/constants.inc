; =============================================================================
; Game Constants — 8.8 Fixed-Point Physics + Tile IDs
; =============================================================================

; --- Physics (8.8 fixed-point: high byte = pixels, low byte = sub-pixel) ---
GRAVITY         = $00C0         ; ~0.75 px/frame²
MAX_FALL_SPEED  = $0400         ; 4.0 px/frame

WALK_ACCEL      = $0098         ; ~0.59 px/frame²
WALK_MAX_SPEED  = $0200         ; 2.0 px/frame
FRICTION        = $0098         ; ~0.59 px/frame²

; --- Screen ---
SCREEN_WIDTH    = 256
SCREEN_HEIGHT   = 224
GROUND_Y        = 192           ; Ground level Y pixel (12 tiles * 16)

; --- Level ---
LEVEL_WIDTH_TILES  = 224        ; World 1-1 width in 16x16 metatiles
LEVEL_HEIGHT_TILES = 14         ; Height in 16x16 metatiles (224 pixels)
LEVEL_WIDTH_PX     = 3584       ; 224 * 16
LEVEL_HEIGHT_PX    = 224        ; 14 * 16
METATILE_SIZE      = 16         ; 16x16 pixels per metatile

; --- Mario ---
MARIO_WIDTH     = 12            ; Collision box width
MARIO_HEIGHT    = 14            ; Small mario height (only size in V2 step 1)
MARIO_START_X   = 40            ; Starting X position (world)
MARIO_START_Y   = 176           ; Starting Y position

; --- Tile IDs (metatile types) ---
TILE_EMPTY      = $00
TILE_GROUND     = $01
TILE_BRICK      = $02

; --- Sprite tile bases (16x16: base N uses N, N+1, N+16, N+17) ---
SPR_MARIO_STAND = $00
SPR_MARIO_WALK1 = $02
SPR_MARIO_WALK2 = $04
SPR_MARIO_WALK3 = $06
SPR_MARIO_JUMP  = $08

; --- Animation states ---
MANIM_STAND     = 0
MANIM_WALK      = 1
MANIM_JUMP      = 2

; --- Animation timing ---
WALK_ANIM_SPEED = 8             ; frames per walk animation frame

; --- Direction ---
DIR_RIGHT       = 0
DIR_LEFT        = 1

; --- Joypad bit masks (SNES standard) ---
JOY_B           = $8000
JOY_Y           = $4000
JOY_SELECT      = $2000
JOY_START       = $1000
JOY_UP          = $0800
JOY_DOWN        = $0400
JOY_LEFT        = $0200
JOY_RIGHT       = $0100
JOY_A           = $0080
JOY_X           = $0040
JOY_L           = $0020
JOY_R           = $0010
