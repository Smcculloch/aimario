using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Core;
using AIMario.Graphics;

namespace AIMario.Entities.Enemies;

public class Goomba : Enemy
{
    private bool _flat;
    private float _flatTimer;
    private float _turnCooldown;

    public Goomba(SpriteGenerator sprites) : base(sprites)
    {
        Body.Width = 14;
        Body.Height = 16;
        Body.Velocity.X = -Constants.GoombaSpeed;
    }

    public override void Update(float dt, Level.Level level)
    {
        if (_flat)
        {
            _flatTimer += dt;
            if (_flatTimer > 0.5f) Active = false;
            return;
        }

        if (IsStomped)
        {
            // Death by shell/fireball/star - fall off screen
            Body.Velocity.Y += Constants.Gravity;
            Body.Position += Body.Velocity;
            DeathTimer += dt;
            if (DeathTimer > 2f) Active = false;
            return;
        }

        AnimTimer += dt;
        _turnCooldown -= dt;
        Body.ApplyPhysics();

        var result = level.CollisionSystem.MoveAndCollide(Body);

        // Reverse direction on wall hit (use absolute speed since collision zeroes velocity)
        if ((result.HitLeft || result.HitRight) && _turnCooldown <= 0)
        {
            Body.Velocity.X = result.HitLeft ? Constants.GoombaSpeed : -Constants.GoombaSpeed;
            _turnCooldown = 0.1f;
        }

        // Fall off screen
        if (Body.Position.Y > Constants.LevelHeightTiles * Constants.TileSize)
            Active = false;
    }

    public override void OnStomped(Level.Level level)
    {
        _flat = true;
        IsStomped = true; // Prevent further collision checks
        _flatTimer = 0;
        Body.Velocity.X = 0;
        // Shift position down so the 2px flat sprite aligns with feet
        Body.Position.Y += Body.Height - 2;
        Body.Height = 2;
    }

    public void KillByHit()
    {
        IsStomped = true;
        Body.Velocity.Y = -3f;
        Body.ApplyGravity = true;
    }

    protected override Texture2D GetTexture()
    {
        if (_flat) return Sprites.Textures["goomba_flat"];
        int frame = ((int)(AnimTimer * 4)) % 2;
        return Sprites.Textures["goomba" + frame];
    }

    public override void Draw(SpriteBatch sb)
    {
        if (!Active) return;
        var tex = GetTexture();
        if (tex == null) return;

        float drawY = Body.Position.Y;
        SpriteEffects effects = SpriteEffects.None;

        if (_flat)
        {
            // Flat sprite has content in rows 14-15 of a 16px texture;
            // offset so those rows align with the body position at feet
            drawY = Body.Position.Y - 14;
        }
        else if (IsStomped)
        {
            effects = SpriteEffects.FlipVertically;
        }

        sb.Draw(tex, new Vector2((int)Body.Position.X - 1, (int)drawY),
            null, Color.White, 0f, Vector2.Zero, 1f, effects, 0f);
    }
}
