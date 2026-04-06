namespace AIMario.Core;

public enum GameState
{
    Title,
    Playing,
    Death,
    GameOver,
    LevelComplete
}

public class GameStateManager
{
    public GameState CurrentState { get; private set; } = GameState.Title;
    private float _stateTimer;

    public void SetState(GameState state)
    {
        CurrentState = state;
        _stateTimer = 0;
    }

    public float StateTimer => _stateTimer;

    public void Update(float deltaTime)
    {
        _stateTimer += deltaTime;
    }
}
