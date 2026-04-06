using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using System.Collections.Generic;

namespace AIMario.Graphics;

public class SpriteGenerator
{
    private GraphicsDevice _gd;
    public Dictionary<string, Texture2D> Textures { get; } = new();

    // NES-like color palette
    // CLASSIC NES PALETTE
    static readonly Color T = Color.Transparent;
    static readonly Color BLK = new(0, 0, 0);
    static readonly Color WHT = new(252, 252, 252);
    static readonly Color RED = new(200, 36, 0);
    static readonly Color DRK_RED = new(136, 20, 0);
    static readonly Color BRN = new(136, 76, 0);
    static readonly Color SKIN = new(252, 188, 148);
    static readonly Color GRN = new(0, 168, 0);
    static readonly Color DRK_GRN = new(0, 120, 0);
    static readonly Color BLU = new(32, 56, 236);
    static readonly Color ORG = new(228, 92, 16);
    static readonly Color YLW = new(248, 184, 0);
    static readonly Color TAN = new(228, 148, 88);
    static readonly Color DRK_TAN = new(136, 112, 0);
    static readonly Color PIPE_GRN = new(0, 168, 68);
    static readonly Color PIPE_DRK = new(0, 120, 0);
    static readonly Color PIPE_LIT = new(128, 208, 16);
    static readonly Color GRY = new(188, 188, 188);

    // Underground color palette
    static readonly Color UG_BLU = new(32, 56, 236);
    static readonly Color UG_DRK = new(16, 28, 128);
    static readonly Color UG_GND = new(60, 60, 100);
    static readonly Color UG_GND_LIT = new(80, 80, 140);

    public void Generate(GraphicsDevice gd)
    {
        _gd = gd;
        GenerateTiles();
        GenerateUndergroundTiles();
        GenerateMario();
        GenerateEnemies();
        GenerateItems();
        GenerateFireball();
        GenerateBowser();
        GenerateFont();
    }

    private Texture2D CreateTexture(int w, int h, Color[] data)
    {
        var tex = new Texture2D(_gd, w, h);
        tex.SetData(data);
        return tex;
    }

    private Texture2D From2D(Color[,] grid)
    {
        int h = grid.GetLength(0), w = grid.GetLength(1);
        var data = new Color[w * h];
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
                data[y * w + x] = grid[y, x];
        return CreateTexture(w, h, data);
    }

    #region Tiles
    private void GenerateTiles()
    {
        // Ground tile (brown brick pattern)
        Textures["ground"] = From2D(new Color[16, 16] {
            { ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG },
            { ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN },
            { ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN },
            { ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN },
            { ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN },
            { ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN },
            { ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN },
            { ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN },
            { ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG },
            { BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN },
            { BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN },
            { BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN },
            { BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN },
            { BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN },
            { BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN },
            { BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN },
        });

        // Brick tile
        Textures["brick"] = From2D(new Color[16, 16] {
            { BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK },
            { BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK },
            { BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK },
            { BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK },
            { BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK },
            { BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK },
            { BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK },
            { BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK },
            { BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK },
            { RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED },
            { RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED },
            { RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED },
            { RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED },
            { RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED },
            { RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED },
            { BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK },
        });

        // Question block (frame 0 - yellow with ?)
        Textures["question0"] = GenerateQuestionBlock(YLW, ORG);
        Textures["question1"] = GenerateQuestionBlock(new Color(200, 168, 40), new Color(168, 120, 20));
        Textures["question2"] = GenerateQuestionBlock(new Color(160, 128, 20), new Color(120, 80, 10));

        // Used block (dark, empty)
        Textures["used_block"] = From2D(MakeSolidBlock(DRK_TAN, BLK));

        // Hard block (stone)
        Textures["hard_block"] = From2D(MakeSolidBlock(GRY, BLK));

        // Pipe textures
        GeneratePipeTextures();

        // Flagpole
        Textures["flagpole"] = GenerateFlagpole();
        Textures["flagtop"] = GenerateFlagtop();
        Textures["flag"] = GenerateFlag();
    }

    private Texture2D GenerateQuestionBlock(Color main, Color dark)
    {
        var g = MakeSolidBlock(main, BLK);
        // Draw ? mark
        for (int x = 6; x <= 10; x++) g[3, x] = WHT;
        g[4, 5] = WHT; g[4, 11] = WHT;
        g[5, 11] = WHT; g[6, 10] = WHT;
        g[7, 9] = WHT; g[8, 8] = WHT;
        g[10, 8] = WHT; g[11, 8] = WHT;
        // Shadow edges
        for (int x = 1; x < 15; x++) g[14, x] = dark;
        for (int y = 1; y < 15; y++) g[y, 14] = dark;
        return From2D(g);
    }

    private Color[,] MakeSolidBlock(Color fill, Color border)
    {
        var g = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = (x == 0 || x == 15 || y == 0 || y == 15) ? border : fill;
        return g;
    }

    private void GeneratePipeTextures()
    {
        // Pipe top left
        var ptl = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
            {
                if (y < 2 || x < 2) ptl[y, x] = BLK;
                else if (x < 5) ptl[y, x] = PIPE_LIT;
                else ptl[y, x] = PIPE_GRN;
            }
        Textures["pipe_tl"] = From2D(ptl);

        // Pipe top right
        var ptr = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
            {
                if (y < 2 || x > 13) ptr[y, x] = BLK;
                else if (x > 10) ptr[y, x] = PIPE_DRK;
                else ptr[y, x] = PIPE_GRN;
            }
        Textures["pipe_tr"] = From2D(ptr);

        // Pipe body left
        var pbl = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
            {
                if (x < 4) pbl[y, x] = BLK;
                else if (x < 7) pbl[y, x] = PIPE_LIT;
                else pbl[y, x] = PIPE_GRN;
            }
        Textures["pipe_bl"] = From2D(pbl);

        // Pipe body right
        var pbr = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
            {
                if (x > 11) pbr[y, x] = BLK;
                else if (x > 8) pbr[y, x] = PIPE_DRK;
                else pbr[y, x] = PIPE_GRN;
            }
        Textures["pipe_br"] = From2D(pbr);
    }

    private Texture2D GenerateFlagpole()
    {
        var g = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = (x >= 7 && x <= 8) ? GRY : T;
        return From2D(g);
    }

    private Texture2D GenerateFlagtop()
    {
        var g = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = T;
        // Ball on top
        for (int y = 2; y <= 6; y++)
            for (int x = 5; x <= 10; x++)
                g[y, x] = GRN;
        // Pole below
        for (int y = 7; y < 16; y++) { g[y, 7] = GRY; g[y, 8] = GRY; }
        return From2D(g);
    }

    private Texture2D GenerateFlag()
    {
        var g = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = T;
        // Triangle flag shape
        for (int y = 0; y < 14; y++)
        {
            int w = 14 - y;
            for (int x = 0; x < w && x < 16; x++)
                g[y, x] = GRN;
        }
        return From2D(g);
    }
    private void GenerateUndergroundTiles()
    {
        // Underground ground tile (blue-tinted brick pattern)
        var ugGround = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
            {
                ugGround[y, x] = UG_GND;
                if (y == 0 || y == 8)
                    ugGround[y, x] = UG_GND_LIT;
                else if ((y < 8 && (x == 0 || x == 8)) || (y >= 8 && (x == 4 || x == 12)))
                    ugGround[y, x] = UG_GND_LIT;
            }
        Textures["ground_ug"] = From2D(ugGround);

        // Underground brick tile
        var ugBrick = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
            {
                ugBrick[y, x] = UG_BLU;
                if (x == 0 || x == 15 || y == 0 || y == 7 || y == 8 || y == 15)
                    ugBrick[y, x] = BLK;
                else if (x == 1 || (y > 8 && x == 5) || (y > 8 && x == 13) || (y <= 7 && x == 8))
                    ugBrick[y, x] = UG_DRK;
            }
        Textures["brick_ug"] = From2D(ugBrick);

        // Underground hard block
        Textures["hard_block_ug"] = From2D(MakeSolidBlock(UG_DRK, BLK));
    }
    #endregion

    #region Mario
    private void GenerateMario()
    {
        // Small Mario standing (16x16 with 12x16 used area)
        Textures["mario_small_stand"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T },
            { T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T },
            { T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T },
            { T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, BLU, RED, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   RED, RED, RED, BLU, RED, RED, BLU, RED, RED, RED, T,   T,   T },
            { T,   T,   RED, RED, RED, RED, BLU, BLU, BLU, BLU, RED, RED, RED, RED, T,   T },
            { T,   T,   SKIN,SKIN,RED, BLU, YLW, BLU, BLU, YLW, BLU, RED, SKIN,SKIN,T,   T },
            { T,   T,   SKIN,SKIN,SKIN,BLU, BLU, BLU, BLU, BLU, BLU, SKIN,SKIN,SKIN,T,   T },
            { T,   T,   SKIN,SKIN,BLU, BLU, BLU, BLU, BLU, BLU, BLU, BLU, SKIN,SKIN,T,   T },
            { T,   T,   T,   T,   BLU, BLU, BLU, T,   T,   BLU, BLU, BLU, T,   T,   T,   T },
            { T,   T,   T,   BRN, BRN, BRN, T,   T,   T,   T,   BRN, BRN, BRN, T,   T,   T },
            { T,   T,   BRN, BRN, BRN, BRN, T,   T,   T,   T,   BRN, BRN, BRN, BRN, T,   T },
        });

        // Small Mario walking frame 1
        Textures["mario_small_walk1"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T },
            { T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T },
            { T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T },
            { T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, RED, BLU, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   RED, RED, RED, BLU, BLU, RED, RED, RED, T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, BLU, BLU, BLU, BLU, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   BLU, BLU, BLU, BLU, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   BRN, BRN, RED, RED, RED, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, BRN, BRN, BRN, RED, T,   T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, BRN, T,   BRN, BRN, BRN, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   BRN, BRN, BRN, BRN, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T,   T,   T,   T },
        });

        // Walk frame 2
        Textures["mario_small_walk2"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T },
            { T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T },
            { T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T },
            { T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T },
            { T,   T,   T,   T,   T,   RED, RED, BLU, RED, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, RED, BLU, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, BLU, BLU, BLU, BLU, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   BRN, BLU, BLU, BLU, BRN, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, BRN, BRN, RED, BRN, BRN, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, BRN, BRN, BRN, BRN, T,   T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   BRN, BRN, BRN, T,   T,   T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
        });

        // Walk frame 3 (skid-like)
        Textures["mario_small_walk3"] = Textures["mario_small_walk1"]; // reuse

        // Jump frame
        Textures["mario_small_jump"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   SKIN,T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T },
            { T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T },
            { T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T },
            { T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T },
            { T,   T,   RED, RED, RED, RED, BLU, RED, RED, BLU, T,   T,   T,   T,   T,   T },
            { SKIN,RED, RED, RED, RED, RED, BLU, BLU, BLU, BLU, RED, T,   T,   T,   T,   T },
            { SKIN,SKIN,T,   RED, BLU, YLW, BLU, BLU, YLW, BLU, RED, RED, T,   T,   T,   T },
            { T,   T,   T,   BLU, BLU, BLU, BLU, BLU, BLU, BLU, BLU, T,   T,   T,   T,   T },
            { T,   T,   BLU, BLU, BLU, BLU, BLU, T,   BLU, BLU, T,   T,   T,   T,   T,   T },
            { T,   BRN, BRN, BRN, T,   T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T,   T },
            { T,   BRN, BRN, BRN, BRN, T,   T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
        });

        // Death sprite
        Textures["mario_small_death"] = Textures["mario_small_jump"]; // reuse jump as death

        // Big Mario (16x32) - standing
        Textures["mario_big_stand"] = GenerateBigMario(false, 0);
        Textures["mario_big_walk1"] = GenerateBigMario(false, 1);
        Textures["mario_big_walk2"] = GenerateBigMario(false, 2);
        Textures["mario_big_walk3"] = GenerateBigMario(false, 1);
        Textures["mario_big_jump"] = GenerateBigMario(false, 3);
        Textures["mario_big_duck"] = GenerateBigMarioDuck();

        // Fire Mario
        Textures["mario_fire_stand"] = GenerateBigMario(true, 0);
        Textures["mario_fire_walk1"] = GenerateBigMario(true, 1);
        Textures["mario_fire_walk2"] = GenerateBigMario(true, 2);
        Textures["mario_fire_walk3"] = GenerateBigMario(true, 1);
        Textures["mario_fire_jump"] = GenerateBigMario(true, 3);
        Textures["mario_fire_duck"] = GenerateBigMarioDuck(true);
    }

    private Texture2D GenerateBigMario(bool fire, int frame)
    {
        Color hat = fire ? WHT : RED;
        Color overalls = fire ? BRN : BLU;

        var g = new Color[32, 16];
        for (int y = 0; y < 32; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = T;

        // Big Mario: full 32px tall sprite
        // Head (rows 0-12)
        // Hat
        for (int x = 4; x <= 9; x++) g[1, x] = hat;
        for (int x = 3; x <= 12; x++) g[2, x] = hat;
        for (int x = 3; x <= 13; x++) g[3, x] = hat;
        // Face
        for (int x = 3; x <= 5; x++) g[4, x] = BRN;
        for (int x = 6; x <= 8; x++) g[4, x] = SKIN;
        g[4, 9] = BLK; g[4, 10] = SKIN;
        g[5, 2] = BRN; g[5, 3] = BRN;
        g[5, 4] = SKIN; g[5, 5] = BRN;
        for (int x = 6; x <= 8; x++) g[5, x] = SKIN;
        g[5, 9] = BLK;
        for (int x = 10; x <= 12; x++) g[5, x] = SKIN;
        g[6, 2] = BRN; g[6, 3] = SKIN; g[6, 4] = BRN; g[6, 5] = BRN;
        for (int x = 6; x <= 8; x++) g[6, x] = SKIN;
        g[6, 9] = BLK;
        for (int x = 10; x <= 13; x++) g[6, x] = SKIN;
        for (int x = 3; x <= 4; x++) g[7, x] = BRN;
        for (int x = 5; x <= 9; x++) g[7, x] = SKIN;
        for (int x = 10; x <= 12; x++) g[7, x] = BLK;
        for (int x = 5; x <= 11; x++) g[8, x] = SKIN;

        // Torso / shirt (rows 9-14)
        for (int x = 3; x <= 11; x++) g[10, x] = hat;
        g[10, 6] = overalls;
        for (int x = 2; x <= 12; x++) g[11, x] = hat;
        g[11, 5] = overalls; g[11, 7] = overalls;
        for (int x = 2; x <= 12; x++) g[12, x] = hat;
        g[12, 5] = overalls; g[12, 6] = hat; g[12, 7] = overalls;
        for (int x = 2; x <= 12; x++) g[13, x] = hat;
        g[13, 4] = overalls; g[13, 5] = hat; g[13, 6] = overalls;
        g[13, 7] = hat; g[13, 8] = overalls;

        // Overalls (rows 15-21)
        for (int x = 2; x <= 12; x++) g[15, x] = overalls;
        g[15, 4] = YLW; g[15, 10] = YLW;
        for (int x = 2; x <= 12; x++) g[16, x] = overalls;
        for (int x = 2; x <= 12; x++) g[17, x] = overalls;
        g[17, 4] = YLW; g[17, 10] = YLW;
        for (int x = 2; x <= 12; x++) g[18, x] = overalls;
        for (int x = 2; x <= 12; x++) g[19, x] = overalls;
        for (int x = 2; x <= 12; x++) g[20, x] = overalls;
        for (int x = 3; x <= 11; x++) g[21, x] = overalls;

        // Legs and feet (rows 22-31) - vary by frame
        if (frame == 0) // standing
        {
            for (int x = 3; x <= 5; x++) g[22, x] = overalls;
            for (int x = 9; x <= 11; x++) g[22, x] = overalls;
            for (int x = 3; x <= 5; x++) g[23, x] = overalls;
            for (int x = 9; x <= 11; x++) g[23, x] = overalls;
            for (int x = 3; x <= 5; x++) g[24, x] = overalls;
            for (int x = 9; x <= 11; x++) g[24, x] = overalls;
            for (int x = 3; x <= 5; x++) g[25, x] = overalls;
            for (int x = 9; x <= 11; x++) g[25, x] = overalls;
            // Shoes
            for (int x = 2; x <= 6; x++) g[26, x] = BRN;
            for (int x = 8; x <= 12; x++) g[26, x] = BRN;
            for (int x = 2; x <= 6; x++) g[27, x] = BRN;
            for (int x = 8; x <= 12; x++) g[27, x] = BRN;
            for (int x = 1; x <= 6; x++) g[28, x] = BRN;
            for (int x = 8; x <= 13; x++) g[28, x] = BRN;
            for (int x = 1; x <= 7; x++) g[29, x] = BRN;
            for (int x = 8; x <= 14; x++) g[29, x] = BRN;
        }
        else if (frame == 1) // walk1 - legs spread
        {
            g[22, 4] = overalls; g[22, 5] = overalls; g[22, 6] = overalls;
            g[22, 9] = overalls; g[22, 10] = overalls;
            g[23, 4] = overalls; g[23, 5] = overalls; g[23, 6] = overalls; g[23, 7] = overalls;
            g[23, 9] = overalls; g[23, 10] = overalls;
            g[24, 5] = overalls; g[24, 6] = overalls; g[24, 7] = overalls;
            g[24, 10] = overalls; g[24, 11] = overalls;
            for (int x = 6; x <= 8; x++) g[25, x] = BRN;
            g[25, 10] = BRN; g[25, 11] = BRN;
            for (int x = 6; x <= 9; x++) g[26, x] = BRN;
            g[26, 11] = BRN; g[26, 12] = BRN;
            for (int x = 7; x <= 10; x++) g[27, x] = BRN;
            g[27, 12] = BRN; g[27, 13] = BRN;
        }
        else if (frame == 2) // walk2 - legs closer
        {
            g[22, 5] = overalls; g[22, 6] = overalls;
            g[22, 8] = overalls; g[22, 9] = overalls;
            g[23, 5] = overalls; g[23, 6] = overalls;
            g[23, 8] = overalls; g[23, 9] = overalls;
            g[24, 4] = overalls; g[24, 5] = overalls;
            g[24, 9] = overalls; g[24, 10] = overalls;
            for (int x = 3; x <= 6; x++) g[25, x] = BRN;
            for (int x = 9; x <= 11; x++) g[25, x] = BRN;
            for (int x = 3; x <= 6; x++) g[26, x] = BRN;
            for (int x = 9; x <= 12; x++) g[26, x] = BRN;
            for (int x = 2; x <= 5; x++) g[27, x] = BRN;
            for (int x = 9; x <= 12; x++) g[27, x] = BRN;
        }
        else // jump - one arm up, legs asymmetric
        {
            g[9, 2] = SKIN; g[9, 3] = SKIN;  // Raised arm
            g[22, 3] = overalls; g[22, 4] = overalls; g[22, 5] = hat;
            g[22, 10] = overalls; g[22, 11] = overalls;
            g[23, 2] = overalls; g[23, 3] = overalls; g[23, 4] = hat;
            g[23, 11] = overalls; g[23, 12] = overalls;
            g[24, 1] = BRN; g[24, 2] = BRN; g[24, 3] = BRN;
            g[24, 12] = overalls; g[24, 13] = overalls;
            g[25, 1] = BRN; g[25, 2] = BRN; g[25, 3] = BRN;
            g[25, 13] = BRN; g[25, 14] = BRN;
            g[26, 1] = BRN; g[26, 2] = BRN;
            g[26, 13] = BRN; g[26, 14] = BRN;
        }

        return From2D(g);
    }

    private Texture2D GenerateBigMarioDuck(bool fire = false)
    {
        Color hat = fire ? WHT : RED;
        Color overalls = fire ? BRN : BLU;

        // Ducking sprite is 16px tall, placed in a 32x16 texture at the bottom
        var g = new Color[32, 16];
        for (int y = 0; y < 32; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = T;

        // Draw duck sprite in bottom 16 rows (rows 16-31)
        int oy = 16;
        // Hat/head compressed
        for (int x = 4; x <= 9; x++) g[oy + 0, x] = hat;
        for (int x = 3; x <= 12; x++) g[oy + 1, x] = hat;
        for (int x = 3; x <= 12; x++) g[oy + 2, x] = hat;
        for (int x = 3; x <= 5; x++) g[oy + 3, x] = BRN;
        for (int x = 6; x <= 8; x++) g[oy + 3, x] = SKIN;
        g[oy + 3, 9] = BLK; g[oy + 3, 10] = SKIN;
        for (int x = 5; x <= 11; x++) g[oy + 4, x] = SKIN;

        // Body compressed
        for (int x = 3; x <= 11; x++) g[oy + 5, x] = hat;
        for (int x = 2; x <= 12; x++) g[oy + 6, x] = hat;
        for (int x = 2; x <= 12; x++) g[oy + 7, x] = overalls;
        g[oy + 7, 4] = YLW; g[oy + 7, 10] = YLW;
        for (int x = 2; x <= 12; x++) g[oy + 8, x] = overalls;
        for (int x = 2; x <= 12; x++) g[oy + 9, x] = overalls;
        for (int x = 3; x <= 11; x++) g[oy + 10, x] = overalls;
        // Shoes
        for (int x = 2; x <= 5; x++) g[oy + 11, x] = BRN;
        for (int x = 9; x <= 12; x++) g[oy + 11, x] = BRN;
        for (int x = 1; x <= 6; x++) g[oy + 12, x] = BRN;
        for (int x = 8; x <= 13; x++) g[oy + 12, x] = BRN;

        return From2D(g);
    }
    #endregion

    #region Enemies
    private void GenerateEnemies()
    {
        // Goomba - frame 0
        Color GB = new(172, 80, 0);       // goomba brown
        Color GD = new(116, 52, 0);      // goomba dark brown

        Textures["goomba0"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   T,   GB,  GB,  GB,  GB,  T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   GB,  GB,  GB,  GB,  GB,  GB,  T,   T,   T,   T,   T },
            { T,   T,   T,   T,   GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  T,   T,   T,   T },
            { T,   T,   T,   GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  T,   T,   T },
            { T,   T,   GB,  GB,  BLK, BLK, GB,  GB,  GB,  GB,  BLK, BLK, GB,  GB,  T,   T },
            { T,   GB,  GB,  BLK, WHT, BLK, GB,  GB,  GB,  GB,  BLK, WHT, BLK, GB,  GB,  T },
            { T,   GB,  GB,  BLK, BLK, GB,  GB,  GB,  GB,  GB,  GB,  BLK, BLK, GB,  GB,  T },
            { T,   GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  T },
            { T,   T,   GB,  GB,  GB,  GB,  GD,  GD,  GD,  GD,  GB,  GB,  GB,  GB,  T,   T },
            { T,   T,   T,   T,   GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  T,   T,   T,   T },
            { T,   T,   T,   GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  T,   T,   T },
            { T,   T,   GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  T,   T },
            { T,   T,   T,   SKIN,SKIN,GD,  GD,  GD,  GD,  GD,  GD,  SKIN,SKIN,T,   T,   T },
            { T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T },
            { T,   BLK, BLK, BLK, SKIN,SKIN,T,   T,   T,   T,   SKIN,SKIN,BLK, BLK, BLK, T },
            { BLK, BLK, BLK, BLK, BLK, T,   T,   T,   T,   T,   T,   BLK, BLK, BLK, BLK, BLK },
        });

        // Goomba frame 1 (mirrored feet)
        Textures["goomba1"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   T,   GB,  GB,  GB,  GB,  T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   GB,  GB,  GB,  GB,  GB,  GB,  T,   T,   T,   T,   T },
            { T,   T,   T,   T,   GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  T,   T,   T,   T },
            { T,   T,   T,   GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  T,   T,   T },
            { T,   T,   GB,  GB,  BLK, BLK, GB,  GB,  GB,  GB,  BLK, BLK, GB,  GB,  T,   T },
            { T,   GB,  GB,  BLK, WHT, BLK, GB,  GB,  GB,  GB,  BLK, WHT, BLK, GB,  GB,  T },
            { T,   GB,  GB,  BLK, BLK, GB,  GB,  GB,  GB,  GB,  GB,  BLK, BLK, GB,  GB,  T },
            { T,   GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  GB,  T },
            { T,   T,   GB,  GB,  GB,  GB,  GD,  GD,  GD,  GD,  GB,  GB,  GB,  GB,  T,   T },
            { T,   T,   T,   T,   GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  T,   T,   T,   T },
            { T,   T,   T,   GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  T,   T,   T },
            { T,   T,   GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  GD,  T,   T },
            { T,   T,   T,   GD,  GD,  SKIN,SKIN,T,   T,   SKIN,SKIN,GD,  GD,  T,   T,   T },
            { T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T },
            { T,   SKIN,SKIN,BLK, BLK, BLK, T,   T,   T,   T,   BLK, BLK, BLK, SKIN,SKIN, T },
            { T,   T,   BLK, BLK, BLK, BLK, BLK, T,   T,   BLK, BLK, BLK, BLK, BLK, T,   T },
        });

        // Goomba flat (stomped)
        var flat = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
                flat[y, x] = T;
        for (int x = 1; x <= 14; x++) flat[14, x] = GD;
        for (int x = 2; x <= 13; x++) flat[15, x] = GD;
        flat[14, 4] = BLK; flat[14, 5] = BLK; flat[14, 10] = BLK; flat[14, 11] = BLK;
        Textures["goomba_flat"] = From2D(flat);

        // Koopa (green turtle) - simplified
        Textures["koopa0"] = GenerateKoopa(0);
        Textures["koopa1"] = GenerateKoopa(1);
        Textures["koopa_shell"] = GenerateShell();
    }

    private Texture2D GenerateKoopa(int frame)
    {
        var g = new Color[24, 16];
        for (int y = 0; y < 24; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = T;

        // Head
        for (int x = 7; x <= 12; x++) g[0, x] = GRN;
        for (int x = 6; x <= 13; x++) g[1, x] = GRN;
        for (int x = 6; x <= 13; x++) g[2, x] = GRN;
        g[2, 10] = WHT; g[2, 11] = WHT;
        for (int x = 6; x <= 13; x++) g[3, x] = GRN;
        g[3, 10] = WHT; g[3, 11] = BLK; g[3, 12] = SKIN;
        for (int x = 7; x <= 13; x++) g[4, x] = GRN;
        g[4, 12] = SKIN; g[4, 13] = SKIN;
        for (int x = 8; x <= 11; x++) g[5, x] = GRN;

        // Shell body
        for (int x = 3; x <= 11; x++) g[6, x] = GRN;
        for (int x = 2; x <= 12; x++) g[7, x] = GRN;
        for (int x = 2; x <= 12; x++) g[8, x] = DRK_GRN;
        g[8, 5] = YLW; g[8, 6] = YLW; g[8, 9] = YLW; g[8, 10] = YLW;
        for (int x = 2; x <= 12; x++) g[9, x] = DRK_GRN;
        for (int x = 2; x <= 12; x++) g[10, x] = GRN;
        for (int x = 3; x <= 11; x++) g[11, x] = GRN;

        // Feet
        if (frame == 0)
        {
            for (int x = 3; x <= 5; x++) g[12, x] = SKIN;
            for (int x = 9; x <= 11; x++) g[12, x] = SKIN;
            for (int x = 2; x <= 5; x++) g[13, x] = SKIN;
            for (int x = 9; x <= 12; x++) g[13, x] = SKIN;
        }
        else
        {
            for (int x = 4; x <= 6; x++) g[12, x] = SKIN;
            for (int x = 8; x <= 10; x++) g[12, x] = SKIN;
            for (int x = 5; x <= 7; x++) g[13, x] = SKIN;
            for (int x = 7; x <= 9; x++) g[13, x] = SKIN;
        }

        // Place in 24-tall texture, bottom-aligned to 24px
        // Already positioned from top, shift down to fill 24px
        var result = new Color[24, 16];
        for (int y = 0; y < 24; y++)
            for (int x = 0; x < 16; x++)
                result[y, x] = T;
        for (int y = 0; y < 14; y++)
            for (int x = 0; x < 16; x++)
                result[y + 10, x] = g[y, x];

        return From2D(result);
    }

    private Texture2D GenerateShell()
    {
        var g = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
                g[y, x] = T;

        for (int x = 4; x <= 11; x++) g[2, x] = GRN;
        for (int x = 3; x <= 12; x++) g[3, x] = GRN;
        for (int x = 2; x <= 13; x++) g[4, x] = GRN;
        for (int x = 2; x <= 13; x++) g[5, x] = DRK_GRN;
        g[5, 5] = YLW; g[5, 6] = YLW; g[5, 9] = YLW; g[5, 10] = YLW;
        for (int x = 2; x <= 13; x++) g[6, x] = DRK_GRN;
        for (int x = 2; x <= 13; x++) g[7, x] = DRK_GRN;
        for (int x = 2; x <= 13; x++) g[8, x] = GRN;
        for (int x = 2; x <= 13; x++) g[9, x] = GRN;
        for (int x = 3; x <= 12; x++) g[10, x] = GRN;
        for (int x = 3; x <= 12; x++) g[11, x] = WHT;
        for (int x = 4; x <= 11; x++) g[12, x] = WHT;
        for (int x = 5; x <= 10; x++) g[13, x] = WHT;

        return From2D(g);
    }
    #endregion

    #region Items
    private void GenerateItems()
    {
        // Coin (spinning) - single frame
        Textures["coin"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   YLW, YLW, ORG, ORG, YLW, YLW, T,   T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, YLW, ORG, YLW, YLW, ORG, YLW, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   YLW, YLW, ORG, YLW, YLW, ORG, YLW, YLW, T,   T,   T,   T },
            { T,   T,   T,   T,   T,   YLW, YLW, ORG, ORG, YLW, YLW, T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
        });

        // Mushroom (super mushroom - red with white dots)
        Color MR = new(200, 36, 0); // mushroom red
        Textures["mushroom"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   MR,  MR,  MR,  MR,  MR,  MR,  T,   T,   T,   T,   T },
            { T,   T,   T,   MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  T,   T,   T },
            { T,   T,   MR,  MR,  WHT, WHT, MR,  MR,  MR,  MR,  WHT, WHT, MR,  MR,  T,   T },
            { T,   MR,  MR,  WHT, WHT, WHT, WHT, MR,  MR,  WHT, WHT, WHT, WHT, MR,  MR,  T },
            { T,   MR,  WHT, WHT, WHT, WHT, MR,  MR,  MR,  MR,  WHT, WHT, WHT, WHT, MR,  T },
            { MR,  MR,  MR,  WHT, WHT, MR,  MR,  MR,  MR,  MR,  MR,  WHT, WHT, MR,  MR,  MR },
            { MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR },
            { MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR,  MR },
            { T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T },
            { T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T },
            { T,   SKIN,BLK, BLK, BLK, BLK, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, SKIN,T },
            { T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T },
            { T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T },
            { T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
        });

        // Fire flower
        Color FO = new(228, 92, 16);  // fire orange
        Textures["fireflower"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   T,   RED, RED, RED, RED, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   RED, RED, RED, YLW, YLW, RED, RED, RED, T,   T,   T,   T },
            { T,   T,   T,   RED, RED, YLW, FO,  FO,  FO,  FO,  YLW, RED, RED, T,   T,   T },
            { T,   T,   RED, RED, YLW, FO,  FO,  WHT, WHT, FO,  FO,  YLW, RED, RED, T,   T },
            { T,   T,   RED, YLW, FO,  FO,  WHT, WHT, WHT, WHT, FO,  FO,  YLW, RED, T,   T },
            { T,   T,   RED, YLW, FO,  FO,  WHT, WHT, WHT, WHT, FO,  FO,  YLW, RED, T,   T },
            { T,   T,   RED, RED, YLW, FO,  FO,  FO,  FO,  FO,  FO,  YLW, RED, RED, T,   T },
            { T,   T,   T,   RED, RED, YLW, FO,  FO,  FO,  FO,  YLW, RED, RED, T,   T,   T },
            { T,   T,   T,   T,   T,   GRN, GRN, GRN, GRN, GRN, GRN, T,   T,   T,   T,   T },
            { T,   T,   T,   T,   GRN, GRN, T,   GRN, GRN, T,   GRN, GRN, T,   T,   T,   T },
            { T,   T,   T,   GRN, GRN, T,   T,   GRN, GRN, T,   T,   GRN, GRN, T,   T,   T },
            { T,   T,   T,   GRN, T,   T,   T,   GRN, GRN, T,   T,   T,   GRN, T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   GRN, GRN, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   GRN, GRN, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   GRN, GRN, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
        });

        // Star (starman)
        Textures["star"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   T,   T,   YLW, YLW, T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, YLW, YLW, T,   T,   T,   T,   T },
            { YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW },
            { T,   YLW, YLW, YLW, YLW, YLW, ORG, ORG, ORG, ORG, YLW, YLW, YLW, YLW, YLW, T },
            { T,   T,   YLW, YLW, YLW, ORG, ORG, BLK, BLK, ORG, ORG, YLW, YLW, YLW, T,   T },
            { T,   T,   T,   YLW, YLW, ORG, BLK, ORG, ORG, BLK, ORG, YLW, YLW, T,   T,   T },
            { T,   T,   T,   YLW, YLW, ORG, ORG, ORG, ORG, ORG, ORG, YLW, YLW, T,   T,   T },
            { T,   T,   T,   YLW, YLW, YLW, ORG, ORG, ORG, ORG, YLW, YLW, YLW, T,   T,   T },
            { T,   T,   T,   T,   YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, T,   T,   T,   T },
            { T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   YLW, YLW, YLW, YLW, T,   T,   T },
            { T,   T,   YLW, YLW, YLW, T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, T,   T },
            { T,   YLW, YLW, YLW, T,   T,   T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
        });

        // 1-Up mushroom (green)
        Textures["oneup"] = From2D(new Color[16, 16] {
            { T,   T,   T,   T,   T,   GRN, GRN, GRN, GRN, GRN, GRN, T,   T,   T,   T,   T },
            { T,   T,   T,   GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, T,   T,   T },
            { T,   T,   GRN, GRN, WHT, WHT, GRN, GRN, GRN, GRN, WHT, WHT, GRN, GRN, T,   T },
            { T,   GRN, GRN, WHT, WHT, WHT, WHT, GRN, GRN, WHT, WHT, WHT, WHT, GRN, GRN, T },
            { T,   GRN, WHT, WHT, WHT, WHT, GRN, GRN, GRN, GRN, WHT, WHT, WHT, WHT, GRN, T },
            { GRN, GRN, GRN, WHT, WHT, GRN, GRN, GRN, GRN, GRN, GRN, WHT, WHT, GRN, GRN, GRN },
            { GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN },
            { GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN },
            { T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T },
            { T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T },
            { T,   SKIN,BLK, BLK, BLK, BLK, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, SKIN,T },
            { T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T },
            { T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T },
            { T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T },
            { T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T },
        });

        // Brick debris (small particle)
        var debris = new Color[8, 8];
        for (int y = 0; y < 8; y++)
            for (int x = 0; x < 8; x++)
                debris[y, x] = (x == 0 || x == 7 || y == 0 || y == 7) ? BLK : RED;
        Textures["brick_debris"] = From2D(debris);

        // Coin popup (score coin that appears from blocks)
        Textures["coin_popup"] = Textures["coin"];
    }
    #endregion

    #region Fireball
    private void GenerateFireball()
    {
        var g = new Color[8, 8];
        Color FR = new(252, 152, 56);
        for (int y = 0; y < 8; y++)
            for (int x = 0; x < 8; x++)
                g[y, x] = T;
        for (int x = 2; x <= 5; x++) g[1, x] = FR;
        for (int x = 1; x <= 6; x++) g[2, x] = YLW;
        for (int x = 1; x <= 6; x++) g[3, x] = YLW;
        for (int x = 1; x <= 6; x++) g[4, x] = FR;
        for (int x = 1; x <= 6; x++) g[5, x] = FR;
        for (int x = 2; x <= 5; x++) g[6, x] = RED;
        Textures["fireball"] = From2D(g);
    }
    #endregion

    #region Bowser Easter Egg
    private void GenerateBowser()
    {
        // Mini Bowser pointing/laughing frame 0 (24x32)
        // Simplified NES-style: spiked shell (GRN), red body, yellow belly, horns
        var g0 = new Color[32, 24];
        for (int y = 0; y < 32; y++)
            for (int x = 0; x < 24; x++)
                g0[y, x] = T;

        // Horns (rows 0-3)
        g0[0, 6] = YLW; g0[0, 7] = YLW;
        g0[0, 15] = YLW; g0[0, 16] = YLW;
        g0[1, 7] = YLW; g0[1, 8] = YLW;
        g0[1, 14] = YLW; g0[1, 15] = YLW;
        g0[2, 8] = YLW; g0[2, 9] = YLW;
        g0[2, 13] = YLW; g0[2, 14] = YLW;

        // Head (rows 3-9)
        for (int x = 7; x <= 16; x++) g0[3, x] = GRN;
        for (int x = 6; x <= 17; x++) g0[4, x] = GRN;
        for (int x = 6; x <= 17; x++) g0[5, x] = GRN;
        // Eyes
        g0[5, 8] = WHT; g0[5, 9] = WHT; g0[5, 10] = BLK;
        g0[5, 13] = BLK; g0[5, 14] = WHT; g0[5, 15] = WHT;
        for (int x = 6; x <= 17; x++) g0[6, x] = GRN;
        g0[6, 8] = WHT; g0[6, 9] = BLK; g0[6, 10] = BLK;
        g0[6, 13] = BLK; g0[6, 14] = BLK; g0[6, 15] = WHT;
        // Snout/mouth
        for (int x = 7; x <= 16; x++) g0[7, x] = GRN;
        g0[7, 10] = SKIN; g0[7, 11] = SKIN; g0[7, 12] = SKIN; g0[7, 13] = SKIN;
        for (int x = 8; x <= 15; x++) g0[8, x] = GRN;
        // Open mouth (laughing)
        g0[8, 9] = SKIN; g0[8, 10] = RED; g0[8, 11] = RED;
        g0[8, 12] = RED; g0[8, 13] = RED; g0[8, 14] = SKIN;
        for (int x = 9; x <= 14; x++) g0[9, x] = SKIN;
        g0[9, 10] = RED; g0[9, 11] = RED; g0[9, 12] = RED; g0[9, 13] = RED;

        // Body (rows 10-17) — red torso, yellow belly
        for (int x = 5; x <= 18; x++) g0[10, x] = RED;
        for (int x = 4; x <= 19; x++) g0[11, x] = RED;
        for (int x = 9; x <= 14; x++) g0[11, x] = YLW;
        for (int x = 4; x <= 19; x++) g0[12, x] = RED;
        for (int x = 8; x <= 15; x++) g0[12, x] = YLW;
        for (int x = 4; x <= 19; x++) g0[13, x] = RED;
        for (int x = 8; x <= 15; x++) g0[13, x] = YLW;
        for (int x = 4; x <= 19; x++) g0[14, x] = RED;
        for (int x = 9; x <= 14; x++) g0[14, x] = YLW;
        for (int x = 5; x <= 18; x++) g0[15, x] = RED;

        // Pointing arm (right side, extends out) — frame 0
        g0[11, 20] = RED; g0[11, 21] = RED; g0[11, 22] = SKIN;
        g0[12, 20] = RED; g0[12, 21] = SKIN; g0[12, 22] = SKIN; g0[12, 23] = SKIN;
        g0[13, 20] = RED; g0[13, 21] = RED; g0[13, 22] = SKIN;

        // Shell (rows 16-22) — green with spikes
        for (int x = 5; x <= 18; x++) g0[16, x] = GRN;
        for (int x = 4; x <= 19; x++) g0[17, x] = GRN;
        // Spike details
        g0[16, 7] = YLW; g0[16, 11] = YLW; g0[16, 15] = YLW;
        for (int x = 4; x <= 19; x++) g0[18, x] = DRK_GRN;
        for (int x = 4; x <= 19; x++) g0[19, x] = DRK_GRN;
        for (int x = 5; x <= 18; x++) g0[20, x] = GRN;
        for (int x = 6; x <= 17; x++) g0[21, x] = GRN;
        for (int x = 7; x <= 16; x++) g0[22, x] = GRN;

        // Tail (left side)
        g0[18, 2] = GRN; g0[18, 3] = GRN;
        g0[19, 1] = GRN; g0[19, 2] = GRN; g0[19, 3] = GRN;
        g0[20, 2] = GRN; g0[20, 3] = GRN; g0[20, 4] = GRN;

        // Legs/feet (rows 23-27)
        for (int x = 6; x <= 9; x++) g0[23, x] = RED;
        for (int x = 14; x <= 17; x++) g0[23, x] = RED;
        for (int x = 6; x <= 9; x++) g0[24, x] = RED;
        for (int x = 14; x <= 17; x++) g0[24, x] = RED;
        for (int x = 5; x <= 9; x++) g0[25, x] = RED;
        for (int x = 14; x <= 18; x++) g0[25, x] = RED;
        // Claws
        for (int x = 4; x <= 10; x++) g0[26, x] = SKIN;
        for (int x = 13; x <= 19; x++) g0[26, x] = SKIN;
        for (int x = 4; x <= 10; x++) g0[27, x] = SKIN;
        for (int x = 13; x <= 19; x++) g0[27, x] = SKIN;

        Textures["bowser0"] = From2D(g0);

        // Frame 1: same but arm slightly different position (more animated laugh)
        var g1 = (Color[,])g0.Clone();
        // Clear old arm
        g1[11, 20] = T; g1[11, 21] = T; g1[11, 22] = T;
        g1[12, 20] = T; g1[12, 21] = T; g1[12, 22] = T; g1[12, 23] = T;
        g1[13, 20] = T; g1[13, 21] = T; g1[13, 22] = T;
        // Arm raised slightly
        g1[10, 20] = RED; g1[10, 21] = SKIN;
        g1[11, 20] = RED; g1[11, 21] = RED; g1[11, 22] = SKIN; g1[11, 23] = SKIN;
        g1[12, 20] = RED; g1[12, 21] = SKIN;
        // Mouth slightly different
        g1[9, 10] = WHT; g1[9, 13] = WHT; // teeth showing

        Textures["bowser1"] = From2D(g1);

        // Mini explosion sprite (16x16) — starburst with spiky rays
        var poof = new Color[16, 16];
        for (int y = 0; y < 16; y++)
            for (int x = 0; x < 16; x++)
                poof[y, x] = T;
        // Center white flash
        for (int x = 6; x <= 9; x++)
            for (int y = 6; y <= 9; y++)
                poof[y, x] = WHT;
        // Yellow ring around center
        for (int x = 5; x <= 10; x++) { poof[5, x] = YLW; poof[10, x] = YLW; }
        for (int y = 5; y <= 10; y++) { poof[y, 5] = YLW; poof[y, 10] = YLW; }
        // Orange spike rays outward (4 cardinal + 4 diagonal)
        // Up
        poof[3, 7] = ORG; poof[3, 8] = ORG; poof[2, 7] = RED; poof[2, 8] = RED;
        poof[0, 7] = ORG; poof[0, 8] = ORG;
        // Down
        poof[12, 7] = ORG; poof[12, 8] = ORG; poof[13, 7] = RED; poof[13, 8] = RED;
        poof[15, 7] = ORG; poof[15, 8] = ORG;
        // Left
        poof[7, 3] = ORG; poof[8, 3] = ORG; poof[7, 2] = RED; poof[8, 2] = RED;
        poof[7, 0] = ORG; poof[8, 0] = ORG;
        // Right
        poof[7, 12] = ORG; poof[8, 12] = ORG; poof[7, 13] = RED; poof[8, 13] = RED;
        poof[7, 15] = ORG; poof[8, 15] = ORG;
        // Diagonal spikes
        poof[4, 4] = YLW; poof[3, 3] = ORG; poof[1, 1] = RED;
        poof[4, 11] = YLW; poof[3, 12] = ORG; poof[1, 14] = RED;
        poof[11, 4] = YLW; poof[12, 3] = ORG; poof[14, 1] = RED;
        poof[11, 11] = YLW; poof[12, 12] = ORG; poof[14, 14] = RED;

        Textures["bowser_poof"] = From2D(poof);
    }
    #endregion

    #region Font
    private void GenerateFont()
    {
        // Simple 5x7 bitmap font for 0-9, A-Z, and some symbols
        string[] chars = {
            "0","1","2","3","4","5","6","7","8","9",
            "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
            "-","x","!",".",":"," "
        };

        // 5x7 font patterns (1 = pixel on)
        byte[][] patterns = {
            new byte[]{0x0E,0x11,0x13,0x15,0x19,0x11,0x0E}, // 0
            new byte[]{0x04,0x0C,0x04,0x04,0x04,0x04,0x0E}, // 1
            new byte[]{0x0E,0x11,0x01,0x06,0x08,0x10,0x1F}, // 2
            new byte[]{0x0E,0x11,0x01,0x06,0x01,0x11,0x0E}, // 3
            new byte[]{0x02,0x06,0x0A,0x12,0x1F,0x02,0x02}, // 4
            new byte[]{0x1F,0x10,0x1E,0x01,0x01,0x11,0x0E}, // 5
            new byte[]{0x06,0x08,0x10,0x1E,0x11,0x11,0x0E}, // 6
            new byte[]{0x1F,0x01,0x02,0x04,0x08,0x08,0x08}, // 7
            new byte[]{0x0E,0x11,0x11,0x0E,0x11,0x11,0x0E}, // 8
            new byte[]{0x0E,0x11,0x11,0x0F,0x01,0x02,0x0C}, // 9
            new byte[]{0x0E,0x11,0x11,0x1F,0x11,0x11,0x11}, // A
            new byte[]{0x1E,0x11,0x11,0x1E,0x11,0x11,0x1E}, // B
            new byte[]{0x0E,0x11,0x10,0x10,0x10,0x11,0x0E}, // C
            new byte[]{0x1E,0x11,0x11,0x11,0x11,0x11,0x1E}, // D
            new byte[]{0x1F,0x10,0x10,0x1E,0x10,0x10,0x1F}, // E
            new byte[]{0x1F,0x10,0x10,0x1E,0x10,0x10,0x10}, // F
            new byte[]{0x0E,0x11,0x10,0x17,0x11,0x11,0x0F}, // G
            new byte[]{0x11,0x11,0x11,0x1F,0x11,0x11,0x11}, // H
            new byte[]{0x0E,0x04,0x04,0x04,0x04,0x04,0x0E}, // I
            new byte[]{0x07,0x02,0x02,0x02,0x02,0x12,0x0C}, // J
            new byte[]{0x11,0x12,0x14,0x18,0x14,0x12,0x11}, // K
            new byte[]{0x10,0x10,0x10,0x10,0x10,0x10,0x1F}, // L
            new byte[]{0x11,0x1B,0x15,0x15,0x11,0x11,0x11}, // M
            new byte[]{0x11,0x11,0x19,0x15,0x13,0x11,0x11}, // N
            new byte[]{0x0E,0x11,0x11,0x11,0x11,0x11,0x0E}, // O
            new byte[]{0x1E,0x11,0x11,0x1E,0x10,0x10,0x10}, // P
            new byte[]{0x0E,0x11,0x11,0x11,0x15,0x12,0x0D}, // Q
            new byte[]{0x1E,0x11,0x11,0x1E,0x14,0x12,0x11}, // R
            new byte[]{0x0E,0x11,0x10,0x0E,0x01,0x11,0x0E}, // S
            new byte[]{0x1F,0x04,0x04,0x04,0x04,0x04,0x04}, // T
            new byte[]{0x11,0x11,0x11,0x11,0x11,0x11,0x0E}, // U
            new byte[]{0x11,0x11,0x11,0x11,0x0A,0x0A,0x04}, // V
            new byte[]{0x11,0x11,0x11,0x15,0x15,0x1B,0x11}, // W
            new byte[]{0x11,0x11,0x0A,0x04,0x0A,0x11,0x11}, // X
            new byte[]{0x11,0x11,0x0A,0x04,0x04,0x04,0x04}, // Y
            new byte[]{0x1F,0x01,0x02,0x04,0x08,0x10,0x1F}, // Z
            new byte[]{0x00,0x00,0x00,0x1F,0x00,0x00,0x00}, // -
            new byte[]{0x00,0x11,0x0A,0x04,0x0A,0x11,0x00}, // x (multiply)
            new byte[]{0x04,0x04,0x04,0x04,0x04,0x00,0x04}, // !
            new byte[]{0x00,0x00,0x00,0x00,0x00,0x00,0x04}, // .
            new byte[]{0x00,0x04,0x00,0x00,0x00,0x04,0x00}, // :
            new byte[]{0x00,0x00,0x00,0x00,0x00,0x00,0x00}, // space
        };

        for (int i = 0; i < chars.Length; i++)
        {
            var data = new Color[7 * 5];
            for (int y = 0; y < 7; y++)
                for (int x = 0; x < 5; x++)
                    data[y * 5 + x] = ((patterns[i][y] >> (4 - x)) & 1) == 1 ? WHT : T;
            var tex = new Texture2D(_gd, 5, 7);
            tex.SetData(data);
            Textures["font_" + chars[i]] = tex;
        }
    }
    #endregion

    // Helper to create a simple 1x1 white pixel
    public Texture2D CreatePixel()
    {
        var tex = new Texture2D(_gd, 1, 1);
        tex.SetData(new[] { Color.White });
        return tex;
    }
}
