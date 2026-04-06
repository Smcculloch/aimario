using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Core;
using AIMario.Graphics;

namespace AIMario.Entities.Items;

public class Mushroom : Entity
{
    private SpriteGenerator _sprites;
    public bool IsOneUp { get; }
    private float _emergeTimer;
    private float _startY;
    private bool _emerged;

    public Mushroom(SpriteGenerator sprites, bool isOneUp = false)
    {
        _sprites = sprites;
        IsOneUp = isOneUp;
        Body.Width = 16;
        Body.Height = 16;
        Body.ApplyGravity = false;
    }

    public void StartEmerge()
    {
        _startY = Body.Position.Y;
        _emerged = false;
        _emergeTimer = 0;
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
                Body.Velocity.X = Constants.MushroomSpeed;
                Body.ApplyGravity = true;
            }
            return;
        }

        Body.ApplyPhysics();
        var result = level.CollisionSystem.MoveAndCollide(Body);

        if (result.HitLeft || result.HitRight)
            Body.Velocity.X = result.HitLeft ? Constants.MushroomSpeed : -Constants.MushroomSpeed;

        if (Body.Position.Y > Constants.LevelHeightTiles * Constants.TileSize)
            Active = false;
    }

    protected override Texture2D GetTexture() =>
        IsOneUp ? _sprites.Textures["oneup"] : _sprites.Textures["mushroom"];
}
