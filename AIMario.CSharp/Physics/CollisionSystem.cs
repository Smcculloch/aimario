using Microsoft.Xna.Framework;
using AIMario.Tiles;
using AIMario.Core;

namespace AIMario.Physics;

public class CollisionSystem
{
    private Tile[,] _tiles;

    public void SetTiles(Tile[,] tiles)
    {
        _tiles = tiles;
    }

    /// <summary>
    /// 2-pass collision: Move X, resolve X, then move Y, resolve Y.
    /// Returns which sides were hit.
    /// </summary>
    public CollisionResult MoveAndCollide(PhysicsBody body)
    {
        var result = new CollisionResult();

        // X pass
        body.Position.X += body.Velocity.X;
        ResolveX(body, ref result);

        // Y pass
        body.Position.Y += body.Velocity.Y;
        ResolveY(body, ref result);

        return result;
    }

    private void ResolveX(PhysicsBody body, ref CollisionResult result)
    {
        int tileLeft = (int)(body.Left / Constants.TileSize) - 1;
        int tileRight = (int)(body.Right / Constants.TileSize) + 1;
        int tileTop = (int)(body.Top / Constants.TileSize);
        int tileBottom = (int)((body.Bottom - 1) / Constants.TileSize);

        tileLeft = System.Math.Max(0, tileLeft);
        tileRight = System.Math.Min(Constants.LevelWidthTiles - 1, tileRight);
        tileTop = System.Math.Max(0, tileTop);
        tileBottom = System.Math.Min(Constants.LevelHeightTiles - 1, tileBottom);

        for (int y = tileTop; y <= tileBottom; y++)
        {
            for (int x = tileLeft; x <= tileRight; x++)
            {
                var tile = _tiles[y, x];
                if (tile == null || !tile.IsSolid) continue;

                var tileBounds = tile.Bounds;
                if (!Intersects(body, tileBounds)) continue;

                if (body.Velocity.X > 0)
                {
                    body.Position.X = tileBounds.Left - body.Width;
                    body.Velocity.X = 0;
                    result.HitRight = true;
                }
                else if (body.Velocity.X < 0)
                {
                    body.Position.X = tileBounds.Right;
                    body.Velocity.X = 0;
                    result.HitLeft = true;
                }
            }
        }
    }

    private void ResolveY(PhysicsBody body, ref CollisionResult result)
    {
        int tileLeft = (int)(body.Left / Constants.TileSize);
        int tileRight = (int)((body.Right - 1) / Constants.TileSize);
        int tileTop = (int)(body.Top / Constants.TileSize) - 1;
        int tileBottom = (int)(body.Bottom / Constants.TileSize) + 1;

        tileLeft = System.Math.Max(0, tileLeft);
        tileRight = System.Math.Min(Constants.LevelWidthTiles - 1, tileRight);
        tileTop = System.Math.Max(0, tileTop);
        tileBottom = System.Math.Min(Constants.LevelHeightTiles - 1, tileBottom);

        body.OnGround = false;

        for (int y = tileTop; y <= tileBottom; y++)
        {
            for (int x = tileLeft; x <= tileRight; x++)
            {
                var tile = _tiles[y, x];
                if (tile == null || !tile.IsSolid) continue;

                var tileBounds = tile.Bounds;
                if (!Intersects(body, tileBounds)) continue;

                if (body.Velocity.Y > 0)
                {
                    body.Position.Y = tileBounds.Top - body.Height;
                    body.Velocity.Y = 0;
                    body.OnGround = true;
                    result.HitBottom = true;
                }
                else if (body.Velocity.Y < 0)
                {
                    body.Position.Y = tileBounds.Bottom;
                    body.Velocity.Y = 0;
                    result.HitTop = true;
                    result.HitTile = tile;
                }
            }
        }
    }

    private bool Intersects(PhysicsBody body, Rectangle rect)
    {
        return body.Left < rect.Right &&
               body.Right > rect.Left &&
               body.Top < rect.Bottom &&
               body.Bottom > rect.Top;
    }

    public Tile GetTileAt(int gridX, int gridY)
    {
        if (gridX < 0 || gridX >= Constants.LevelWidthTiles ||
            gridY < 0 || gridY >= Constants.LevelHeightTiles)
            return null;
        return _tiles[gridY, gridX];
    }

    public bool IsSolidAt(float worldX, float worldY)
    {
        int gx = (int)(worldX / Constants.TileSize);
        int gy = (int)(worldY / Constants.TileSize);
        var tile = GetTileAt(gx, gy);
        return tile != null && tile.IsSolid;
    }
}

public struct CollisionResult
{
    public bool HitLeft, HitRight, HitTop, HitBottom;
    public Tile HitTile; // Tile hit from below (for question/brick blocks)
}
