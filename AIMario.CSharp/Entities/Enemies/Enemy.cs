using Microsoft.Xna.Framework.Graphics;
using AIMario.Graphics;

namespace AIMario.Entities.Enemies;

public abstract class Enemy : Entity
{
    protected SpriteGenerator Sprites;
    public bool IsStomped { get; set; }
    protected float DeathTimer;
    protected float AnimTimer;

    protected Enemy(SpriteGenerator sprites)
    {
        Sprites = sprites;
        FacingRight = false; // Enemies walk left by default
    }

    public virtual void OnStomped(Level.Level level)
    {
        IsStomped = true;
    }

    public virtual bool CanBeStomped => true;
}
