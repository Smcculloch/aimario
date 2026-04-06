using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace AIMario.Tiles;

public class Tile
{
    public TileType Type { get; set; }
    public int GridX { get; }
    public int GridY { get; }
    public Rectangle Bounds => new(GridX * Core.Constants.TileSize, GridY * Core.Constants.TileSize,
        Core.Constants.TileSize, Core.Constants.TileSize);

    // For question/brick blocks: what item they contain
    public ItemContent Content { get; set; } = ItemContent.None;
    public bool IsHit { get; set; }

    // Animation
    public float BumpOffset { get; set; }
    private float _animTimer;

    public Tile(TileType type, int gridX, int gridY)
    {
        Type = type;
        GridX = gridX;
        GridY = gridY;
    }

    public bool IsSolid => Type switch
    {
        TileType.Empty => false,
        TileType.FlagPole => false,
        TileType.FlagTop => false,
        TileType.Invisible when !IsHit => false,
        _ => true
    };

    public void Update(float dt)
    {
        // Question block animation (blinking)
        if (Type == TileType.Question)
        {
            _animTimer += dt;
        }

        // Bump animation
        if (BumpOffset < 0)
        {
            BumpOffset += 0.5f;
            if (BumpOffset > 0) BumpOffset = 0;
        }
    }

    public int GetAnimFrame()
    {
        if (Type != TileType.Question) return 0;
        float cycle = _animTimer % 1.0f;
        if (cycle < 0.5f) return 0;
        if (cycle < 0.65f) return 1;
        if (cycle < 0.8f) return 2;
        return 1;
    }
}

public enum ItemContent
{
    None,
    Coin,
    Mushroom,      // Becomes fire flower if big
    Star,
    OneUp,
    MultiCoin,    // Brick with multiple coins
    Bowser        // Easter egg mini Bowser
}
