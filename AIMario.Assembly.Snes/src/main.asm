; =============================================================================
; Main Loop + NMI Handler
; =============================================================================

.include "registers.inc"
.include "constants.inc"
.include "macros.inc"

.importzp joy1_raw, joy1_press, joy1_held
.importzp mario_x_sub, mario_x_lo, mario_x_hi
.importzp mario_y_sub, mario_y_lo, mario_y_hi
.importzp mario_vx_lo, mario_vx_hi, mario_vy_lo, mario_vy_hi
.importzp mario_state, mario_anim, mario_dir, mario_on_ground
.importzp mario_anim_frame, mario_anim_timer, mario_jump_held
.importzp camera_x_lo, camera_x_hi
.importzp frame_counter, nmi_ready, game_state
.importzp scroll_col_drawn
.importzp score, coins, lives, timer, timer_tick, hud_dirty
.importzp temp0, temp1, temp2, temp3, temp4, temp5, temp6, temp7
.importzp ptr0, ptr0h
.importzp tile_upd_col, tile_upd_row, tile_upd_type, tile_upd_pending

.import ReadJoypad
.import Mario_Update
.import Camera_Update
.import Sprites_Begin, Sprites_DrawMario, Sprites_Finish
.import Sprites_DrawItems
.import DMA_TransferOAM
.import oam_buf, oam_buf_hi
.import Level_Init, Level_StreamColumn, Level_CopyToRAM
.import Upload_Palette, Upload_BG_Tiles, Upload_Sprite_Tiles
.import Upload_Initial_Tilemap
.import Items_Update
.import HUD_Init, HUD_Upload, Timer_Update
.import TileUpdate_Apply

.export Main_Init, NMI_Handler

.segment "CODE"

; =============================================================================
; Main_Init — called after hardware init
; =============================================================================
.proc Main_Init
    ; Upload graphics data to VRAM
    jsr Upload_BG_Tiles
    jsr Upload_Sprite_Tiles
    jsr Upload_Palette

    ; Mode 1: BG1=4bpp, BG2=4bpp, BG3=2bpp
    ; Bit 3 = BG3 priority (puts BG3 in front of everything in Mode 1)
    lda #$09
    sta BGMODE

    ; BG1 tilemap at VRAM $4000, 64 tiles wide (bit 0 set)
    lda #$41
    sta BG1SC

    ; BG3 tilemap at VRAM $2800, 32 tiles wide
    ; BG3SC = (VRAM_addr / $400) << 2 | size
    ; $2800 / $400 = $0A, so reg = $0A << 2 = $28
    lda #$28
    sta BG3SC

    ; BG1 chr at VRAM $0000
    lda #$00
    sta BG12NBA

    ; BG3 chr at VRAM $2000 (2bpp tiles for HUD font)
    ; BG34NBA: low nibble = BG3 base / $1000, high nibble = BG4
    lda #$02
    sta BG34NBA

    ; Sprite chr at VRAM $6000, 8x8/16x16 size
    lda #$03
    sta OBSEL

    ; Enable BG1 + BG3 + sprites on main screen
    ; BG1=$01, BG3=$04, OBJ=$10 → $15
    lda #$15
    sta TM

    ; --- Initialize game state ---
    lda #GSTATE_PLAYING
    sta game_state

    ; Mario starting position: pixel (40, 176)
    stz mario_x_sub
    lda #MARIO_START_X
    sta mario_x_lo
    stz mario_x_hi              ; high byte = 0 (x < 256)

    stz mario_y_sub
    lda #MARIO_START_Y
    sta mario_y_lo
    stz mario_y_hi

    ; Clear velocities
    stz mario_vx_lo
    stz mario_vx_hi
    stz mario_vy_lo
    stz mario_vy_hi

    ; Mario state
    lda #MSTATE_SMALL
    sta mario_state
    lda #MANIM_STAND
    sta mario_anim
    lda #DIR_RIGHT
    sta mario_dir
    lda #$01
    sta mario_on_ground
    stz mario_anim_frame
    lda #WALK_ANIM_SPEED
    sta mario_anim_timer
    stz mario_jump_held

    ; Camera starts at 0
    stz camera_x_lo
    stz camera_x_hi

    ; Initialize level data
    jsr Level_Init
    jsr Level_CopyToRAM

    ; Initialize HUD (upload font tiles, write static tilemap)
    jsr HUD_Init

    ; Upload initial visible columns to tilemap
    jsr Upload_Initial_Tilemap

    ; Track which column we've drawn (0-16 uploaded above)
    lda #16
    sta scroll_col_drawn

    ; Initialize game state
    lda #7
    sta lives                   ; set to 7 to verify correct ROM is loaded
    stz coins
    stz score
    stz score+1
    stz score+2
    ; timer = 400 ($0190)
    lda #$90
    sta timer
    lda #$01
    sta timer+1
    stz timer_tick
    lda #$01
    sta hud_dirty
    stz tile_upd_pending

    ; Pre-fill OAM buffer with Y=$F0 BEFORE enabling NMI
    ; This ensures even the first DMA transfer shows no garbage sprites
    SetAXY_8_16
    ldx #$0000
@prefill_oam:
    stz oam_buf,x               ; X pos = 0
    inx
    lda #$F0
    sta oam_buf,x               ; Y pos = $F0 (offscreen)
    inx
    stz oam_buf,x               ; tile = 0
    inx
    stz oam_buf,x               ; attr = 0
    inx
    cpx #$0200
    bne @prefill_oam
    ldx #$0000
@prefill_hi:
    stz oam_buf_hi,x
    inx
    cpx #$0020
    bne @prefill_hi

    ; Enable NMI + joypad auto-read
    lda #$81
    sta NMITIMEN

    ; Turn on screen (full brightness)
    lda #$0F
    sta INIDISP

    ; --- Main game loop ---
MainLoop:
    lda #$01
    sta nmi_ready
@wait_nmi:
    wai
    lda nmi_ready
    bne @wait_nmi

    ; --- Game logic ---
    jsr ReadJoypad
    jsr Mario_Update
    jsr Camera_Update
    jsr Items_Update
    jsr Timer_Update

    ; --- Sprite drawing ---
    jsr Sprites_Begin
    jsr Sprites_DrawMario
    jsr Sprites_DrawItems

    inc frame_counter
    jmp MainLoop
.endproc

; =============================================================================
; NMI_Handler — VBlank interrupt
; =============================================================================
.proc NMI_Handler
    ; Save registers in 16-bit mode for consistent push/pull sizes
    rep #$30                    ; force A=16, XY=16
    .a16
    .i16
    pha                         ; 2 bytes
    phx                         ; 2 bytes
    phy                         ; 2 bytes
    phb                         ; 1 byte (always)
    phd                         ; 2 bytes (always)

    ; Set known register modes for handler body
    sep #$20                    ; A=8
    .a8

    ; Set data bank to $00
    lda #$00
    pha
    plb

    ; Set direct page to $0000
    rep #$20
    .a16
    lda #$0000
    tcd
    sep #$20
    .a8

    ; Acknowledge NMI
    lda RDNMI

    ; Only do VBlank work if main loop signals ready
    lda nmi_ready
    beq @done

    ; --- VBlank work ---

    ; 1. DMA sprite data to OAM
    jsr DMA_TransferOAM

    ; 2. BG1 scroll from camera position
    lda camera_x_lo
    sta BG1HOFS
    lda camera_x_hi
    sta BG1HOFS
    stz BG1VOFS
    stz BG1VOFS

    ; 3. BG3 scroll (HUD is fixed, doesn't scroll)
    stz BG3HOFS
    stz BG3HOFS
    stz BG3VOFS
    stz BG3VOFS

    ; 4-6: VRAM routines (save/restore temp vars they clobber)
    rep #$20
    .a16
    lda temp0
    pha
    lda temp2
    pha
    lda temp4
    pha
    lda temp6
    pha
    lda ptr0
    pha
    sep #$20
    .a8

    jsr HUD_Upload
    jsr TileUpdate_Apply
    ; Level_StreamColumn disabled — too heavy for VBlank, needs DMA rewrite

    rep #$20
    .a16
    pla
    sta ptr0
    pla
    sta temp6
    pla
    sta temp4
    pla
    sta temp2
    pla
    sta temp0
    sep #$20
    .a8

    ; Signal main loop
    stz nmi_ready

@done:
    ; Restore registers in same 16-bit mode used for pushing
    rep #$30
    .a16
    .i16
    pld
    plb
    ply
    plx
    pla
    rti
.endproc
