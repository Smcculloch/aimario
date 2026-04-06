#pragma once
#include "types.h"
#include <vector>

struct Fireball {
    PhysicsBody body;
    bool active = true;
    float timer = 0;

    Fireball(float x, float y, bool goRight);
    void Update(float dt, const std::vector<std::vector<Tile>>& tiles);
    bool IntersectsBody(const PhysicsBody& other) const;
};
