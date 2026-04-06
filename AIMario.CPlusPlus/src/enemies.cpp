#include "enemies.h"
#include "collision.h"
#include "constants.h"

Enemy Enemy::NewGoomba() {
    Enemy e;
    e.body.width = 14; e.body.height = 16;
    e.body.vx = -GOOMBA_SPEED;
    e.enemyType = EnemyTypeId::Goomba;
    return e;
}

Enemy Enemy::NewKoopa() {
    Enemy e;
    e.body.width = 14; e.body.height = 24;
    e.body.vx = -KOOPA_SPEED;
    e.enemyType = EnemyTypeId::Koopa;
    return e;
}

void Enemy::Update(float dt, const std::vector<std::vector<Tile>>& tiles) {
    if (enemyType == EnemyTypeId::Goomba) UpdateGoomba(dt, tiles);
    else UpdateKoopa(dt, tiles);
}

void Enemy::UpdateGoomba(float dt, const std::vector<std::vector<Tile>>& tiles) {
    if (flat) {
        flatTimer += dt;
        if (flatTimer > 0.5f) active = false;
        return;
    }
    if (isStomped) {
        body.vy += GRAVITY;
        body.x += body.vx; body.y += body.vy;
        deathTimer += dt;
        if (deathTimer > 2.0f) active = false;
        return;
    }
    animTimer += dt;
    turnCooldown -= dt;
    body.ApplyPhysics();
    auto result = MoveAndCollide(body, tiles);
    if ((result.hitLeft || result.hitRight) && turnCooldown <= 0) {
        body.vx = result.hitLeft ? GOOMBA_SPEED : -GOOMBA_SPEED;
        turnCooldown = 0.1f;
    }
    if (body.y > LEVEL_HEIGHT_TILES * TILE_SIZE) active = false;
}

void Enemy::UpdateKoopa(float dt, const std::vector<std::vector<Tile>>& tiles) {
    if (isStomped && !isShell) {
        body.vy += GRAVITY;
        body.x += body.vx; body.y += body.vy;
        deathTimer += dt;
        if (deathTimer > 2.0f) active = false;
        return;
    }
    animTimer += dt;
    shellKickCooldown -= dt;
    turnCooldown -= dt;
    body.ApplyPhysics();
    auto result = MoveAndCollide(body, tiles);
    if ((result.hitLeft || result.hitRight) && turnCooldown <= 0) {
        float speed = shellMoving ? SHELL_SPEED : KOOPA_SPEED;
        body.vx = result.hitLeft ? speed : -speed;
        facingRight = body.vx > 0;
        turnCooldown = 0.1f;
    }
    if (body.y > LEVEL_HEIGHT_TILES * TILE_SIZE) active = false;
}

void Enemy::OnStompedGoomba() {
    flat = true; isStomped = true; flatTimer = 0;
    body.vx = 0;
    body.y += body.height - 2;
    body.height = 2;
}

void Enemy::OnStompedKoopa(float marioX) {
    if (!isShell) {
        isShell = true; shellMoving = false;
        body.vx = 0; body.height = 16;
        body.y += 8; shellKickCooldown = 0.2f;
    } else if (!shellMoving && shellKickCooldown <= 0) {
        KickShell(marioX < body.x);
    } else if (shellMoving) {
        shellMoving = false; body.vx = 0;
        shellKickCooldown = 0.2f;
    }
}

void Enemy::KickShell(bool kickRight) {
    shellMoving = true;
    body.vx = kickRight ? SHELL_SPEED : -SHELL_SPEED;
    shellKickCooldown = 0.2f;
}

void Enemy::KillByHit() {
    isStomped = true;
    body.vy = -3.0f;
}

const char* Enemy::GetTextureName() const {
    if (enemyType == EnemyTypeId::Goomba) {
        if (flat) return "goomba_flat";
        return ((int)(animTimer * 4) % 2 == 0) ? "goomba0" : "goomba1";
    } else {
        if (isShell) return "koopa_shell";
        return ((int)(animTimer * 4) % 2 == 0) ? "koopa0" : "koopa1";
    }
}

bool Enemy::IntersectsBody(const PhysicsBody& other) const {
    return active && BodiesIntersect(body, other);
}
