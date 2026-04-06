; =============================================================================
; WRAM Variable Declarations (Zero Page + Low RAM)
; =============================================================================

; Position format: 24-bit = sub(8) + lo(8) + hi(8)
; sub = fractional pixel, lo+hi = 16-bit pixel coordinate
; Velocity format: 16-bit signed 8.8 fixed-point

; --- Zero Page ($00-$6F) — fast access ---
.globalzp joy1_raw, joy1_press, joy1_held
.globalzp mario_x_sub, mario_x_lo, mario_x_hi
.globalzp mario_y_sub, mario_y_lo, mario_y_hi
.globalzp mario_vx_lo, mario_vx_hi
.globalzp mario_vy_lo, mario_vy_hi
.globalzp mario_state, mario_anim, mario_dir, mario_on_ground
.globalzp mario_anim_frame, mario_anim_timer
.globalzp camera_x_lo, camera_x_hi
.globalzp frame_counter, nmi_ready, game_state
.globalzp temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7
.globalzp ptr0, ptr0h, ptr1, ptr1h
.globalzp scroll_col_drawn
.globalzp mario_jump_held

.segment "ZEROPAGE"

; Joypad state (16-bit each)
joy1_raw:       .res 2          ; $00 current frame raw
joy1_press:     .res 2          ; $02 newly pressed this frame
joy1_held:      .res 2          ; $04 previous frame (for edge detection)

; Mario position: 24-bit (sub + lo + hi)
; sub = fractional, lo+hi = 16-bit pixel position
mario_x_sub:    .res 1          ; $06 sub-pixel X
mario_x_lo:     .res 1          ; $07 pixel X low byte
mario_x_hi:     .res 1          ; $08 pixel X high byte
mario_y_sub:    .res 1          ; $09 sub-pixel Y
mario_y_lo:     .res 1          ; $0A pixel Y low byte
mario_y_hi:     .res 1          ; $0B pixel Y high byte (usually 0)

; Mario velocity (16-bit signed 8.8 fixed-point)
; hi byte = signed pixel delta, lo byte = sub-pixel delta
mario_vx_lo:    .res 1          ; $0C
mario_vx_hi:    .res 1          ; $0D
mario_vy_lo:    .res 1          ; $0E
mario_vy_hi:    .res 1          ; $0F

; Mario gameplay state
mario_state:    .res 1          ; $10 small/big/fire
mario_anim:     .res 1          ; $11 current animation
mario_dir:      .res 1          ; $12 facing direction
mario_on_ground:.res 1          ; $13 nonzero = on ground
mario_anim_frame:.res 1         ; $14 walk frame index (0-2)
mario_anim_timer:.res 1         ; $15 walk frame countdown
mario_jump_held:.res 1          ; $16 nonzero = jump button still held

; Camera (16-bit pixel X position)
camera_x_lo:    .res 1          ; $17
camera_x_hi:    .res 1          ; $18

; System
frame_counter:  .res 1          ; $19
nmi_ready:      .res 1          ; $1A set by main loop, cleared by NMI
game_state:     .res 1          ; $1B

; Scratch registers
temp0:          .res 1          ; $1C
temp1:          .res 1          ; $1D
temp2:          .res 1          ; $1E
temp3:          .res 1          ; $1F
temp4:          .res 2          ; $20 (16-bit temp)
temp5:          .res 1          ; $22
temp6:          .res 1          ; $23
temp7:          .res 1          ; $24

; Pointers
ptr0:           .res 1          ; $25
ptr0h:          .res 1          ; $26
ptr1:           .res 1          ; $27
ptr1h:          .res 1          ; $28

; Scroll column tracking
scroll_col_drawn: .res 1        ; $29 last metatile column uploaded

; Score / HUD state
.globalzp score, coins, lives, timer, timer_tick, hud_dirty
score:          .res 3          ; $2A-$2C 24-bit BCD (6 digits: 000000-999999)
coins:          .res 1          ; $2D binary 0-99
lives:          .res 1          ; $2E binary 0-9
timer:          .res 2          ; $2F-$30 16-bit binary countdown from 400
timer_tick:     .res 1          ; $31 sub-frame accumulator
hud_dirty:      .res 1          ; $32 nonzero = HUD needs VRAM update

; Tile update queue (single tile update per frame for block hits)
.globalzp tile_upd_col, tile_upd_row, tile_upd_type, tile_upd_pending
tile_upd_col:   .res 1          ; $33 metatile column to update
tile_upd_row:   .res 1          ; $34 metatile row
tile_upd_type:  .res 1          ; $35 new metatile type
tile_upd_pending: .res 1        ; $36 nonzero = tile update queued

; --- Low RAM (not zero-page) ---
.global oam_buf, oam_buf_hi, oam_index
.global item_active, item_type, item_x_lo, item_x_hi
.global item_y_lo, item_y_hi, item_vy_lo, item_vy_hi
.global item_vx_lo, item_vx_hi, item_timer, item_dir
.global level_ram

.segment "BSS"

; OAM shadow buffer (512 + 32 = 544 bytes)
oam_buf:        .res 512
oam_buf_hi:     .res 32

; OAM index tracking
oam_index:      .res 1

; Item slots (4 items max)
item_active:    .res 4          ; nonzero = slot in use
item_type:      .res 4          ; ITEM_COIN / ITEM_MUSHROOM
item_x_lo:      .res 4          ; 16-bit world X (lo byte)
item_x_hi:      .res 4          ; 16-bit world X (hi byte)
item_y_lo:      .res 4          ; 16-bit world Y (lo byte)
item_y_hi:      .res 4          ; 16-bit world Y (hi byte)
item_vx_lo:     .res 4          ; 8.8 horizontal velocity (lo)
item_vx_hi:     .res 4          ; 8.8 horizontal velocity (hi)
item_vy_lo:     .res 4          ; 8.8 vertical velocity (lo)
item_vy_hi:     .res 4          ; 8.8 vertical velocity (hi)
item_timer:     .res 4          ; generic timer (popup duration, etc)
item_dir:       .res 4          ; movement direction

; Level data RAM copy (mutable — for block hits)
; Must be in BSS (LORAM $0200-$1FFF) so it's accessible via WRAM mirror
; (HIBSS at $2000+ maps to PPU registers in bank $00, not WRAM!)
level_ram:      .res 3136       ; 224 cols × 14 rows
