#include "items.h"
#include "collision.h"
#include "constants.h"

Item Item::NewCoinPopup(float x, float y) {
    Item it;
    it.body.x = x; it.body.y = y;
    it.body.width = 16; it.body.height = 16;
    it.body.vy = -6; it.body.applyGravity = false;
    it.itemType = ItemTypeId::Coin;
    it.isPopup = true; it.emerged = true;
    return it;
}

Item Item::NewStaticCoin(float x, float y) {
    Item it;
    it.body.x = x; it.body.y = y;
    it.body.width = 16; it.body.height = 16;
    it.body.applyGravity = false;
    it.itemType = ItemTypeId::Coin;
    it.isPopup = false;
    it.emerged = true;
    it.startY = y;
    return it;
}

Item Item::NewMushroom(float x, float y, bool isOneUp) {
    Item it;
    it.body.x = x; it.body.y = y;
    it.body.width = 16; it.body.height = 16;
    it.body.applyGravity = false;
    it.itemType = isOneUp ? ItemTypeId::OneUp : ItemTypeId::Mushroom;
    it.startY = y;
    return it;
}

Item Item::NewFireFlower(float x, float y) {
    Item it;
    it.body.x = x; it.body.y = y;
    it.body.width = 16; it.body.height = 16;
    it.body.applyGravity = false;
    it.itemType = ItemTypeId::FireFlower;
    it.startY = y;
    return it;
}

Item Item::NewStar(float x, float y) {
    Item it;
    it.body.x = x; it.body.y = y;
    it.body.width = 16; it.body.height = 16;
    it.body.applyGravity = false;
    it.itemType = ItemTypeId::Star;
    it.startY = y;
    return it;
}

void Item::Update(float dt, const std::vector<std::vector<Tile>>& tiles) {
    timer += dt;

    switch (itemType) {
    case ItemTypeId::Coin:
        if (isPopup) {
            if (startY == 0) startY = body.y;
            body.vy += 0.3f;
            body.y += body.vy;
            if (body.y > startY) active = false;
        }
        break;

    case ItemTypeId::Mushroom:
    case ItemTypeId::OneUp:
        if (!emerged) {
            emergeTimer += dt;
            body.y = startY - (emergeTimer / 0.5f) * 16.0f;
            if (emergeTimer >= 0.5f) {
                emerged = true;
                body.y = startY - 16;
                body.vx = MUSHROOM_SPEED;
                body.applyGravity = true;
            }
            return;
        }
        body.ApplyPhysics();
        {
            auto result = MoveAndCollide(body, tiles);
            if (result.hitLeft || result.hitRight) body.vx = result.hitLeft ? MUSHROOM_SPEED : -MUSHROOM_SPEED;
        }
        if (body.y > LEVEL_HEIGHT_TILES * TILE_SIZE) active = false;
        break;

    case ItemTypeId::FireFlower:
        if (!emerged) {
            emergeTimer += dt;
            body.y = startY - (emergeTimer / 0.5f) * 16.0f;
            if (emergeTimer >= 0.5f) {
                emerged = true;
                body.y = startY - 16;
            }
        }
        break;

    case ItemTypeId::Star:
        if (!emerged) {
            emergeTimer += dt;
            body.y = startY - (emergeTimer / 0.5f) * 16.0f;
            if (emergeTimer >= 0.5f) {
                emerged = true;
                body.y = startY - 16;
                body.vx = STAR_SPEED;
                body.vy = STAR_BOUNCE;
                body.applyGravity = true;
            }
            return;
        }
        body.ApplyPhysics();
        {
            auto result = MoveAndCollide(body, tiles);
            if (result.hitLeft || result.hitRight) body.vx = result.hitLeft ? STAR_SPEED : -STAR_SPEED;
            if (result.hitBottom) body.vy = STAR_BOUNCE;
        }
        if (body.y > LEVEL_HEIGHT_TILES * TILE_SIZE) active = false;
        break;
    }
}

const char* Item::GetTextureName() const {
    switch (itemType) {
        case ItemTypeId::Coin: return "coin";
        case ItemTypeId::Mushroom: return "mushroom";
        case ItemTypeId::OneUp: return "oneup";
        case ItemTypeId::FireFlower: return "fireflower";
        case ItemTypeId::Star: return "star";
    }
    return "coin";
}

bool Item::IntersectsBody(const PhysicsBody& other) const {
    return active && BodiesIntersect(body, other);
}
