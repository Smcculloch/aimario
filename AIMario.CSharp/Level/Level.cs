using System;
using System.Collections.Generic;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using AIMario.Core;
using AIMario.Entities;
using AIMario.Entities.Enemies;
using AIMario.Entities.Items;
using AIMario.Entities.Projectiles;
using AIMario.Graphics;
using AIMario.Input;
using AIMario.Physics;
using AIMario.Tiles;

namespace AIMario.Level;

public enum LevelArea { Overworld, Underground }
public enum PipeState { None, EnteringPipe, ExitingPipe }

public class Level
{
    public Mario Mario { get; private set; }
    public Camera Camera { get; private set; }
    public CollisionSystem CollisionSystem { get; private set; }
    public List<Enemy> Enemies { get; private set; }

    private Tile[,] _tiles;
    private SpriteGenerator _sprites;
    private List<Entity> _items = new();
    private List<Fireball> _fireballs = new();
    private List<ScorePopup> _scorePopups = new();
    private List<BrickDebris> _debris = new();

    // Game state
    public int Score { get; set; }
    public int Coins { get; set; }
    public int Lives { get; set; } = Constants.StartingLives;
    public float Timer { get; private set; } = Constants.LevelTime;
    private float _timerAccum;
    public bool LevelComplete { get; private set; }

    private float _fireballCooldown;

    // Flag
    private bool _flagDescending;
    private float _flagY;
    private float _flagTargetY;

    // Underground pipe transition
    private LevelArea _currentArea = LevelArea.Overworld;
    private Tile[,] _overworldTiles;
    private Tile[,] _undergroundTiles;
    private List<Enemy> _overworldEnemies;
    private PipeState _pipeState = PipeState.None;
    private float _pipeTimer;
    private float _savedCameraX;

    public Color BackgroundColor => _currentArea == LevelArea.Overworld
        ? new Color(92, 148, 252)
        : Color.Black;

    public Level(SpriteGenerator sprites)
    {
        _sprites = sprites;
    }

    public void Load()
    {
        var (tiles, enemies) = LevelLoader.Load(_sprites);
        _tiles = tiles;
        _overworldTiles = (Tile[,])tiles.Clone();
        Enemies = enemies;

        // Load underground tiles
        LoadUndergroundTiles();

        CollisionSystem = new CollisionSystem();
        CollisionSystem.SetTiles(_tiles);

        Camera = new Camera(Constants.LevelWidthTiles * Constants.TileSize);

        Mario = new Mario(_sprites);
        Mario.Reset(new Vector2(40, (Constants.LevelHeightTiles - 3) * Constants.TileSize));

        _items.Clear();
        _fireballs.Clear();
        _scorePopups.Clear();
        _debris.Clear();
        Timer = Constants.LevelTime;
        LevelComplete = false;
        _flagDescending = false;
        _currentArea = LevelArea.Overworld;
        _pipeState = PipeState.None;
        _pipeTimer = 0;
    }

    private void LoadUndergroundTiles()
    {
        var (ugMapData, _) = LevelData.GetUnderground();
        int h = Constants.LevelHeightTiles;
        int w = Constants.LevelWidthTiles;
        _undergroundTiles = new Tile[h, w];
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                var type = (TileType)ugMapData[y, x];
                if (type == TileType.Empty) continue;
                _undergroundTiles[y, x] = new Tile(type, x, y);
            }
        }
    }

    public void Reset()
    {
        Mario.Reset(new Vector2(40, (Constants.LevelHeightTiles - 3) * Constants.TileSize));
        Camera.Reset();
        Timer = Constants.LevelTime;
        _items.Clear();
        _fireballs.Clear();
        _scorePopups.Clear();
        _debris.Clear();
        LevelComplete = false;
        _flagDescending = false;
        _currentArea = LevelArea.Overworld;
        _pipeState = PipeState.None;
        _pipeTimer = 0;

        // Reload enemies
        var (_, enemies) = LevelLoader.Load(_sprites);
        Enemies = enemies;

        // Reload tiles
        var (tiles, _) = LevelLoader.Load(_sprites);
        _tiles = tiles;
        _overworldTiles = (Tile[,])tiles.Clone();
        CollisionSystem.SetTiles(_tiles);

        // Reload underground
        LoadUndergroundTiles();
    }

    public void Update(float dt, InputManager input)
    {
        // Handle pipe animation states
        if (_pipeState != PipeState.None)
        {
            UpdatePipeTransition(dt);
            return;
        }

        // Timer
        if (!LevelComplete && !Mario.IsDead)
        {
            _timerAccum += dt;
            while (_timerAccum >= Constants.TimerTickRate)
            {
                _timerAccum -= Constants.TimerTickRate;
                Timer--;
                if (Timer <= 0)
                {
                    Timer = 0;
                    Mario.Die();
                }
            }
        }

        // Mario
        Mario.Update(dt, this, input);

        // Camera follows Mario
        if (!Mario.IsDead)
            Camera.Follow(Mario.Body.Position.X);

        // Fireball shooting (fires on button press, not hold)
        _fireballCooldown -= dt;
        if (Mario.Power == PowerState.Fire && input.RunPressed && _fireballCooldown <= 0 && !Mario.IsDead
            && _fireballs.FindAll(f => f.Active).Count < 2)
        {
            var fb = new Fireball(_sprites,
                new Vector2(Mario.Body.Position.X + (Mario.FacingRight ? 12 : -8),
                            Mario.Body.Position.Y + 8),
                Mario.FacingRight);
            _fireballs.Add(fb);
            _fireballCooldown = 0.3f;
        }

        // Update tiles
        for (int y = 0; y < Constants.LevelHeightTiles; y++)
            for (int x = 0; x < Constants.LevelWidthTiles; x++)
                _tiles[y, x]?.Update(dt);

        // Update enemies (only if near camera)
        foreach (var enemy in Enemies)
        {
            if (!enemy.Active) continue;
            if (!Camera.IsVisible(enemy.Body.Position.X, enemy.Body.Width + 16))
            {
                // Don't activate enemies that haven't been on screen yet
                continue;
            }
            enemy.Update(dt, this);
        }

        // Update items
        for (int i = _items.Count - 1; i >= 0; i--)
        {
            _items[i].Update(dt, this);
            if (!_items[i].Active) _items.RemoveAt(i);
        }

        // Update fireballs
        for (int i = _fireballs.Count - 1; i >= 0; i--)
        {
            _fireballs[i].Update(dt, this);
            if (!_fireballs[i].Active) _fireballs.RemoveAt(i);
        }

        // Update score popups
        for (int i = _scorePopups.Count - 1; i >= 0; i--)
        {
            _scorePopups[i].Timer -= dt;
            _scorePopups[i].Y -= 1f;
            if (_scorePopups[i].Timer <= 0) _scorePopups.RemoveAt(i);
        }

        // Update debris
        for (int i = _debris.Count - 1; i >= 0; i--)
        {
            _debris[i].Update(dt);
            if (!_debris[i].Active) _debris.RemoveAt(i);
        }

        // Flag animation
        if (_flagDescending)
        {
            _flagY += 2f;
            if (_flagY >= _flagTargetY) _flagY = _flagTargetY;
        }

        // Collision: Mario vs Enemies
        if (!Mario.IsDead && !Mario.ReachedFlag)
            CheckMarioEnemyCollisions();

        // Collision: Mario vs Items
        if (!Mario.IsDead)
            CheckMarioItemCollisions();

        // Check pipe entry (after collision so Mario is on ground)
        if (!Mario.IsDead && !Mario.ReachedFlag && input.DownPressed && Mario.Body.OnGround)
            CheckPipeEntry();

        // Check flagpole
        if (!LevelComplete && !Mario.IsDead)
            CheckFlagpole();
    }

    private void CheckMarioEnemyCollisions()
    {
        foreach (var enemy in Enemies)
        {
            if (!enemy.Active || enemy.IsStomped) continue;
            if (enemy is Koopa koopa && koopa.IsShell && !koopa.ShellMoving) continue;

            if (!Mario.Intersects(enemy)) continue;

            // Check if stomping (Mario falling onto enemy)
            // Mario is stomping if he's moving downward and his feet are in the top half of the enemy
            float marioFeetPrevFrame = Mario.Body.Bottom - Mario.Body.Velocity.Y;
            bool isFalling = Mario.Body.Velocity.Y > 0;
            bool feetAboveEnemyMid = Mario.Body.Bottom < enemy.Body.Top + enemy.Body.Height / 2;
            bool wasAboveEnemy = marioFeetPrevFrame <= enemy.Body.Top + 2;
            if (isFalling && (feetAboveEnemyMid || wasAboveEnemy)
                && enemy.CanBeStomped)
            {
                enemy.OnStomped(this);
                Mario.Body.Velocity.Y = Constants.JumpVelocityWalk * 0.6f;
                AddScore(enemy is Goomba ? Constants.ScoreGoomba : Constants.ScoreKoopa, enemy.Body.Position);
            }
            else if (Mario.HasStar)
            {
                // Star kills enemy
                if (enemy is Goomba g) g.KillByHit();
                else if (enemy is Koopa k) k.KillByHit();
                AddScore(Constants.ScoreGoomba, enemy.Body.Position);
            }
            else
            {
                // Mario takes damage
                if (enemy is Koopa k2 && k2.IsShell && !k2.ShellMoving)
                {
                    k2.KickShell(Mario.Body.Position.X < k2.Body.Position.X);
                }
                else
                {
                    Mario.TakeDamage();
                }
            }
        }
    }

    private void CheckMarioItemCollisions()
    {
        for (int i = _items.Count - 1; i >= 0; i--)
        {
            var item = _items[i];
            if (!item.Active || !Mario.Intersects(item)) continue;

            if (item is Mushroom mush)
            {
                if (mush.IsOneUp)
                {
                    Lives++;
                }
                else
                {
                    Mario.CollectMushroom();
                    AddScore(Constants.ScoreMushroom, item.Body.Position);
                }
                item.Active = false;
            }
            else if (item is FireFlower)
            {
                Mario.CollectFireFlower();
                AddScore(Constants.ScoreFireFlower, item.Body.Position);
                item.Active = false;
            }
            else if (item is Star)
            {
                Mario.CollectStar();
                AddScore(Constants.ScoreStar, item.Body.Position);
                item.Active = false;
            }
            else if (item is Coin)
            {
                Coins++;
                Score += Constants.ScoreCoin;
                if (Coins >= 100)
                {
                    Coins -= 100;
                    Lives++;
                }
                item.Active = false;
            }
        }
    }

    private void CheckFlagpole()
    {
        // Check if Mario touches the flagpole (x=206 tiles)
        int flagX = 206 * Constants.TileSize;
        if (Mario.Body.Right >= flagX && Mario.Body.Left <= flagX + Constants.TileSize && !LevelComplete)
        {
            LevelComplete = true;
            Mario.ReachedFlag = true;
            Mario.Body.Position.X = flagX - Mario.Body.Width;

            // Calculate flag score based on height
            float height = Mario.Body.Position.Y;
            int flagScore = height < 4 * Constants.TileSize ? 5000 :
                           height < 6 * Constants.TileSize ? 2000 :
                           height < 8 * Constants.TileSize ? 800 :
                           height < 10 * Constants.TileSize ? 400 : Constants.ScoreFlagBase;
            AddScore(flagScore, Mario.Body.Position);

            // Start flag descent
            _flagDescending = true;
            _flagY = 2 * Constants.TileSize;
            _flagTargetY = 12 * Constants.TileSize;
        }
    }

    private void CheckPipeEntry()
    {
        float marioCenterX = (Mario.Body.Position.X + Mario.Body.Width / 2f) / Constants.TileSize;
        int marioFeetY = (int)(Mario.Body.Bottom / Constants.TileSize);

        switch (_currentArea)
        {
            case LevelArea.Overworld:
            {
                // Check if Mario is on the enterable pipe at x=46 (pipe top at y=9)
                float pipeX = Constants.PipeEntryX;
                if (marioCenterX >= pipeX && marioCenterX <= pipeX + 2f
                    && marioFeetY == Constants.PipeEntryTopY)
                {
                    _pipeState = PipeState.EnteringPipe;
                    _pipeTimer = 0;
                    _savedCameraX = Camera.X;
                    _overworldEnemies = new List<Enemy>(Enemies);
                    Enemies = new List<Enemy>();
                    Mario.Body.Velocity = Vector2.Zero;
                    // Center Mario on pipe
                    Mario.Body.Position.X = (Constants.PipeEntryX + 0.5f) * Constants.TileSize - Mario.Body.Width / 2f;
                }
                break;
            }
            case LevelArea.Underground:
            {
                // Check if Mario is on the exit pipe at x=13 (pipe top at y=11)
                float pipeX = 13f;
                if (marioCenterX >= pipeX && marioCenterX <= pipeX + 2f
                    && marioFeetY == 11)
                {
                    _pipeState = PipeState.EnteringPipe;
                    _pipeTimer = 0;
                    Mario.Body.Velocity = Vector2.Zero;
                    // Center Mario on pipe
                    Mario.Body.Position.X = 13f * Constants.TileSize + Constants.TileSize - Mario.Body.Width / 2f;
                }
                break;
            }
        }
    }

    private void UpdatePipeTransition(float dt)
    {
        _pipeTimer += dt;

        switch (_pipeState)
        {
            case PipeState.EnteringPipe:
            {
                // Slide Mario down into the pipe
                Mario.Body.Position.Y += 1f;

                if (_pipeTimer >= Constants.PipeAnimDuration)
                {
                    // Done entering - swap areas
                    switch (_currentArea)
                    {
                        case LevelArea.Overworld:
                        {
                            // Save overworld tiles state
                            _overworldTiles = (Tile[,])_tiles.Clone();
                            // Switch to underground
                            _tiles = (Tile[,])_undergroundTiles.Clone();
                            _currentArea = LevelArea.Underground;
                            CollisionSystem.SetTiles(_tiles);
                            // Reset camera for underground (one screen)
                            Camera = new Camera(Constants.UndergroundWidthTiles * Constants.TileSize);
                            Camera.Reset();
                            // Place Mario at underground entry
                            Mario.Body.Position.X = 2f * Constants.TileSize;
                            Mario.Body.Position.Y = 11f * Constants.TileSize - Mario.Body.Height;
                            Mario.Body.Velocity = Vector2.Zero;
                            Mario.Body.OnGround = false;
                            // Spawn underground coins as items
                            var (_, coinPositions) = LevelData.GetUnderground();
                            _items.Clear();
                            foreach (var (row, col) in coinPositions)
                            {
                                var coin = new Coin(_sprites, isPopup: false, isStatic: true);
                                coin.Position = new Vector2(col * Constants.TileSize, row * Constants.TileSize);
                                _items.Add(coin);
                            }
                            _fireballs.Clear();
                            Enemies.Clear();
                            _pipeState = PipeState.None;
                            break;
                        }
                        case LevelArea.Underground:
                        {
                            // Switch back to overworld
                            _tiles = (Tile[,])_overworldTiles.Clone();
                            _currentArea = LevelArea.Overworld;
                            CollisionSystem.SetTiles(_tiles);
                            // Restore camera
                            Camera = new Camera(Constants.LevelWidthTiles * Constants.TileSize);
                            // Place Mario inside the exit pipe (he'll slide up out of it)
                            float exitX = Constants.PipeExitReturnX * Constants.TileSize + Constants.TileSize - Mario.Body.Width / 2f;
                            float pipeTopY = 11f * Constants.TileSize;
                            Mario.Body.Position.X = exitX;
                            Mario.Body.Position.Y = pipeTopY;
                            Mario.Body.Velocity = Vector2.Zero;
                            Mario.Body.OnGround = false;
                            // Restore enemies
                            Enemies = _overworldEnemies ?? new List<Enemy>();
                            _overworldEnemies = null;
                            _items.Clear();
                            _fireballs.Clear();
                            // Set camera to Mario's position
                            Camera.ForceX(Math.Max(0, Math.Min(exitX - Constants.NESWidth / 2f, Camera.MaxX)));
                            _pipeState = PipeState.ExitingPipe;
                            _pipeTimer = 0;
                            break;
                        }
                    }
                }
                break;
            }
            case PipeState.ExitingPipe:
            {
                // Mario slides up out of the pipe at overworld exit
                float pipeTopY = 11f * Constants.TileSize;
                float targetY = pipeTopY - Mario.Body.Height;
                Mario.Body.Position.Y -= 1f;

                if (Mario.Body.Position.Y <= targetY || _pipeTimer >= Constants.PipeAnimDuration)
                {
                    Mario.Body.Position.Y = targetY;
                    Mario.Body.OnGround = true;
                    _pipeState = PipeState.None;
                }
                break;
            }
        }
    }

    public void HitBlock(Tile tile, Mario mario)
    {
        if (tile.IsHit && tile.Type == TileType.QuestionUsed) return;

        tile.BumpOffset = -8;

        if (tile.Type == TileType.Question || (tile.Type == TileType.Invisible && !tile.IsHit))
        {
            tile.IsHit = true;
            tile.Type = TileType.QuestionUsed;
            SpawnItemFromBlock(tile);
        }
        else if (tile.Type == TileType.Brick)
        {
            if (mario.Power != PowerState.Small)
            {
                // Break brick
                BreakBrick(tile);
            }
            else if (tile.Content != ItemContent.None)
            {
                tile.IsHit = true;
                tile.Type = TileType.QuestionUsed;
                SpawnItemFromBlock(tile);
            }
            else
            {
                tile.BumpOffset = -4;
            }

            // Bump kills enemies standing on top
            foreach (var enemy in Enemies)
            {
                if (!enemy.Active || enemy.IsStomped) continue;
                int ex = (int)(enemy.Body.Position.X + enemy.Body.Width / 2) / Constants.TileSize;
                int ey = (int)(enemy.Body.Bottom) / Constants.TileSize;
                if (ex == tile.GridX && ey == tile.GridY)
                {
                    if (enemy is Goomba g) g.KillByHit();
                    else if (enemy is Koopa k) k.KillByHit();
                    AddScore(Constants.ScoreGoomba, enemy.Body.Position);
                }
            }
        }
    }

    private void SpawnItemFromBlock(Tile tile)
    {
        float spawnX = tile.GridX * Constants.TileSize;
        float spawnY = tile.GridY * Constants.TileSize;

        switch (tile.Content)
        {
            case ItemContent.Coin:
                Coins++;
                Score += Constants.ScoreCoin;
                if (Coins >= 100) { Coins -= 100; Lives++; }
                // Spawn popup coin
                var popCoin = new Coin(_sprites, true);
                popCoin.Position = new Vector2(spawnX, spawnY);
                _items.Add(popCoin);
                break;

            case ItemContent.Mushroom:
                if (Mario.Power == PowerState.Small)
                {
                    var mush = new Mushroom(_sprites);
                    mush.Position = new Vector2(spawnX, spawnY);
                    mush.StartEmerge();
                    _items.Add(mush);
                }
                else
                {
                    var flower = new FireFlower(_sprites);
                    flower.Position = new Vector2(spawnX, spawnY);
                    flower.StartEmerge();
                    _items.Add(flower);
                }
                break;

            case ItemContent.Star:
                var star = new Star(_sprites);
                star.Position = new Vector2(spawnX, spawnY);
                star.StartEmerge();
                _items.Add(star);
                break;

            case ItemContent.OneUp:
                var oneUp = new Mushroom(_sprites, true);
                oneUp.Position = new Vector2(spawnX, spawnY);
                oneUp.StartEmerge();
                _items.Add(oneUp);
                break;

            case ItemContent.Bowser:
                var bowser = new Entities.Items.BowserEasterEgg(_sprites);
                bowser.Position = new Vector2(spawnX, spawnY);
                bowser.StartEmerge();
                _items.Add(bowser);
                break;

            case ItemContent.None:
                // Empty question block? Give a coin
                Coins++;
                Score += Constants.ScoreCoin;
                if (Coins >= 100) { Coins -= 100; Lives++; }
                var defCoin = new Coin(_sprites, true);
                defCoin.Position = new Vector2(spawnX, spawnY);
                _items.Add(defCoin);
                break;
        }
    }

    private void BreakBrick(Tile tile)
    {
        _tiles[tile.GridY, tile.GridX] = null;
        Score += Constants.ScoreBrick;

        // Spawn 4 debris pieces
        float bx = tile.GridX * Constants.TileSize + 8;
        float by = tile.GridY * Constants.TileSize + 8;
        _debris.Add(new BrickDebris(bx - 4, by - 4, -1.5f, -4f));
        _debris.Add(new BrickDebris(bx + 4, by - 4, 1.5f, -4f));
        _debris.Add(new BrickDebris(bx - 4, by + 4, -1f, -3f));
        _debris.Add(new BrickDebris(bx + 4, by + 4, 1f, -3f));
    }

    public void AddScore(int amount, Vector2 position)
    {
        Score += amount;
        _scorePopups.Add(new ScorePopup { Amount = amount, X = position.X, Y = position.Y, Timer = 1f });
    }

    public void Draw(SpriteBatch sb)
    {
        // Draw tiles
        int startX = Math.Max(0, (int)(Camera.X / Constants.TileSize) - 1);
        int endX = Math.Min(Constants.LevelWidthTiles - 1, startX + (Constants.NESWidth / Constants.TileSize) + 2);

        for (int y = 0; y < Constants.LevelHeightTiles; y++)
        {
            for (int x = startX; x <= endX; x++)
            {
                var tile = _tiles[y, x];
                if (tile == null) continue;
                DrawTile(sb, tile);
            }
        }

        // Draw flag (overworld only)
        if ((_flagDescending || LevelComplete) && _currentArea == LevelArea.Overworld)
        {
            float flagDrawX = 206 * Constants.TileSize - 16;
            sb.Draw(_sprites.Textures["flag"], new Vector2(flagDrawX, _flagY),
                null, Color.White, 0f, Vector2.Zero, 1f, SpriteEffects.None, 0f);
        }

        // Draw items
        foreach (var item in _items)
            item.Draw(sb);

        // Draw enemies
        foreach (var enemy in Enemies)
        {
            if (enemy.Active && Camera.IsVisible(enemy.Body.Position.X, 16))
                enemy.Draw(sb);
        }

        // Draw Mario
        Mario.Draw(sb);

        // Draw fireballs
        foreach (var fb in _fireballs)
            fb.Draw(sb);

        // Draw debris
        foreach (var d in _debris)
            d.Draw(sb, _sprites.Textures["brick_debris"]);

        // Draw score popups
        foreach (var popup in _scorePopups)
        {
            DrawText(sb, popup.Amount.ToString(), popup.X, popup.Y, 0.8f);
        }
    }

    private void DrawTile(SpriteBatch sb, Tile tile)
    {
        bool isUg = _currentArea == LevelArea.Underground;
        string texName = tile.Type switch
        {
            TileType.Ground => isUg ? "ground_ug" : "ground",
            TileType.Brick => isUg ? "brick_ug" : "brick",
            TileType.Question => "question" + tile.GetAnimFrame(),
            TileType.QuestionUsed => "used_block",
            TileType.HardBlock => isUg ? "hard_block_ug" : "hard_block",
            TileType.PipeTopLeft => "pipe_tl",
            TileType.PipeTopRight => "pipe_tr",
            TileType.PipeBodyLeft => "pipe_bl",
            TileType.PipeBodyRight => "pipe_br",
            TileType.FlagPole => "flagpole",
            TileType.FlagTop => "flagtop",
            _ => null
        };

        if (texName == null || !_sprites.Textures.ContainsKey(texName)) return;

        float drawY = tile.GridY * Constants.TileSize + tile.BumpOffset;
        sb.Draw(_sprites.Textures[texName],
            new Vector2(tile.GridX * Constants.TileSize, drawY),
            Color.White);
    }

    public void DrawText(SpriteBatch sb, string text, float x, float y, float scale = 1f)
    {
        float cx = x;
        foreach (char c in text.ToUpper())
        {
            string key = "font_" + c;
            if (_sprites.Textures.ContainsKey(key))
            {
                sb.Draw(_sprites.Textures[key], new Vector2(cx, y), null, Color.White,
                    0f, Vector2.Zero, scale, SpriteEffects.None, 0f);
            }
            cx += 6 * scale;
        }
    }
}

public class ScorePopup
{
    public int Amount;
    public float X, Y;
    public float Timer;
}

public class BrickDebris
{
    public float X, Y, VX, VY;
    public bool Active = true;

    public BrickDebris(float x, float y, float vx, float vy)
    {
        X = x; Y = y; VX = vx; VY = vy;
    }

    public void Update(float dt)
    {
        VY += Constants.Gravity;
        X += VX;
        Y += VY;
        if (Y > Constants.LevelHeightTiles * Constants.TileSize) Active = false;
    }

    public void Draw(SpriteBatch sb, Texture2D tex)
    {
        sb.Draw(tex, new Vector2((int)X, (int)Y), Color.White);
    }
}
