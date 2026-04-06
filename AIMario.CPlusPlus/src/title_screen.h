#pragma once

struct SpriteGenerator;

struct TitleScreen {
    float blinkTimer = 0;

    void Update(float dt);
    void Draw(const SpriteGenerator& sprites) const;
};
