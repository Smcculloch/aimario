using AIMario.Core;
using AIMario.Entities.Enemies;
using AIMario.Graphics;
using AIMario.Tiles;
using Microsoft.Xna.Framework;
using System.Collections.Generic;

namespace AIMario.Level;

public static class LevelLoader
{
    public static (Tile[,] tiles, List<Enemy> enemies) Load(SpriteGenerator sprites)
    {
        var mapData = LevelData.GetWorld1_1();
        var blockContents = LevelData.GetBlockContents();
        var enemySpawns = LevelData.GetEnemySpawns();

        int h = Constants.LevelHeightTiles;
        int w = Constants.LevelWidthTiles;
        var tiles = new Tile[h, w];

        // Create tiles
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                var type = (TileType)mapData[y, x];
                if (type == TileType.Empty) continue;

                var tile = new Tile(type, x, y);

                // Set block contents
                if (blockContents.TryGetValue((x, y), out var content))
                    tile.Content = content;

                tiles[y, x] = tile;
            }
        }

        // Create enemies
        var enemies = new List<Enemy>();
        foreach (var spawn in enemySpawns)
        {
            Enemy enemy = spawn.Type switch
            {
                EnemyType.Goomba => new Goomba(sprites),
                EnemyType.Koopa => new Koopa(sprites),
                _ => null
            };

            if (enemy != null)
            {
                enemy.Position = new Vector2(
                    spawn.X * Constants.TileSize + 1,
                    spawn.Y * Constants.TileSize - enemy.Body.Height);
                enemies.Add(enemy);
            }
        }

        return (tiles, enemies);
    }
}
