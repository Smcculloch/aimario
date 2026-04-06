#include "fireball.h"
#include "collision.h"
#include "constants.h"

Fireball::Fireball(float x, float y, bool goRight) {
    body.x = x; body.y = y;
    body.width = 8; body.height = 8;
    body.vx = goRight ? FIREBALL_SPEED : -FIREBALL_SPEED;
    body.applyGravity = false;
}

void Fireball::Update(float dt, const std::vector<std::vector<Tile>>& tiles) {
    timer += dt;
    body.vy += FIREBALL_GRAVITY;
    if (body.vy > MAX_FALL_SPEED) body.vy = MAX_FALL_SPEED;

    auto result = MoveAndCollide(body, tiles);
    if (result.hitLeft || result.hitRight) { active = false; return; }
    if (result.hitBottom) body.vy = FIREBALL_BOUNCE;
    if (body.y > LEVEL_HEIGHT_TILES * TILE_SIZE) active = false;
    if (timer > 3.0f) active = false;
}

bool Fireball::IntersectsBody(const PhysicsBody& other) const {
    return active && BodiesIntersect(body, other);
}
