namespace AIMario.Core;

public static class Constants
{
    // Screen
    public const int NESWidth = 256;
    public const int NESHeight = 240;
    public const int WindowScale = 3;
    public const int WindowWidth = NESWidth * WindowScale;
    public const int WindowHeight = NESHeight * WindowScale;

    // Tiles
    public const int TileSize = 16;

    // Level
    public const int LevelWidthTiles = 224;
    public const int LevelHeightTiles = 15;

    // Physics (per frame at 60 FPS)
    public const float Gravity = 0.28f;
    public const float MaxFallSpeed = 5.0f;

    // Mario movement
    public const float WalkAccel = 0.1f;
    public const float WalkMaxSpeed = 1.5f;
    public const float RunAccel = 0.1f;
    public const float RunMaxSpeed = 2.5f;
    public const float Friction = 0.15f;
    public const float JumpVelocityWalk = -6.3f;
    public const float JumpVelocityRun = -7.2f;
    public const float JumpReleaseCap = -2.0f;

    // Enemy
    public const float GoombaSpeed = 0.5f;
    public const float KoopaSpeed = 0.5f;
    public const float ShellSpeed = 3.0f;
    public const float FireballSpeed = 3.0f;
    public const float FireballGravity = 0.3f;
    public const float FireballBounce = -3.5f;

    // Items
    public const float MushroomSpeed = 1.0f;
    public const float StarSpeed = 1.5f;
    public const float StarBounce = -4.0f;

    // Scoring
    public const int ScoreCoin = 200;
    public const int ScoreGoomba = 100;
    public const int ScoreKoopa = 100;
    public const int ScoreMushroom = 1000;
    public const int ScoreFireFlower = 1000;
    public const int ScoreStar = 1000;
    public const int Score1Up = 0;
    public const int ScoreBrick = 50;
    public const int ScoreFlagBase = 100;

    // Timer
    public const int LevelTime = 400;
    public const float TimerTickRate = 0.4f; // seconds per timer unit

    // Lives
    public const int StartingLives = 3;

    // Underground pipe transition
    public const int UndergroundWidthTiles = 16;
    public const int PipeEntryX = 46;
    public const int PipeEntryTopY = 9;
    public const int PipeExitReturnX = 163;
    public const float PipeAnimDuration = 0.5f;

    // Colors (NES palette approximations)
    public const uint SkyBlue = 0xFF9290FF;       // ABGR for MonoGame
}
