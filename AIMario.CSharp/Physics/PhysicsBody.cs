using Microsoft.Xna.Framework;

namespace AIMario.Physics;

public class PhysicsBody
{
    public Vector2 Position;
    public Vector2 Velocity;
    public float Width;
    public float Height;
    public bool OnGround;
    public bool ApplyGravity = true;

    public Rectangle Bounds => new(
        (int)Position.X, (int)Position.Y,
        (int)Width, (int)Height);

    public float Left => Position.X;
    public float Right => Position.X + Width;
    public float Top => Position.Y;
    public float Bottom => Position.Y + Height;

    public void ApplyPhysics()
    {
        if (ApplyGravity)
        {
            Velocity.Y += Core.Constants.Gravity;
            if (Velocity.Y > Core.Constants.MaxFallSpeed)
                Velocity.Y = Core.Constants.MaxFallSpeed;
        }
    }
}
