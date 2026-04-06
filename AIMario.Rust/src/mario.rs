use macroquad::prelude::*;
use crate::constants::*;
use crate::physics::PhysicsBody;
use crate::sprites::SpriteGenerator;
use crate::input::InputManager;

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum PowerState {
    Small,
    Big,
    Fire,
}

pub struct Mario {
    pub body: PhysicsBody,
    pub active: bool,
    pub facing_right: bool,
    pub power: PowerState,
    pub is_dead: bool,
    pub is_invincible: bool,
    pub has_star: bool,
    pub is_ducking: bool,
    pub reached_flag: bool,

    invincible_timer: f32,
    star_timer: f32,
    death_timer: f32,
    death_bounce: bool,
    blink_timer: f32,
    pub visible: bool,
    walk_anim_timer: f32,
}

impl Mario {
    pub fn new() -> Self {
        Self {
            body: PhysicsBody {
                width: 14.0,
                height: 16.0,
                ..PhysicsBody::new()
            },
            active: true,
            facing_right: true,
            power: PowerState::Small,
            is_dead: false,
            is_invincible: false,
            has_star: false,
            is_ducking: false,
            reached_flag: false,
            invincible_timer: 0.0,
            star_timer: 0.0,
            death_timer: 0.0,
            death_bounce: false,
            blink_timer: 0.0,
            visible: true,
            walk_anim_timer: 0.0,
        }
    }

    pub fn reset(&mut self, x: f32, y: f32) {
        self.body.x = x;
        self.body.y = y;
        self.body.vx = 0.0;
        self.body.vy = 0.0;
        self.body.on_ground = false;
        self.body.apply_gravity = true;
        self.power = PowerState::Small;
        self.body.width = 14.0;
        self.body.height = 16.0;
        self.is_dead = false;
        self.is_invincible = false;
        self.has_star = false;
        self.is_ducking = false;
        self.reached_flag = false;
        self.facing_right = true;
        self.active = true;
        self.visible = true;
        self.death_timer = 0.0;
        self.death_bounce = false;
        self.walk_anim_timer = 0.0;
    }

    pub fn update_input(&mut self, dt: f32, input: &InputManager) {
        if self.is_dead {
            self.update_death(dt);
            return;
        }

        if self.reached_flag {
            self.update_flag_slide(dt);
            return;
        }

        // Invincibility flashing
        if self.is_invincible && !self.has_star {
            self.invincible_timer -= dt;
            self.blink_timer += dt;
            self.visible = (self.blink_timer * 10.0) as i32 % 2 == 0;
            if self.invincible_timer <= 0.0 {
                self.is_invincible = false;
                self.visible = true;
            }
        }

        // Star timer
        if self.has_star {
            self.star_timer -= dt;
            self.blink_timer += dt;
            self.visible = (self.blink_timer * 15.0) as i32 % 2 == 0;
            if self.star_timer <= 0.0 {
                self.has_star = false;
                self.is_invincible = false;
                self.visible = true;
            }
        }

        // Horizontal movement
        let max_speed = if input.run { RUN_MAX_SPEED } else { WALK_MAX_SPEED };
        let accel = if input.run { RUN_ACCEL } else { WALK_ACCEL };

        if input.left {
            self.body.vx -= accel;
            if self.body.vx < -max_speed { self.body.vx = -max_speed; }
            self.facing_right = false;
        } else if input.right {
            self.body.vx += accel;
            if self.body.vx > max_speed { self.body.vx = max_speed; }
            self.facing_right = true;
        } else {
            if self.body.vx > 0.0 {
                self.body.vx -= FRICTION;
                if self.body.vx < 0.0 { self.body.vx = 0.0; }
            } else if self.body.vx < 0.0 {
                self.body.vx += FRICTION;
                if self.body.vx > 0.0 { self.body.vx = 0.0; }
            }
        }

        // Ducking
        if self.power != PowerState::Small && self.body.on_ground && input.down {
            if !self.is_ducking {
                self.is_ducking = true;
                self.body.height = 16.0;
                self.body.y += 16.0;
            }
        } else if self.is_ducking {
            self.is_ducking = false;
            self.body.height = 32.0;
            self.body.y -= 16.0;
        }

        // Jump
        if input.jump_pressed && self.body.on_ground {
            let jump_vel = if self.body.vx.abs() > WALK_MAX_SPEED {
                JUMP_VELOCITY_RUN
            } else {
                JUMP_VELOCITY_WALK
            };
            self.body.vy = jump_vel;
            self.body.on_ground = false;
        }

        // Variable jump height
        if !input.jump && self.body.vy < JUMP_RELEASE_CAP {
            self.body.vy = JUMP_RELEASE_CAP;
        }

        // Physics
        self.body.apply_physics();

        // Walk animation
        if self.body.vx.abs() > 0.1 && self.body.on_ground {
            self.walk_anim_timer += self.body.vx.abs() * dt;
        } else if self.body.on_ground {
            self.walk_anim_timer = 0.0;
        }
    }

    fn update_death(&mut self, dt: f32) {
        self.death_timer += dt;
        if !self.death_bounce && self.death_timer > 0.5 {
            self.body.vy = -5.0;
            self.death_bounce = true;
        }
        if self.death_bounce {
            self.body.vy += GRAVITY;
            self.body.y += self.body.vy;
        }
    }

    fn update_flag_slide(&mut self, dt: f32) {
        let _ = dt;
        self.body.vx = 0.0;
        self.body.vy = 2.0;
        self.body.y += self.body.vy;

        let ground_y = (LEVEL_HEIGHT_TILES - 2) as f32 * TILE_SIZE as f32 - self.body.height;
        if self.body.y >= ground_y {
            self.body.y = ground_y;
            self.body.vy = 0.0;
        }
    }

    pub fn die(&mut self) {
        if self.is_dead { return; }
        self.is_dead = true;
        self.death_timer = 0.0;
        self.death_bounce = false;
        self.body.vx = 0.0;
        self.body.vy = 0.0;
        self.body.apply_gravity = false;
        self.active = true;
    }

    pub fn take_damage(&mut self) {
        if self.is_invincible || self.is_dead { return; }

        if self.power == PowerState::Fire || self.power == PowerState::Big {
            self.power = PowerState::Small;
            self.body.height = 16.0;
            self.is_invincible = true;
            self.invincible_timer = 2.0;
            self.blink_timer = 0.0;
        } else {
            self.die();
        }
    }

    pub fn collect_mushroom(&mut self) {
        if self.power == PowerState::Small {
            self.power = PowerState::Big;
            self.body.height = 32.0;
            self.body.y -= 16.0;
        }
    }

    pub fn collect_fire_flower(&mut self) {
        if self.power == PowerState::Small {
            self.power = PowerState::Big;
            self.body.height = 32.0;
            self.body.y -= 16.0;
        }
        self.power = PowerState::Fire;
    }

    pub fn collect_star(&mut self) {
        self.has_star = true;
        self.is_invincible = true;
        self.star_timer = 10.0;
        self.blink_timer = 0.0;
    }

    pub fn get_texture_name(&self) -> String {
        let prefix = match self.power {
            PowerState::Fire => "mario_fire",
            PowerState::Big => "mario_big",
            PowerState::Small => "mario_small",
        };

        if self.is_dead { return "mario_small_death".into(); }
        if self.is_ducking { return format!("{}_duck", prefix); }
        if !self.body.on_ground { return format!("{}_jump", prefix); }

        if self.body.vx.abs() > 0.1 {
            let frame = ((self.walk_anim_timer * 8.0) as i32) % 3 + 1;
            return format!("{}_walk{}", prefix, frame);
        }

        format!("{}_stand", prefix)
    }

    pub fn draw(&self, sprites: &SpriteGenerator) {
        if !self.visible { return; }

        let tex_name = self.get_texture_name();
        if let Some(tex) = sprites.textures.get(&tex_name) {
            let draw_x = self.body.x - 1.0;
            let mut draw_y = self.body.y;

            if self.is_ducking {
                draw_y = self.body.y - 16.0;
            }

            let flip = !self.facing_right;
            draw_texture_ex(
                &tex,
                draw_x.floor(),
                draw_y.floor(),
                WHITE,
                DrawTextureParams {
                    flip_x: flip,
                    ..Default::default()
                },
            );
        }
    }
}
