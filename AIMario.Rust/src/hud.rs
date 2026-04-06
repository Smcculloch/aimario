use macroquad::prelude::*;
use crate::level::Level;
use crate::sprites::SpriteGenerator;

pub fn draw_hud(sprites: &SpriteGenerator, level: &Level) {
    let hud_white = Color::from_rgba(252, 252, 252, 255);
    let hud_gold = Color::from_rgba(248, 184, 0, 255);

    let y = 8.0;
    let scale = 1.0;

    // MARIO
    draw_text_colored(sprites, "MARIO", 24.0, y, scale, hud_white);
    draw_text_colored(sprites, &format!("{:06}", level.score), 24.0, y + 10.0, scale, hud_white);

    // Coins
    draw_text_colored(sprites, &format!("x{:02}", level.coins), 96.0, y + 10.0, scale, hud_gold);

    // WORLD
    draw_text_colored(sprites, "WORLD", 144.0, y, scale, hud_white);
    draw_text_colored(sprites, "1-1", 152.0, y + 10.0, scale, hud_white);

    // TIME
    draw_text_colored(sprites, "TIME", 200.0, y, scale, hud_white);
    draw_text_colored(sprites, &format!("{:03}", level.timer as i32), 208.0, y + 10.0, scale, hud_white);
}

fn draw_text_colored(sprites: &SpriteGenerator, text: &str, x: f32, y: f32, scale: f32, color: Color) {
    Level::draw_text_colored(sprites, text, x, y, scale, color);
}
