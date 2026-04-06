use crate::constants::*;

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum TileType {
    Empty = 0,
    Ground = 1,
    Brick = 2,
    Question = 3,
    QuestionUsed = 4,
    HardBlock = 5,
    PipeTopLeft = 6,
    PipeTopRight = 7,
    PipeBodyLeft = 8,
    PipeBodyRight = 9,
    Invisible = 10,
    FlagPole = 11,
    FlagTop = 12,
}

impl TileType {
    pub fn from_i32(v: i32) -> Self {
        match v {
            1 => TileType::Ground,
            2 => TileType::Brick,
            3 => TileType::Question,
            4 => TileType::QuestionUsed,
            5 => TileType::HardBlock,
            6 => TileType::PipeTopLeft,
            7 => TileType::PipeTopRight,
            8 => TileType::PipeBodyLeft,
            9 => TileType::PipeBodyRight,
            10 => TileType::Invisible,
            11 => TileType::FlagPole,
            12 => TileType::FlagTop,
            _ => TileType::Empty,
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Debug)]
pub enum ItemContent {
    None,
    Coin,
    Mushroom,
    Star,
    OneUp,
    MultiCoin,
}

#[derive(Clone)]
pub struct Tile {
    pub tile_type: TileType,
    pub grid_x: i32,
    pub grid_y: i32,
    pub content: ItemContent,
    pub is_hit: bool,
    pub bump_offset: f32,
    anim_timer: f32,
}

impl Tile {
    pub fn new(tile_type: TileType, grid_x: i32, grid_y: i32) -> Self {
        Self {
            tile_type,
            grid_x,
            grid_y,
            content: ItemContent::None,
            is_hit: false,
            bump_offset: 0.0,
            anim_timer: 0.0,
        }
    }

    pub fn is_solid(&self) -> bool {
        match self.tile_type {
            TileType::Empty => false,
            TileType::FlagPole => false,
            TileType::FlagTop => false,
            TileType::Invisible if !self.is_hit => false,
            _ => true,
        }
    }

    pub fn bounds(&self) -> (f32, f32, f32, f32) {
        let x = self.grid_x as f32 * TILE_SIZE as f32;
        let y = self.grid_y as f32 * TILE_SIZE as f32;
        (x, y, TILE_SIZE as f32, TILE_SIZE as f32)
    }

    pub fn update(&mut self, dt: f32) {
        if self.tile_type == TileType::Question {
            self.anim_timer += dt;
        }
        if self.bump_offset < 0.0 {
            self.bump_offset += 0.5;
            if self.bump_offset > 0.0 {
                self.bump_offset = 0.0;
            }
        }
    }

    pub fn get_anim_frame(&self) -> i32 {
        if self.tile_type != TileType::Question {
            return 0;
        }
        let cycle = self.anim_timer % 1.0;
        if cycle < 0.5 {
            0
        } else if cycle < 0.65 {
            1
        } else if cycle < 0.8 {
            2
        } else {
            1
        }
    }
}
