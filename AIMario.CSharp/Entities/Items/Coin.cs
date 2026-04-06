using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Graphics;

namespace AIMario.Entities.Items;

public class Coin : Entity
{
    private SpriteGenerator _sprites;
    private float _timer;
    private float _startY;
    private bool _isPopup; // Coin that pops out of block
    private bool _isStatic; // Static coin (underground room, collectible on touch)

    public Coin(SpriteGenerator sprites, bool isPopup = false, bool isStatic = false)
    {
        _sprites = sprites;
        _isPopup = isPopup;
        _isStatic = isStatic;
        Body.Width = 16;
        Body.Height = 16;
        Body.ApplyGravity = false;

        if (isPopup)
        {
            Body.Velocity.Y = -6f;
        }
    }

    public override void Update(float dt, Level.Level level)
    {
        _timer += dt;

        if (_isPopup)
        {
            if (_startY == 0) _startY = Body.Position.Y;

            Body.Velocity.Y += 0.3f;
            Body.Position.Y += Body.Velocity.Y;

            if (Body.Position.Y > _startY)
            {
                Active = false;
            }
        }
        // Static coins don't move - they just sit there and wait to be collected
    }

    protected override Texture2D GetTexture() => _sprites.Textures["coin"];

    public override void Draw(SpriteBatch sb)
    {
        if (!Active) return;
        var tex = GetTexture();
        sb.Draw(tex, new Vector2((int)Body.Position.X, (int)Body.Position.Y),
            null, Color.White, 0f, Vector2.Zero, 1f, SpriteEffects.None, 0f);
    }
}
