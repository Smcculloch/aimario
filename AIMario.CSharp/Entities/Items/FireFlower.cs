using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Graphics;

namespace AIMario.Entities.Items;

public class FireFlower : Entity
{
    private SpriteGenerator _sprites;
    private float _emergeTimer;
    private float _startY;
    private bool _emerged;

    public FireFlower(SpriteGenerator sprites)
    {
        _sprites = sprites;
        Body.Width = 16;
        Body.Height = 16;
        Body.ApplyGravity = false;
    }

    public void StartEmerge()
    {
        _startY = Body.Position.Y;
        _emerged = false;
    }

    public override void Update(float dt, Level.Level level)
    {
        if (!_emerged)
        {
            _emergeTimer += dt;
            Body.Position.Y = _startY - (_emergeTimer / 0.5f) * 16;
            if (_emergeTimer >= 0.5f)
            {
                _emerged = true;
                Body.Position.Y = _startY - 16;
            }
            return;
        }
        // Fire flower just sits there
    }

    protected override Texture2D GetTexture() => _sprites.Textures["fireflower"];
}
