using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using AIMario.Core;
using AIMario.Graphics;
using AIMario.Input;
using AIMario.UI;

namespace AIMario;

public class MarioGame : Game
{
    private GraphicsDeviceManager _graphics;
    private SpriteBatch _spriteBatch;
    private RenderTarget2D _renderTarget;

    private SpriteGenerator _sprites;
    private InputManager _input;
    private GameStateManager _stateManager;
    private Level.Level _level;
    private HUD _hud;
    private TitleScreen _titleScreen;
    private Texture2D _pixel;

    public MarioGame()
    {
        _graphics = new GraphicsDeviceManager(this);
        _graphics.PreferredBackBufferWidth = Constants.WindowWidth;
        _graphics.PreferredBackBufferHeight = Constants.WindowHeight;
        IsFixedTimeStep = true;
        TargetElapsedTime = System.TimeSpan.FromSeconds(1.0 / 60.0);
        IsMouseVisible = false;
        Window.Title = "SUPER MARIO BROS";
    }

    protected override void Initialize()
    {
        _input = new InputManager();
        _stateManager = new GameStateManager();
        base.Initialize();
    }

    protected override void LoadContent()
    {
        _spriteBatch = new SpriteBatch(GraphicsDevice);
        _renderTarget = new RenderTarget2D(GraphicsDevice, Constants.NESWidth, Constants.NESHeight);

        _sprites = new SpriteGenerator();
        _sprites.Generate(GraphicsDevice);
        _pixel = _sprites.CreatePixel();

        _level = new Level.Level(_sprites);
        _level.Load();

        _hud = new HUD(_sprites);
        _titleScreen = new TitleScreen(_sprites);
    }

    protected override void Update(GameTime gameTime)
    {
        if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed
            || Keyboard.GetState().IsKeyDown(Keys.Escape))
            Exit();

        float dt = (float)gameTime.ElapsedGameTime.TotalSeconds;
        _input.Update();
        _stateManager.Update(dt);

        switch (_stateManager.CurrentState)
        {
            case GameState.Title:
                _titleScreen.Update(dt);
                if (_input.Start)
                {
                    _level.Load();
                    _stateManager.SetState(GameState.Playing);
                }
                break;

            case GameState.Playing:
                _level.Update(dt, _input);

                if (_level.Mario.IsDead)
                    _stateManager.SetState(GameState.Death);
                else if (_level.LevelComplete)
                    _stateManager.SetState(GameState.LevelComplete);
                break;

            case GameState.Death:
                _level.Update(dt, _input);
                if (_stateManager.StateTimer > 3f)
                {
                    _level.Lives--;
                    if (_level.Lives <= 0)
                        _stateManager.SetState(GameState.GameOver);
                    else
                    {
                        _level.Reset();
                        _stateManager.SetState(GameState.Playing);
                    }
                }
                break;

            case GameState.LevelComplete:
                _level.Update(dt, _input);
                if (_stateManager.StateTimer > 5f)
                {
                    _stateManager.SetState(GameState.Title);
                }
                break;

            case GameState.GameOver:
                if (_stateManager.StateTimer > 3f)
                {
                    _level.Lives = Constants.StartingLives;
                    _level.Score = 0;
                    _level.Coins = 0;
                    _stateManager.SetState(GameState.Title);
                }
                break;
        }

        base.Update(gameTime);
    }

    protected override void Draw(GameTime gameTime)
    {
        // Draw to render target at NES resolution
        GraphicsDevice.SetRenderTarget(_renderTarget);

        // Dynamic background color (sky blue for overworld, black for underground)
        var bgColor = (_stateManager.CurrentState == GameState.Playing
            || _stateManager.CurrentState == GameState.Death
            || _stateManager.CurrentState == GameState.LevelComplete)
            ? _level.BackgroundColor
            : new Color(92, 148, 252);
        GraphicsDevice.Clear(bgColor);

        _spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.AlphaBlend,
            SamplerState.PointClamp, null, null, null,
            _stateManager.CurrentState == GameState.Title ? Matrix.Identity : _level.Camera.GetTransform());

        switch (_stateManager.CurrentState)
        {
            case GameState.Title:
                _titleScreen.Draw(_spriteBatch);
                break;

            case GameState.Playing:
            case GameState.Death:
            case GameState.LevelComplete:
                _level.Draw(_spriteBatch);
                break;

            case GameState.GameOver:
                // Black screen with text
                break;
        }

        _spriteBatch.End();

        // Draw HUD (no camera transform)
        if (_stateManager.CurrentState != GameState.Title)
        {
            _spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.AlphaBlend,
                SamplerState.PointClamp);

            if (_stateManager.CurrentState == GameState.GameOver)
            {
                // Draw black background
                _spriteBatch.Draw(_pixel, new Rectangle(0, 0, Constants.NESWidth, Constants.NESHeight),
                    Color.Black);
                _level.DrawText(_spriteBatch, "GAME OVER", 88, 112, 1f);
            }
            else
            {
                _hud.Draw(_spriteBatch, _level);
            }

            _spriteBatch.End();
        }

        // Scale render target to window
        GraphicsDevice.SetRenderTarget(null);
        GraphicsDevice.Clear(Color.Black);

        _spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.AlphaBlend,
            SamplerState.PointClamp);
        _spriteBatch.Draw(_renderTarget,
            new Rectangle(0, 0, Constants.WindowWidth, Constants.WindowHeight),
            Color.White);
        _spriteBatch.End();

        base.Draw(gameTime);
    }
}
