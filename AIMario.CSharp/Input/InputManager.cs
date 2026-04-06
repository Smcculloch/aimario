using Microsoft.Xna.Framework.Input;

namespace AIMario.Input;

public class InputManager
{
    private KeyboardState _currentKb, _previousKb;
    private GamePadState _currentGp, _previousGp;

    public void Update()
    {
        _previousKb = _currentKb;
        _previousGp = _currentGp;
        _currentKb = Keyboard.GetState();
        _currentGp = GamePad.GetState(0);
    }

    public bool Left => _currentKb.IsKeyDown(Keys.Left) || _currentGp.DPad.Left == ButtonState.Pressed;
    public bool Right => _currentKb.IsKeyDown(Keys.Right) || _currentGp.DPad.Right == ButtonState.Pressed;
    public bool Down => _currentKb.IsKeyDown(Keys.Down) || _currentGp.DPad.Down == ButtonState.Pressed;
    public bool DownPressed => IsKeyPressed(Keys.Down)
        || (_currentGp.DPad.Down == ButtonState.Pressed && _previousGp.DPad.Down == ButtonState.Released);
    public bool Up => _currentKb.IsKeyDown(Keys.Up) || _currentGp.DPad.Up == ButtonState.Pressed;

    public bool Jump => _currentKb.IsKeyDown(Keys.Z) || _currentKb.IsKeyDown(Keys.Space)
        || _currentGp.Buttons.A == ButtonState.Pressed;
    public bool JumpPressed => (IsKeyPressed(Keys.Z) || IsKeyPressed(Keys.Space))
        || (_currentGp.Buttons.A == ButtonState.Pressed && _previousGp.Buttons.A == ButtonState.Released);

    public bool Run => _currentKb.IsKeyDown(Keys.X) || _currentKb.IsKeyDown(Keys.LeftShift)
        || _currentGp.Buttons.B == ButtonState.Pressed;
    public bool RunPressed => (IsKeyPressed(Keys.X) || IsKeyPressed(Keys.LeftShift))
        || (_currentGp.Buttons.B == ButtonState.Pressed && _previousGp.Buttons.B == ButtonState.Released);

    public bool Start => IsKeyPressed(Keys.Enter)
        || (_currentGp.Buttons.Start == ButtonState.Pressed && _previousGp.Buttons.Start == ButtonState.Released);

    private bool IsKeyPressed(Keys key) => _currentKb.IsKeyDown(key) && !_previousKb.IsKeyDown(key);
}
