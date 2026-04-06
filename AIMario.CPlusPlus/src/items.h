#pragma once
#include "types.h"
#include <vector>

struct SpriteGenerator;

struct Item {
    PhysicsBody body;
    bool active = true;
    ItemTypeId itemType;

    float timer = 0;
    float startY = 0;
    bool isPopup = false;
    bool emerged = false;
    float emergeTimer = 0;

    static Item NewCoinPopup(float x, float y);
    static Item NewStaticCoin(float x, float y);
    static Item NewMushroom(float x, float y, bool isOneUp);
    static Item NewFireFlower(float x, float y);
    static Item NewStar(float x, float y);

    void Update(float dt, const std::vector<std::vector<Tile>>& tiles);
    const char* GetTextureName() const;
    bool IntersectsBody(const PhysicsBody& other) const;
};
