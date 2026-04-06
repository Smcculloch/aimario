#include "level_data.h"
#include "constants.h"

static void SetTile(std::vector<std::vector<int>>& map, int x, int y, TileType tt) {
    if (x >= 0 && x < LEVEL_WIDTH_TILES && y >= 0 && y < LEVEL_HEIGHT_TILES)
        map[y][x] = (int)tt;
}

static void ClearGround(std::vector<std::vector<int>>& map, int sx, int ex) {
    for (int x = sx; x <= ex; x++) { map[13][x] = 0; map[14][x] = 0; }
}

static void SetPipe(std::vector<std::vector<int>>& map, int x, int topY, int h) {
    SetTile(map, x, topY, TileType::PipeTopLeft);
    SetTile(map, x+1, topY, TileType::PipeTopRight);
    for (int y = topY+1; y < topY+h; y++) {
        SetTile(map, x, y, TileType::PipeBodyLeft);
        SetTile(map, x+1, y, TileType::PipeBodyRight);
    }
}

static void BuildStair(std::vector<std::vector<int>>& map, int startX, int bottomY, int height, bool ascending) {
    for (int i = 0; i < height; i++) {
        int x = startX + i;
        int colH = ascending ? (i+1) : (height-i);
        for (int h = 0; h < colH; h++)
            SetTile(map, x, bottomY - h, TileType::HardBlock);
    }
}

std::vector<std::vector<int>> GetWorld1_1() {
    int w = LEVEL_WIDTH_TILES, h = LEVEL_HEIGHT_TILES;
    std::vector<std::vector<int>> map(h, std::vector<int>(w, 0));

    // Ground
    for (int x = 0; x < w; x++) { map[13][x] = (int)TileType::Ground; map[14][x] = (int)TileType::Ground; }

    // Pits
    ClearGround(map, 69, 70);
    ClearGround(map, 86, 88);
    ClearGround(map, 153, 154);

    // Blocks
    SetTile(map, 16, 9, TileType::Question);
    SetTile(map, 20, 9, TileType::Brick);
    SetTile(map, 21, 9, TileType::Question);
    SetTile(map, 22, 9, TileType::Brick);
    SetTile(map, 23, 9, TileType::Question);
    SetTile(map, 22, 5, TileType::Question);

    SetPipe(map, 28, 11, 2);
    SetPipe(map, 38, 10, 3);
    SetPipe(map, 46, 9, 4);
    SetPipe(map, 57, 9, 4);

    // Exit pipe (underground return)
    SetPipe(map, 163, 11, 2);

    SetTile(map, 77, 9, TileType::Question);
    SetTile(map, 80, 9, TileType::Brick);
    for (int x = 81; x <= 88; x++) SetTile(map, x, 5, TileType::Brick);

    SetTile(map, 91, 5, TileType::Brick);
    SetTile(map, 92, 5, TileType::Brick);
    SetTile(map, 93, 5, TileType::Brick);
    SetTile(map, 94, 9, TileType::Question);

    SetTile(map, 100, 9, TileType::Brick);
    SetTile(map, 101, 9, TileType::Question);
    SetTile(map, 102, 9, TileType::Brick);
    SetTile(map, 101, 5, TileType::Question);

    SetTile(map, 106, 9, TileType::Question);
    SetTile(map, 109, 9, TileType::Question);
    SetTile(map, 109, 5, TileType::Question);
    SetTile(map, 112, 9, TileType::Question);

    SetTile(map, 118, 9, TileType::Brick);
    SetTile(map, 119, 5, TileType::Brick);
    SetTile(map, 120, 5, TileType::Brick);
    SetTile(map, 121, 5, TileType::Brick);

    SetTile(map, 128, 5, TileType::Brick);
    SetTile(map, 129, 5, TileType::Question);
    SetTile(map, 130, 5, TileType::Question);
    SetTile(map, 131, 5, TileType::Brick);
    SetTile(map, 129, 9, TileType::Brick);
    SetTile(map, 130, 9, TileType::Brick);

    // Staircases
    BuildStair(map, 134, 12, 4, true);
    BuildStair(map, 140, 12, 4, true);
    BuildStair(map, 144, 12, 4, false);
    BuildStair(map, 148, 12, 4, true);
    BuildStair(map, 152, 12, 5, false);

    BuildStair(map, 181, 12, 4, true);
    BuildStair(map, 185, 12, 4, false);
    BuildStair(map, 189, 12, 4, true);
    BuildStair(map, 193, 12, 4, false);

    BuildStair(map, 198, 12, 8, true);

    // Flagpole
    for (int y = 2; y <= 12; y++) SetTile(map, 206, y, TileType::FlagPole);
    SetTile(map, 206, 1, TileType::FlagTop);

    // Castle
    for (int x = 208; x <= 212; x++)
        for (int y = 9; y <= 12; y++) SetTile(map, x, y, TileType::HardBlock);
    for (int x = 209; x <= 211; x++) SetTile(map, x, 8, TileType::HardBlock);
    SetTile(map, 210, 7, TileType::HardBlock);

    return map;
}

std::vector<EnemySpawn> GetEnemySpawns() {
    return {
        {22,12,EnemyTypeId::Goomba}, {40,12,EnemyTypeId::Goomba},
        {51,12,EnemyTypeId::Goomba}, {52,12,EnemyTypeId::Goomba},
        {80,4,EnemyTypeId::Goomba},  {82,4,EnemyTypeId::Goomba},
        {97,12,EnemyTypeId::Goomba}, {98,12,EnemyTypeId::Goomba},
        {107,12,EnemyTypeId::Koopa},
        {114,12,EnemyTypeId::Goomba},{115,12,EnemyTypeId::Goomba},
        {124,12,EnemyTypeId::Goomba},{125,12,EnemyTypeId::Goomba},
        {128,12,EnemyTypeId::Goomba},{129,12,EnemyTypeId::Goomba},
        {174,12,EnemyTypeId::Goomba},{175,12,EnemyTypeId::Goomba},
    };
}

std::map<std::pair<int,int>, ItemContent> GetBlockContents() {
    std::map<std::pair<int,int>, ItemContent> m;
    m[{16,9}] = ItemContent::Coin;
    m[{21,9}] = ItemContent::Mushroom;
    m[{23,9}] = ItemContent::Coin;
    m[{22,5}] = ItemContent::OneUp;
    m[{77,9}] = ItemContent::Coin;
    m[{94,9}] = ItemContent::Coin;
    m[{101,9}] = ItemContent::Coin;
    m[{101,5}] = ItemContent::Star;
    m[{106,9}] = ItemContent::Mushroom;
    m[{109,9}] = ItemContent::Coin;
    m[{109,5}] = ItemContent::Coin;
    m[{112,9}] = ItemContent::Coin;
    m[{129,5}] = ItemContent::Coin;
    m[{130,5}] = ItemContent::Coin;
    return m;
}

UndergroundData GetUnderground() {
    int w = LEVEL_WIDTH_TILES, h = LEVEL_HEIGHT_TILES;
    int uw = UNDERGROUND_WIDTH_TILES;
    std::vector<std::vector<int>> map(h, std::vector<int>(w, 0));

    // Ceiling: rows 0-1
    for (int x = 0; x < uw; x++) {
        map[0][x] = (int)TileType::HardBlock;
        map[1][x] = (int)TileType::HardBlock;
    }

    // Floor: rows 13-14
    for (int x = 0; x < uw; x++) {
        map[13][x] = (int)TileType::HardBlock;
        map[14][x] = (int)TileType::HardBlock;
    }

    // Walls: column 0 and 15
    for (int y = 2; y < 13; y++) {
        map[y][0] = (int)TileType::HardBlock;
        map[y][uw - 1] = (int)TileType::HardBlock;
    }

    // Exit pipe at x=13, y=11 (top), height 2
    SetPipe(map, 13, 11, 2);

    // Coin positions at rows 4, 6, 8, columns 2-13
    std::vector<std::pair<int,int>> coinPositions;
    int coinRows[] = {4, 6, 8};
    for (int row : coinRows) {
        for (int col = 2; col < 14; col++) {
            coinPositions.push_back({col, row});
        }
    }

    return {map, coinPositions};
}
