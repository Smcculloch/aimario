; =============================================================================
; WRAM Variable Declarations (Zero Page + Low RAM)
; =============================================================================

; Position format: 24-bit = sub(8) + lo(8) + hi(8)
; Velocity format: 16-bit signed 8.8 fixed-point

; --- Zero Page ($00-$FF) — fast access ---
.globalzp joy1_raw, joy1_press, joy1_held
.globalzp mario_x_sub, mario_x_lo, mario_x_hi
.globalzp mario_y_sub, mario_y_lo, mario_y_hi
.globalzp mario_vx_lo, mario_vx_hi
.globalzp mario_vy_lo, mario_vy_hi
.globalzp mario_dir, mario_on_ground
.globalzp mario_anim, mario_anim_frame, mario_anim_timer, mario_jump_held
.globalzp camera_x_lo, camera_x_hi
.globalzp score, coins, lives, timer, timer_tick, hud_dirty
.globalzp frame_counter, nmi_ready
.globalzp temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7
.globalzp ptr0, ptr0h, ptr1, ptr1h
.globalzp scroll_col_drawn
.globalzp tile_upd_col, tile_upd_row, tile_upd_type, tile_upd_pending

.segment "ZEROPAGE"

; Joypad state (16-bit each)
joy1_raw:       .res 2
joy1_press:     .res 2
joy1_held:      .res 2

; Mario position: 24-bit (sub + lo + hi)
mario_x_sub:    .res 1
mario_x_lo:     .res 1
mario_x_hi:     .res 1
mario_y_sub:    .res 1
mario_y_lo:     .res 1
mario_y_hi:     .res 1

; Mario velocity (16-bit signed 8.8 fixed-point)
mario_vx_lo:    .res 1
mario_vx_hi:    .res 1
mario_vy_lo:    .res 1
mario_vy_hi:    .res 1

; Mario gameplay state
mario_dir:      .res 1          ; facing direction
mario_on_ground:.res 1          ; nonzero = on ground
mario_anim:     .res 1          ; current animation (MANIM_*)
mario_anim_frame:.res 1         ; walk frame index (0-3)
mario_anim_timer:.res 1         ; walk frame countdown
mario_jump_held:.res 1          ; nonzero = jump button held (variable height)

; Camera (16-bit pixel X position)
camera_x_lo:    .res 1
camera_x_hi:    .res 1

; HUD state
score:          .res 3          ; 24-bit BCD (3 bytes = 6 digits)
coins:          .res 1          ; binary 0-99
lives:          .res 1          ; binary 0-9
timer:          .res 2          ; 16-bit binary countdown (400→0)
timer_tick:     .res 1          ; sub-frame counter for timer
hud_dirty:      .res 1          ; nonzero = HUD needs VRAM update

; System
frame_counter:  .res 1
nmi_ready:      .res 1

; Scratch registers
temp0:          .res 1
temp1:          .res 1
temp2:          .res 1
temp3:          .res 1
temp4:          .res 2          ; 16-bit temp
temp5:          .res 1
temp6:          .res 1
temp7:          .res 1

; Pointers
ptr0:           .res 1
ptr0h:          .res 1
ptr1:           .res 1
ptr1h:          .res 1

; Scroll column tracking
scroll_col_drawn: .res 1

; Tile update queue (for VBlank VRAM writes)
tile_upd_col:     .res 1        ; metatile column to update
tile_upd_row:     .res 1        ; metatile row to update
tile_upd_type:    .res 1        ; new tile type
tile_upd_pending: .res 1        ; nonzero = pending VRAM update

; --- Low RAM (not zero-page) ---
.global oam_buf, oam_buf_hi, oam_index
.global level_ram

.segment "BSS"

; OAM shadow buffer (512 + 32 = 544 bytes)
oam_buf:        .res 512
oam_buf_hi:     .res 32

; OAM index tracking
oam_index:      .res 1

; Level data RAM copy (mutable)
; Must be in BSS (LORAM $0200-$1FFF) so it's accessible via WRAM mirror
level_ram:      .res 3136       ; 224 cols x 14 rows
