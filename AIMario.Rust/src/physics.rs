use crate::constants::*;
use crate::tiles::Tile;

#[derive(Clone)]
pub struct PhysicsBody {
    pub x: f32,
    pub y: f32,
    pub vx: f32,
    pub vy: f32,
    pub width: f32,
    pub height: f32,
    pub on_ground: bool,
    pub apply_gravity: bool,
}

impl PhysicsBody {
    pub fn new() -> Self {
        Self {
            x: 0.0,
            y: 0.0,
            vx: 0.0,
            vy: 0.0,
            width: 0.0,
            height: 0.0,
            on_ground: false,
            apply_gravity: true,
        }
    }

    pub fn left(&self) -> f32 { self.x }
    pub fn right(&self) -> f32 { self.x + self.width }
    pub fn top(&self) -> f32 { self.y }
    pub fn bottom(&self) -> f32 { self.y + self.height }

    pub fn apply_physics(&mut self) {
        if self.apply_gravity {
            self.vy += GRAVITY;
            if self.vy > MAX_FALL_SPEED {
                self.vy = MAX_FALL_SPEED;
            }
        }
    }
}

pub struct CollisionResult {
    pub hit_left: bool,
    pub hit_right: bool,
    pub hit_top: bool,
    pub hit_bottom: bool,
    pub hit_tile_x: i32,
    pub hit_tile_y: i32,
    pub has_hit_tile: bool,
}

impl CollisionResult {
    pub fn new() -> Self {
        Self {
            hit_left: false,
            hit_right: false,
            hit_top: false,
            hit_bottom: false,
            hit_tile_x: 0,
            hit_tile_y: 0,
            has_hit_tile: false,
        }
    }
}

pub fn move_and_collide(body: &mut PhysicsBody, tiles: &Vec<Vec<Option<Tile>>>) -> CollisionResult {
    let mut result = CollisionResult::new();

    // X pass
    body.x += body.vx;
    resolve_x(body, tiles, &mut result);

    // Y pass
    body.y += body.vy;
    resolve_y(body, tiles, &mut result);

    result
}

fn resolve_x(body: &mut PhysicsBody, tiles: &Vec<Vec<Option<Tile>>>, result: &mut CollisionResult) {
    let tile_left = ((body.left() / TILE_SIZE as f32) as i32 - 1).max(0);
    let tile_right = ((body.right() / TILE_SIZE as f32) as i32 + 1).min(LEVEL_WIDTH_TILES - 1);
    let tile_top = ((body.top() / TILE_SIZE as f32) as i32).max(0);
    let tile_bottom = (((body.bottom() - 1.0) / TILE_SIZE as f32) as i32).min(LEVEL_HEIGHT_TILES - 1);

    for y in tile_top..=tile_bottom {
        for x in tile_left..=tile_right {
            if let Some(tile) = &tiles[y as usize][x as usize] {
                if !tile.is_solid() { continue; }
                let (tx, ty, tw, th) = tile.bounds();
                if !intersects_rect(body, tx, ty, tw, th) { continue; }

                if body.vx > 0.0 {
                    body.x = tx - body.width;
                    body.vx = 0.0;
                    result.hit_right = true;
                } else if body.vx < 0.0 {
                    body.x = tx + tw;
                    body.vx = 0.0;
                    result.hit_left = true;
                }
            }
        }
    }
}

fn resolve_y(body: &mut PhysicsBody, tiles: &Vec<Vec<Option<Tile>>>, result: &mut CollisionResult) {
    let tile_left = ((body.left() / TILE_SIZE as f32) as i32).max(0);
    let tile_right = (((body.right() - 1.0) / TILE_SIZE as f32) as i32).min(LEVEL_WIDTH_TILES - 1);
    let tile_top = ((body.top() / TILE_SIZE as f32) as i32 - 1).max(0);
    let tile_bottom = ((body.bottom() / TILE_SIZE as f32) as i32 + 1).min(LEVEL_HEIGHT_TILES - 1);

    body.on_ground = false;

    for y in tile_top..=tile_bottom {
        for x in tile_left..=tile_right {
            if let Some(tile) = &tiles[y as usize][x as usize] {
                if !tile.is_solid() { continue; }
                let (tx, ty, tw, th) = tile.bounds();
                if !intersects_rect(body, tx, ty, tw, th) { continue; }

                if body.vy > 0.0 {
                    body.y = ty - body.height;
                    body.vy = 0.0;
                    body.on_ground = true;
                    result.hit_bottom = true;
                } else if body.vy < 0.0 {
                    body.y = ty + th;
                    body.vy = 0.0;
                    result.hit_top = true;
                    result.has_hit_tile = true;
                    result.hit_tile_x = tile.grid_x;
                    result.hit_tile_y = tile.grid_y;
                }
            }
        }
    }
}

fn intersects_rect(body: &PhysicsBody, rx: f32, ry: f32, rw: f32, rh: f32) -> bool {
    body.left() < rx + rw &&
    body.right() > rx &&
    body.top() < ry + rh &&
    body.bottom() > ry
}

pub fn is_solid_at(tiles: &Vec<Vec<Option<Tile>>>, world_x: f32, world_y: f32) -> bool {
    let gx = (world_x / TILE_SIZE as f32) as i32;
    let gy = (world_y / TILE_SIZE as f32) as i32;
    if gx < 0 || gx >= LEVEL_WIDTH_TILES || gy < 0 || gy >= LEVEL_HEIGHT_TILES {
        return false;
    }
    if let Some(tile) = &tiles[gy as usize][gx as usize] {
        tile.is_solid()
    } else {
        false
    }
}

pub fn bodies_intersect(a: &PhysicsBody, b: &PhysicsBody) -> bool {
    a.left() < b.right() &&
    a.right() > b.left() &&
    a.top() < b.bottom() &&
    a.bottom() > b.top()
}
