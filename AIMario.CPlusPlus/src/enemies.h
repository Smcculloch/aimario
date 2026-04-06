#pragma once
#include "types.h"
#include <vector>
#include <string>

struct SpriteGenerator;

struct Enemy {
    PhysicsBody body;
    bool active = true;
    bool facingRight = false;
    bool isStomped = false;
    EnemyTypeId enemyType;
    bool canBeStomped = true;

    // Goomba
    bool flat = false;
    float flatTimer = 0;
    float turnCooldown = 0;

    // Koopa
    bool isShell = false;
    bool shellMoving = false;
    float shellKickCooldown = 0;

    float animTimer = 0;
    float deathTimer = 0;

    static Enemy NewGoomba();
    static Enemy NewKoopa();

    void Update(float dt, const std::vector<std::vector<Tile>>& tiles);
    void OnStompedGoomba();
    void OnStompedKoopa(float marioX);
    void KickShell(bool kickRight);
    void KillByHit();
    const char* GetTextureName() const;
    bool IntersectsBody(const PhysicsBody& other) const;

private:
    void UpdateGoomba(float dt, const std::vector<std::vector<Tile>>& tiles);
    void UpdateKoopa(float dt, const std::vector<std::vector<Tile>>& tiles);
};
