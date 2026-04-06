using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Core;
using AIMario.Graphics;
using AIMario.Input;
using AIMario.Physics;

namespace AIMario.Entities;

public enum PowerState
{
    Small,
    Big,
    Fire
}

public class Mario : Entity
{
    public PowerState Power { get; set; } = PowerState.Small;
    public bool IsDead { get; set; }
    public bool IsInvincible { get; private set; }
    public bool HasStar { get; private set; }
    public bool IsDucking { get; private set; }
    public bool ReachedFlag { get; set; }

    private AnimationController _anim = new();
    private float _invincibleTimer;
    private float _starTimer;
    private float _deathTimer;
    private bool _deathBounce;
    private float _blinkTimer;
    private bool _visible = true;

    // Track animation speed based on movement
    private float _walkAnimTimer;

    private SpriteGenerator _sprites;

    public Mario(SpriteGenerator sprites)
    {
        _sprites = sprites;
        Body.Width = 14;
        Body.Height = 16;
        SetupAnimations();
    }

    private void SetupAnimations()
    {
        // Animations are handled manually via sprite lookup
    }

    public void Reset(Vector2 position)
    {
        Position = position;
        Body.Velocity = Vector2.Zero;
        Body.OnGround = false;
        Power = PowerState.Small;
        Body.Width = 14;
        Body.Height = 16;
        IsDead = false;
        IsInvincible = false;
        HasStar = false;
        IsDucking = false;
        ReachedFlag = false;
        FacingRight = true;
        Active = true;
        _visible = true;
    }

    public void Update(float dt, Level.Level level, InputManager input)
    {
        if (IsDead)
        {
            UpdateDeath(dt);
            return;
        }

        if (ReachedFlag)
        {
            UpdateFlagSlide(dt);
            return;
        }

        // Invincibility flashing
        if (IsInvincible && !HasStar)
        {
            _invincibleTimer -= dt;
            _blinkTimer += dt;
            _visible = ((int)(_blinkTimer * 10)) % 2 == 0;
            if (_invincibleTimer <= 0)
            {
                IsInvincible = false;
                _visible = true;
            }
        }

        // Star timer
        if (HasStar)
        {
            _starTimer -= dt;
            _blinkTimer += dt;
            _visible = ((int)(_blinkTimer * 15)) % 2 == 0;
            if (_starTimer <= 0)
            {
                HasStar = false;
                IsInvincible = false;
                _visible = true;
            }
        }

        // Horizontal movement
        float maxSpeed = input.Run ? Constants.RunMaxSpeed : Constants.WalkMaxSpeed;
        float accel = input.Run ? Constants.RunAccel : Constants.WalkAccel;

        if (input.Left)
        {
            Body.Velocity.X -= accel;
            if (Body.Velocity.X < -maxSpeed) Body.Velocity.X = -maxSpeed;
            FacingRight = false;
        }
        else if (input.Right)
        {
            Body.Velocity.X += accel;
            if (Body.Velocity.X > maxSpeed) Body.Velocity.X = maxSpeed;
            FacingRight = true;
        }
        else
        {
            // Friction
            if (Body.Velocity.X > 0)
            {
                Body.Velocity.X -= Constants.Friction;
                if (Body.Velocity.X < 0) Body.Velocity.X = 0;
            }
            else if (Body.Velocity.X < 0)
            {
                Body.Velocity.X += Constants.Friction;
                if (Body.Velocity.X > 0) Body.Velocity.X = 0;
            }
        }

        // Ducking (only when big and on ground)
        if (Power != PowerState.Small && Body.OnGround && input.Down)
        {
            if (!IsDucking)
            {
                IsDucking = true;
                Body.Height = 16;
                Body.Position.Y += 16; // Adjust position when ducking
            }
        }
        else if (IsDucking)
        {
            IsDucking = false;
            Body.Height = 32;
            Body.Position.Y -= 16;
        }

        // Jump
        if (input.JumpPressed && Body.OnGround)
        {
            float jumpVel = System.Math.Abs(Body.Velocity.X) > Constants.WalkMaxSpeed
                ? Constants.JumpVelocityRun : Constants.JumpVelocityWalk;
            Body.Velocity.Y = jumpVel;
            Body.OnGround = false;
        }

        // Variable jump height
        if (!input.Jump && Body.Velocity.Y < Constants.JumpReleaseCap)
        {
            Body.Velocity.Y = Constants.JumpReleaseCap;
        }

        // Physics
        Body.ApplyPhysics();

        // Collision
        var result = level.CollisionSystem.MoveAndCollide(Body);

        // Hit block from below
        if (result.HitTop && result.HitTile != null)
        {
            level.HitBlock(result.HitTile, this);
        }

        // Don't go left of camera
        if (Body.Position.X < level.Camera.X)
            Body.Position.X = level.Camera.X;

        // Fell in pit
        if (Body.Position.Y > Constants.LevelHeightTiles * Constants.TileSize)
        {
            Die();
        }

        // Animation - cycle through walk frames based on distance traveled
        if (System.Math.Abs(Body.Velocity.X) > 0.1f && Body.OnGround)
        {
            _walkAnimTimer += System.Math.Abs(Body.Velocity.X) * dt;
        }
        else if (Body.OnGround)
        {
            _walkAnimTimer = 0;
        }
    }

    public override void Update(float dt, Level.Level level)
    {
        // Called by base; actual update needs InputManager
    }

    private void UpdateDeath(float dt)
    {
        _deathTimer += dt;
        if (!_deathBounce && _deathTimer > 0.5f)
        {
            Body.Velocity.Y = -5f;
            _deathBounce = true;
        }
        if (_deathBounce)
        {
            Body.Velocity.Y += Constants.Gravity;
            Body.Position.Y += Body.Velocity.Y;
        }
    }

    private void UpdateFlagSlide(float dt)
    {
        // Slide down flagpole
        Body.Velocity.X = 0;
        Body.Velocity.Y = 2f;
        Body.Position.Y += Body.Velocity.Y;

        // Stop at ground level
        float groundY = (Constants.LevelHeightTiles - 2) * Constants.TileSize - Body.Height;
        if (Body.Position.Y >= groundY)
        {
            Body.Position.Y = groundY;
            Body.Velocity.Y = 0;
        }
    }

    public void Die()
    {
        if (IsDead) return;
        IsDead = true;
        _deathTimer = 0;
        _deathBounce = false;
        Body.Velocity = Vector2.Zero;
        Body.ApplyGravity = false;
        Active = true; // Keep active for death animation
    }

    public void TakeDamage()
    {
        if (IsInvincible || IsDead) return;

        if (Power == PowerState.Fire || Power == PowerState.Big)
        {
            Power = PowerState.Small;
            Body.Height = 16;
            IsInvincible = true;
            _invincibleTimer = 2.0f;
            _blinkTimer = 0;
        }
        else
        {
            Die();
        }
    }

    public void CollectMushroom()
    {
        if (Power == PowerState.Small)
        {
            Power = PowerState.Big;
            Body.Height = 32;
            Body.Position.Y -= 16;
        }
    }

    public void CollectFireFlower()
    {
        if (Power == PowerState.Small)
        {
            Power = PowerState.Big;
            Body.Height = 32;
            Body.Position.Y -= 16;
        }
        Power = PowerState.Fire;
    }

    public void CollectStar()
    {
        HasStar = true;
        IsInvincible = true;
        _starTimer = 10f;
        _blinkTimer = 0;
    }

    protected override Texture2D GetTexture()
    {
        string prefix;
        if (Power == PowerState.Fire) prefix = "mario_fire";
        else if (Power == PowerState.Big) prefix = "mario_big";
        else prefix = "mario_small";

        if (IsDead) return _sprites.Textures["mario_small_death"];

        if (IsDucking) return _sprites.Textures[prefix + "_duck"];

        if (!Body.OnGround)
            return _sprites.Textures[prefix + "_jump"];

        if (System.Math.Abs(Body.Velocity.X) > 0.1f)
        {
            // Cycle through 3 walk frames; faster movement = faster animation
            int frame = ((int)(_walkAnimTimer * 8)) % 3 + 1;
            return _sprites.Textures[prefix + "_walk" + frame];
        }

        return _sprites.Textures[prefix + "_stand"];
    }

    public override void Draw(SpriteBatch sb)
    {
        if (!_visible) return;

        var tex = GetTexture();
        if (tex == null) return;

        var effects = FacingRight ? SpriteEffects.None : SpriteEffects.FlipHorizontally;
        // Center the 16px wide sprite on the 14px hitbox
        float drawX = Body.Position.X - 1;
        float drawY = Body.Position.Y;

        // Duck sprite is 32px texture with content in bottom 16px,
        // but hitbox is 16px positioned at feet - draw 16px up
        if (IsDucking)
            drawY = Body.Position.Y - 16;

        sb.Draw(tex, new Vector2((int)drawX, (int)drawY),
            null, Color.White, 0f, Vector2.Zero, 1f, effects, 0f);
    }
}
