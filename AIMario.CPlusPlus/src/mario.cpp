#include "mario.h"
#include "types.h"
#include "constants.h"
#include "sprites.h"
#include <cmath>
#include <string>

Mario::Mario() {
    body.width = 14; body.height = 16;
}

void Mario::Reset(float rx, float ry) {
    body.x = rx; body.y = ry;
    body.vx = 0; body.vy = 0;
    body.onGround = false; body.applyGravity = true;
    power = PowerState::Small;
    body.width = 14; body.height = 16;
    isDead = false; isInvincible = false; hasStar = false;
    isDucking = false; reachedFlag = false;
    facingRight = true; active = true; visible = true;
    deathTimer = 0; deathBounce = false; walkAnimTimer = 0;
}

void Mario::UpdateInput(float dt, const InputManager& input) {
    if (isDead) { UpdateDeath(dt); return; }
    if (reachedFlag) { UpdateFlagSlide(dt); return; }

    // Invincibility flashing
    if (isInvincible && !hasStar) {
        invincibleTimer -= dt;
        blinkTimer += dt;
        visible = ((int)(blinkTimer * 10.0f)) % 2 == 0;
        if (invincibleTimer <= 0) { isInvincible = false; visible = true; }
    }

    // Star timer
    if (hasStar) {
        starTimer -= dt;
        blinkTimer += dt;
        visible = ((int)(blinkTimer * 15.0f)) % 2 == 0;
        if (starTimer <= 0) { hasStar = false; isInvincible = false; visible = true; }
    }

    // Horizontal movement
    float maxSpeed = input.run ? RUN_MAX_SPEED : WALK_MAX_SPEED;
    float accel = input.run ? RUN_ACCEL : WALK_ACCEL;

    if (input.left) {
        body.vx -= accel;
        if (body.vx < -maxSpeed) body.vx = -maxSpeed;
        facingRight = false;
    } else if (input.right) {
        body.vx += accel;
        if (body.vx > maxSpeed) body.vx = maxSpeed;
        facingRight = true;
    } else {
        if (body.vx > 0) { body.vx -= FRICTION; if (body.vx < 0) body.vx = 0; }
        else if (body.vx < 0) { body.vx += FRICTION; if (body.vx > 0) body.vx = 0; }
    }

    // Ducking
    if (power != PowerState::Small && body.onGround && input.down) {
        if (!isDucking) { isDucking = true; body.height = 16; body.y += 16; }
    } else if (isDucking) {
        isDucking = false; body.height = 32; body.y -= 16;
    }

    // Jump
    if (input.jumpPressed && body.onGround) {
        float jumpVel = (fabsf(body.vx) > WALK_MAX_SPEED) ? JUMP_VELOCITY_RUN : JUMP_VELOCITY_WALK;
        body.vy = jumpVel;
        body.onGround = false;
    }

    // Variable jump height
    if (!input.jump && body.vy < JUMP_RELEASE_CAP) {
        body.vy = JUMP_RELEASE_CAP;
    }

    body.ApplyPhysics();

    // Walk animation
    if (fabsf(body.vx) > 0.1f && body.onGround) {
        walkAnimTimer += fabsf(body.vx) * dt;
    } else if (body.onGround) {
        walkAnimTimer = 0;
    }
}

void Mario::UpdateDeath(float dt) {
    deathTimer += dt;
    if (!deathBounce && deathTimer > 0.5f) {
        body.vy = -5.0f;
        deathBounce = true;
    }
    if (deathBounce) {
        body.vy += GRAVITY;
        body.y += body.vy;
    }
}

void Mario::UpdateFlagSlide(float) {
    body.vx = 0;
    body.vy = 2.0f;
    body.y += body.vy;
    float groundY = (LEVEL_HEIGHT_TILES - 2) * (float)TILE_SIZE - body.height;
    if (body.y >= groundY) { body.y = groundY; body.vy = 0; }
}

void Mario::Die() {
    if (isDead) return;
    isDead = true;
    deathTimer = 0; deathBounce = false;
    body.vx = 0; body.vy = 0;
    body.applyGravity = false;
    active = true;
}

void Mario::TakeDamage() {
    if (isInvincible || isDead) return;
    if (power == PowerState::Fire || power == PowerState::Big) {
        power = PowerState::Small;
        body.height = 16;
        isInvincible = true;
        invincibleTimer = 2.0f;
        blinkTimer = 0;
    } else {
        Die();
    }
}

void Mario::CollectMushroom() {
    if (power == PowerState::Small) {
        power = PowerState::Big;
        body.height = 32; body.y -= 16;
    }
}

void Mario::CollectFireFlower() {
    if (power == PowerState::Small) {
        power = PowerState::Big;
        body.height = 32; body.y -= 16;
    }
    power = PowerState::Fire;
}

void Mario::CollectStar() {
    hasStar = true; isInvincible = true;
    starTimer = 10.0f; blinkTimer = 0;
}

std::string Mario::GetTextureName() const {
    const char* prefix = (power == PowerState::Fire) ? "mario_fire" :
                         (power == PowerState::Big) ? "mario_big" : "mario_small";
    if (isDead) return "mario_small_death";
    if (isDucking) return std::string(prefix) + "_duck";
    if (!body.onGround) return std::string(prefix) + "_jump";
    if (fabsf(body.vx) > 0.1f) {
        int frame = ((int)(walkAnimTimer * 8.0f)) % 3 + 1;
        return std::string(prefix) + "_walk" + std::to_string(frame);
    }
    return std::string(prefix) + "_stand";
}
