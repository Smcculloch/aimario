using AIMario.Core;
using AIMario.Tiles;
using Microsoft.Xna.Framework;
using System.Collections.Generic;

namespace AIMario.Level;

public static class LevelData
{
    // World 1-1 tile map (15 rows x 224 columns)
    // Row 0 = top, Row 14 = bottom
    // Ground is rows 13-14
    public static int[,] GetWorld1_1()
    {
        int W = 224, H = 15;
        var map = new int[H, W];

        // Fill ground (rows 13-14)
        for (int x = 0; x < W; x++)
        {
            map[13, x] = (int)TileType.Ground;
            map[14, x] = (int)TileType.Ground;
        }

        // Gaps (pits) - remove ground
        // Pit 1: around tile 69-70
        ClearGround(map, 69, 70);
        // Pit 2: around tile 86-88
        ClearGround(map, 86, 88);
        // Pit 3: around tile 153-154
        ClearGround(map, 153, 154);

        // Question blocks with coins (row 9 = 5 tiles above ground)
        SetTile(map, 16, 9, TileType.Question);  // First ? block (coin)
        SetTile(map, 20, 9, TileType.Brick);
        SetTile(map, 21, 9, TileType.Question);  // ? block (mushroom - handled in content)
        SetTile(map, 22, 9, TileType.Brick);
        SetTile(map, 23, 9, TileType.Question);  // ? block (coin)
        SetTile(map, 22, 5, TileType.Question);  // High ? block (1-up - hidden in content setup)

        // Pipes (original World 1-1 heights)
        // Pipe 1: x=28-29, 2 tiles tall (rows 11-12)
        SetPipe(map, 28, 11, 2);
        // Pipe 2: x=38-39, 3 tiles tall (rows 10-12)
        SetPipe(map, 38, 10, 3);
        // Pipe 3: x=46-47, 4 tiles tall (rows 9-12)
        SetPipe(map, 46, 9, 4);
        // Pipe 4: x=57-58, 4 tiles tall (rows 9-12)
        SetPipe(map, 57, 9, 4);

        // Exit pipe from underground: x=163, 2 tiles tall (rows 11-12)
        SetPipe(map, 163, 11, 2);

        // Brick/block formations above first area
        // Block formation after underground exit area
        SetTile(map, 77, 9, TileType.Question);  // ? (coin)
        // Brick row
        SetTile(map, 80, 9, TileType.Brick);
        SetTile(map, 81, 5, TileType.Brick);
        SetTile(map, 82, 5, TileType.Brick);
        SetTile(map, 83, 5, TileType.Brick);
        SetTile(map, 84, 5, TileType.Brick);
        SetTile(map, 85, 5, TileType.Brick);
        SetTile(map, 86, 5, TileType.Brick);
        SetTile(map, 87, 5, TileType.Brick);
        SetTile(map, 88, 5, TileType.Brick);

        // High brick row with coins
        SetTile(map, 91, 5, TileType.Brick);
        SetTile(map, 92, 5, TileType.Brick);
        SetTile(map, 93, 5, TileType.Brick);
        SetTile(map, 94, 9, TileType.Question);  // ? (coin)

        // Block staircase section
        SetTile(map, 100, 9, TileType.Brick);
        SetTile(map, 101, 9, TileType.Question);
        SetTile(map, 102, 9, TileType.Brick);
        SetTile(map, 101, 5, TileType.Question);  // High ? (star)

        // Brick blocks
        SetTile(map, 106, 9, TileType.Question);
        SetTile(map, 109, 9, TileType.Question);
        SetTile(map, 109, 5, TileType.Question);
        SetTile(map, 112, 9, TileType.Question);

        // Brick rows
        SetTile(map, 118, 9, TileType.Brick);
        SetTile(map, 119, 5, TileType.Brick);
        SetTile(map, 120, 5, TileType.Brick);
        SetTile(map, 121, 5, TileType.Brick);

        SetTile(map, 128, 5, TileType.Brick);
        SetTile(map, 129, 5, TileType.Question);
        SetTile(map, 130, 5, TileType.Question);
        SetTile(map, 131, 5, TileType.Brick);

        SetTile(map, 129, 9, TileType.Brick);
        SetTile(map, 130, 9, TileType.Brick);

        // Stairs before flagpole (right side)
        // Staircase 1: around x=134
        BuildStair(map, 134, 12, 4, true);  // ascending right

        // Staircase 2: around x=140
        BuildStair(map, 140, 12, 4, true);
        BuildStair(map, 144, 12, 4, false); // descending

        // Staircase 3: around x=148
        BuildStair(map, 148, 12, 4, true);
        BuildStair(map, 152, 12, 5, false);

        // Final staircase to flagpole
        BuildStair(map, 181, 12, 4, true);
        BuildStair(map, 185, 12, 4, false);

        // Second set of stairs near end
        BuildStair(map, 189, 12, 4, true);
        BuildStair(map, 193, 12, 4, false);

        // Final staircase (8-block tall) at end
        BuildStair(map, 198, 12, 8, true);

        // Flagpole at x=206
        for (int y = 2; y <= 12; y++)
            SetTile(map, 206, y, TileType.FlagPole);
        SetTile(map, 206, 1, TileType.FlagTop);

        // Castle hint (hard blocks at end)
        for (int x = 208; x <= 212; x++)
        {
            for (int y = 9; y <= 12; y++)
                SetTile(map, x, y, TileType.HardBlock);
        }
        for (int x = 209; x <= 211; x++)
        {
            SetTile(map, x, 8, TileType.HardBlock);
        }
        SetTile(map, 210, 7, TileType.HardBlock);

        return map;
    }

    private static void SetTile(int[,] map, int x, int y, TileType type)
    {
        if (x >= 0 && x < map.GetLength(1) && y >= 0 && y < map.GetLength(0))
            map[y, x] = (int)type;
    }

    private static void ClearGround(int[,] map, int startX, int endX)
    {
        for (int x = startX; x <= endX; x++)
        {
            map[13, x] = 0;
            map[14, x] = 0;
        }
    }

    private static void SetPipe(int[,] map, int x, int topY, int height)
    {
        SetTile(map, x, topY, TileType.PipeTopLeft);
        SetTile(map, x + 1, topY, TileType.PipeTopRight);
        for (int y = topY + 1; y < topY + height; y++)
        {
            SetTile(map, x, y, TileType.PipeBodyLeft);
            SetTile(map, x + 1, y, TileType.PipeBodyRight);
        }
    }

    private static void BuildStair(int[,] map, int startX, int bottomY, int height, bool ascending)
    {
        for (int i = 0; i < height; i++)
        {
            int x = ascending ? startX + i : startX + i;
            int colHeight = ascending ? i + 1 : height - i;
            for (int h = 0; h < colHeight; h++)
            {
                SetTile(map, x, bottomY - h, TileType.HardBlock);
            }
        }
    }

    /// <summary>
    /// Returns the underground room tile map (stored in a full 224x15 grid for physics compatibility)
    /// and a list of coin positions (row, col) to spawn as static coins.
    /// Layout (16x15): rows 0-1 ceiling, rows 13-14 floor, cols 0 and 15 walls,
    /// exit pipe at x=13 y=11, coin rows at 4,6,8.
    /// </summary>
    public static (int[,] map, List<(int row, int col)> coinPositions) GetUnderground()
    {
        int W = Constants.LevelWidthTiles;
        int H = Constants.LevelHeightTiles;
        int UW = Constants.UndergroundWidthTiles;
        var map = new int[H, W];

        // Ceiling: rows 0-1
        for (int x = 0; x < UW; x++)
        {
            map[0, x] = (int)TileType.HardBlock;
            map[1, x] = (int)TileType.HardBlock;
        }

        // Floor: rows 13-14
        for (int x = 0; x < UW; x++)
        {
            map[13, x] = (int)TileType.HardBlock;
            map[14, x] = (int)TileType.HardBlock;
        }

        // Walls: column 0 and 15, rows 2-12
        for (int y = 2; y <= 12; y++)
        {
            map[y, 0] = (int)TileType.HardBlock;
            map[y, UW - 1] = (int)TileType.HardBlock;
        }

        // Exit pipe at x=13, y=11, height 2
        SetPipe(map, 13, 11, 2);

        // Coin positions: rows 4, 6, 8, columns 2-13
        var coinPositions = new List<(int row, int col)>();
        int[] coinRows = { 4, 6, 8 };
        foreach (int row in coinRows)
        {
            for (int col = 2; col <= 13; col++)
            {
                coinPositions.Add((row, col));
            }
        }

        return (map, coinPositions);
    }

    // Enemy spawn data: (x_tile, y_tile, type)
    public static List<EnemySpawn> GetEnemySpawns()
    {
        return new List<EnemySpawn>
        {
            new(22, 12, EnemyType.Goomba),
            new(40, 12, EnemyType.Goomba),
            new(51, 12, EnemyType.Goomba),
            new(52, 12, EnemyType.Goomba),
            new(80, 4, EnemyType.Goomba),
            new(82, 4, EnemyType.Goomba),
            new(97, 12, EnemyType.Goomba),
            new(98, 12, EnemyType.Goomba),
            new(107, 12, EnemyType.Koopa),
            new(114, 12, EnemyType.Goomba),
            new(115, 12, EnemyType.Goomba),
            new(124, 12, EnemyType.Goomba),
            new(125, 12, EnemyType.Goomba),
            new(128, 12, EnemyType.Goomba),
            new(129, 12, EnemyType.Goomba),
            new(174, 12, EnemyType.Goomba),
            new(175, 12, EnemyType.Goomba),
        };
    }

    // Item content for specific blocks
    public static Dictionary<(int x, int y), ItemContent> GetBlockContents()
    {
        return new Dictionary<(int, int), ItemContent>
        {
            { (16, 9), ItemContent.Coin },
            { (21, 9), ItemContent.Mushroom },   // Mushroom/Fire flower
            { (23, 9), ItemContent.Coin },
            { (22, 5), ItemContent.OneUp },       // Hidden 1-up
            { (77, 9), ItemContent.Coin },
            { (94, 9), ItemContent.Coin },
            { (101, 9), ItemContent.Coin },
            { (101, 5), ItemContent.Star },
            { (106, 9), ItemContent.Mushroom },
            { (109, 9), ItemContent.Coin },
            { (109, 5), ItemContent.Bowser },     // Easter egg: mini Bowser laughs at Mario
            { (112, 9), ItemContent.Coin },
            { (129, 5), ItemContent.Coin },
            { (130, 5), ItemContent.Coin },
        };
    }
}

public struct EnemySpawn
{
    public int X, Y;
    public EnemyType Type;
    public EnemySpawn(int x, int y, EnemyType type) { X = x; Y = y; Type = type; }
}

public enum EnemyType { Goomba, Koopa }
