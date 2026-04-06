// Screen
pub const NES_WIDTH: i32 = 256;
pub const NES_HEIGHT: i32 = 240;
pub const WINDOW_SCALE: i32 = 3;
pub const WINDOW_WIDTH: i32 = NES_WIDTH * WINDOW_SCALE;
pub const WINDOW_HEIGHT: i32 = NES_HEIGHT * WINDOW_SCALE;

// Tiles
pub const TILE_SIZE: i32 = 16;

// Level
pub const LEVEL_WIDTH_TILES: i32 = 224;
pub const LEVEL_HEIGHT_TILES: i32 = 15;

// Physics (per frame at 60 FPS)
pub const GRAVITY: f32 = 0.28;
pub const MAX_FALL_SPEED: f32 = 5.0;

// Mario movement
pub const WALK_ACCEL: f32 = 0.1;
pub const WALK_MAX_SPEED: f32 = 1.5;
pub const RUN_ACCEL: f32 = 0.1;
pub const RUN_MAX_SPEED: f32 = 2.5;
pub const FRICTION: f32 = 0.15;
pub const JUMP_VELOCITY_WALK: f32 = -6.3;
pub const JUMP_VELOCITY_RUN: f32 = -7.2;
pub const JUMP_RELEASE_CAP: f32 = -2.0;

// Enemy
pub const GOOMBA_SPEED: f32 = 0.5;
pub const KOOPA_SPEED: f32 = 0.5;
pub const SHELL_SPEED: f32 = 3.0;
pub const FIREBALL_SPEED: f32 = 3.0;
pub const FIREBALL_GRAVITY: f32 = 0.3;
pub const FIREBALL_BOUNCE: f32 = -3.5;

// Items
pub const MUSHROOM_SPEED: f32 = 1.0;
pub const STAR_SPEED: f32 = 1.5;
pub const STAR_BOUNCE: f32 = -4.0;

// Scoring
pub const SCORE_COIN: i32 = 200;
pub const SCORE_GOOMBA: i32 = 100;
pub const SCORE_KOOPA: i32 = 100;
pub const SCORE_MUSHROOM: i32 = 1000;
pub const SCORE_FIRE_FLOWER: i32 = 1000;
pub const SCORE_STAR: i32 = 1000;
pub const SCORE_BRICK: i32 = 50;
pub const SCORE_FLAG_BASE: i32 = 100;

// Timer
pub const LEVEL_TIME: f32 = 400.0;
pub const TIMER_TICK_RATE: f32 = 0.4;

// Lives
pub const STARTING_LIVES: i32 = 3;

// Underground
pub const UNDERGROUND_WIDTH_TILES: i32 = 16;
pub const PIPE_ENTRY_X: i32 = 46;
pub const PIPE_ENTRY_TOP_Y: i32 = 9;
pub const PIPE_EXIT_RETURN_X: i32 = 163;
pub const PIPE_ANIM_DURATION: f32 = 0.5;
