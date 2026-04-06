#include "raylib.h"
#include "constants.h"
#include "types.h"
#include "sprites.h"
#include "level.h"
#include "hud.h"
#include "title_screen.h"
#include <algorithm>

int main() {
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "SUPER MARIO BROS");
    SetTargetFPS(60);

    SpriteGenerator sprites;
    sprites.Generate();
    Texture2D pixel = sprites.CreatePixel();

    RenderTexture2D renderTarget = LoadRenderTexture(NES_WIDTH, NES_HEIGHT);
    SetTextureFilter(renderTarget.texture, TEXTURE_FILTER_POINT);

    InputManager input;
    GameStateManager stateMgr;
    Level level;
    level.Load();
    TitleScreen title;

    while (!WindowShouldClose()) {
        float dt = std::min(GetFrameTime(), 0.05f);
        input.Update();
        stateMgr.Update(dt);

        // Update
        switch (stateMgr.currentState) {
        case GameState::Title:
            title.Update(dt);
            if (input.start) {
                level.Load();
                stateMgr.SetState(GameState::Playing);
            }
            break;
        case GameState::Playing:
            level.Update(dt, input);
            if (level.mario.isDead) stateMgr.SetState(GameState::Death);
            else if (level.levelComplete) stateMgr.SetState(GameState::LevelComplete);
            break;
        case GameState::Death:
            level.Update(dt, input);
            if (stateMgr.stateTimer > 3.0f) {
                level.lives--;
                if (level.lives <= 0) stateMgr.SetState(GameState::GameOver);
                else { level.Reset(); stateMgr.SetState(GameState::Playing); }
            }
            break;
        case GameState::LevelComplete:
            level.Update(dt, input);
            if (stateMgr.stateTimer > 5.0f) stateMgr.SetState(GameState::Title);
            break;
        case GameState::GameOver:
            if (stateMgr.stateTimer > 3.0f) {
                level.lives = STARTING_LIVES;
                level.score = 0;
                level.coins = 0;
                stateMgr.SetState(GameState::Title);
            }
            break;
        }

        // Draw to render target
        BeginTextureMode(renderTarget);
        {
            Color bg = {92, 148, 252, 255}; // Classic sky blue (default for title)
            if (stateMgr.currentState == GameState::Playing ||
                stateMgr.currentState == GameState::Death ||
                stateMgr.currentState == GameState::LevelComplete) {
                bg = level.BackgroundColor();
            }
            ClearBackground(bg);
        }

        switch (stateMgr.currentState) {
        case GameState::Title:
            title.Draw(sprites);
            break;
        case GameState::Playing:
        case GameState::Death:
        case GameState::LevelComplete:
            level.Draw(sprites, level.cam.x);
            break;
        case GameState::GameOver:
            break;
        }

        // HUD
        if (stateMgr.currentState != GameState::Title) {
            if (stateMgr.currentState == GameState::GameOver) {
                DrawRectangle(0, 0, NES_WIDTH, NES_HEIGHT, BLACK);
                Level::DrawText(sprites, "GAME OVER", 88, 112, 1);
            } else {
                DrawHUD(sprites, level);
            }
        }

        EndTextureMode();

        // Scale render target to window
        BeginDrawing();
        ClearBackground(BLACK);

        // raylib render textures have flipped Y, so we flip it back
        Rectangle src = {0, 0, (float)NES_WIDTH, -(float)NES_HEIGHT};
        Rectangle dst = {0, 0, (float)WINDOW_WIDTH, (float)WINDOW_HEIGHT};
        DrawTexturePro(renderTarget.texture, src, dst, {0,0}, 0, WHITE);

        EndDrawing();
    }

    sprites.Unload();
    UnloadTexture(pixel);
    UnloadRenderTexture(renderTarget);
    CloseWindow();
    return 0;
}
