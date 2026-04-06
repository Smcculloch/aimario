use macroquad::prelude::*;

mod constants;
mod game_state;
mod camera;
mod physics;
mod tiles;
mod input;
mod sprites;
mod mario;
mod enemies;
mod items;
mod fireball;
mod level_data;
mod level;
mod hud;
mod title_screen;

use constants::*;
use game_state::*;
use input::InputManager;
use sprites::SpriteGenerator;
use level::Level;
use title_screen::TitleScreen;

fn window_conf() -> Conf {
    Conf {
        window_title: "SUPER MARIO BROS".to_owned(),
        window_width: WINDOW_WIDTH,
        window_height: WINDOW_HEIGHT,
        window_resizable: false,
        ..Default::default()
    }
}

#[macroquad::main(window_conf)]
async fn main() {
    let mut sprites = SpriteGenerator::new();
    sprites.generate();
    let pixel = sprites.create_pixel();

    let render_target = render_target(NES_WIDTH as u32, NES_HEIGHT as u32);
    render_target.texture.set_filter(FilterMode::Nearest);

    let mut input_mgr = InputManager::new();
    let mut state_mgr = GameStateManager::new();
    let mut level = Level::new();
    level.load();
    let mut title = TitleScreen::new();

    loop {
        if is_key_pressed(KeyCode::Escape) {
            break;
        }

        let dt = get_frame_time().min(0.05); // cap dt to avoid physics issues
        input_mgr.update();
        state_mgr.update(dt);

        // Update
        match state_mgr.current_state {
            GameState::Title => {
                title.update(dt);
                if input_mgr.start {
                    level.load();
                    state_mgr.set_state(GameState::Playing);
                }
            }
            GameState::Playing => {
                level.update(dt, &input_mgr);
                if level.mario.is_dead {
                    state_mgr.set_state(GameState::Death);
                } else if level.level_complete {
                    state_mgr.set_state(GameState::LevelComplete);
                }
            }
            GameState::Death => {
                level.update(dt, &input_mgr);
                if state_mgr.state_timer > 3.0 {
                    level.lives -= 1;
                    if level.lives <= 0 {
                        state_mgr.set_state(GameState::GameOver);
                    } else {
                        level.reset();
                        state_mgr.set_state(GameState::Playing);
                    }
                }
            }
            GameState::LevelComplete => {
                level.update(dt, &input_mgr);
                if state_mgr.state_timer > 5.0 {
                    state_mgr.set_state(GameState::Title);
                }
            }
            GameState::GameOver => {
                if state_mgr.state_timer > 3.0 {
                    level.lives = STARTING_LIVES;
                    level.score = 0;
                    level.coins = 0;
                    state_mgr.set_state(GameState::Title);
                }
            }
        }

        // Draw to render target
        set_camera(&Camera2D {
            render_target: Some(render_target.clone()),
            zoom: vec2(2.0 / NES_WIDTH as f32, 2.0 / NES_HEIGHT as f32),
            target: vec2(NES_WIDTH as f32 / 2.0, NES_HEIGHT as f32 / 2.0),
            ..Default::default()
        });

        // Background color depends on current area
        clear_background(level.background_color());

        match state_mgr.current_state {
            GameState::Title => {
                title.draw(&sprites);
            }
            GameState::Playing | GameState::Death | GameState::LevelComplete => {
                level.draw(&sprites, level.camera.x);
            }
            GameState::GameOver => {
                // Black screen drawn later in HUD pass
            }
        }

        // HUD pass (no camera transform - draw directly on render target)
        if state_mgr.current_state != GameState::Title {
            if state_mgr.current_state == GameState::GameOver {
                // Draw black background
                draw_texture_ex(
                    &pixel,
                    0.0,
                    0.0,
                    BLACK,
                    DrawTextureParams {
                        dest_size: Some(Vec2::new(NES_WIDTH as f32, NES_HEIGHT as f32)),
                        ..Default::default()
                    },
                );
                Level::draw_text(&sprites, "GAME OVER", 88.0, 112.0, 1.0);
            } else {
                hud::draw_hud(&sprites, &level);
            }
        }

        // Scale render target to window
        set_default_camera();
        clear_background(BLACK);

        draw_texture_ex(
            &render_target.texture,
            0.0,
            0.0,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(WINDOW_WIDTH as f32, WINDOW_HEIGHT as f32)),
                flip_y: false,
                ..Default::default()
            },
        );

        next_frame().await;
    }
}
