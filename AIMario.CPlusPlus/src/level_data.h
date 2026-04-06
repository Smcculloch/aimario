#pragma once
#include "types.h"
#include <vector>
#include <map>
#include <utility>

struct EnemySpawn {
    int x, y;
    EnemyTypeId enemyType;
};

struct UndergroundData {
    std::vector<std::vector<int>> map;
    std::vector<std::pair<int,int>> coinPositions;  // (gridX, gridY)
};

std::vector<std::vector<int>> GetWorld1_1();
std::vector<EnemySpawn> GetEnemySpawns();
std::map<std::pair<int,int>, ItemContent> GetBlockContents();
UndergroundData GetUnderground();
