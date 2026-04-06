use macroquad::prelude::*;
use crate::constants::*;
use crate::physics::{PhysicsBody, move_and_collide, bodies_intersect};
use crate::sprites::SpriteGenerator;
use crate::tiles::Tile;

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum ItemType {
    Coin,
    Mushroom,
    OneUp,
    FireFlower,
    Star,
}

pub struct Item {
    pub body: PhysicsBody,
    pub active: bool,
    pub item_type: ItemType,

    timer: f32,
    start_y: f32,
    is_popup: bool,
    emerged: bool,
    emerge_timer: f32,
}

impl Item {
    pub fn new_static_coin(x: f32, y: f32) -> Self {
        Self {
            body: PhysicsBody {
                x, y,
                width: 16.0,
                height: 16.0,
                apply_gravity: false,
                ..PhysicsBody::new()
            },
            active: true,
            item_type: ItemType::Coin,
            timer: 0.0,
            start_y: y,
            is_popup: false,
            emerged: true,
            emerge_timer: 0.0,
        }
    }

    pub fn new_coin_popup(x: f32, y: f32) -> Self {
        Self {
            body: PhysicsBody {
                x, y,
                width: 16.0,
                height: 16.0,
                vy: -6.0,
                apply_gravity: false,
                ..PhysicsBody::new()
            },
            active: true,
            item_type: ItemType::Coin,
            timer: 0.0,
            start_y: 0.0,
            is_popup: true,
            emerged: true,
            emerge_timer: 0.0,
        }
    }

    pub fn new_mushroom(x: f32, y: f32, is_oneup: bool) -> Self {
        Self {
            body: PhysicsBody {
                x, y,
                width: 16.0,
                height: 16.0,
                apply_gravity: false,
                ..PhysicsBody::new()
            },
            active: true,
            item_type: if is_oneup { ItemType::OneUp } else { ItemType::Mushroom },
            timer: 0.0,
            start_y: y,
            is_popup: false,
            emerged: false,
            emerge_timer: 0.0,
        }
    }

    pub fn new_fire_flower(x: f32, y: f32) -> Self {
        Self {
            body: PhysicsBody {
                x, y,
                width: 16.0,
                height: 16.0,
                apply_gravity: false,
                ..PhysicsBody::new()
            },
            active: true,
            item_type: ItemType::FireFlower,
            timer: 0.0,
            start_y: y,
            is_popup: false,
            emerged: false,
            emerge_timer: 0.0,
        }
    }

    pub fn new_star(x: f32, y: f32) -> Self {
        Self {
            body: PhysicsBody {
                x, y,
                width: 16.0,
                height: 16.0,
                apply_gravity: false,
                ..PhysicsBody::new()
            },
            active: true,
            item_type: ItemType::Star,
            timer: 0.0,
            start_y: y,
            is_popup: false,
            emerged: false,
            emerge_timer: 0.0,
        }
    }

    pub fn update(&mut self, dt: f32, tiles: &Vec<Vec<Option<Tile>>>) {
        self.timer += dt;

        match self.item_type {
            ItemType::Coin => {
                if self.is_popup {
                    if self.start_y == 0.0 { self.start_y = self.body.y; }
                    self.body.vy += 0.3;
                    self.body.y += self.body.vy;
                    if self.body.y > self.start_y {
                        self.active = false;
                    }
                }
            }
            ItemType::Mushroom | ItemType::OneUp => {
                if !self.emerged {
                    self.emerge_timer += dt;
                    self.body.y = self.start_y - (self.emerge_timer / 0.5) * 16.0;
                    if self.emerge_timer >= 0.5 {
                        self.emerged = true;
                        self.body.y = self.start_y - 16.0;
                        self.body.vx = MUSHROOM_SPEED;
                        self.body.apply_gravity = true;
                    }
                    return;
                }

                self.body.apply_physics();
                let result = move_and_collide(&mut self.body, tiles);
                if result.hit_left || result.hit_right {
                    self.body.vx = -self.body.vx;
                }
                if self.body.y > LEVEL_HEIGHT_TILES as f32 * TILE_SIZE as f32 {
                    self.active = false;
                }
            }
            ItemType::FireFlower => {
                if !self.emerged {
                    self.emerge_timer += dt;
                    self.body.y = self.start_y - (self.emerge_timer / 0.5) * 16.0;
                    if self.emerge_timer >= 0.5 {
                        self.emerged = true;
                        self.body.y = self.start_y - 16.0;
                    }
                }
            }
            ItemType::Star => {
                if !self.emerged {
                    self.emerge_timer += dt;
                    self.body.y = self.start_y - (self.emerge_timer / 0.5) * 16.0;
                    if self.emerge_timer >= 0.5 {
                        self.emerged = true;
                        self.body.y = self.start_y - 16.0;
                        self.body.vx = STAR_SPEED;
                        self.body.vy = STAR_BOUNCE;
                        self.body.apply_gravity = true;
                    }
                    return;
                }

                self.body.apply_physics();
                let result = move_and_collide(&mut self.body, tiles);
                if result.hit_left || result.hit_right {
                    self.body.vx = -self.body.vx;
                }
                if result.hit_bottom {
                    self.body.vy = STAR_BOUNCE;
                }
                if self.body.y > LEVEL_HEIGHT_TILES as f32 * TILE_SIZE as f32 {
                    self.active = false;
                }
            }
        }
    }

    pub fn get_texture_name(&self) -> &str {
        match self.item_type {
            ItemType::Coin => "coin",
            ItemType::Mushroom => "mushroom",
            ItemType::OneUp => "oneup",
            ItemType::FireFlower => "fireflower",
            ItemType::Star => "star",
        }
    }

    pub fn draw(&self, sprites: &SpriteGenerator) {
        if !self.active { return; }
        let tex_name = self.get_texture_name();
        if let Some(tex) = sprites.textures.get(tex_name) {
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
