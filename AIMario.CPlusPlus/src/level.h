#pragma once
#include "types.h"
#include "mario.h"
#include "enemies.h"
#include "items.h"
#include "fireball.h"
#include "sprites.h"
#include <vector>
#include <string>

enum class LevelArea { Overworld, Underground };
enum class PipeState { None, EnteringPipe, ExitingPipe };

struct Level {
    Mario mario;
    GameCamera cam;
    std::vector<std::vector<Tile>> tiles;
    std::vector<Enemy> enemies;
    std::vector<Item> items;
    std::vector<Fireball> fireballs;
    std::vector<ScorePopup> scorePopups;
    std::vector<BrickDebris> debris;

    int score = 0;
    int coins = 0;
    int lives = STARTING_LIVES;
    float timer = LEVEL_TIME;
    float timerAccum = 0;
    bool levelComplete = false;
    float fireballCooldown = 0;

    bool flagDescending = false;
    float flagY = 0;
    float flagTargetY = 0;

    // Underground / pipe transitions
    LevelArea currentArea = LevelArea::Overworld;
    std::vector<std::vector<Tile>> overworldTiles;
    std::vector<std::vector<Tile>> undergroundTiles;
    std::vector<Enemy> overworldEnemies;
    PipeState pipeState = PipeState::None;
    float pipeTimer = 0.0f;
    float savedCameraX = 0.0f;

    Level();
    void Load();
    void Reset();
    void Update(float dt, const InputManager& input);
    void Draw(const SpriteGenerator& sprites, float camX) const;
    Color BackgroundColor() const;

    static void DrawText(const SpriteGenerator& sprites, const char* text, float x, float y, float scale);
    static void DrawTextColored(const SpriteGenerator& sprites, const char* text, float x, float y, float scale, Color color);

private:
    void HitBlock(int gridX, int gridY);
    void SpawnItemFromBlock(const Tile& tile);
    void BreakBrick(int gridX, int gridY);
    void AddScore(int amount, float x, float y);
    void CheckMarioEnemyCollisions();
    void CheckMarioItemCollisions();
    void CheckFlagpole();
    void CheckPipeEntry(const InputManager& input);
    void UpdatePipeTransition(float dt);
    void LoadUndergroundTiles();
    void DrawTile(const SpriteGenerator& sprites, const Tile& tile, float camX) const;
    void DrawEnemy(const SpriteGenerator& sprites, const Enemy& enemy, float camX) const;
    void DrawMario(const SpriteGenerator& sprites, float camX) const;
    void DrawTextAt(const SpriteGenerator& sprites, const char* text, float x, float y, float scale) const;
};
