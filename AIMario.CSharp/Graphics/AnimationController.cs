using System.Collections.Generic;
using Microsoft.Xna.Framework.Graphics;

namespace AIMario.Graphics;

public class AnimationController
{
    private Dictionary<string, Animation> _animations = new();
    private string _currentAnim = "";

    public void Add(string name, Animation anim)
    {
        _animations[name] = anim;
    }

    public void Play(string name)
    {
        if (_currentAnim == name) return;
        _currentAnim = name;
        if (_animations.ContainsKey(name))
            _animations[name].Reset();
    }

    public void Update(float dt)
    {
        if (_animations.ContainsKey(_currentAnim))
            _animations[_currentAnim].Update(dt);
    }

    public Texture2D CurrentFrame =>
        _animations.ContainsKey(_currentAnim) ? _animations[_currentAnim].CurrentFrame : null;

    public string CurrentAnimation => _currentAnim;
}
