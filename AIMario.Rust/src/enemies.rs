use macroquad::prelude::*;
use crate::constants::*;
use crate::physics::{PhysicsBody, move_and_collide, bodies_intersect};
use crate::sprites::SpriteGenerator;
use crate::tiles::Tile;

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum EnemyType {
    Goomba,
    Koopa,
}

pub struct Enemy {
    pub body: PhysicsBody,
    pub active: bool,
    pub facing_right: bool,
    pub is_stomped: bool,
    pub enemy_type: EnemyType,
    pub can_be_stomped: bool,

    // Goomba-specific
    flat: bool,
    flat_timer: f32,
    turn_cooldown: f32,

    // Koopa-specific
    pub is_shell: bool,
    pub shell_moving: bool,
    shell_kick_cooldown: f32,

    // Common
    anim_timer: f32,
    death_timer: f32,
}

impl Enemy {
    pub fn new_goomba() -> Self {
        Self {
            body: PhysicsBody {
                width: 14.0,
                height: 16.0,
                vx: -GOOMBA_SPEED,
                ..PhysicsBody::new()
            },
            active: true,
            facing_right: false,
            is_stomped: false,
            enemy_type: EnemyType::Goomba,
            can_be_stomped: true,
            flat: false,
            flat_timer: 0.0,
            turn_cooldown: 0.0,
            is_shell: false,
            shell_moving: false,
            shell_kick_cooldown: 0.0,
            anim_timer: 0.0,
            death_timer: 0.0,
        }
    }

    pub fn new_koopa() -> Self {
        Self {
            body: PhysicsBody {
                width: 14.0,
                height: 24.0,
                vx: -KOOPA_SPEED,
                ..PhysicsBody::new()
            },
            active: true,
            facing_right: false,
            is_stomped: false,
            enemy_type: EnemyType::Koopa,
            can_be_stomped: true,
            flat: false,
            flat_timer: 0.0,
            turn_cooldown: 0.0,
            is_shell: false,
            shell_moving: false,
            shell_kick_cooldown: 0.0,
            anim_timer: 0.0,
            death_timer: 0.0,
        }
    }

    pub fn update(&mut self, dt: f32, tiles: &Vec<Vec<Option<Tile>>>) {
        match self.enemy_type {
            EnemyType::Goomba => self.update_goomba(dt, tiles),
            EnemyType::Koopa => self.update_koopa(dt, tiles),
        }
    }

    fn update_goomba(&mut self, dt: f32, tiles: &Vec<Vec<Option<Tile>>>) {
        if self.flat {
            self.flat_timer += dt;
            if self.flat_timer > 0.5 { self.active = false; }
            return;
        }

        if self.is_stomped {
            self.body.vy += GRAVITY;
            self.body.x += self.body.vx;
            self.body.y += self.body.vy;
            self.death_timer += dt;
            if self.death_timer > 2.0 { self.active = false; }
            return;
        }

        self.anim_timer += dt;
        self.turn_cooldown -= dt;
        self.body.apply_physics();

        let result = move_and_collide(&mut self.body, tiles);

        if (result.hit_left || result.hit_right) && self.turn_cooldown <= 0.0 {
            self.body.vx = if result.hit_left { GOOMBA_SPEED } else { -GOOMBA_SPEED };
            self.turn_cooldown = 0.1;
        }

        if self.body.y > LEVEL_HEIGHT_TILES as f32 * TILE_SIZE as f32 {
            self.active = false;
        }
    }

    fn update_koopa(&mut self, dt: f32, tiles: &Vec<Vec<Option<Tile>>>) {
        if self.is_stomped && !self.is_shell {
            self.body.vy += GRAVITY;
            self.body.x += self.body.vx;
            self.body.y += self.body.vy;
            self.death_timer += dt;
            if self.death_timer > 2.0 { self.active = false; }
            return;
        }

        self.anim_timer += dt;
        self.shell_kick_cooldown -= dt;
        self.turn_cooldown -= dt;

        self.body.apply_physics();
        let result = move_and_collide(&mut self.body, tiles);

        if (result.hit_left || result.hit_right) && self.turn_cooldown <= 0.0 {
            let speed = if self.shell_moving { SHELL_SPEED } else { KOOPA_SPEED };
            self.body.vx = if result.hit_left { speed } else { -speed };
            self.facing_right = self.body.vx > 0.0;
            self.turn_cooldown = 0.1;
        }

        if self.body.y > LEVEL_HEIGHT_TILES as f32 * TILE_SIZE as f32 {
            self.active = false;
        }
    }

    pub fn on_stomped_goomba(&mut self) {
        self.flat = true;
        self.is_stomped = true;
        self.flat_timer = 0.0;
        self.body.vx = 0.0;
        self.body.y += self.body.height - 2.0;
        self.body.height = 2.0;
    }

    pub fn on_stomped_koopa(&mut self, mario_x: f32) {
        if !self.is_shell {
            self.is_shell = true;
            self.shell_moving = false;
            self.body.vx = 0.0;
            self.body.height = 16.0;
            self.body.y += 8.0;
            self.shell_kick_cooldown = 0.2;
        } else if !self.shell_moving && self.shell_kick_cooldown <= 0.0 {
            self.kick_shell(mario_x < self.body.x);
        } else if self.shell_moving {
            self.shell_moving = false;
            self.body.vx = 0.0;
            self.shell_kick_cooldown = 0.2;
        }
    }

    pub fn kick_shell(&mut self, kick_right: bool) {
        self.shell_moving = true;
        self.body.vx = if kick_right { SHELL_SPEED } else { -SHELL_SPEED };
        self.shell_kick_cooldown = 0.2;
    }

    pub fn kill_by_hit(&mut self) {
        self.is_stomped = true;
        self.body.vy = -3.0;
    }

    pub fn get_texture_name(&self) -> &str {
        match self.enemy_type {
            EnemyType::Goomba => {
                if self.flat { return "goomba_flat"; }
                let frame = (self.anim_timer * 4.0) as i32 % 2;
                if frame == 0 { "goomba0" } else { "goomba1" }
            }
            EnemyType::Koopa => {
                if self.is_shell { return "koopa_shell"; }
                let frame = (self.anim_timer * 4.0) as i32 % 2;
                if frame == 0 { "koopa0" } else { "koopa1" }
            }
        }
    }

    pub fn draw(&self, sprites: &SpriteGenerator) {
        if !self.active { return; }

        let tex_name = self.get_texture_name();
        if let Some(tex) = sprites.textures.get(tex_name) {
            let mut draw_y = self.body.y;
            let mut flip_x = false;
            let mut flip_y = false;

            match self.enemy_type {
                EnemyType::Goomba => {
                    if self.flat {
                        draw_y = self.body.y - 14.0;
                    } else if self.is_stomped {
                        flip_y = true;
                    }
                }
                EnemyType::Koopa => {
                    if self.is_stomped && !self.is_shell {
                        flip_y = true;
                    } else {
                        flip_x = self.facing_right;
                    }
                }
            }

            draw_texture_ex(
                &tex,
                (self.body.x - 1.0).floor(),
                draw_y.floor(),
                WHITE,
                DrawTextureParams {
                    flip_x,
                    flip_y,
                    ..Default::default()
                },
            );
        }
    }

    pub fn intersects_body(&self, other: &PhysicsBody) -> bool {
        self.active && bodies_intersect(&self.body, other)
    }
}
