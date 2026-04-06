#include "level.h"
#include "level_data.h"
#include "collision.h"
#include "hud.h"
#include <cmath>
#include <cstdio>
#include <cctype>
#include <algorithm>
#include <string>

Level::Level() {}

void Level::Load() {
    auto mapData = GetWorld1_1();
    auto blockContents = GetBlockContents();
    auto enemySpawns = GetEnemySpawns();

    int h = LEVEL_HEIGHT_TILES, w = LEVEL_WIDTH_TILES;
    tiles.assign(h, std::vector<Tile>(w));

    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            TileType tt = TileTypeFromInt(mapData[y][x]);
            Tile& tile = tiles[y][x];
            tile.type = tt;
            tile.gridX = x;
            tile.gridY = y;
            auto it = blockContents.find({x, y});
            if (it != blockContents.end()) tile.content = it->second;
        }
    }

    enemies.clear();
    for (auto& spawn : enemySpawns) {
        Enemy e = (spawn.enemyType == EnemyTypeId::Goomba) ? Enemy::NewGoomba() : Enemy::NewKoopa();
        e.body.x = spawn.x * (float)TILE_SIZE + 1.0f;
        e.body.y = spawn.y * (float)TILE_SIZE - e.body.height;
        enemies.push_back(e);
    }

    overworldTiles = tiles;
    LoadUndergroundTiles();

    cam.Init(LEVEL_WIDTH_TILES * (float)TILE_SIZE);
    mario = Mario();
    mario.Reset(40.0f, (LEVEL_HEIGHT_TILES - 3) * (float)TILE_SIZE);

    items.clear(); fireballs.clear(); scorePopups.clear(); debris.clear();
    timer = LEVEL_TIME; timerAccum = 0;
    levelComplete = false; flagDescending = false;
    score = 0; coins = 0;

    currentArea = LevelArea::Overworld;
    pipeState = PipeState::None;
    pipeTimer = 0.0f;
}

void Level::Reset() {
    mario.Reset(40.0f, (LEVEL_HEIGHT_TILES - 3) * (float)TILE_SIZE);
    cam.Init(LEVEL_WIDTH_TILES * (float)TILE_SIZE);
    cam.Reset();
    timer = LEVEL_TIME; timerAccum = 0;
    items.clear(); fireballs.clear(); scorePopups.clear(); debris.clear();
    levelComplete = false; flagDescending = false;

    currentArea = LevelArea::Overworld;
    pipeState = PipeState::None;
    pipeTimer = 0.0f;

    auto mapData = GetWorld1_1();
    auto blockContents = GetBlockContents();
    auto enemySpawns = GetEnemySpawns();

    int h = LEVEL_HEIGHT_TILES, w = LEVEL_WIDTH_TILES;
    tiles.assign(h, std::vector<Tile>(w));
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            TileType tt = TileTypeFromInt(mapData[y][x]);
            tiles[y][x].type = tt;
            tiles[y][x].gridX = x;
            tiles[y][x].gridY = y;
            auto it = blockContents.find({x, y});
            if (it != blockContents.end()) tiles[y][x].content = it->second;
        }
    }
    overworldTiles = tiles;
    LoadUndergroundTiles();

    enemies.clear();
    overworldEnemies.clear();
    for (auto& spawn : enemySpawns) {
        Enemy e = (spawn.enemyType == EnemyTypeId::Goomba) ? Enemy::NewGoomba() : Enemy::NewKoopa();
        e.body.x = spawn.x * (float)TILE_SIZE + 1.0f;
        e.body.y = spawn.y * (float)TILE_SIZE - e.body.height;
        enemies.push_back(e);
    }
}

void Level::Update(float dt, const InputManager& input) {
    // Handle pipe animation states
    if (pipeState != PipeState::None) {
        UpdatePipeTransition(dt);
        return;
    }

    // Timer
    if (!levelComplete && !mario.isDead) {
        timerAccum += dt;
        while (timerAccum >= TIMER_TICK_RATE) {
            timerAccum -= TIMER_TICK_RATE;
            timer -= 1.0f;
            if (timer <= 0) { timer = 0; mario.Die(); }
        }
    }

    mario.UpdateInput(dt, input);

    // Tile collision
    if (!mario.isDead && !mario.reachedFlag) {
        auto result = MoveAndCollide(mario.body, tiles);
        if (result.hitTop && result.hasHitTile) HitBlock(result.hitTileX, result.hitTileY);
        if (mario.body.x < cam.x) mario.body.x = cam.x;
        if (mario.body.y > LEVEL_HEIGHT_TILES * (float)TILE_SIZE) mario.Die();

        // Pipe entry detection
        CheckPipeEntry(input);
    }

    if (!mario.isDead) cam.Follow(mario.body.x);

    // Fireballs
    fireballCooldown -= dt;
    if (mario.power == PowerState::Fire && input.runPressed && fireballCooldown <= 0 && !mario.isDead) {
        int active = 0;
        for (auto& f : fireballs) if (f.active) active++;
        if (active < 2) {
            float fx = mario.body.x + (mario.facingRight ? 12.0f : -8.0f);
            float fy = mario.body.y + 8.0f;
            fireballs.push_back(Fireball(fx, fy, mario.facingRight));
            fireballCooldown = 0.3f;
        }
    }

    // Update tiles
    for (auto& row : tiles)
        for (auto& tile : row) tile.Update(dt);

    // Update enemies
    for (auto& enemy : enemies) {
        if (!enemy.active) continue;
        if (!cam.IsVisible(enemy.body.x, enemy.body.width + 16)) continue;
        enemy.Update(dt, tiles);
    }

    // Update items
    for (auto& item : items) item.Update(dt, tiles);
    items.erase(std::remove_if(items.begin(), items.end(), [](const Item& i){ return !i.active; }), items.end());

    // Update fireballs
    for (auto& fb : fireballs) fb.Update(dt, tiles);

    // Fireball-enemy collisions
    for (size_t fi = 0; fi < fireballs.size(); fi++) {
        if (!fireballs[fi].active) continue;
        for (size_t ei = 0; ei < enemies.size(); ei++) {
            if (!enemies[ei].active || enemies[ei].isStomped) continue;
            if (fireballs[fi].IntersectsBody(enemies[ei].body)) {
                fireballs[fi].active = false;
                float px = enemies[ei].body.x, py = enemies[ei].body.y;
                enemies[ei].KillByHit();
                AddScore(SCORE_GOOMBA, px, py);
                break;
            }
        }
    }
    fireballs.erase(std::remove_if(fireballs.begin(), fireballs.end(), [](const Fireball& f){ return !f.active; }), fireballs.end());

    // Score popups
    for (auto& p : scorePopups) { p.timer -= dt; p.y -= 1.0f; }
    scorePopups.erase(std::remove_if(scorePopups.begin(), scorePopups.end(), [](const ScorePopup& p){ return p.timer <= 0; }), scorePopups.end());

    // Debris
    for (auto& d : debris) d.Update(dt);
    debris.erase(std::remove_if(debris.begin(), debris.end(), [](const BrickDebris& d){ return !d.active; }), debris.end());

    // Flag animation
    if (flagDescending) {
        flagY += 2.0f;
        if (flagY >= flagTargetY) flagY = flagTargetY;
    }

    if (!mario.isDead && !mario.reachedFlag) CheckMarioEnemyCollisions();
    if (!mario.isDead) CheckMarioItemCollisions();
    if (!levelComplete && !mario.isDead) CheckFlagpole();
}

void Level::CheckMarioEnemyCollisions() {
    for (size_t i = 0; i < enemies.size(); i++) {
        if (!enemies[i].active || enemies[i].isStomped) continue;
        if (enemies[i].enemyType == EnemyTypeId::Koopa && enemies[i].isShell && !enemies[i].shellMoving) continue;
        if (!BodiesIntersect(mario.body, enemies[i].body)) continue;

        float marioFeetPrev = mario.body.Bottom() - mario.body.vy;
        bool isFalling = mario.body.vy > 0;
        bool feetAboveMid = mario.body.Bottom() < enemies[i].body.Top() + enemies[i].body.height / 2;
        bool wasAbove = marioFeetPrev <= enemies[i].body.Top() + 2;

        if (isFalling && (feetAboveMid || wasAbove) && enemies[i].canBeStomped) {
            float px = enemies[i].body.x, py = enemies[i].body.y;
            if (enemies[i].enemyType == EnemyTypeId::Goomba) {
                enemies[i].OnStompedGoomba();
            } else {
                enemies[i].OnStompedKoopa(mario.body.x);
            }
            mario.body.vy = JUMP_VELOCITY_WALK * 0.6f;
            int sc = (enemies[i].enemyType == EnemyTypeId::Goomba) ? SCORE_GOOMBA : SCORE_KOOPA;
            AddScore(sc, px, py);
        } else if (mario.hasStar) {
            float px = enemies[i].body.x, py = enemies[i].body.y;
            enemies[i].KillByHit();
            AddScore(SCORE_GOOMBA, px, py);
        } else {
            if (enemies[i].enemyType == EnemyTypeId::Koopa && enemies[i].isShell && !enemies[i].shellMoving) {
                enemies[i].KickShell(mario.body.x < enemies[i].body.x);
            } else {
                mario.TakeDamage();
            }
        }
    }

    // Shell kills
    for (size_t i = 0; i < enemies.size(); i++) {
        if (!enemies[i].active) continue;
        if (!(enemies[i].enemyType == EnemyTypeId::Koopa && enemies[i].isShell && enemies[i].shellMoving)) continue;
        for (size_t j = 0; j < enemies.size(); j++) {
            if (i == j || !enemies[j].active || enemies[j].isStomped) continue;
            if (BodiesIntersect(enemies[i].body, enemies[j].body)) {
                float px = enemies[j].body.x, py = enemies[j].body.y;
                enemies[j].KillByHit();
                AddScore(SCORE_KOOPA, px, py);
            }
        }
    }
}

void Level::CheckMarioItemCollisions() {
    for (int i = (int)items.size() - 1; i >= 0; i--) {
        if (!items[i].active || !items[i].IntersectsBody(mario.body)) continue;

        switch (items[i].itemType) {
        case ItemTypeId::Mushroom:
            mario.CollectMushroom();
            AddScore(SCORE_MUSHROOM, items[i].body.x, items[i].body.y);
            items[i].active = false;
            break;
        case ItemTypeId::OneUp:
            lives++;
            items[i].active = false;
            break;
        case ItemTypeId::FireFlower:
            mario.CollectFireFlower();
            AddScore(SCORE_FIRE_FLOWER, items[i].body.x, items[i].body.y);
            items[i].active = false;
            break;
        case ItemTypeId::Star:
            mario.CollectStar();
            AddScore(SCORE_STAR, items[i].body.x, items[i].body.y);
            items[i].active = false;
            break;
        case ItemTypeId::Coin:
            coins++;
            score += SCORE_COIN;
            if (coins >= 100) { coins -= 100; lives++; }
            items[i].active = false;
            break;
        }
    }
}

void Level::CheckFlagpole() {
    float flagX = 206.0f * TILE_SIZE;
    if (mario.body.Right() >= flagX && mario.body.Left() <= flagX + TILE_SIZE && !levelComplete) {
        levelComplete = true;
        mario.reachedFlag = true;
        mario.body.x = flagX - mario.body.width;

        float height = mario.body.y;
        int flagScore;
        if (height < 4.0f * TILE_SIZE) flagScore = 5000;
        else if (height < 6.0f * TILE_SIZE) flagScore = 2000;
        else if (height < 8.0f * TILE_SIZE) flagScore = 800;
        else if (height < 10.0f * TILE_SIZE) flagScore = 400;
        else flagScore = SCORE_FLAG_BASE;
        AddScore(flagScore, mario.body.x, mario.body.y);

        flagDescending = true;
        flagY = 2.0f * TILE_SIZE;
        flagTargetY = 12.0f * TILE_SIZE;
    }
}

Color Level::BackgroundColor() const {
    if (currentArea == LevelArea::Underground) return {0, 0, 0, 255};
    return {92, 148, 252, 255};
}

void Level::CheckPipeEntry(const InputManager& input) {
    if (!input.downPressed || !mario.body.onGround) return;

    float marioCenterX = (mario.body.x + mario.body.width / 2.0f) / (float)TILE_SIZE;
    int marioFeetY = (int)(mario.body.Bottom() / (float)TILE_SIZE);

    if (currentArea == LevelArea::Overworld) {
        float pipeX = (float)PIPE_ENTRY_X;
        if (marioCenterX >= pipeX && marioCenterX <= pipeX + 2.0f
            && marioFeetY == PIPE_ENTRY_TOP_Y)
        {
            pipeState = PipeState::EnteringPipe;
            pipeTimer = 0.0f;
            savedCameraX = cam.x;
            overworldEnemies = std::move(enemies);
            enemies.clear();
            mario.body.vx = 0.0f;
            mario.body.vy = 0.0f;
            // Center Mario on pipe
            mario.body.x = ((float)PIPE_ENTRY_X + 0.5f) * (float)TILE_SIZE - mario.body.width / 2.0f;
        }
    } else {
        // Underground: exit pipe at x=13, top at y=11
        float pipeX = 13.0f;
        if (marioCenterX >= pipeX && marioCenterX <= pipeX + 2.0f
            && marioFeetY == 11)
        {
            pipeState = PipeState::EnteringPipe;
            pipeTimer = 0.0f;
            mario.body.vx = 0.0f;
            mario.body.vy = 0.0f;
            // Center Mario on pipe
            mario.body.x = 13.0f * (float)TILE_SIZE + (float)TILE_SIZE - mario.body.width / 2.0f;
        }
    }
}

void Level::UpdatePipeTransition(float dt) {
    pipeTimer += dt;

    if (pipeState == PipeState::EnteringPipe) {
        // Slide Mario down into the pipe
        mario.body.y += 1.0f;

        if (pipeTimer >= PIPE_ANIM_DURATION) {
            if (currentArea == LevelArea::Overworld) {
                // Save overworld tiles state
                overworldTiles = tiles;
                // Switch to underground
                tiles = undergroundTiles;
                currentArea = LevelArea::Underground;
                // Reset camera for underground (one screen)
                cam.Init((float)UNDERGROUND_WIDTH_TILES * (float)TILE_SIZE);
                cam.Reset();
                // Place Mario at underground entry
                mario.body.x = 2.0f * (float)TILE_SIZE;
                mario.body.y = 11.0f * (float)TILE_SIZE - mario.body.height;
                mario.body.vx = 0.0f;
                mario.body.vy = 0.0f;
                mario.body.onGround = false;
                mario.visible = true;
                // Spawn underground coins as items
                items.clear();
                auto ugData = GetUnderground();
                for (auto& pos : ugData.coinPositions) {
                    float cx = pos.first * (float)TILE_SIZE;
                    float cy = pos.second * (float)TILE_SIZE;
                    items.push_back(Item::NewStaticCoin(cx, cy));
                }
                fireballs.clear();
                enemies.clear();
                pipeState = PipeState::None;
            } else {
                // Switch back to overworld
                tiles = overworldTiles;
                currentArea = LevelArea::Overworld;
                // Restore camera
                cam.Init((float)LEVEL_WIDTH_TILES * (float)TILE_SIZE);
                // Place Mario inside the exit pipe (he'll slide up out of it)
                float exitX = (float)PIPE_EXIT_RETURN_X * (float)TILE_SIZE + (float)TILE_SIZE - mario.body.width / 2.0f;
                float pipeTopY = 11.0f * (float)TILE_SIZE;
                mario.body.x = exitX;
                mario.body.y = pipeTopY;
                mario.body.vx = 0.0f;
                mario.body.vy = 0.0f;
                mario.body.onGround = false;
                mario.visible = true;
                // Restore enemies
                enemies = std::move(overworldEnemies);
                overworldEnemies.clear();
                items.clear();
                fireballs.clear();
                // Set camera to Mario's position
                float desiredCamX = exitX - NES_WIDTH / 2.0f;
                if (desiredCamX < 0) desiredCamX = 0;
                if (desiredCamX > cam.maxX) desiredCamX = cam.maxX;
                cam.x = desiredCamX;
                pipeState = PipeState::ExitingPipe;
                pipeTimer = 0.0f;
            }
        }
    } else if (pipeState == PipeState::ExitingPipe) {
        // Mario slides up out of the pipe at overworld exit
        float pipeTopY = 11.0f * (float)TILE_SIZE;
        float targetY = pipeTopY - mario.body.height;
        mario.body.y -= 1.0f;

        if (mario.body.y <= targetY || pipeTimer >= PIPE_ANIM_DURATION) {
            mario.body.y = targetY;
            mario.body.onGround = true;
            pipeState = PipeState::None;
        }
    }
}

void Level::LoadUndergroundTiles() {
    auto ugData = GetUnderground();
    int h = LEVEL_HEIGHT_TILES, w = LEVEL_WIDTH_TILES;
    undergroundTiles.assign(h, std::vector<Tile>(w));
    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            TileType tt = TileTypeFromInt(ugData.map[y][x]);
            undergroundTiles[y][x].type = tt;
            undergroundTiles[y][x].gridX = x;
            undergroundTiles[y][x].gridY = y;
        }
    }
}

void Level::HitBlock(int gridX, int gridY) {
    Tile& tile = tiles[gridY][gridX];
    if (tile.type == TileType::Empty) return;
    if (tile.isHit && tile.type == TileType::QuestionUsed) return;

    tile.bumpOffset = -8.0f;

    if (tile.type == TileType::Question || (tile.type == TileType::Invisible && !tile.isHit)) {
        Tile copy = tile;
        tile.isHit = true;
        tile.type = TileType::QuestionUsed;
        SpawnItemFromBlock(copy);
    } else if (tile.type == TileType::Brick) {
        if (mario.power != PowerState::Small) {
            BreakBrick(gridX, gridY);
        } else if (tile.content != ItemContent::None) {
            Tile copy = tile;
            tile.isHit = true;
            tile.type = TileType::QuestionUsed;
            SpawnItemFromBlock(copy);
        } else {
            tile.bumpOffset = -4.0f;
        }

        for (auto& enemy : enemies) {
            if (!enemy.active || enemy.isStomped) continue;
            int ex = (int)((enemy.body.x + enemy.body.width / 2) / TILE_SIZE);
            int ey = (int)(enemy.body.Bottom() / TILE_SIZE);
            if (ex == gridX && ey == gridY) {
                float px = enemy.body.x, py = enemy.body.y;
                enemy.KillByHit();
                score += SCORE_GOOMBA;
                scorePopups.push_back({SCORE_GOOMBA, px, py, 1.0f});
            }
        }
    }
}

void Level::SpawnItemFromBlock(const Tile& tile) {
    float sx = tile.gridX * (float)TILE_SIZE;
    float sy = tile.gridY * (float)TILE_SIZE;

    switch (tile.content) {
    case ItemContent::Coin:
        coins++; score += SCORE_COIN;
        if (coins >= 100) { coins -= 100; lives++; }
        items.push_back(Item::NewCoinPopup(sx, sy));
        break;
    case ItemContent::Mushroom:
        if (mario.power == PowerState::Small) items.push_back(Item::NewMushroom(sx, sy, false));
        else items.push_back(Item::NewFireFlower(sx, sy));
        break;
    case ItemContent::Star:
        items.push_back(Item::NewStar(sx, sy));
        break;
    case ItemContent::OneUp:
        items.push_back(Item::NewMushroom(sx, sy, true));
        break;
    case ItemContent::None:
    case ItemContent::MultiCoin:
        coins++; score += SCORE_COIN;
        if (coins >= 100) { coins -= 100; lives++; }
        items.push_back(Item::NewCoinPopup(sx, sy));
        break;
    }
}

void Level::BreakBrick(int gridX, int gridY) {
    tiles[gridY][gridX].type = TileType::Empty;
    score += SCORE_BRICK;

    float bx = gridX * (float)TILE_SIZE + 8;
    float by = gridY * (float)TILE_SIZE + 8;
    debris.push_back({bx-4, by-4, -1.5f, -4.0f, true});
    debris.push_back({bx+4, by-4,  1.5f, -4.0f, true});
    debris.push_back({bx-4, by+4, -1.0f, -3.0f, true});
    debris.push_back({bx+4, by+4,  1.0f, -3.0f, true});
}

void Level::AddScore(int amount, float x, float y) {
    score += amount;
    scorePopups.push_back({amount, x, y, 1.0f});
}

void Level::Draw(const SpriteGenerator& sprites, float camX) const {
    int startX = std::max((int)(camX / TILE_SIZE) - 1, 0);
    int endX = std::min(startX + (NES_WIDTH / TILE_SIZE) + 2, LEVEL_WIDTH_TILES - 1);

    for (int y = 0; y < LEVEL_HEIGHT_TILES; y++) {
        for (int x = startX; x <= endX; x++) {
            const Tile& tile = tiles[y][x];
            if (tile.type != TileType::Empty) DrawTile(sprites, tile, camX);
        }
    }

    // Flag (only in overworld)
    if ((flagDescending || levelComplete) && currentArea == LevelArea::Overworld) {
        float fdx = 206.0f * TILE_SIZE - 16.0f;
        auto it = sprites.textures.find("flag");
        if (it != sprites.textures.end())
            DrawTexture(it->second, (int)(fdx - camX), (int)flagY, WHITE);
    }

    // Items
    for (auto& item : items) {
        if (!item.active) continue;
        auto it = sprites.textures.find(item.GetTextureName());
        if (it != sprites.textures.end())
            DrawTexture(it->second, (int)(floorf(item.body.x) - camX), (int)floorf(item.body.y), WHITE);
    }

    // Enemies
    for (auto& enemy : enemies) {
        if (enemy.active && cam.IsVisible(enemy.body.x, 16))
            DrawEnemy(sprites, enemy, camX);
    }

    // Mario
    DrawMario(sprites, camX);

    // Fireballs
    for (auto& fb : fireballs) {
        if (!fb.active) continue;
        auto it = sprites.textures.find("fireball");
        if (it != sprites.textures.end())
            DrawTexture(it->second, (int)(floorf(fb.body.x) - camX), (int)floorf(fb.body.y), WHITE);
    }

    // Debris
    for (auto& d : debris) {
        if (!d.active) continue;
        auto it = sprites.textures.find("brick_debris");
        if (it != sprites.textures.end())
            DrawTexture(it->second, (int)(floorf(d.x) - camX), (int)floorf(d.y), WHITE);
    }

    // Score popups
    for (auto& p : scorePopups) {
        char buf[16]; snprintf(buf, sizeof(buf), "%d", p.amount);
        DrawTextAt(sprites, buf, p.x - camX, p.y, 0.8f);
    }
}

void Level::DrawTile(const SpriteGenerator& sprites, const Tile& tile, float camX) const {
    bool isUg = (currentArea == LevelArea::Underground);
    const char* texName = nullptr;
    switch (tile.type) {
    case TileType::Ground: texName = isUg ? "ground_ug" : "ground"; break;
    case TileType::Brick: texName = isUg ? "brick_ug" : "brick"; break;
    case TileType::Question:
        switch (tile.GetAnimFrame()) {
        case 0: texName = "question0"; break;
        case 1: texName = "question1"; break;
        default: texName = "question2"; break;
        }
        break;
    case TileType::QuestionUsed: texName = "used_block"; break;
    case TileType::HardBlock: texName = isUg ? "hard_block_ug" : "hard_block"; break;
    case TileType::PipeTopLeft: texName = "pipe_tl"; break;
    case TileType::PipeTopRight: texName = "pipe_tr"; break;
    case TileType::PipeBodyLeft: texName = "pipe_bl"; break;
    case TileType::PipeBodyRight: texName = "pipe_br"; break;
    case TileType::FlagPole: texName = "flagpole"; break;
    case TileType::FlagTop: texName = "flagtop"; break;
    default: return;
    }

    auto it = sprites.textures.find(texName);
    if (it != sprites.textures.end()) {
        float dx = tile.gridX * (float)TILE_SIZE - camX;
        float dy = tile.gridY * (float)TILE_SIZE + tile.bumpOffset;
        DrawTexture(it->second, (int)dx, (int)dy, WHITE);
    }
}

void Level::DrawEnemy(const SpriteGenerator& sprites, const Enemy& enemy, float camX) const {
    if (!enemy.active) return;
    const char* texName = enemy.GetTextureName();
    auto it = sprites.textures.find(texName);
    if (it == sprites.textures.end()) return;

    float drawY = enemy.body.y;
    bool flipX = false, flipY = false;

    if (enemy.enemyType == EnemyTypeId::Goomba) {
        if (enemy.flat) drawY = enemy.body.y - 14;
        else if (enemy.isStomped) flipY = true;
    } else {
        if (enemy.isStomped && !enemy.isShell) flipY = true;
        else flipX = enemy.facingRight;
    }

    Texture2D tex = it->second;
    Rectangle src = {0, 0, (float)tex.width, (float)tex.height};
    if (flipX) src.width = -src.width;
    if (flipY) src.height = -src.height;
    Rectangle dst = {floorf(enemy.body.x - 1) - camX, floorf(drawY), (float)tex.width, (float)tex.height};
    DrawTexturePro(tex, src, dst, {0,0}, 0, WHITE);
}

void Level::DrawMario(const SpriteGenerator& sprites, float camX) const {
    if (!mario.visible) return;
    std::string texName = mario.GetTextureName();
    auto it = sprites.textures.find(texName);
    if (it == sprites.textures.end()) return;

    float drawX = mario.body.x - 1 - camX;
    float drawY = mario.body.y;
    if (mario.isDucking) drawY = mario.body.y - 16;
    bool flip = !mario.facingRight;

    Texture2D tex = it->second;
    Rectangle src = {0, 0, (float)tex.width, (float)tex.height};
    if (flip) src.width = -src.width;
    Rectangle dst = {floorf(drawX), floorf(drawY), (float)tex.width, (float)tex.height};
    DrawTexturePro(tex, src, dst, {0,0}, 0, WHITE);
}

void Level::DrawTextAt(const SpriteGenerator& sprites, const char* text, float x, float y, float scale) const {
    float cx = x;
    for (const char* p = text; *p; p++) {
        char c = (char)toupper(*p);
        std::string key = std::string("font_") + c;
        auto it = sprites.textures.find(key);
        if (it != sprites.textures.end()) {
            Rectangle dst = {cx, y, 5*scale, 7*scale};
            DrawTexturePro(it->second, {0,0,5,7}, dst, {0,0}, 0, WHITE);
        }
        cx += 6 * scale;
    }
}

void Level::DrawText(const SpriteGenerator& sprites, const char* text, float x, float y, float scale) {
    float cx = x;
    for (const char* p = text; *p; p++) {
        char c = (char)toupper(*p);
        std::string key = std::string("font_") + c;
        auto it = sprites.textures.find(key);
        if (it != sprites.textures.end()) {
            Rectangle dst = {cx, y, 5*scale, 7*scale};
            DrawTexturePro(it->second, {0,0,5,7}, dst, {0,0}, 0, WHITE);
        }
        cx += 6 * scale;
    }
}

void Level::DrawTextColored(const SpriteGenerator& sprites, const char* text, float x, float y, float scale, Color color) {
    float cx = x;
    for (const char* p = text; *p; p++) {
        char c = (char)toupper(*p);
        std::string key = std::string("font_") + c;
        auto it = sprites.textures.find(key);
        if (it != sprites.textures.end()) {
            Rectangle dst = {cx, y, 5*scale, 7*scale};
            DrawTexturePro(it->second, {0,0,5,7}, dst, {0,0}, 0, color);
        }
        cx += 6 * scale;
    }
}
