#pragma once

// Screen
constexpr int NES_WIDTH = 256;
constexpr int NES_HEIGHT = 240;
constexpr int WINDOW_SCALE = 3;
constexpr int WINDOW_WIDTH = NES_WIDTH * WINDOW_SCALE;
constexpr int WINDOW_HEIGHT = NES_HEIGHT * WINDOW_SCALE;

// Tiles
constexpr int TILE_SIZE = 16;

// Level
constexpr int LEVEL_WIDTH_TILES = 224;
constexpr int LEVEL_HEIGHT_TILES = 15;

// Physics
constexpr float GRAVITY = 0.28f;
constexpr float MAX_FALL_SPEED = 5.0f;

// Mario movement
constexpr float WALK_ACCEL = 0.1f;
constexpr float WALK_MAX_SPEED = 1.5f;
constexpr float RUN_ACCEL = 0.1f;
constexpr float RUN_MAX_SPEED = 2.5f;
constexpr float FRICTION = 0.15f;
constexpr float JUMP_VELOCITY_WALK = -6.3f;
constexpr float JUMP_VELOCITY_RUN = -7.2f;
constexpr float JUMP_RELEASE_CAP = -2.0f;

// Enemy
constexpr float GOOMBA_SPEED = 0.5f;
constexpr float KOOPA_SPEED = 0.5f;
constexpr float SHELL_SPEED = 3.0f;
constexpr float FIREBALL_SPEED = 3.0f;
constexpr float FIREBALL_GRAVITY = 0.3f;
constexpr float FIREBALL_BOUNCE = -3.5f;

// Items
constexpr float MUSHROOM_SPEED = 1.0f;
constexpr float STAR_SPEED = 1.5f;
constexpr float STAR_BOUNCE = -4.0f;

// Scoring
constexpr int SCORE_COIN = 200;
constexpr int SCORE_GOOMBA = 100;
constexpr int SCORE_KOOPA = 100;
constexpr int SCORE_MUSHROOM = 1000;
constexpr int SCORE_FIRE_FLOWER = 1000;
constexpr int SCORE_STAR = 1000;
constexpr int SCORE_BRICK = 50;
constexpr int SCORE_FLAG_BASE = 100;

// Timer
constexpr float LEVEL_TIME = 400.0f;
constexpr float TIMER_TICK_RATE = 0.4f;

// Lives
constexpr int STARTING_LIVES = 3;

// Underground / Pipe transitions
constexpr int UNDERGROUND_WIDTH_TILES = 16;
constexpr int PIPE_ENTRY_X = 46;
constexpr int PIPE_ENTRY_TOP_Y = 9;
constexpr int PIPE_EXIT_RETURN_X = 163;
constexpr float PIPE_ANIM_DURATION = 0.5f;
