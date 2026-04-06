#include "collision.h"
#include "constants.h"
#include <algorithm>

static bool IntersectsRect(const PhysicsBody& b, float rx, float ry, float rw, float rh) {
    return b.Left() < rx + rw && b.Right() > rx && b.Top() < ry + rh && b.Bottom() > ry;
}

static void ResolveX(PhysicsBody& body, const std::vector<std::vector<Tile>>& tiles, CollisionResult& result) {
    int tileLeft = std::max((int)(body.Left() / TILE_SIZE) - 1, 0);
    int tileRight = std::min((int)(body.Right() / TILE_SIZE) + 1, LEVEL_WIDTH_TILES - 1);
    int tileTop = std::max((int)(body.Top() / TILE_SIZE), 0);
    int tileBottom = std::min((int)((body.Bottom() - 1) / TILE_SIZE), LEVEL_HEIGHT_TILES - 1);

    for (int y = tileTop; y <= tileBottom; y++) {
        for (int x = tileLeft; x <= tileRight; x++) {
            const Tile& tile = tiles[y][x];
            if (!tile.IsSolid()) continue;
            float tx = tile.BoundsX(), ty = tile.BoundsY();
            float tw = TILE_SIZE, th = TILE_SIZE;
            if (!IntersectsRect(body, tx, ty, tw, th)) continue;

            if (body.vx > 0) {
                body.x = tx - body.width;
                body.vx = 0;
                result.hitRight = true;
            } else if (body.vx < 0) {
                body.x = tx + tw;
                body.vx = 0;
                result.hitLeft = true;
            }
        }
    }
}

static void ResolveY(PhysicsBody& body, const std::vector<std::vector<Tile>>& tiles, CollisionResult& result) {
    int tileLeft = std::max((int)(body.Left() / TILE_SIZE), 0);
    int tileRight = std::min((int)((body.Right() - 1) / TILE_SIZE), LEVEL_WIDTH_TILES - 1);
    int tileTop = std::max((int)(body.Top() / TILE_SIZE) - 1, 0);
    int tileBottom = std::min((int)(body.Bottom() / TILE_SIZE) + 1, LEVEL_HEIGHT_TILES - 1);

    body.onGround = false;

    for (int y = tileTop; y <= tileBottom; y++) {
        for (int x = tileLeft; x <= tileRight; x++) {
            const Tile& tile = tiles[y][x];
            if (!tile.IsSolid()) continue;
            float tx = tile.BoundsX(), ty = tile.BoundsY();
            float tw = TILE_SIZE, th = TILE_SIZE;
            if (!IntersectsRect(body, tx, ty, tw, th)) continue;

            if (body.vy > 0) {
                body.y = ty - body.height;
                body.vy = 0;
                body.onGround = true;
                result.hitBottom = true;
            } else if (body.vy < 0) {
                body.y = ty + th;
                body.vy = 0;
                result.hitTop = true;
                result.hasHitTile = true;
                result.hitTileX = tile.gridX;
                result.hitTileY = tile.gridY;
            }
        }
    }
}

CollisionResult MoveAndCollide(PhysicsBody& body, const std::vector<std::vector<Tile>>& tiles) {
    CollisionResult result;
    body.x += body.vx;
    ResolveX(body, tiles, result);
    body.y += body.vy;
    ResolveY(body, tiles, result);
    return result;
}
