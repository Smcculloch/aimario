#pragma once
#include "types.h"
#include <string>

struct InputManager;
struct SpriteGenerator;

struct Mario {
    PhysicsBody body;
    bool active = true;
    bool facingRight = true;
    PowerState power = PowerState::Small;
    bool isDead = false;
    bool isInvincible = false;
    bool hasStar = false;
    bool isDucking = false;
    bool reachedFlag = false;
    bool visible = true;

    float invincibleTimer = 0;
    float starTimer = 0;
    float deathTimer = 0;
    bool deathBounce = false;
    float blinkTimer = 0;
    float walkAnimTimer = 0;

    Mario();
    void Reset(float x, float y);
    void UpdateInput(float dt, const InputManager& input);
    void Die();
    void TakeDamage();
    void CollectMushroom();
    void CollectFireFlower();
    void CollectStar();
    std::string GetTextureName() const;

private:
    void UpdateDeath(float dt);
    void UpdateFlagSlide(float dt);
};
