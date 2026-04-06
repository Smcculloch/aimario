using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Physics;

namespace AIMario.Entities;

public abstract class Entity
{
    public PhysicsBody Body { get; } = new();
    public bool Active { get; set; } = true;
    public bool FacingRight { get; set; } = true;
    public bool RemoveWhenOffScreen { get; set; } = true;

    public Vector2 Position
    {
        get => Body.Position;
        set => Body.Position = value;
    }

    public abstract void Update(float dt, Level.Level level);

    public virtual void Draw(SpriteBatch sb)
    {
        var tex = GetTexture();
        if (tex == null || !Active) return;

        var effects = FacingRight ? SpriteEffects.None : SpriteEffects.FlipHorizontally;
        sb.Draw(tex, new Vector2((int)Body.Position.X, (int)Body.Position.Y + Body.BumpOffset()),
            null, Color.White, 0f, Vector2.Zero, 1f, effects, 0f);
    }

    protected virtual Texture2D GetTexture() => null;

    public Rectangle Bounds => Body.Bounds;

    public bool Intersects(Entity other)
    {
        return Active && other.Active &&
               Body.Left < other.Body.Right &&
               Body.Right > other.Body.Left &&
               Body.Top < other.Body.Bottom &&
               Body.Bottom > other.Body.Top;
    }
}

// Extension to avoid modifying PhysicsBody
public static class PhysicsBodyExtensions
{
    public static float BumpOffset(this PhysicsBody body) => 0;
}
