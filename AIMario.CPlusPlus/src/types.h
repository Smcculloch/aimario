#pragma once
#include "raylib.h"
#include "constants.h"
#include <cmath>
#include <algorithm>

// ---- Enums ----

enum class GameState { Title, Playing, Death, GameOver, LevelComplete };
enum class TileType { Empty=0, Ground=1, Brick=2, Question=3, QuestionUsed=4, HardBlock=5,
    PipeTopLeft=6, PipeTopRight=7, PipeBodyLeft=8, PipeBodyRight=9,
    Invisible=10, FlagPole=11, FlagTop=12 };
enum class ItemContent { None, Coin, Mushroom, Star, OneUp, MultiCoin };
enum class PowerState { Small, Big, Fire };
enum class EnemyTypeId { Goomba, Koopa };
enum class ItemTypeId { Coin, Mushroom, OneUp, FireFlower, Star };

inline TileType TileTypeFromInt(int v) {
    if (v >= 0 && v <= 12) return static_cast<TileType>(v);
    return TileType::Empty;
}

// ---- GameStateManager ----

struct GameStateManager {
    GameState currentState = GameState::Title;
    float stateTimer = 0.0f;
    void SetState(GameState s) { currentState = s; stateTimer = 0.0f; }
    void Update(float dt) { stateTimer += dt; }
};

// ---- PhysicsBody ----

struct PhysicsBody {
    float x=0, y=0, vx=0, vy=0;
    float width=0, height=0;
    bool onGround = false;
    bool applyGravity = true;

    float Left() const { return x; }
    float Right() const { return x + width; }
    float Top() const { return y; }
    float Bottom() const { return y + height; }

    void ApplyPhysics() {
        if (applyGravity) {
            vy += GRAVITY;
            if (vy > MAX_FALL_SPEED) vy = MAX_FALL_SPEED;
        }
    }
};

inline bool BodiesIntersect(const PhysicsBody& a, const PhysicsBody& b) {
    return a.Left() < b.Right() && a.Right() > b.Left() &&
           a.Top() < b.Bottom() && a.Bottom() > b.Top();
}

// ---- Tile ----

struct Tile {
    TileType type = TileType::Empty;
    int gridX = 0, gridY = 0;
    ItemContent content = ItemContent::None;
    bool isHit = false;
    float bumpOffset = 0.0f;
    float animTimer = 0.0f;

    bool IsSolid() const {
        switch (type) {
            case TileType::Empty: return false;
            case TileType::FlagPole: return false;
            case TileType::FlagTop: return false;
            case TileType::Invisible: return isHit;
            default: return true;
        }
    }

    void Update(float dt) {
        if (type == TileType::Question) animTimer += dt;
        if (bumpOffset < 0.0f) {
            bumpOffset += 0.5f;
            if (bumpOffset > 0.0f) bumpOffset = 0.0f;
        }
    }

    int GetAnimFrame() const {
        if (type != TileType::Question) return 0;
        float cycle = fmodf(animTimer, 1.0f);
        if (cycle < 0.5f) return 0;
        if (cycle < 0.65f) return 1;
        if (cycle < 0.8f) return 2;
        return 1;
    }

    float BoundsX() const { return gridX * (float)TILE_SIZE; }
    float BoundsY() const { return gridY * (float)TILE_SIZE; }
};

// ---- Camera ----

struct GameCamera {
    float x = 0.0f;
    float maxX = 0.0f;

    void Init(float levelWidth) { maxX = levelWidth - NES_WIDTH; x = 0; }
    void Follow(float targetX) {
        float desired = targetX - NES_WIDTH / 2.0f;
        if (desired > x) x = desired;
        if (x < 0) x = 0;
        if (x > maxX) x = maxX;
    }
    bool IsVisible(float ex, float w) const {
        return ex + w > x - 16 && ex < x + NES_WIDTH + 16;
    }
    void Reset() { x = 0; }
};

// ---- InputManager ----

struct InputManager {
    bool left=false, right=false, down=false;
    bool downPressed=false;
    bool jump=false, jumpPressed=false;
    bool run=false, runPressed=false;
    bool start=false;

    void Update() {
        left = IsKeyDown(KEY_LEFT);
        right = IsKeyDown(KEY_RIGHT);
        down = IsKeyDown(KEY_DOWN);
        downPressed = IsKeyPressed(KEY_DOWN);
        jump = IsKeyDown(KEY_Z) || IsKeyDown(KEY_SPACE);
        jumpPressed = IsKeyPressed(KEY_Z) || IsKeyPressed(KEY_SPACE);
        run = IsKeyDown(KEY_X) || IsKeyDown(KEY_LEFT_SHIFT);
        runPressed = IsKeyPressed(KEY_X) || IsKeyPressed(KEY_LEFT_SHIFT);
        start = IsKeyPressed(KEY_ENTER);
    }
};

// ---- ScorePopup / BrickDebris ----

struct ScorePopup {
    int amount; float x, y, timer;
};

struct BrickDebris {
    float x, y, vx, vy;
    bool active = true;
    void Update(float) {
        vy += GRAVITY; x += vx; y += vy;
        if (y > LEVEL_HEIGHT_TILES * TILE_SIZE) active = false;
    }
};
