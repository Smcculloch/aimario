; =============================================================================
; Game Constants — 8.8 Fixed-Point Physics + Tile/Sprite IDs
; =============================================================================

; --- Physics (8.8 fixed-point: high byte = pixels, low byte = sub-pixel) ---
GRAVITY         = $00C0         ; ~0.75 px/frame² (snappy gravity)
MAX_FALL_SPEED  = $0400         ; 4.0 px/frame

WALK_ACCEL      = $0098         ; ~0.59 px/frame² (very responsive)
WALK_MAX_SPEED  = $0200         ; 2.0 px/frame
RUN_ACCEL       = $0098         ; ~0.59 px/frame²
RUN_MAX_SPEED   = $0380         ; 3.5 px/frame
FRICTION        = $0098         ; ~0.59 px/frame² (quick stop)

JUMP_VEL_WALK   = $FB40         ; -4.75 (negative = upward)
JUMP_VEL_RUN    = $FA80         ; -5.50
JUMP_HOLD_GRAV  = $0030         ; reduced gravity while holding jump (floatier hold)

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
MARIO_HEIGHT_SM = 14            ; Small mario height
MARIO_HEIGHT_BG = 28            ; Big mario height
MARIO_START_X   = 40            ; Starting X position (world)
MARIO_START_Y   = 176           ; Starting Y position

; --- Tile IDs (metatile types) ---
TILE_EMPTY      = $00
TILE_GROUND     = $01
TILE_BRICK      = $02
TILE_QBLOCK     = $03
TILE_QBLOCK_HIT = $04
TILE_PIPE_TL    = $05
TILE_PIPE_TR    = $06
TILE_PIPE_BL    = $07
TILE_PIPE_BR    = $08
TILE_BLOCK      = $09           ; Solid decorative block
TILE_STAIR      = $0A           ; Staircase block
TILE_FLAG_POLE  = $0B
TILE_FLAG_TOP   = $0C
TILE_CASTLE     = $0D

; --- Sprite tile indices in VRAM ---
SPR_MARIO_SM_STAND  = $00
SPR_MARIO_SM_WALK1  = $02
SPR_MARIO_SM_WALK2  = $04
SPR_MARIO_SM_WALK3  = $06
SPR_MARIO_SM_JUMP   = $08
SPR_MARIO_SM_SKID   = $0A
SPR_MARIO_SM_DEAD   = $0C

; Big Mario bottom-half sprite tiles (top half reuses small Mario tiles)
SPR_MARIO_BG_STAND_BOT = $40
SPR_MARIO_BG_WALK1_BOT = $42
SPR_MARIO_BG_WALK2_BOT = $44
SPR_MARIO_BG_WALK3_BOT = $46
SPR_MARIO_BG_JUMP_BOT  = $48

; --- Palette indices ---
PAL_BG_SKY      = 0             ; BG palette 0: sky + ground
PAL_BG_BRICK    = 1             ; BG palette 1: brick/block
PAL_BG_PIPE     = 2             ; BG palette 2: pipes
PAL_BG_QBLOCK   = 3             ; BG palette 3: question blocks
PAL_SPR_MARIO   = 0             ; Sprite palette 0: Mario
PAL_SPR_ENEMY   = 1             ; Sprite palette 1: enemies
PAL_SPR_FIRE    = 2             ; Sprite palette 2: fireballs/star

; --- Mario states ---
MSTATE_SMALL    = 0
MSTATE_BIG      = 1
MSTATE_FIRE     = 2

; --- Mario animation ---
MANIM_STAND     = 0
MANIM_WALK      = 1
MANIM_JUMP      = 2
MANIM_SKID      = 3
MANIM_DEAD      = 4

; --- Game states ---
GSTATE_TITLE    = 0
GSTATE_PLAYING  = 1
GSTATE_DYING    = 2
GSTATE_GAMEOVER = 3
GSTATE_COMPLETE = 4

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

; --- Animation timing ---
WALK_ANIM_SPEED = 8             ; frames per walk animation frame
DEATH_ANIM_TIME = 90            ; frames for death animation

; --- Item types ---
ITEM_COIN       = 0             ; popup coin (visual only)
ITEM_MUSHROOM   = 1             ; grows Mario small→big

; --- Item constants ---
MAX_ITEMS       = 4             ; max simultaneous items
COIN_POPUP_TIME = 30            ; frames for coin popup animation
MUSHROOM_VX     = $0100         ; 1.0 px/frame horizontal (8.8)
MUSHROOM_GRAVITY = $0060        ; 0.375 px/frame² gravity for mushroom

; --- Score values (BCD) ---
SCORE_COIN      = $02           ; 200 points (BCD hundreds digit)
SCORE_BRICK     = $00           ; 50 points (BCD tens digit = 5)
SCORE_MUSHROOM  = $10           ; 1000 points (BCD thousands digit)

; --- Timer ---
TIMER_TICK_MAX  = 24            ; frames per timer tick (~0.4s at 60fps)
TIMER_START     = 400           ; starting timer value

; --- HUD ---
HUD_FONT_VRAM   = $2000         ; BG3 character base in VRAM (word addr)
HUD_MAP_VRAM    = $2800         ; BG3 tilemap in VRAM (word addr)
