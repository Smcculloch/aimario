using Microsoft.Xna.Framework.Graphics;

namespace AIMario.Graphics;

public class Animation
{
    public Texture2D[] Frames { get; }
    public float FrameTime { get; }
    public bool Loop { get; }

    private float _timer;
    private int _currentFrame;

    public Animation(Texture2D[] frames, float frameTime, bool loop = true)
    {
        Frames = frames;
        FrameTime = frameTime;
        Loop = loop;
    }

    public Texture2D CurrentFrame => Frames[_currentFrame];

    public void Update(float dt)
    {
        _timer += dt;
        if (_timer >= FrameTime)
        {
            _timer -= FrameTime;
            _currentFrame++;
            if (_currentFrame >= Frames.Length)
                _currentFrame = Loop ? 0 : Frames.Length - 1;
        }
    }

    public void Reset()
    {
        _timer = 0;
        _currentFrame = 0;
    }
}
