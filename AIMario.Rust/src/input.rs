use macroquad::prelude::*;

pub struct InputManager {
    // Current frame state
    pub left: bool,
    pub right: bool,
    pub down: bool,
    pub down_pressed: bool,
    pub jump: bool,
    pub jump_pressed: bool,
    pub run: bool,
    pub run_pressed: bool,
    pub start: bool,
}

impl InputManager {
    pub fn new() -> Self {
        Self {
            left: false,
            right: false,
            down: false,
            down_pressed: false,
            jump: false,
            jump_pressed: false,
            run: false,
            run_pressed: false,
            start: false,
        }
    }

    pub fn update(&mut self) {
        self.left = is_key_down(KeyCode::Left);
        self.right = is_key_down(KeyCode::Right);
        self.down = is_key_down(KeyCode::Down);
        self.down_pressed = is_key_pressed(KeyCode::Down);

        self.jump = is_key_down(KeyCode::Z) || is_key_down(KeyCode::Space);
        self.jump_pressed = is_key_pressed(KeyCode::Z) || is_key_pressed(KeyCode::Space);

        self.run = is_key_down(KeyCode::X) || is_key_down(KeyCode::LeftShift);
        self.run_pressed = is_key_pressed(KeyCode::X) || is_key_pressed(KeyCode::LeftShift);

        self.start = is_key_pressed(KeyCode::Enter);
    }
}
