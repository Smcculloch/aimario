using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Core;
using AIMario.Graphics;

namespace AIMario.Entities.Projectiles;

public class Fireball : Entity
{
    private SpriteGenerator _sprites;
    private float _timer;

    public Fireball(SpriteGenerator sprites, Vector2 position, bool goRight)
    {
        _sprites = sprites;
        Body.Width = 8;
        Body.Height = 8;
        Body.Position = position;
        Body.Velocity.X = goRight ? Constants.FireballSpeed : -Constants.FireballSpeed;
        Body.Velocity.Y = 0;
        Body.ApplyGravity = false; // We handle gravity manually for bounce
    }

    public override void Update(float dt, Level.Level level)
    {
        _timer += dt;

        // Custom gravity for bounce
        Body.Velocity.Y += Constants.FireballGravity;
        if (Body.Velocity.Y > Constants.MaxFallSpeed)
            Body.Velocity.Y = Constants.MaxFallSpeed;

        var result = level.CollisionSystem.MoveAndCollide(Body);

        if (result.HitLeft || result.HitRight)
        {
            Active = false;
            return;
        }

        if (result.HitBottom)
        {
            Body.Velocity.Y = Constants.FireballBounce;
        }

        // Check enemy collisions
        foreach (var enemy in level.Enemies)
        {
            if (!enemy.Active || enemy.IsStomped) continue;
            if (Intersects(enemy))
            {
                Active = false;
                if (enemy is Enemies.Goomba g) g.KillByHit();
                else if (enemy is Enemies.Koopa k) k.KillByHit();
                level.AddScore(Constants.ScoreGoomba, enemy.Body.Position);
                return;
            }
        }

        if (Body.Position.Y > Constants.LevelHeightTiles * Constants.TileSize)
            Active = false;

        if (_timer > 3f) Active = false;
    }

    protected override Texture2D GetTexture() => _sprites.Textures["fireball"];

    public override void Draw(SpriteBatch sb)
    {
        if (!Active) return;
        var tex = GetTexture();
        sb.Draw(tex, new Vector2((int)Body.Position.X, (int)Body.Position.Y),
            null, Color.White, 0f, Vector2.Zero, 1f, SpriteEffects.None, 0f);
    }
}
