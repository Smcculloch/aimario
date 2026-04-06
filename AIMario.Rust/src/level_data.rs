use std::collections::HashMap;
use crate::constants::*;
use crate::tiles::{TileType, ItemContent};
use crate::enemies::EnemyType;
use crate::items::Item;

pub struct EnemySpawn {
    pub x: i32,
    pub y: i32,
    pub enemy_type: EnemyType,
}

fn set_tile(map: &mut Vec<Vec<i32>>, x: i32, y: i32, tile_type: TileType) {
    if x >= 0 && x < LEVEL_WIDTH_TILES && y >= 0 && y < LEVEL_HEIGHT_TILES {
        map[y as usize][x as usize] = tile_type as i32;
    }
}

fn clear_ground(map: &mut Vec<Vec<i32>>, start_x: i32, end_x: i32) {
    for x in start_x..=end_x {
        map[13][x as usize] = 0;
        map[14][x as usize] = 0;
    }
}

fn set_pipe(map: &mut Vec<Vec<i32>>, x: i32, top_y: i32, height: i32) {
    set_tile(map, x, top_y, TileType::PipeTopLeft);
    set_tile(map, x + 1, top_y, TileType::PipeTopRight);
    for y in (top_y + 1)..(top_y + height) {
        set_tile(map, x, y, TileType::PipeBodyLeft);
        set_tile(map, x + 1, y, TileType::PipeBodyRight);
    }
}

fn build_stair(map: &mut Vec<Vec<i32>>, start_x: i32, bottom_y: i32, height: i32, ascending: bool) {
    for i in 0..height {
        let x = start_x + i;
        let col_height = if ascending { i + 1 } else { height - i };
        for h in 0..col_height {
            set_tile(map, x, bottom_y - h, TileType::HardBlock);
        }
    }
}

pub fn get_world_1_1() -> Vec<Vec<i32>> {
    let w = LEVEL_WIDTH_TILES as usize;
    let h = LEVEL_HEIGHT_TILES as usize;
    let mut map = vec![vec![0i32; w]; h];

    // Fill ground (rows 13-14)
    for x in 0..w {
        map[13][x] = TileType::Ground as i32;
        map[14][x] = TileType::Ground as i32;
    }

    // Pits
    clear_ground(&mut map, 69, 70);
    clear_ground(&mut map, 86, 88);
    clear_ground(&mut map, 153, 154);

    // Question/brick blocks
    set_tile(&mut map, 16, 9, TileType::Question);
    set_tile(&mut map, 20, 9, TileType::Brick);
    set_tile(&mut map, 21, 9, TileType::Question);
    set_tile(&mut map, 22, 9, TileType::Brick);
    set_tile(&mut map, 23, 9, TileType::Question);
    set_tile(&mut map, 22, 5, TileType::Question);

    // Pipes
    set_pipe(&mut map, 28, 11, 2);
    set_pipe(&mut map, 38, 10, 3);
    set_pipe(&mut map, 46, 9, 4);
    set_pipe(&mut map, 57, 9, 4);

    // Exit pipe (underground return)
    set_pipe(&mut map, 163, 11, 2);

    // Block formations
    set_tile(&mut map, 77, 9, TileType::Question);
    set_tile(&mut map, 80, 9, TileType::Brick);
    for x in 81..=88 { set_tile(&mut map, x, 5, TileType::Brick); }

    set_tile(&mut map, 91, 5, TileType::Brick);
    set_tile(&mut map, 92, 5, TileType::Brick);
    set_tile(&mut map, 93, 5, TileType::Brick);
    set_tile(&mut map, 94, 9, TileType::Question);

    set_tile(&mut map, 100, 9, TileType::Brick);
    set_tile(&mut map, 101, 9, TileType::Question);
    set_tile(&mut map, 102, 9, TileType::Brick);
    set_tile(&mut map, 101, 5, TileType::Question);

    set_tile(&mut map, 106, 9, TileType::Question);
    set_tile(&mut map, 109, 9, TileType::Question);
    set_tile(&mut map, 109, 5, TileType::Question);
    set_tile(&mut map, 112, 9, TileType::Question);

    set_tile(&mut map, 118, 9, TileType::Brick);
    set_tile(&mut map, 119, 5, TileType::Brick);
    set_tile(&mut map, 120, 5, TileType::Brick);
    set_tile(&mut map, 121, 5, TileType::Brick);

    set_tile(&mut map, 128, 5, TileType::Brick);
    set_tile(&mut map, 129, 5, TileType::Question);
    set_tile(&mut map, 130, 5, TileType::Question);
    set_tile(&mut map, 131, 5, TileType::Brick);
    set_tile(&mut map, 129, 9, TileType::Brick);
    set_tile(&mut map, 130, 9, TileType::Brick);

    // Staircases
    build_stair(&mut map, 134, 12, 4, true);
    build_stair(&mut map, 140, 12, 4, true);
    build_stair(&mut map, 144, 12, 4, false);
    build_stair(&mut map, 148, 12, 4, true);
    build_stair(&mut map, 152, 12, 5, false);

    build_stair(&mut map, 181, 12, 4, true);
    build_stair(&mut map, 185, 12, 4, false);
    build_stair(&mut map, 189, 12, 4, true);
    build_stair(&mut map, 193, 12, 4, false);

    // Final staircase
    build_stair(&mut map, 198, 12, 8, true);

    // Flagpole
    for y in 2..=12 { set_tile(&mut map, 206, y, TileType::FlagPole); }
    set_tile(&mut map, 206, 1, TileType::FlagTop);

    // Castle
    for x in 208..=212 {
        for y in 9..=12 { set_tile(&mut map, x, y, TileType::HardBlock); }
    }
    for x in 209..=211 { set_tile(&mut map, x, 8, TileType::HardBlock); }
    set_tile(&mut map, 210, 7, TileType::HardBlock);

    map
}

pub fn get_enemy_spawns() -> Vec<EnemySpawn> {
    vec![
        EnemySpawn { x: 22,  y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 40,  y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 51,  y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 52,  y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 80,  y: 4,  enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 82,  y: 4,  enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 97,  y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 98,  y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 107, y: 12, enemy_type: EnemyType::Koopa },
        EnemySpawn { x: 114, y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 115, y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 124, y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 125, y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 128, y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 129, y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 174, y: 12, enemy_type: EnemyType::Goomba },
        EnemySpawn { x: 175, y: 12, enemy_type: EnemyType::Goomba },
    ]
}

/// Returns the underground room tile map (stored in a full 224x15 grid for physics compatibility)
/// and a list of coin items to spawn.
///
/// Layout (16x15):
/// Row  0-1:  ceiling (HardBlock)
/// Row  2-10: open space with coin rows at 4, 6, 8
/// Row 11-12: exit pipe on right side
/// Row 13-14: floor (HardBlock)
pub fn get_underground() -> (Vec<Vec<i32>>, Vec<Item>) {
    let w = LEVEL_WIDTH_TILES as usize;
    let h = LEVEL_HEIGHT_TILES as usize;
    let uw = UNDERGROUND_WIDTH_TILES as usize;
    let mut map = vec![vec![0i32; w]; h];

    // Ceiling: rows 0-1
    for x in 0..uw {
        map[0][x] = TileType::HardBlock as i32;
        map[1][x] = TileType::HardBlock as i32;
    }

    // Floor: rows 13-14
    for x in 0..uw {
        map[13][x] = TileType::HardBlock as i32;
        map[14][x] = TileType::HardBlock as i32;
    }

    // Walls: column 0 and 15
    for y in 2..13 {
        map[y][0] = TileType::HardBlock as i32;
        map[y][uw - 1] = TileType::HardBlock as i32;
    }

    // Exit pipe at x=13, y=11 (top), height 2
    set_pipe(&mut map, 13, 11, 2);

    // Spawn coins as items
    let mut coins = Vec::new();
    let coin_rows = [4, 6, 8];
    for &row in &coin_rows {
        for col in 2..14 {
            let cx = col as f32 * TILE_SIZE as f32;
            let cy = row as f32 * TILE_SIZE as f32;
            coins.push(Item::new_static_coin(cx, cy));
        }
    }

    (map, coins)
}

pub fn get_block_contents() -> HashMap<(i32, i32), ItemContent> {
    let mut m = HashMap::new();
    m.insert((16, 9), ItemContent::Coin);
    m.insert((21, 9), ItemContent::Mushroom);
    m.insert((23, 9), ItemContent::Coin);
    m.insert((22, 5), ItemContent::OneUp);
    m.insert((77, 9), ItemContent::Coin);
    m.insert((94, 9), ItemContent::Coin);
    m.insert((101, 9), ItemContent::Coin);
    m.insert((101, 5), ItemContent::Star);
    m.insert((106, 9), ItemContent::Mushroom);
    m.insert((109, 9), ItemContent::Coin);
    m.insert((109, 5), ItemContent::Coin);
    m.insert((112, 9), ItemContent::Coin);
    m.insert((129, 5), ItemContent::Coin);
    m.insert((130, 5), ItemContent::Coin);
    m
}
