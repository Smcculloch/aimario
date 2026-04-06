#include "hud.h"
#include "level.h"
#include "sprites.h"
#include <cstdio>

void DrawHUD(const SpriteGenerator& sprites, const Level& level) {
    Color hudWhite = {252,252,252,255};
    Color hudGold = {248,184,0,255};
    float y = 8.0f;

    Level::DrawTextColored(sprites, "MARIO", 24, y, 1, hudWhite);
    char buf[32];
    snprintf(buf, sizeof(buf), "%06d", level.score);
    Level::DrawTextColored(sprites, buf, 24, y+10, 1, hudWhite);

    snprintf(buf, sizeof(buf), "x%02d", level.coins);
    Level::DrawTextColored(sprites, buf, 96, y+10, 1, hudGold);

    Level::DrawTextColored(sprites, "WORLD", 144, y, 1, hudWhite);
    Level::DrawTextColored(sprites, "1-1", 152, y+10, 1, hudWhite);

    Level::DrawTextColored(sprites, "TIME", 200, y, 1, hudWhite);
    snprintf(buf, sizeof(buf), "%03d", (int)level.timer);
    Level::DrawTextColored(sprites, buf, 208, y+10, 1, hudWhite);
}
