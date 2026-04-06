#include "sprites.h"
#include <cstring>

// Undef raylib color macros that conflict with our palette names
#undef RED
#undef WHITE
#undef BLACK
#undef GREEN
#undef BLUE
#undef ORANGE
#undef YELLOW
#undef GRAY
#undef BROWN

// Color palette - Classic NES
using C = Color;
constexpr C T_   = {0,0,0,0};
constexpr C BLK  = {0,0,0,255};
constexpr C WHT  = {252,252,252,255};
constexpr C RED  = {200,36,0,255};
constexpr C DRK_RED = {136,20,0,255};
constexpr C BRN  = {136,76,0,255};
constexpr C SKIN = {252,188,148,255};
constexpr C GRN  = {0,168,0,255};
constexpr C DRK_GRN = {0,120,0,255};
constexpr C BLU  = {32,56,236,255};
constexpr C ORG  = {228,92,16,255};
constexpr C YLW  = {248,184,0,255};
constexpr C TAN_ = {228,148,88,255};
constexpr C DRK_TAN = {136,112,0,255};
constexpr C PIPE_GRN = {0,168,68,255};
constexpr C PIPE_DRK = {0,120,0,255};
constexpr C PIPE_LIT = {128,208,16,255};
constexpr C GRY  = {188,188,188,255};

static Texture2D MakeTexture(int w, int h, const C* pixels) {
    Image img = GenImageColor(w, h, T_);
    for (int y = 0; y < h; y++)
        for (int x = 0; x < w; x++)
            ImageDrawPixel(&img, x, y, pixels[y * w + x]);
    Texture2D tex = LoadTextureFromImage(img);
    SetTextureFilter(tex, TEXTURE_FILTER_POINT);
    UnloadImage(img);
    return tex;
}

static void MakeSolidBlock(C* g, C fill, C border) {
    for (int y = 0; y < 16; y++)
        for (int x = 0; x < 16; x++)
            g[y*16+x] = (x==0||x==15||y==0||y==15) ? border : fill;
}

void SpriteGenerator::Generate() {
    GenerateTiles();
    GenerateMario();
    GenerateEnemies();
    GenerateItems();
    GenerateFireball();
    GenerateFont();
    GenerateUndergroundTiles();
}

void SpriteGenerator::Unload() {
    for (auto& [k, t] : textures) UnloadTexture(t);
    textures.clear();
}

Texture2D SpriteGenerator::CreatePixel() {
    C white = {255,255,255,255};
    return MakeTexture(1, 1, &white);
}

void SpriteGenerator::GenerateTiles() {
    // Ground
    C ground[256];
    for (int y = 0; y < 16; y++) for (int x = 0; x < 16; x++) {
        if (y < 8) {
            ground[y*16+x] = (x == 0 || x == 8 || y == 0 || y == 8) ? ORG : BRN;
        } else {
            int lx = (x + 5) % 8; // offset pattern
            ground[y*16+x] = (lx == 3 || y == 8) ? ORG : BRN;
        }
    }
    // More accurate ground
    C gnd[256] = {
        ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,
        ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,
        ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,
        ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,
        ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,
        ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,
        ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,
        ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,
        ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,ORG,
        BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,
        BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,
        BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,
        BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,
        BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,
        BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,
        BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,BRN,BRN,BRN,ORG,BRN,BRN,BRN,BRN,
    };
    textures["ground"] = MakeTexture(16, 16, gnd);

    // Brick
    C brick[256] = {
        BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,
        BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,
        BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,
        BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,
        BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,
        BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,
        BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,
        BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,
        BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,
        RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,
        RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,
        RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,
        RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,
        RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,
        RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,RED,RED,RED,BLK,BLK,DRK_RED,RED,RED,
        BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,BLK,
    };
    textures["brick"] = MakeTexture(16, 16, brick);

    // Question blocks
    textures["question0"] = GenQuestionBlock(YLW, ORG);
    textures["question1"] = GenQuestionBlock({200,168,40,255}, {168,120,20,255});
    textures["question2"] = GenQuestionBlock({160,128,20,255}, {120,80,10,255});

    // Used block
    C ub[256]; MakeSolidBlock(ub, DRK_TAN, BLK);
    textures["used_block"] = MakeTexture(16, 16, ub);

    // Hard block
    C hb[256]; MakeSolidBlock(hb, GRY, BLK);
    textures["hard_block"] = MakeTexture(16, 16, hb);

    GeneratePipeTextures();

    textures["flagpole"] = GenFlagpole();
    textures["flagtop"] = GenFlagtop();
    textures["flag"] = GenFlag();
}

Texture2D SpriteGenerator::GenQuestionBlock(C main, C dark) {
    C g[256]; MakeSolidBlock(g, main, BLK);
    for (int x = 6; x <= 10; x++) g[3*16+x] = WHT;
    g[4*16+5]=WHT; g[4*16+11]=WHT;
    g[5*16+11]=WHT; g[6*16+10]=WHT;
    g[7*16+9]=WHT; g[8*16+8]=WHT;
    g[10*16+8]=WHT; g[11*16+8]=WHT;
    for (int x=1;x<15;x++) g[14*16+x]=dark;
    for (int y=1;y<15;y++) g[y*16+14]=dark;
    return MakeTexture(16, 16, g);
}

void SpriteGenerator::GeneratePipeTextures() {
    // Pipe top left
    C ptl[256];
    for (int y=0;y<16;y++) for (int x=0;x<16;x++)
        ptl[y*16+x] = (y<2||x<2) ? BLK : (x<5) ? PIPE_LIT : PIPE_GRN;
    textures["pipe_tl"] = MakeTexture(16,16,ptl);

    // Pipe top right
    C ptr[256];
    for (int y=0;y<16;y++) for (int x=0;x<16;x++)
        ptr[y*16+x] = (y<2||x>13) ? BLK : (x>10) ? PIPE_DRK : PIPE_GRN;
    textures["pipe_tr"] = MakeTexture(16,16,ptr);

    // Pipe body left
    C pbl[256];
    for (int y=0;y<16;y++) for (int x=0;x<16;x++)
        pbl[y*16+x] = (x<4) ? BLK : (x<7) ? PIPE_LIT : PIPE_GRN;
    textures["pipe_bl"] = MakeTexture(16,16,pbl);

    // Pipe body right
    C pbr[256];
    for (int y=0;y<16;y++) for (int x=0;x<16;x++)
        pbr[y*16+x] = (x>11) ? BLK : (x>8) ? PIPE_DRK : PIPE_GRN;
    textures["pipe_br"] = MakeTexture(16,16,pbr);
}

Texture2D SpriteGenerator::GenFlagpole() {
    C g[256]; for (int i=0;i<256;i++) g[i]=T_;
    for (int y=0;y<16;y++) { g[y*16+7]=GRY; g[y*16+8]=GRY; }
    return MakeTexture(16,16,g);
}

Texture2D SpriteGenerator::GenFlagtop() {
    C g[256]; for (int i=0;i<256;i++) g[i]=T_;
    for (int y=2;y<=6;y++) for (int x=5;x<=10;x++) g[y*16+x]=GRN;
    for (int y=7;y<16;y++) { g[y*16+7]=GRY; g[y*16+8]=GRY; }
    return MakeTexture(16,16,g);
}

Texture2D SpriteGenerator::GenFlag() {
    C g[256]; for (int i=0;i<256;i++) g[i]=T_;
    for (int y=0;y<14;y++) { int w=14-y; for (int x=0;x<w&&x<16;x++) g[y*16+x]=GRN; }
    return MakeTexture(16,16,g);
}

void SpriteGenerator::GenerateMario() {
    // Small Mario standing
    C stand[256] = {
        T_,T_,T_,T_,T_,RED,RED,RED,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,RED,RED,RED,RED,RED,RED,RED,T_,T_,T_,
        T_,T_,T_,T_,BRN,BRN,BRN,SKIN,SKIN,BLK,SKIN,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,
        T_,T_,T_,BRN,BRN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,BLK,BLK,T_,T_,T_,
        T_,T_,T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,BLU,RED,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,RED,RED,RED,BLU,RED,RED,BLU,RED,RED,RED,T_,T_,T_,
        T_,T_,RED,RED,RED,RED,BLU,BLU,BLU,BLU,RED,RED,RED,RED,T_,T_,
        T_,T_,SKIN,SKIN,RED,BLU,YLW,BLU,BLU,YLW,BLU,RED,SKIN,SKIN,T_,T_,
        T_,T_,SKIN,SKIN,SKIN,BLU,BLU,BLU,BLU,BLU,BLU,SKIN,SKIN,SKIN,T_,T_,
        T_,T_,SKIN,SKIN,BLU,BLU,BLU,BLU,BLU,BLU,BLU,BLU,SKIN,SKIN,T_,T_,
        T_,T_,T_,T_,BLU,BLU,BLU,T_,T_,BLU,BLU,BLU,T_,T_,T_,T_,
        T_,T_,T_,BRN,BRN,BRN,T_,T_,T_,T_,BRN,BRN,BRN,T_,T_,T_,
        T_,T_,BRN,BRN,BRN,BRN,T_,T_,T_,T_,BRN,BRN,BRN,BRN,T_,T_,
    };
    textures["mario_small_stand"] = MakeTexture(16,16,stand);

    // Walk1
    C walk1[256] = {
        T_,T_,T_,T_,T_,RED,RED,RED,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,RED,RED,RED,RED,RED,RED,RED,T_,T_,T_,
        T_,T_,T_,T_,BRN,BRN,BRN,SKIN,SKIN,BLK,SKIN,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,
        T_,T_,T_,BRN,BRN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,BLK,BLK,T_,T_,T_,
        T_,T_,T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,RED,BLU,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,RED,RED,RED,BLU,BLU,RED,RED,RED,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,BLU,BLU,BLU,BLU,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,BLU,BLU,BLU,BLU,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,BRN,BRN,RED,RED,RED,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,BRN,BRN,BRN,RED,T_,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,BRN,T_,BRN,BRN,BRN,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,BRN,BRN,BRN,BRN,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,BRN,BRN,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["mario_small_walk1"] = MakeTexture(16,16,walk1);

    // Walk2
    C walk2[256] = {
        T_,T_,T_,T_,T_,RED,RED,RED,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,RED,RED,RED,RED,RED,RED,RED,T_,T_,T_,
        T_,T_,T_,T_,BRN,BRN,BRN,SKIN,SKIN,BLK,SKIN,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,
        T_,T_,T_,BRN,BRN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,BLK,BLK,T_,T_,T_,
        T_,T_,T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,RED,RED,BLU,RED,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,RED,BLU,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,BLU,BLU,BLU,BLU,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,BRN,BLU,BLU,BLU,BRN,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,BRN,BRN,RED,BRN,BRN,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,BRN,BRN,BRN,BRN,T_,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,BRN,BRN,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,BRN,BRN,BRN,T_,T_,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["mario_small_walk2"] = MakeTexture(16,16,walk2);
    textures["mario_small_walk3"] = textures["mario_small_walk1"]; // reuse

    // Jump
    C jump[256] = {
        T_,T_,T_,T_,T_,T_,T_,T_,T_,SKIN,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,RED,RED,RED,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,RED,RED,RED,RED,RED,RED,RED,T_,T_,T_,
        T_,T_,T_,T_,BRN,BRN,BRN,SKIN,SKIN,BLK,SKIN,T_,T_,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,T_,BRN,SKIN,BRN,BRN,SKIN,SKIN,SKIN,BLK,SKIN,SKIN,SKIN,T_,T_,
        T_,T_,T_,BRN,BRN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,BLK,BLK,T_,T_,T_,
        T_,T_,T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,T_,
        T_,T_,RED,RED,RED,RED,BLU,RED,RED,BLU,T_,T_,T_,T_,T_,T_,
        SKIN,RED,RED,RED,RED,RED,BLU,BLU,BLU,BLU,RED,T_,T_,T_,T_,T_,
        SKIN,SKIN,T_,RED,BLU,YLW,BLU,BLU,YLW,BLU,RED,RED,T_,T_,T_,T_,
        T_,T_,T_,BLU,BLU,BLU,BLU,BLU,BLU,BLU,BLU,T_,T_,T_,T_,T_,
        T_,T_,BLU,BLU,BLU,BLU,BLU,T_,BLU,BLU,T_,T_,T_,T_,T_,T_,
        T_,BRN,BRN,BRN,T_,T_,T_,T_,T_,BRN,BRN,T_,T_,T_,T_,T_,
        T_,BRN,BRN,BRN,BRN,T_,T_,T_,T_,T_,BRN,BRN,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["mario_small_jump"] = MakeTexture(16,16,jump);
    textures["mario_small_death"] = textures["mario_small_jump"];

    // Big Mario
    textures["mario_big_stand"] = GenBigMario(false, 0);
    textures["mario_big_walk1"] = GenBigMario(false, 1);
    textures["mario_big_walk2"] = GenBigMario(false, 2);
    textures["mario_big_walk3"] = textures["mario_big_walk1"];
    textures["mario_big_jump"] = GenBigMario(false, 3);
    textures["mario_big_duck"] = GenBigMarioDuck(false);

    // Fire Mario
    textures["mario_fire_stand"] = GenBigMario(true, 0);
    textures["mario_fire_walk1"] = GenBigMario(true, 1);
    textures["mario_fire_walk2"] = GenBigMario(true, 2);
    textures["mario_fire_walk3"] = textures["mario_fire_walk1"];
    textures["mario_fire_jump"] = GenBigMario(true, 3);
    textures["mario_fire_duck"] = GenBigMarioDuck(true);
}

Texture2D SpriteGenerator::GenBigMario(bool fire, int frame) {
    C hat = fire ? WHT : RED;
    C overalls = fire ? BRN : BLU;

    C g[16*32]; for (int i=0;i<16*32;i++) g[i]=T_;
    auto s = [&](int y, int x, C c) { g[y*16+x]=c; };

    // Head
    for (int x=4;x<=9;x++) s(1,x,hat);
    for (int x=3;x<=12;x++) s(2,x,hat);
    for (int x=3;x<=13;x++) s(3,x,hat);
    for (int x=3;x<=5;x++) s(4,x,BRN);
    for (int x=6;x<=8;x++) s(4,x,SKIN);
    s(4,9,BLK); s(4,10,SKIN);
    s(5,2,BRN); s(5,3,BRN); s(5,4,SKIN); s(5,5,BRN);
    for (int x=6;x<=8;x++) s(5,x,SKIN);
    s(5,9,BLK); for (int x=10;x<=12;x++) s(5,x,SKIN);
    s(6,2,BRN); s(6,3,SKIN); s(6,4,BRN); s(6,5,BRN);
    for (int x=6;x<=8;x++) s(6,x,SKIN);
    s(6,9,BLK); for (int x=10;x<=13;x++) s(6,x,SKIN);
    for (int x=3;x<=4;x++) s(7,x,BRN);
    for (int x=5;x<=9;x++) s(7,x,SKIN);
    for (int x=10;x<=12;x++) s(7,x,BLK);
    for (int x=5;x<=11;x++) s(8,x,SKIN);

    // Torso
    for (int x=3;x<=11;x++) s(10,x,hat);
    s(10,6,overalls);
    for (int x=2;x<=12;x++) s(11,x,hat);
    s(11,5,overalls); s(11,7,overalls);
    for (int x=2;x<=12;x++) s(12,x,hat);
    s(12,5,overalls); s(12,6,hat); s(12,7,overalls);
    for (int x=2;x<=12;x++) s(13,x,hat);
    s(13,4,overalls); s(13,5,hat); s(13,6,overalls); s(13,7,hat); s(13,8,overalls);

    // Overalls
    for (int x=2;x<=12;x++) s(15,x,overalls);
    s(15,4,YLW); s(15,10,YLW);
    for (int x=2;x<=12;x++) s(16,x,overalls);
    for (int x=2;x<=12;x++) s(17,x,overalls);
    s(17,4,YLW); s(17,10,YLW);
    for (int x=2;x<=12;x++) s(18,x,overalls);
    for (int x=2;x<=12;x++) s(19,x,overalls);
    for (int x=2;x<=12;x++) s(20,x,overalls);
    for (int x=3;x<=11;x++) s(21,x,overalls);

    // Legs
    if (frame == 0) { // standing
        for (int x=3;x<=5;x++) { s(22,x,overalls);s(23,x,overalls);s(24,x,overalls);s(25,x,overalls); }
        for (int x=9;x<=11;x++) { s(22,x,overalls);s(23,x,overalls);s(24,x,overalls);s(25,x,overalls); }
        for (int x=2;x<=6;x++) { s(26,x,BRN);s(27,x,BRN); }
        for (int x=8;x<=12;x++) { s(26,x,BRN);s(27,x,BRN); }
        for (int x=1;x<=6;x++) s(28,x,BRN);
        for (int x=8;x<=13;x++) s(28,x,BRN);
        for (int x=1;x<=7;x++) s(29,x,BRN);
        for (int x=8;x<=14;x++) s(29,x,BRN);
    } else if (frame == 1) { // walk1
        for (int i : {4,5,6}) s(22,i,overalls);
        s(22,9,overalls); s(22,10,overalls);
        for (int i : {4,5,6,7}) s(23,i,overalls);
        s(23,9,overalls); s(23,10,overalls);
        for (int i : {5,6,7}) s(24,i,overalls);
        s(24,10,overalls); s(24,11,overalls);
        for (int x=6;x<=8;x++) s(25,x,BRN);
        s(25,10,BRN); s(25,11,BRN);
        for (int x=6;x<=9;x++) s(26,x,BRN);
        s(26,11,BRN); s(26,12,BRN);
        for (int x=7;x<=10;x++) s(27,x,BRN);
        s(27,12,BRN); s(27,13,BRN);
    } else if (frame == 2) { // walk2
        s(22,5,overalls); s(22,6,overalls); s(22,8,overalls); s(22,9,overalls);
        s(23,5,overalls); s(23,6,overalls); s(23,8,overalls); s(23,9,overalls);
        s(24,4,overalls); s(24,5,overalls); s(24,9,overalls); s(24,10,overalls);
        for (int x=3;x<=6;x++) s(25,x,BRN);
        for (int x=9;x<=11;x++) s(25,x,BRN);
        for (int x=3;x<=6;x++) s(26,x,BRN);
        for (int x=9;x<=12;x++) s(26,x,BRN);
        for (int x=2;x<=5;x++) s(27,x,BRN);
        for (int x=9;x<=12;x++) s(27,x,BRN);
    } else { // jump
        s(9,2,SKIN); s(9,3,SKIN);
        s(22,3,overalls); s(22,4,overalls); s(22,5,hat);
        s(22,10,overalls); s(22,11,overalls);
        s(23,2,overalls); s(23,3,overalls); s(23,4,hat);
        s(23,11,overalls); s(23,12,overalls);
        s(24,1,BRN); s(24,2,BRN); s(24,3,BRN);
        s(24,12,overalls); s(24,13,overalls);
        s(25,1,BRN); s(25,2,BRN); s(25,3,BRN);
        s(25,13,BRN); s(25,14,BRN);
        s(26,1,BRN); s(26,2,BRN);
        s(26,13,BRN); s(26,14,BRN);
    }

    return MakeTexture(16, 32, g);
}

Texture2D SpriteGenerator::GenBigMarioDuck(bool fire) {
    C hat = fire ? WHT : RED;
    C overalls = fire ? BRN : BLU;

    C g[16*32]; for (int i=0;i<16*32;i++) g[i]=T_;
    auto s = [&](int y, int x, C c) { g[y*16+x]=c; };
    int oy = 16;

    for (int x=4;x<=9;x++) s(oy,x,hat);
    for (int x=3;x<=12;x++) s(oy+1,x,hat);
    for (int x=3;x<=12;x++) s(oy+2,x,hat);
    for (int x=3;x<=5;x++) s(oy+3,x,BRN);
    for (int x=6;x<=8;x++) s(oy+3,x,SKIN);
    s(oy+3,9,BLK); s(oy+3,10,SKIN);
    for (int x=5;x<=11;x++) s(oy+4,x,SKIN);
    for (int x=3;x<=11;x++) s(oy+5,x,hat);
    for (int x=2;x<=12;x++) s(oy+6,x,hat);
    for (int x=2;x<=12;x++) s(oy+7,x,overalls);
    s(oy+7,4,YLW); s(oy+7,10,YLW);
    for (int x=2;x<=12;x++) s(oy+8,x,overalls);
    for (int x=2;x<=12;x++) s(oy+9,x,overalls);
    for (int x=3;x<=11;x++) s(oy+10,x,overalls);
    for (int x=2;x<=5;x++) s(oy+11,x,BRN);
    for (int x=9;x<=12;x++) s(oy+11,x,BRN);
    for (int x=1;x<=6;x++) s(oy+12,x,BRN);
    for (int x=8;x<=13;x++) s(oy+12,x,BRN);

    return MakeTexture(16, 32, g);
}

void SpriteGenerator::GenerateEnemies() {
    C gb = {172,80,0,255};
    C gd = {116,52,0,255};

    // Goomba frame 0
    C goomba0[256] = {
        T_,T_,T_,T_,T_,T_,gb,gb,gb,gb,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,gb,gb,gb,gb,gb,gb,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,gb,gb,gb,gb,gb,gb,gb,gb,T_,T_,T_,T_,
        T_,T_,T_,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,T_,T_,T_,
        T_,T_,gb,gb,BLK,BLK,gb,gb,gb,gb,BLK,BLK,gb,gb,T_,T_,
        T_,gb,gb,BLK,WHT,BLK,gb,gb,gb,gb,BLK,WHT,BLK,gb,gb,T_,
        T_,gb,gb,BLK,BLK,gb,gb,gb,gb,gb,gb,BLK,BLK,gb,gb,T_,
        T_,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,T_,
        T_,T_,gb,gb,gb,gb,gd,gd,gd,gd,gb,gb,gb,gb,T_,T_,
        T_,T_,T_,T_,gd,gd,gd,gd,gd,gd,gd,gd,T_,T_,T_,T_,
        T_,T_,T_,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,T_,T_,T_,
        T_,T_,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,T_,T_,
        T_,T_,T_,SKIN,SKIN,gd,gd,gd,gd,gd,gd,SKIN,SKIN,T_,T_,T_,
        T_,T_,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,T_,SKIN,SKIN,SKIN,SKIN,T_,T_,
        T_,BLK,BLK,BLK,SKIN,SKIN,T_,T_,T_,T_,SKIN,SKIN,BLK,BLK,BLK,T_,
        BLK,BLK,BLK,BLK,BLK,T_,T_,T_,T_,T_,T_,BLK,BLK,BLK,BLK,BLK,
    };
    textures["goomba0"] = MakeTexture(16,16,goomba0);

    // Goomba frame 1
    C goomba1[256] = {
        T_,T_,T_,T_,T_,T_,gb,gb,gb,gb,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,gb,gb,gb,gb,gb,gb,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,gb,gb,gb,gb,gb,gb,gb,gb,T_,T_,T_,T_,
        T_,T_,T_,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,T_,T_,T_,
        T_,T_,gb,gb,BLK,BLK,gb,gb,gb,gb,BLK,BLK,gb,gb,T_,T_,
        T_,gb,gb,BLK,WHT,BLK,gb,gb,gb,gb,BLK,WHT,BLK,gb,gb,T_,
        T_,gb,gb,BLK,BLK,gb,gb,gb,gb,gb,gb,BLK,BLK,gb,gb,T_,
        T_,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,gb,T_,
        T_,T_,gb,gb,gb,gb,gd,gd,gd,gd,gb,gb,gb,gb,T_,T_,
        T_,T_,T_,T_,gd,gd,gd,gd,gd,gd,gd,gd,T_,T_,T_,T_,
        T_,T_,T_,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,T_,T_,T_,
        T_,T_,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,gd,T_,T_,
        T_,T_,T_,gd,gd,SKIN,SKIN,T_,T_,SKIN,SKIN,gd,gd,T_,T_,T_,
        T_,T_,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,T_,SKIN,SKIN,SKIN,SKIN,T_,T_,
        T_,SKIN,SKIN,BLK,BLK,BLK,T_,T_,T_,T_,BLK,BLK,BLK,SKIN,SKIN,T_,
        T_,T_,BLK,BLK,BLK,BLK,BLK,T_,T_,BLK,BLK,BLK,BLK,BLK,T_,T_,
    };
    textures["goomba1"] = MakeTexture(16,16,goomba1);

    // Goomba flat
    C flat[256]; for (int i=0;i<256;i++) flat[i]=T_;
    for (int x=1;x<=14;x++) flat[14*16+x]=gd;
    for (int x=2;x<=13;x++) flat[15*16+x]=gd;
    flat[14*16+4]=BLK; flat[14*16+5]=BLK;
    flat[14*16+10]=BLK; flat[14*16+11]=BLK;
    textures["goomba_flat"] = MakeTexture(16,16,flat);

    textures["koopa0"] = GenKoopa(0);
    textures["koopa1"] = GenKoopa(1);
    textures["koopa_shell"] = GenShell();
}

Texture2D SpriteGenerator::GenKoopa(int frame) {
    C g[16*24]; for (int i=0;i<16*24;i++) g[i]=T_;
    auto s = [&](int y, int x, C c) { g[y*16+x]=c; };
    int oy=10;

    for (int x=7;x<=12;x++) s(oy,x,GRN);
    for (int x=6;x<=13;x++) s(oy+1,x,GRN);
    for (int x=6;x<=13;x++) s(oy+2,x,GRN);
    s(oy+2,10,WHT); s(oy+2,11,WHT);
    for (int x=6;x<=13;x++) s(oy+3,x,GRN);
    s(oy+3,10,WHT); s(oy+3,11,BLK); s(oy+3,12,SKIN);
    for (int x=7;x<=13;x++) s(oy+4,x,GRN);
    s(oy+4,12,SKIN); s(oy+4,13,SKIN);
    for (int x=8;x<=11;x++) s(oy+5,x,GRN);

    for (int x=3;x<=11;x++) s(oy+6,x,GRN);
    for (int x=2;x<=12;x++) s(oy+7,x,GRN);
    for (int x=2;x<=12;x++) s(oy+8,x,DRK_GRN);
    s(oy+8,5,YLW); s(oy+8,6,YLW); s(oy+8,9,YLW); s(oy+8,10,YLW);
    for (int x=2;x<=12;x++) s(oy+9,x,DRK_GRN);
    for (int x=2;x<=12;x++) s(oy+10,x,GRN);
    for (int x=3;x<=11;x++) s(oy+11,x,GRN);

    if (frame==0) {
        for (int x=3;x<=5;x++) s(oy+12,x,SKIN);
        for (int x=9;x<=11;x++) s(oy+12,x,SKIN);
        for (int x=2;x<=5;x++) s(oy+13,x,SKIN);
        for (int x=9;x<=12;x++) s(oy+13,x,SKIN);
    } else {
        for (int x=4;x<=6;x++) s(oy+12,x,SKIN);
        for (int x=8;x<=10;x++) s(oy+12,x,SKIN);
        for (int x=5;x<=7;x++) s(oy+13,x,SKIN);
        for (int x=7;x<=9;x++) s(oy+13,x,SKIN);
    }

    return MakeTexture(16, 24, g);
}

Texture2D SpriteGenerator::GenShell() {
    C g[256]; for (int i=0;i<256;i++) g[i]=T_;
    auto s = [&](int y, int x, C c) { g[y*16+x]=c; };

    for (int x=4;x<=11;x++) s(2,x,GRN);
    for (int x=3;x<=12;x++) s(3,x,GRN);
    for (int x=2;x<=13;x++) s(4,x,GRN);
    for (int x=2;x<=13;x++) s(5,x,DRK_GRN);
    s(5,5,YLW); s(5,6,YLW); s(5,9,YLW); s(5,10,YLW);
    for (int x=2;x<=13;x++) s(6,x,DRK_GRN);
    for (int x=2;x<=13;x++) s(7,x,DRK_GRN);
    for (int x=2;x<=13;x++) s(8,x,GRN);
    for (int x=2;x<=13;x++) s(9,x,GRN);
    for (int x=3;x<=12;x++) s(10,x,GRN);
    for (int x=3;x<=12;x++) s(11,x,WHT);
    for (int x=4;x<=11;x++) s(12,x,WHT);
    for (int x=5;x<=10;x++) s(13,x,WHT);

    return MakeTexture(16,16,g);
}

void SpriteGenerator::GenerateItems() {
    // Coin
    C coin[256] = {
        T_,T_,T_,T_,T_,T_,YLW,YLW,YLW,YLW,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,YLW,YLW,ORG,ORG,YLW,YLW,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,YLW,ORG,YLW,YLW,ORG,YLW,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,ORG,YLW,YLW,YLW,YLW,ORG,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,YLW,YLW,ORG,YLW,YLW,ORG,YLW,YLW,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,YLW,YLW,ORG,ORG,YLW,YLW,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,YLW,YLW,YLW,YLW,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["coin"] = MakeTexture(16,16,coin);
    textures["coin_popup"] = textures["coin"];

    // Mushroom
    C mr = {200,36,0,255};
    C mush[256] = {
        T_,T_,T_,T_,T_,mr,mr,mr,mr,mr,mr,T_,T_,T_,T_,T_,
        T_,T_,T_,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,T_,T_,T_,
        T_,T_,mr,mr,WHT,WHT,mr,mr,mr,mr,WHT,WHT,mr,mr,T_,T_,
        T_,mr,mr,WHT,WHT,WHT,WHT,mr,mr,WHT,WHT,WHT,WHT,mr,mr,T_,
        T_,mr,WHT,WHT,WHT,WHT,mr,mr,mr,mr,WHT,WHT,WHT,WHT,mr,T_,
        mr,mr,mr,WHT,WHT,mr,mr,mr,mr,mr,mr,WHT,WHT,mr,mr,mr,
        mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,
        mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,mr,
        T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,
        T_,SKIN,SKIN,BLK,BLK,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,SKIN,SKIN,T_,
        T_,SKIN,BLK,BLK,BLK,BLK,SKIN,SKIN,SKIN,SKIN,BLK,BLK,BLK,BLK,SKIN,T_,
        T_,SKIN,SKIN,BLK,BLK,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,SKIN,SKIN,T_,
        T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,
        T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["mushroom"] = MakeTexture(16,16,mush);

    // Fire flower
    C fo = {228,92,16,255};
    C ff[256] = {
        T_,T_,T_,T_,T_,T_,RED,RED,RED,RED,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,RED,RED,RED,YLW,YLW,RED,RED,RED,T_,T_,T_,T_,
        T_,T_,T_,RED,RED,YLW,fo,fo,fo,fo,YLW,RED,RED,T_,T_,T_,
        T_,T_,RED,RED,YLW,fo,fo,WHT,WHT,fo,fo,YLW,RED,RED,T_,T_,
        T_,T_,RED,YLW,fo,fo,WHT,WHT,WHT,WHT,fo,fo,YLW,RED,T_,T_,
        T_,T_,RED,YLW,fo,fo,WHT,WHT,WHT,WHT,fo,fo,YLW,RED,T_,T_,
        T_,T_,RED,RED,YLW,fo,fo,fo,fo,fo,fo,YLW,RED,RED,T_,T_,
        T_,T_,T_,RED,RED,YLW,fo,fo,fo,fo,YLW,RED,RED,T_,T_,T_,
        T_,T_,T_,T_,T_,GRN,GRN,GRN,GRN,GRN,GRN,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,GRN,GRN,T_,GRN,GRN,T_,GRN,GRN,T_,T_,T_,T_,
        T_,T_,T_,GRN,GRN,T_,T_,GRN,GRN,T_,T_,GRN,GRN,T_,T_,T_,
        T_,T_,T_,GRN,T_,T_,T_,GRN,GRN,T_,T_,T_,GRN,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,GRN,GRN,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,GRN,GRN,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,GRN,GRN,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["fireflower"] = MakeTexture(16,16,ff);

    // Star
    C star[256] = {
        T_,T_,T_,T_,T_,T_,T_,YLW,YLW,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,YLW,YLW,YLW,YLW,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,YLW,YLW,YLW,YLW,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,YLW,YLW,YLW,YLW,YLW,YLW,T_,T_,T_,T_,T_,
        YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,
        T_,YLW,YLW,YLW,YLW,YLW,ORG,ORG,ORG,ORG,YLW,YLW,YLW,YLW,YLW,T_,
        T_,T_,YLW,YLW,YLW,ORG,ORG,BLK,BLK,ORG,ORG,YLW,YLW,YLW,T_,T_,
        T_,T_,T_,YLW,YLW,ORG,BLK,ORG,ORG,BLK,ORG,YLW,YLW,T_,T_,T_,
        T_,T_,T_,YLW,YLW,ORG,ORG,ORG,ORG,ORG,ORG,YLW,YLW,T_,T_,T_,
        T_,T_,T_,YLW,YLW,YLW,ORG,ORG,ORG,ORG,YLW,YLW,YLW,T_,T_,T_,
        T_,T_,T_,T_,YLW,YLW,YLW,YLW,YLW,YLW,YLW,YLW,T_,T_,T_,T_,
        T_,T_,T_,YLW,YLW,YLW,YLW,T_,T_,YLW,YLW,YLW,YLW,T_,T_,T_,
        T_,T_,YLW,YLW,YLW,T_,T_,T_,T_,T_,T_,YLW,YLW,YLW,T_,T_,
        T_,YLW,YLW,YLW,T_,T_,T_,T_,T_,T_,T_,T_,YLW,YLW,YLW,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["star"] = MakeTexture(16,16,star);

    // 1-Up
    C oneup[256] = {
        T_,T_,T_,T_,T_,GRN,GRN,GRN,GRN,GRN,GRN,T_,T_,T_,T_,T_,
        T_,T_,T_,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,T_,T_,T_,
        T_,T_,GRN,GRN,WHT,WHT,GRN,GRN,GRN,GRN,WHT,WHT,GRN,GRN,T_,T_,
        T_,GRN,GRN,WHT,WHT,WHT,WHT,GRN,GRN,WHT,WHT,WHT,WHT,GRN,GRN,T_,
        T_,GRN,WHT,WHT,WHT,WHT,GRN,GRN,GRN,GRN,WHT,WHT,WHT,WHT,GRN,T_,
        GRN,GRN,GRN,WHT,WHT,GRN,GRN,GRN,GRN,GRN,GRN,WHT,WHT,GRN,GRN,GRN,
        GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,
        GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,GRN,
        T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,
        T_,SKIN,SKIN,BLK,BLK,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,SKIN,SKIN,T_,
        T_,SKIN,BLK,BLK,BLK,BLK,SKIN,SKIN,SKIN,SKIN,BLK,BLK,BLK,BLK,SKIN,T_,
        T_,SKIN,SKIN,BLK,BLK,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK,BLK,SKIN,SKIN,T_,
        T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,
        T_,T_,T_,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T_,T_,T_,
        T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,T_,
    };
    textures["oneup"] = MakeTexture(16,16,oneup);

    // Brick debris (8x8)
    C debris[64];
    for (int y=0;y<8;y++) for (int x=0;x<8;x++)
        debris[y*8+x] = (x==0||x==7||y==0||y==7) ? BLK : RED;
    textures["brick_debris"] = MakeTexture(8,8,debris);
}

void SpriteGenerator::GenerateFireball() {
    C fr = {252,152,56,255};
    C g[64]; for (int i=0;i<64;i++) g[i]=T_;
    for (int x=2;x<=5;x++) g[1*8+x]=fr;
    for (int x=1;x<=6;x++) g[2*8+x]=YLW;
    for (int x=1;x<=6;x++) g[3*8+x]=YLW;
    for (int x=1;x<=6;x++) g[4*8+x]=fr;
    for (int x=1;x<=6;x++) g[5*8+x]=fr;
    for (int x=2;x<=5;x++) g[6*8+x]=RED;
    textures["fireball"] = MakeTexture(8,8,g);
}

// Underground palette
constexpr C UG_BLU  = {32, 56, 236, 255};
constexpr C UG_DRK  = {16, 28, 128, 255};
constexpr C UG_GND  = {60, 60, 100, 255};
constexpr C UG_GND_LIT = {80, 80, 140, 255};

void SpriteGenerator::GenerateUndergroundTiles() {
    // Underground ground tile (blue-tinted brick pattern)
    C ug_ground[256];
    for (int i = 0; i < 256; i++) ug_ground[i] = UG_GND;
    for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
            if (y == 0 || y == 8) {
                ug_ground[y * 16 + x] = UG_GND_LIT;
            } else if ((y < 8 && (x == 0 || x == 8)) || (y >= 8 && (x == 4 || x == 12))) {
                ug_ground[y * 16 + x] = UG_GND_LIT;
            }
        }
    }
    textures["ground_ug"] = MakeTexture(16, 16, ug_ground);

    // Underground brick tile
    C ug_brick[256];
    for (int i = 0; i < 256; i++) ug_brick[i] = UG_BLU;
    for (int y = 0; y < 16; y++) {
        for (int x = 0; x < 16; x++) {
            if (x == 0 || x == 15 || y == 0 || y == 7 || y == 8 || y == 15) {
                ug_brick[y * 16 + x] = BLK;
            } else if (x == 1 || (y > 8 && x == 5) || (y > 8 && x == 13) || (y <= 7 && x == 8)) {
                ug_brick[y * 16 + x] = UG_DRK;
            }
        }
    }
    textures["brick_ug"] = MakeTexture(16, 16, ug_brick);

    // Underground hard block
    C ug_hb[256]; MakeSolidBlock(ug_hb, UG_DRK, BLK);
    textures["hard_block_ug"] = MakeTexture(16, 16, ug_hb);
}

void SpriteGenerator::GenerateFont() {
    const char* chars[] = {
        "0","1","2","3","4","5","6","7","8","9",
        "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
        "-","x","!",".",":"," ",
    };

    unsigned char patterns[][7] = {
        {0x0E,0x11,0x13,0x15,0x19,0x11,0x0E}, // 0
        {0x04,0x0C,0x04,0x04,0x04,0x04,0x0E}, // 1
        {0x0E,0x11,0x01,0x06,0x08,0x10,0x1F}, // 2
        {0x0E,0x11,0x01,0x06,0x01,0x11,0x0E}, // 3
        {0x02,0x06,0x0A,0x12,0x1F,0x02,0x02}, // 4
        {0x1F,0x10,0x1E,0x01,0x01,0x11,0x0E}, // 5
        {0x06,0x08,0x10,0x1E,0x11,0x11,0x0E}, // 6
        {0x1F,0x01,0x02,0x04,0x08,0x08,0x08}, // 7
        {0x0E,0x11,0x11,0x0E,0x11,0x11,0x0E}, // 8
        {0x0E,0x11,0x11,0x0F,0x01,0x02,0x0C}, // 9
        {0x0E,0x11,0x11,0x1F,0x11,0x11,0x11}, // A
        {0x1E,0x11,0x11,0x1E,0x11,0x11,0x1E}, // B
        {0x0E,0x11,0x10,0x10,0x10,0x11,0x0E}, // C
        {0x1E,0x11,0x11,0x11,0x11,0x11,0x1E}, // D
        {0x1F,0x10,0x10,0x1E,0x10,0x10,0x1F}, // E
        {0x1F,0x10,0x10,0x1E,0x10,0x10,0x10}, // F
        {0x0E,0x11,0x10,0x17,0x11,0x11,0x0F}, // G
        {0x11,0x11,0x11,0x1F,0x11,0x11,0x11}, // H
        {0x0E,0x04,0x04,0x04,0x04,0x04,0x0E}, // I
        {0x07,0x02,0x02,0x02,0x02,0x12,0x0C}, // J
        {0x11,0x12,0x14,0x18,0x14,0x12,0x11}, // K
        {0x10,0x10,0x10,0x10,0x10,0x10,0x1F}, // L
        {0x11,0x1B,0x15,0x15,0x11,0x11,0x11}, // M
        {0x11,0x11,0x19,0x15,0x13,0x11,0x11}, // N
        {0x0E,0x11,0x11,0x11,0x11,0x11,0x0E}, // O
        {0x1E,0x11,0x11,0x1E,0x10,0x10,0x10}, // P
        {0x0E,0x11,0x11,0x11,0x15,0x12,0x0D}, // Q
        {0x1E,0x11,0x11,0x1E,0x14,0x12,0x11}, // R
        {0x0E,0x11,0x10,0x0E,0x01,0x11,0x0E}, // S
        {0x1F,0x04,0x04,0x04,0x04,0x04,0x04}, // T
        {0x11,0x11,0x11,0x11,0x11,0x11,0x0E}, // U
        {0x11,0x11,0x11,0x11,0x0A,0x0A,0x04}, // V
        {0x11,0x11,0x11,0x15,0x15,0x1B,0x11}, // W
        {0x11,0x11,0x0A,0x04,0x0A,0x11,0x11}, // X
        {0x11,0x11,0x0A,0x04,0x04,0x04,0x04}, // Y
        {0x1F,0x01,0x02,0x04,0x08,0x10,0x1F}, // Z
        {0x00,0x00,0x00,0x1F,0x00,0x00,0x00}, // -
        {0x00,0x11,0x0A,0x04,0x0A,0x11,0x00}, // x
        {0x04,0x04,0x04,0x04,0x04,0x00,0x04}, // !
        {0x00,0x00,0x00,0x00,0x00,0x00,0x04}, // .
        {0x00,0x04,0x00,0x00,0x00,0x04,0x00}, // :
        {0x00,0x00,0x00,0x00,0x00,0x00,0x00}, // space
    };

    int numChars = sizeof(chars) / sizeof(chars[0]);
    for (int i = 0; i < numChars; i++) {
        C data[5*7];
        for (int j = 0; j < 35; j++) data[j] = T_;
        for (int y = 0; y < 7; y++) {
            for (int x = 0; x < 5; x++) {
                if ((patterns[i][y] >> (4-x)) & 1) {
                    data[y*5+x] = WHT;
                }
            }
        }
        textures[std::string("font_") + chars[i]] = MakeTexture(5, 7, data);
    }
}
