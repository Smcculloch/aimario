using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Graphics;

namespace AIMario.Entities.Items;

public class BowserEasterEgg : Entity
{
    private SpriteGenerator _sprites;
    private float _timer;
    private bool _emerged;
    private float _emergeTimer;
    private float _startY;
    private bool _exploding;
    private float _explodeTimer;

    private const float EmergeDuration = 0.5f;
    private const float LaughDuration = 3.0f;
    private const float PoofDuration = 0.3f;
    private const float FrameToggle = 0.3f;

    public BowserEasterEgg(SpriteGenerator sprites)
    {
        _sprites = sprites;
        Body.Width = 24;
        Body.Height = 32;
        Body.ApplyGravity = false;
    }

    public void StartEmerge()
    {
        _startY = Body.Position.Y;
        _emerged = false;
        _emergeTimer = 0;
        _timer = 0;
        _exploding = false;
    }

    public override void Update(float dt, Level.Level level)
    {
        if (!_emerged)
        {
            // Phase 1: Rise out of block
            _emergeTimer += dt;
            Body.Position.Y = _startY - (_emergeTimer / EmergeDuration) * 32;
            if (_emergeTimer >= EmergeDuration)
            {
                _emerged = true;
                Body.Position.Y = _startY - 32;
                _timer = 0;
            }
            return;
        }

        if (_exploding)
        {
            // Phase 4: Poof cloud
            _explodeTimer += dt;
            if (_explodeTimer >= PoofDuration)
                Active = false;
            return;
        }

        // Phase 2: Laugh, facing Mario
        _timer += dt;
        FacingRight = level.Mario.Body.Position.X > Body.Position.X;

        if (_timer >= LaughDuration)
        {
            // Phase 3: Start exploding
            _exploding = true;
            _explodeTimer = 0;
        }
    }

    protected override Texture2D GetTexture()
    {
        if (_exploding)
            return _sprites.Textures["bowser_poof"];

        // Alternate laugh frames
        int frame = ((int)(_timer / FrameToggle)) % 2;
        return _sprites.Textures["bowser" + frame];
    }

    public override void Draw(SpriteBatch sb)
    {
        var tex = GetTexture();
        if (tex == null || !Active) return;

        if (_exploding)
        {
            // Center the 16x16 poof on where Bowser was
            float poofX = Body.Position.X + (Body.Width - 16) / 2f;
            float poofY = Body.Position.Y + (Body.Height - 16) / 2f;
            sb.Draw(tex, new Vector2((int)poofX, (int)poofY), Color.White);
        }
        else
        {
            var effects = FacingRight ? SpriteEffects.None : SpriteEffects.FlipHorizontally;
            sb.Draw(tex, new Vector2((int)Body.Position.X, (int)Body.Position.Y),
                null, Color.White, 0f, Vector2.Zero, 1f, effects, 0f);
        }
    }
}
