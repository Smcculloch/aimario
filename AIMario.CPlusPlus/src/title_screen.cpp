#include "title_screen.h"
#include "level.h"
#include "sprites.h"

void TitleScreen::Update(float dt) {
    blinkTimer += dt;
}

void TitleScreen::Draw(const SpriteGenerator& sprites) const {
    Color titleRed = {200,36,0,255};
    Color titleWhite = {252,252,252,255};
    Color titleGold = {248,184,0,255};
    Color shadow = {0,0,0,80};

    Level::DrawTextColored(sprites, "SUPER", 81, 51, 2, shadow);
    Level::DrawTextColored(sprites, "MARIO BROS", 45, 76, 2, shadow);

    Level::DrawTextColored(sprites, "SUPER", 80, 50, 2, titleRed);
    Level::DrawTextColored(sprites, "MARIO BROS", 44, 75, 2, titleWhite);

    Level::DrawTextColored(sprites, "WORLD 1-1", 89, 120, 1, titleGold);

    bool flicker = ((int)(blinkTimer * 3.0f)) % 2 == 0;
    if (flicker) {
        Level::DrawTextColored(sprites, "PRESS ENTER", 74, 170, 1, titleWhite);
    }

    Color grey = {188,188,188,255};
    Level::DrawTextColored(sprites, "A FAITHFUL RECREATION", 38, 210, 1, grey);
}
