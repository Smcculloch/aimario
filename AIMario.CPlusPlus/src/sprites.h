#pragma once
#include "raylib.h"
#include <unordered_map>
#include <string>

struct SpriteGenerator {
    std::unordered_map<std::string, Texture2D> textures;

    void Generate();
    void Unload();
    Texture2D CreatePixel();

private:
    void GenerateTiles();
    void GenerateMario();
    void GenerateEnemies();
    void GenerateItems();
    void GenerateFireball();
    void GenerateFont();
    void GeneratePipeTextures();
    void GenerateUndergroundTiles();

    Texture2D GenQuestionBlock(Color main, Color dark);
    Texture2D GenFlagpole();
    Texture2D GenFlagtop();
    Texture2D GenFlag();
    Texture2D GenBigMario(bool fire, int frame);
    Texture2D GenBigMarioDuck(bool fire);
    Texture2D GenKoopa(int frame);
    Texture2D GenShell();
};
