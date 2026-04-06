#pragma once
#include "types.h"
#include <vector>

struct CollisionResult {
    bool hitLeft=false, hitRight=false, hitTop=false, hitBottom=false;
    bool hasHitTile = false;
    int hitTileX=0, hitTileY=0;
};

CollisionResult MoveAndCollide(PhysicsBody& body, const std::vector<std::vector<Tile>>& tiles);
