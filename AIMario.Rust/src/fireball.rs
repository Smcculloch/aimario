use macroquad::prelude::*;
use crate::constants::*;
use crate::physics::{PhysicsBody, move_and_collide, bodies_intersect};
use crate::sprites::SpriteGenerator;
use crate::tiles::Tile;

pub struct Fireball {
    pub body: PhysicsBody,
    pub active: bool,
    timer: f32,
}

impl Fireball {
    pub fn new(x: f32, y: f32, go_right: bool) -> Self {
        Self {
            body: PhysicsBody {
                x, y,
                width: 8.0,
                height: 8.0,
                vx: if go_right { FIREBALL_SPEED } else { -FIREBALL_SPEED },
                apply_gravity: false,
                ..PhysicsBody::new()
            },
            active: true,
            timer: 0.0,
        }
    }

    pub fn update(&mut self, dt: f32, tiles: &Vec<Vec<Option<Tile>>>) {
        self.timer += dt;

        // Custom gravity for bounce
        self.body.vy += FIREBALL_GRAVITY;
        if self.body.vy > MAX_FALL_SPEED {
            self.body.vy = MAX_FALL_SPEED;
        }

        let result = move_and_collide(&mut self.body, tiles);

        if result.hit_left || result.hit_right {
            self.active = false;
            return;
        }

        if result.hit_bottom {
            self.body.vy = FIREBALL_BOUNCE;
        }

        if self.body.y > LEVEL_HEIGHT_TILES as f32 * TILE_SIZE as f32 {
            self.active = false;
        }

        if self.timer > 3.0 { self.active = false; }
    }

    pub fn draw(&self, sprites: &SpriteGenerator) {
        if !self.active { return; }
        if let Some(tex) = sprites.textures.get("fireball") {
            draw_texture(
                &tex,
                self.body.x.floor(),
                self.body.y.floor(),
                WHITE,
            );
        }
    }

    pub fn intersects_body(&self, other: &PhysicsBody) -> bool {
        self.active && bodies_intersect(&self.body, other)
    }
}
