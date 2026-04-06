use macroquad::prelude::*;
use crate::level::Level;
use crate::sprites::SpriteGenerator;

pub struct TitleScreen {
    blink_timer: f32,
}

impl TitleScreen {
    pub fn new() -> Self {
        Self { blink_timer: 0.0 }
    }

    pub fn update(&mut self, dt: f32) {
        self.blink_timer += dt;
    }

    pub fn draw(&self, sprites: &SpriteGenerator) {
        let title_red = Color::from_rgba(200, 36, 0, 255);
        let title_white = Color::from_rgba(252, 252, 252, 255);
        let title_gold = Color::from_rgba(248, 184, 0, 255);

        // Shadow layer
        let shadow = Color::new(0.0, 0.0, 0.0, 0.314);
        Level::draw_text_colored(sprites, "SUPER", 81.0, 51.0, 2.0, shadow);
        Level::draw_text_colored(sprites, "MARIO BROS", 45.0, 76.0, 2.0, shadow);

        // Main title
        Level::draw_text_colored(sprites, "SUPER", 80.0, 50.0, 2.0, title_red);
        Level::draw_text_colored(sprites, "MARIO BROS", 44.0, 75.0, 2.0, title_white);

        // Subtitle
        Level::draw_text_colored(sprites, "WORLD 1-1", 89.0, 120.0, 1.0, title_gold);

        // Blinking prompt
        let flicker = (self.blink_timer * 3.0) as i32 % 2 == 0;
        if flicker {
            Level::draw_text_colored(sprites, "PRESS ENTER", 74.0, 170.0, 1.0, title_white);
        }

        // Credits
        let grey = Color::from_rgba(188, 188, 188, 255);
        Level::draw_text_colored(sprites, "A FAITHFUL RECREATION", 38.0, 210.0, 1.0, grey);
    }
}
