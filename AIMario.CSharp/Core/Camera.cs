using Microsoft.Xna.Framework;

namespace AIMario.Core;

public class Camera
{
    public float X { get; private set; }
    public float MaxX { get; private set; }

    public Camera(float levelWidth)
    {
        MaxX = levelWidth - Constants.NESWidth;
    }

    public void Follow(float targetX)
    {
        float desired = targetX - Constants.NESWidth / 2f;
        if (desired > X)
            X = desired;
        if (X < 0) X = 0;
        if (X > MaxX) X = MaxX;
    }

    public Matrix GetTransform()
    {
        return Matrix.CreateTranslation(-(int)X, 0, 0);
    }

    public bool IsVisible(float entityX, float width)
    {
        return entityX + width > X - 16 && entityX < X + Constants.NESWidth + 16;
    }

    public void Reset()
    {
        X = 0;
    }

    public void ForceX(float x)
    {
        X = x;
        if (X < 0) X = 0;
        if (X > MaxX) X = MaxX;
    }
}
