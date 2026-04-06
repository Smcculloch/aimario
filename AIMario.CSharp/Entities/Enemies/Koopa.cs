using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Core;
using AIMario.Graphics;

namespace AIMario.Entities.Enemies;

public class Koopa : Enemy
{
    public bool IsShell { get; private set; }
    public bool ShellMoving { get; private set; }
    private float _shellKickCooldown;
    private float _turnCooldown;

    public Koopa(SpriteGenerator sprites) : base(sprites)
    {
        Body.Width = 14;
        Body.Height = 24;
        Body.Velocity.X = -Constants.KoopaSpeed;
    }

    public override void Update(float dt, Level.Level level)
    {
        if (IsStomped && !IsShell)
        {
            // Knocked off by fireball/star
            Body.Velocity.Y += Constants.Gravity;
            Body.Position += Body.Velocity;
            DeathTimer += dt;
            if (DeathTimer > 2f) Active = false;
            return;
        }

        AnimTimer += dt;
        _shellKickCooldown -= dt;
        _turnCooldown -= dt;

        Body.ApplyPhysics();
        var result = level.CollisionSystem.MoveAndCollide(Body);

        if ((result.HitLeft || result.HitRight) && _turnCooldown <= 0)
        {
            float speed = ShellMoving ? Constants.ShellSpeed : Constants.KoopaSpeed;
            Body.Velocity.X = result.HitLeft ? speed : -speed;
            FacingRight = Body.Velocity.X > 0;
            _turnCooldown = 0.1f;
        }

        // Kill enemies in shell path
        if (IsShell && ShellMoving)
        {
            foreach (var enemy in level.Enemies)
            {
                if (enemy == this || !enemy.Active || enemy.IsStomped) continue;
                if (Intersects(enemy))
                {
                    if (enemy is Goomba g)
                        g.KillByHit();
                    else if (enemy is Koopa k)
                        k.KillByHit();
                    level.AddScore(Constants.ScoreKoopa, Body.Position);
                }
            }
        }

        if (Body.Position.Y > Constants.LevelHeightTiles * Constants.TileSize)
            Active = false;
    }

    public override void OnStomped(Level.Level level)
    {
        if (!IsShell)
        {
            // Become shell
            IsShell = true;
            ShellMoving = false;
            Body.Velocity.X = 0;
            Body.Height = 16;
            Body.Position.Y += 8; // Adjust for smaller shell
            _shellKickCooldown = 0.2f;
        }
        else if (!ShellMoving && _shellKickCooldown <= 0)
        {
            // Kick shell
            KickShell(level.Mario.Body.Position.X < Body.Position.X);
        }
        else if (ShellMoving)
        {
            // Stop shell
            ShellMoving = false;
            Body.Velocity.X = 0;
            _shellKickCooldown = 0.2f;
        }
    }

    public void KickShell(bool kickRight)
    {
        ShellMoving = true;
        Body.Velocity.X = kickRight ? Constants.ShellSpeed : -Constants.ShellSpeed;
        _shellKickCooldown = 0.2f;
    }

    public void KillByHit()
    {
        IsStomped = true;
        Body.Velocity.Y = -3f;
    }

    public bool CanHurtMario()
    {
        if (!IsShell) return true;
        return ShellMoving;
    }

    protected override Texture2D GetTexture()
    {
        if (IsShell) return Sprites.Textures["koopa_shell"];
        int frame = ((int)(AnimTimer * 4)) % 2;
        return Sprites.Textures["koopa" + frame];
    }

    public override void Draw(SpriteBatch sb)
    {
        if (!Active) return;
        var tex = GetTexture();
        if (tex == null) return;

        var effects = IsStomped && !IsShell ? SpriteEffects.FlipVertically :
                      (FacingRight ? SpriteEffects.FlipHorizontally : SpriteEffects.None);
        sb.Draw(tex, new Vector2((int)Body.Position.X - 1, (int)Body.Position.Y),
            null, Color.White, 0f, Vector2.Zero, 1f, effects, 0f);
    }
}
