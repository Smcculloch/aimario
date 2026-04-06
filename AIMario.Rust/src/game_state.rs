#[derive(Clone, Copy, PartialEq, Eq)]
pub enum GameState {
    Title,
    Playing,
    Death,
    GameOver,
    LevelComplete,
}

pub struct GameStateManager {
    pub current_state: GameState,
    pub state_timer: f32,
}

impl GameStateManager {
    pub fn new() -> Self {
        Self {
            current_state: GameState::Title,
            state_timer: 0.0,
        }
    }

    pub fn set_state(&mut self, state: GameState) {
        self.current_state = state;
        self.state_timer = 0.0;
    }

    pub fn update(&mut self, dt: f32) {
        self.state_timer += dt;
    }
}
