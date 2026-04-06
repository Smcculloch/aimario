use macroquad::prelude::*;
use crate::constants::*;
use crate::camera::Camera;
use crate::physics::{move_and_collide, bodies_intersect};
use crate::tiles::*;
use crate::mario::*;
use crate::enemies::*;
use crate::items::*;
use crate::fireball::*;
use crate::sprites::SpriteGenerator;
use crate::input::InputManager;
use crate::level_data;

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum LevelArea {
    Overworld,
    Underground,
}

#[derive(Clone, Copy, PartialEq, Eq)]
pub enum PipeState {
    None,
    EnteringPipe,
    ExitingPipe,
}

pub struct ScorePopup {
    pub amount: i32,
    pub x: f32,
    pub y: f32,
    pub timer: f32,
}

pub struct BrickDebris {
    pub x: f32,
    pub y: f32,
    pub vx: f32,
    pub vy: f32,
    pub active: bool,
}

impl BrickDebris {
    pub fn new(x: f32, y: f32, vx: f32, vy: f32) -> Self {
        Self { x, y, vx, vy, active: true }
    }

    pub fn update(&mut self, _dt: f32) {
        self.vy += GRAVITY;
        self.x += self.vx;
        self.y += self.vy;
        if self.y > LEVEL_HEIGHT_TILES as f32 * TILE_SIZE as f32 {
            self.active = false;
        }
    }
}

pub struct Level {
    pub mario: Mario,
    pub camera: Camera,
    pub tiles: Vec<Vec<Option<Tile>>>,
    pub enemies: Vec<Enemy>,
    pub items: Vec<Item>,
    pub fireballs: Vec<Fireball>,
    pub score_popups: Vec<ScorePopup>,
    pub debris: Vec<BrickDebris>,

    pub score: i32,
    pub coins: i32,
    pub lives: i32,
    pub timer: f32,
    timer_accum: f32,
    pub level_complete: bool,

    fireball_cooldown: f32,

    flag_descending: bool,
    flag_y: f32,
    flag_target_y: f32,

    // Underground pipe transition
    pub current_area: LevelArea,
    overworld_tiles: Vec<Vec<Option<Tile>>>,
    underground_tiles: Vec<Vec<Option<Tile>>>,
    underground_coins: Vec<Item>,
    overworld_enemies: Vec<Enemy>,
    pub pipe_state: PipeState,
    pipe_timer: f32,
    saved_camera_x: f32,
}

impl Level {
    pub fn new() -> Self {
        Self {
            mario: Mario::new(),
            camera: Camera::new(LEVEL_WIDTH_TILES as f32 * TILE_SIZE as f32),
            tiles: Vec::new(),
            enemies: Vec::new(),
            items: Vec::new(),
            fireballs: Vec::new(),
            score_popups: Vec::new(),
            debris: Vec::new(),
            score: 0,
            coins: 0,
            lives: STARTING_LIVES,
            timer: LEVEL_TIME,
            timer_accum: 0.0,
            level_complete: false,
            fireball_cooldown: 0.0,
            flag_descending: false,
            flag_y: 0.0,
            flag_target_y: 0.0,

            current_area: LevelArea::Overworld,
            overworld_tiles: Vec::new(),
            underground_tiles: Vec::new(),
            underground_coins: Vec::new(),
            overworld_enemies: Vec::new(),
            pipe_state: PipeState::None,
            pipe_timer: 0.0,
            saved_camera_x: 0.0,
        }
    }

    pub fn load(&mut self) {
        let map_data = level_data::get_world_1_1();
        let block_contents = level_data::get_block_contents();
        let enemy_spawns = level_data::get_enemy_spawns();

        let h = LEVEL_HEIGHT_TILES as usize;
        let w = LEVEL_WIDTH_TILES as usize;
        let mut tiles = vec![vec![None; w]; h];

        for y in 0..h {
            for x in 0..w {
                let tt = TileType::from_i32(map_data[y][x]);
                if tt == TileType::Empty { continue; }
                let mut tile = Tile::new(tt, x as i32, y as i32);
                if let Some(&content) = block_contents.get(&(x as i32, y as i32)) {
                    tile.content = content;
                }
                tiles[y][x] = Some(tile);
            }
        }

        self.tiles = tiles.clone();
        self.overworld_tiles = tiles;

        let mut enemies = Vec::new();
        for spawn in &enemy_spawns {
            let mut enemy = match spawn.enemy_type {
                EnemyType::Goomba => Enemy::new_goomba(),
                EnemyType::Koopa => Enemy::new_koopa(),
            };
            enemy.body.x = spawn.x as f32 * TILE_SIZE as f32 + 1.0;
            enemy.body.y = spawn.y as f32 * TILE_SIZE as f32 - enemy.body.height;
            enemies.push(enemy);
        }
        self.enemies = enemies;

        // Load underground data
        let (ug_map_data, ug_coins) = level_data::get_underground();
        let mut ug_tiles = vec![vec![None; w]; h];
        for y in 0..h {
            for x in 0..w {
                let tt = TileType::from_i32(ug_map_data[y][x]);
                if tt == TileType::Empty { continue; }
                ug_tiles[y][x] = Some(Tile::new(tt, x as i32, y as i32));
            }
        }
        self.underground_tiles = ug_tiles;
        self.underground_coins = ug_coins;

        self.camera = Camera::new(LEVEL_WIDTH_TILES as f32 * TILE_SIZE as f32);
        self.mario = Mario::new();
        self.mario.reset(40.0, (LEVEL_HEIGHT_TILES - 3) as f32 * TILE_SIZE as f32);

        self.items.clear();
        self.fireballs.clear();
        self.score_popups.clear();
        self.debris.clear();
        self.timer = LEVEL_TIME;
        self.timer_accum = 0.0;
        self.level_complete = false;
        self.flag_descending = false;
        self.current_area = LevelArea::Overworld;
        self.pipe_state = PipeState::None;
        self.pipe_timer = 0.0;
    }

    pub fn reset(&mut self) {
        self.mario.reset(40.0, (LEVEL_HEIGHT_TILES - 3) as f32 * TILE_SIZE as f32);
        self.camera = Camera::new(LEVEL_WIDTH_TILES as f32 * TILE_SIZE as f32);
        self.camera.reset();
        self.timer = LEVEL_TIME;
        self.timer_accum = 0.0;
        self.items.clear();
        self.fireballs.clear();
        self.score_popups.clear();
        self.debris.clear();
        self.level_complete = false;
        self.flag_descending = false;
        self.current_area = LevelArea::Overworld;
        self.pipe_state = PipeState::None;
        self.pipe_timer = 0.0;

        // Reload tiles and enemies
        let map_data = level_data::get_world_1_1();
        let block_contents = level_data::get_block_contents();
        let enemy_spawns = level_data::get_enemy_spawns();

        let h = LEVEL_HEIGHT_TILES as usize;
        let w = LEVEL_WIDTH_TILES as usize;
        let mut tiles = vec![vec![None; w]; h];
        for y in 0..h {
            for x in 0..w {
                let tt = TileType::from_i32(map_data[y][x]);
                if tt == TileType::Empty { continue; }
                let mut tile = Tile::new(tt, x as i32, y as i32);
                if let Some(&content) = block_contents.get(&(x as i32, y as i32)) {
                    tile.content = content;
                }
                tiles[y][x] = Some(tile);
            }
        }
        self.tiles = tiles.clone();
        self.overworld_tiles = tiles;

        let mut enemies = Vec::new();
        for spawn in &enemy_spawns {
            let mut enemy = match spawn.enemy_type {
                EnemyType::Goomba => Enemy::new_goomba(),
                EnemyType::Koopa => Enemy::new_koopa(),
            };
            enemy.body.x = spawn.x as f32 * TILE_SIZE as f32 + 1.0;
            enemy.body.y = spawn.y as f32 * TILE_SIZE as f32 - enemy.body.height;
            enemies.push(enemy);
        }
        self.enemies = enemies;

        // Reload underground
        let (ug_map_data, ug_coins) = level_data::get_underground();
        let mut ug_tiles = vec![vec![None; w]; h];
        for y in 0..h {
            for x in 0..w {
                let tt = TileType::from_i32(ug_map_data[y][x]);
                if tt == TileType::Empty { continue; }
                ug_tiles[y][x] = Some(Tile::new(tt, x as i32, y as i32));
            }
        }
        self.underground_tiles = ug_tiles;
        self.underground_coins = ug_coins;
    }

    pub fn update(&mut self, dt: f32, input: &InputManager) {
        // Handle pipe animation states
        if self.pipe_state != PipeState::None {
            self.update_pipe_transition(dt);
            return;
        }

        // Timer
        if !self.level_complete && !self.mario.is_dead {
            self.timer_accum += dt;
            while self.timer_accum >= TIMER_TICK_RATE {
                self.timer_accum -= TIMER_TICK_RATE;
                self.timer -= 1.0;
                if self.timer <= 0.0 {
                    self.timer = 0.0;
                    self.mario.die();
                }
            }
        }

        // Mario
        self.mario.update_input(dt, input);

        // Collision with tiles
        if !self.mario.is_dead && !self.mario.reached_flag {
            let result = move_and_collide(&mut self.mario.body, &self.tiles);
            if result.hit_top && result.has_hit_tile {
                self.hit_block(result.hit_tile_x, result.hit_tile_y);
            }

            // Don't go left of camera
            if self.mario.body.x < self.camera.x {
                self.mario.body.x = self.camera.x;
            }

            // Fell in pit
            if self.mario.body.y > LEVEL_HEIGHT_TILES as f32 * TILE_SIZE as f32 {
                self.mario.die();
            }

            // Pipe entry detection
            if input.down_pressed && self.mario.body.on_ground {
                self.check_pipe_entry();
            }
        }

        // Camera
        if !self.mario.is_dead {
            self.camera.follow(self.mario.body.x);
        }

        // Fireball shooting
        self.fireball_cooldown -= dt;
        if self.mario.power == PowerState::Fire && input.run_pressed && self.fireball_cooldown <= 0.0 && !self.mario.is_dead {
            let active_count = self.fireballs.iter().filter(|f| f.active).count();
            if active_count < 2 {
                let fx = self.mario.body.x + if self.mario.facing_right { 12.0 } else { -8.0 };
                let fy = self.mario.body.y + 8.0;
                self.fireballs.push(Fireball::new(fx, fy, self.mario.facing_right));
                self.fireball_cooldown = 0.3;
            }
        }

        // Update tiles
        for row in &mut self.tiles {
            for tile in row.iter_mut() {
                if let Some(t) = tile {
                    t.update(dt);
                }
            }
        }

        // Update enemies
        for enemy in &mut self.enemies {
            if !enemy.active { continue; }
            if !self.camera.is_visible(enemy.body.x, enemy.body.width + 16.0) {
                continue;
            }
            enemy.update(dt, &self.tiles);
        }

        // Update items
        for item in &mut self.items {
            item.update(dt, &self.tiles);
        }
        self.items.retain(|i| i.active);

        // Update fireballs
        for fb in &mut self.fireballs {
            fb.update(dt, &self.tiles);
        }
        // Check fireball-enemy collisions before cleanup
        let mut fb_kills: Vec<(usize, usize)> = Vec::new();
        for (fi, fb) in self.fireballs.iter().enumerate() {
            if !fb.active { continue; }
            for (ei, enemy) in self.enemies.iter().enumerate() {
                if !enemy.active || enemy.is_stomped { continue; }
                if fb.intersects_body(&enemy.body) {
                    fb_kills.push((fi, ei));
                }
            }
        }
        for (fi, ei) in fb_kills {
            if fi < self.fireballs.len() { self.fireballs[fi].active = false; }
            if ei < self.enemies.len() {
                let pos_x = self.enemies[ei].body.x;
                let pos_y = self.enemies[ei].body.y;
                self.enemies[ei].kill_by_hit();
                self.add_score(SCORE_GOOMBA, pos_x, pos_y);
            }
        }
        self.fireballs.retain(|f| f.active);

        // Update score popups
        for popup in &mut self.score_popups {
            popup.timer -= dt;
            popup.y -= 1.0;
        }
        self.score_popups.retain(|p| p.timer > 0.0);

        // Update debris
        for d in &mut self.debris {
            d.update(dt);
        }
        self.debris.retain(|d| d.active);

        // Flag animation
        if self.flag_descending {
            self.flag_y += 2.0;
            if self.flag_y >= self.flag_target_y {
                self.flag_y = self.flag_target_y;
            }
        }

        // Collision: Mario vs Enemies
        if !self.mario.is_dead && !self.mario.reached_flag {
            self.check_mario_enemy_collisions();
        }

        // Collision: Mario vs Items
        if !self.mario.is_dead {
            self.check_mario_item_collisions();
        }

        // Check flagpole
        if !self.level_complete && !self.mario.is_dead {
            self.check_flagpole();
        }
    }

    fn check_mario_enemy_collisions(&mut self) {
        for i in 0..self.enemies.len() {
            if !self.enemies[i].active || self.enemies[i].is_stomped { continue; }

            // Skip stationary shells
            if self.enemies[i].enemy_type == EnemyType::Koopa
                && self.enemies[i].is_shell
                && !self.enemies[i].shell_moving
            {
                continue;
            }

            if !bodies_intersect(&self.mario.body, &self.enemies[i].body) { continue; }

            let mario_feet_prev = self.mario.body.bottom() - self.mario.body.vy;
            let is_falling = self.mario.body.vy > 0.0;
            let feet_above_mid = self.mario.body.bottom() < self.enemies[i].body.top() + self.enemies[i].body.height / 2.0;
            let was_above = mario_feet_prev <= self.enemies[i].body.top() + 2.0;

            if is_falling && (feet_above_mid || was_above) && self.enemies[i].can_be_stomped {
                // Stomp
                let enemy_type = self.enemies[i].enemy_type;
                let pos_x = self.enemies[i].body.x;
                let pos_y = self.enemies[i].body.y;
                match enemy_type {
                    EnemyType::Goomba => self.enemies[i].on_stomped_goomba(),
                    EnemyType::Koopa => {
                        let mario_x = self.mario.body.x;
                        self.enemies[i].on_stomped_koopa(mario_x);
                    }
                }
                self.mario.body.vy = JUMP_VELOCITY_WALK * 0.6;
                let score = if enemy_type == EnemyType::Goomba { SCORE_GOOMBA } else { SCORE_KOOPA };
                self.add_score(score, pos_x, pos_y);
            } else if self.mario.has_star {
                let pos_x = self.enemies[i].body.x;
                let pos_y = self.enemies[i].body.y;
                self.enemies[i].kill_by_hit();
                self.add_score(SCORE_GOOMBA, pos_x, pos_y);
            } else {
                // Check if it's a stationary shell we can kick
                if self.enemies[i].enemy_type == EnemyType::Koopa
                    && self.enemies[i].is_shell
                    && !self.enemies[i].shell_moving
                {
                    let kick_right = self.mario.body.x < self.enemies[i].body.x;
                    self.enemies[i].kick_shell(kick_right);
                } else {
                    self.mario.take_damage();
                }
            }
        }

        // Shell kills other enemies
        for i in 0..self.enemies.len() {
            if !self.enemies[i].active { continue; }
            if !(self.enemies[i].enemy_type == EnemyType::Koopa && self.enemies[i].is_shell && self.enemies[i].shell_moving) { continue; }

            for j in 0..self.enemies.len() {
                if i == j || !self.enemies[j].active || self.enemies[j].is_stomped { continue; }
                if bodies_intersect(&self.enemies[i].body, &self.enemies[j].body) {
                    let pos_x = self.enemies[j].body.x;
                    let pos_y = self.enemies[j].body.y;
                    self.enemies[j].kill_by_hit();
                    self.add_score(SCORE_KOOPA, pos_x, pos_y);
                }
            }
        }
    }

    fn check_mario_item_collisions(&mut self) {
        for i in (0..self.items.len()).rev() {
            if !self.items[i].active { continue; }
            if !self.items[i].intersects_body(&self.mario.body) { continue; }

            match self.items[i].item_type {
                ItemType::Mushroom => {
                    self.mario.collect_mushroom();
                    let x = self.items[i].body.x;
                    let y = self.items[i].body.y;
                    self.add_score(SCORE_MUSHROOM, x, y);
                    self.items[i].active = false;
                }
                ItemType::OneUp => {
                    self.lives += 1;
                    self.items[i].active = false;
                }
                ItemType::FireFlower => {
                    self.mario.collect_fire_flower();
                    let x = self.items[i].body.x;
                    let y = self.items[i].body.y;
                    self.add_score(SCORE_FIRE_FLOWER, x, y);
                    self.items[i].active = false;
                }
                ItemType::Star => {
                    self.mario.collect_star();
                    let x = self.items[i].body.x;
                    let y = self.items[i].body.y;
                    self.add_score(SCORE_STAR, x, y);
                    self.items[i].active = false;
                }
                ItemType::Coin => {
                    self.coins += 1;
                    self.score += SCORE_COIN;
                    if self.coins >= 100 {
                        self.coins -= 100;
                        self.lives += 1;
                    }
                    self.items[i].active = false;
                }
            }
        }
    }

    fn check_flagpole(&mut self) {
        let flag_x = 206.0 * TILE_SIZE as f32;
        if self.mario.body.right() >= flag_x && self.mario.body.left() <= flag_x + TILE_SIZE as f32 && !self.level_complete {
            self.level_complete = true;
            self.mario.reached_flag = true;
            self.mario.body.x = flag_x - self.mario.body.width;

            let height = self.mario.body.y;
            let flag_score = if height < 4.0 * TILE_SIZE as f32 { 5000 }
                else if height < 6.0 * TILE_SIZE as f32 { 2000 }
                else if height < 8.0 * TILE_SIZE as f32 { 800 }
                else if height < 10.0 * TILE_SIZE as f32 { 400 }
                else { SCORE_FLAG_BASE };
            self.add_score(flag_score, self.mario.body.x, self.mario.body.y);

            self.flag_descending = true;
            self.flag_y = 2.0 * TILE_SIZE as f32;
            self.flag_target_y = 12.0 * TILE_SIZE as f32;
        }
    }

    pub fn background_color(&self) -> Color {
        match self.current_area {
            LevelArea::Overworld => Color::from_rgba(92, 148, 252, 255),
            LevelArea::Underground => Color::from_rgba(0, 0, 0, 255),
        }
    }

    fn check_pipe_entry(&mut self) {
        let mario_center_x = (self.mario.body.x + self.mario.body.width / 2.0) / TILE_SIZE as f32;
        let mario_feet_y = ((self.mario.body.bottom()) / TILE_SIZE as f32) as i32;

        match self.current_area {
            LevelArea::Overworld => {
                // Check if Mario is on the enterable pipe at x=46 (pipe top is at y=9)
                let pipe_x = PIPE_ENTRY_X as f32;
                if mario_center_x >= pipe_x as f32 && mario_center_x <= (pipe_x + 2.0)
                    && mario_feet_y == PIPE_ENTRY_TOP_Y
                {
                    self.pipe_state = PipeState::EnteringPipe;
                    self.pipe_timer = 0.0;
                    self.saved_camera_x = self.camera.x;
                    self.overworld_enemies = std::mem::take(&mut self.enemies);
                    self.mario.body.vx = 0.0;
                    self.mario.body.vy = 0.0;
                    // Center Mario on pipe
                    self.mario.body.x = (PIPE_ENTRY_X as f32 + 0.5) * TILE_SIZE as f32 - self.mario.body.width / 2.0;
                }
            }
            LevelArea::Underground => {
                // Check if Mario is on the exit pipe at x=13 (pipe top at y=11)
                let pipe_x = 13.0;
                if mario_center_x >= pipe_x && mario_center_x <= (pipe_x + 2.0)
                    && mario_feet_y == 11
                {
                    self.pipe_state = PipeState::EnteringPipe;
                    self.pipe_timer = 0.0;
                    self.mario.body.vx = 0.0;
                    self.mario.body.vy = 0.0;
                    // Center Mario on pipe
                    self.mario.body.x = 13.0 * TILE_SIZE as f32 + TILE_SIZE as f32 - self.mario.body.width / 2.0;
                }
            }
        }
    }

    fn update_pipe_transition(&mut self, dt: f32) {
        self.pipe_timer += dt;

        match self.pipe_state {
            PipeState::EnteringPipe => {
                // Slide Mario down into the pipe
                self.mario.body.y += 1.0;

                if self.pipe_timer >= PIPE_ANIM_DURATION {
                    // Done entering — swap areas
                    match self.current_area {
                        LevelArea::Overworld => {
                            // Save overworld tiles state
                            self.overworld_tiles = self.tiles.clone();
                            // Switch to underground
                            self.tiles = self.underground_tiles.clone();
                            self.current_area = LevelArea::Underground;
                            // Reset camera for underground (one screen)
                            self.camera = Camera::new(UNDERGROUND_WIDTH_TILES as f32 * TILE_SIZE as f32);
                            self.camera.reset();
                            // Place Mario at underground entry
                            self.mario.body.x = 2.0 * TILE_SIZE as f32;
                            self.mario.body.y = 11.0 * TILE_SIZE as f32 - self.mario.body.height;
                            self.mario.body.vx = 0.0;
                            self.mario.body.vy = 0.0;
                            self.mario.body.on_ground = false;
                            self.mario.visible = true;
                            // Spawn underground coins as items
                            let (_, ug_coins) = level_data::get_underground();
                            self.items.clear();
                            self.items = ug_coins;
                            self.fireballs.clear();
                            self.enemies.clear();
                            self.pipe_state = PipeState::None;
                        }
                        LevelArea::Underground => {
                            // Switch back to overworld
                            self.tiles = self.overworld_tiles.clone();
                            self.current_area = LevelArea::Overworld;
                            // Restore camera
                            self.camera = Camera::new(LEVEL_WIDTH_TILES as f32 * TILE_SIZE as f32);
                            // Place Mario inside the exit pipe (he'll slide up out of it)
                            // Exit pipe is at x=163, top at y=11
                            let exit_x = PIPE_EXIT_RETURN_X as f32 * TILE_SIZE as f32 + TILE_SIZE as f32 - self.mario.body.width / 2.0;
                            let pipe_top_y = 11.0 * TILE_SIZE as f32;
                            self.mario.body.x = exit_x;
                            // Start Mario hidden inside the pipe (below pipe top)
                            self.mario.body.y = pipe_top_y;
                            self.mario.body.vx = 0.0;
                            self.mario.body.vy = 0.0;
                            self.mario.body.on_ground = false;
                            self.mario.visible = true;
                            // Restore enemies
                            self.enemies = std::mem::take(&mut self.overworld_enemies);
                            self.items.clear();
                            self.fireballs.clear();
                            // Set camera to Mario's position
                            self.camera.x = (exit_x - NES_WIDTH as f32 / 2.0).max(0.0).min(self.camera.max_x);
                            self.pipe_state = PipeState::ExitingPipe;
                            self.pipe_timer = 0.0;
                        }
                    }
                }
            }
            PipeState::ExitingPipe => {
                // Mario slides up out of the pipe at overworld exit
                let pipe_top_y = 11.0 * TILE_SIZE as f32;
                let target_y = pipe_top_y - self.mario.body.height;
                self.mario.body.y -= 1.0;

                if self.mario.body.y <= target_y || self.pipe_timer >= PIPE_ANIM_DURATION {
                    self.mario.body.y = target_y;
                    self.mario.body.on_ground = true;
                    self.pipe_state = PipeState::None;
                }
            }
            PipeState::None => {}
        }
    }

    pub fn hit_block(&mut self, grid_x: i32, grid_y: i32) {
        let tile = match &self.tiles[grid_y as usize][grid_x as usize] {
            Some(t) => t.clone(),
            None => return,
        };

        if tile.is_hit && tile.tile_type == TileType::QuestionUsed { return; }

        // Set bump
        if let Some(t) = &mut self.tiles[grid_y as usize][grid_x as usize] {
            t.bump_offset = -8.0;
        }

        if tile.tile_type == TileType::Question || (tile.tile_type == TileType::Invisible && !tile.is_hit) {
            if let Some(t) = &mut self.tiles[grid_y as usize][grid_x as usize] {
                t.is_hit = true;
                t.tile_type = TileType::QuestionUsed;
            }
            self.spawn_item_from_block(&tile);
        } else if tile.tile_type == TileType::Brick {
            if self.mario.power != PowerState::Small {
                self.break_brick(grid_x, grid_y);
            } else if tile.content != ItemContent::None {
                if let Some(t) = &mut self.tiles[grid_y as usize][grid_x as usize] {
                    t.is_hit = true;
                    t.tile_type = TileType::QuestionUsed;
                }
                self.spawn_item_from_block(&tile);
            } else {
                if let Some(t) = &mut self.tiles[grid_y as usize][grid_x as usize] {
                    t.bump_offset = -4.0;
                }
            }

            // Bump kills enemies on top
            for enemy in &mut self.enemies {
                if !enemy.active || enemy.is_stomped { continue; }
                let ex = ((enemy.body.x + enemy.body.width / 2.0) / TILE_SIZE as f32) as i32;
                let ey = (enemy.body.bottom() / TILE_SIZE as f32) as i32;
                if ex == grid_x && ey == grid_y {
                    let pos_x = enemy.body.x;
                    let pos_y = enemy.body.y;
                    enemy.kill_by_hit();
                    self.score += SCORE_GOOMBA;
                    self.score_popups.push(ScorePopup { amount: SCORE_GOOMBA, x: pos_x, y: pos_y, timer: 1.0 });
                }
            }
        }
    }

    fn spawn_item_from_block(&mut self, tile: &Tile) {
        let spawn_x = tile.grid_x as f32 * TILE_SIZE as f32;
        let spawn_y = tile.grid_y as f32 * TILE_SIZE as f32;

        match tile.content {
            ItemContent::Coin => {
                self.coins += 1;
                self.score += SCORE_COIN;
                if self.coins >= 100 { self.coins -= 100; self.lives += 1; }
                self.items.push(Item::new_coin_popup(spawn_x, spawn_y));
            }
            ItemContent::Mushroom => {
                if self.mario.power == PowerState::Small {
                    self.items.push(Item::new_mushroom(spawn_x, spawn_y, false));
                } else {
                    self.items.push(Item::new_fire_flower(spawn_x, spawn_y));
                }
            }
            ItemContent::Star => {
                self.items.push(Item::new_star(spawn_x, spawn_y));
            }
            ItemContent::OneUp => {
                self.items.push(Item::new_mushroom(spawn_x, spawn_y, true));
            }
            ItemContent::None => {
                self.coins += 1;
                self.score += SCORE_COIN;
                if self.coins >= 100 { self.coins -= 100; self.lives += 1; }
                self.items.push(Item::new_coin_popup(spawn_x, spawn_y));
            }
            ItemContent::MultiCoin => {
                self.coins += 1;
                self.score += SCORE_COIN;
                if self.coins >= 100 { self.coins -= 100; self.lives += 1; }
                self.items.push(Item::new_coin_popup(spawn_x, spawn_y));
            }
        }
    }

    fn break_brick(&mut self, grid_x: i32, grid_y: i32) {
        self.tiles[grid_y as usize][grid_x as usize] = None;
        self.score += SCORE_BRICK;

        let bx = grid_x as f32 * TILE_SIZE as f32 + 8.0;
        let by = grid_y as f32 * TILE_SIZE as f32 + 8.0;
        self.debris.push(BrickDebris::new(bx - 4.0, by - 4.0, -1.5, -4.0));
        self.debris.push(BrickDebris::new(bx + 4.0, by - 4.0, 1.5, -4.0));
        self.debris.push(BrickDebris::new(bx - 4.0, by + 4.0, -1.0, -3.0));
        self.debris.push(BrickDebris::new(bx + 4.0, by + 4.0, 1.0, -3.0));
    }

    pub fn add_score(&mut self, amount: i32, x: f32, y: f32) {
        self.score += amount;
        self.score_popups.push(ScorePopup { amount, x, y, timer: 1.0 });
    }

    pub fn draw(&self, sprites: &SpriteGenerator, cam_x: f32) {
        let start_x = ((cam_x / TILE_SIZE as f32) as i32 - 1).max(0);
        let end_x = (start_x + (NES_WIDTH / TILE_SIZE) + 2).min(LEVEL_WIDTH_TILES - 1);

        // Draw tiles
        for y in 0..LEVEL_HEIGHT_TILES {
            for x in start_x..=end_x {
                if let Some(tile) = &self.tiles[y as usize][x as usize] {
                    self.draw_tile(sprites, tile, cam_x);
                }
            }
        }

        // Draw flag (overworld only)
        if (self.flag_descending || self.level_complete) && self.current_area == LevelArea::Overworld {
            let flag_draw_x = 206.0 * TILE_SIZE as f32 - 16.0;
            if let Some(tex) = sprites.textures.get("flag") {
                draw_texture(&tex, flag_draw_x - cam_x, self.flag_y, WHITE);
            }
        }

        // Draw items
        for item in &self.items {
            if item.active {
                if let Some(tex) = sprites.textures.get(item.get_texture_name()) {
                    draw_texture(&tex, item.body.x.floor() - cam_x, item.body.y.floor(), WHITE);
                }
            }
        }

        // Draw enemies
        for enemy in &self.enemies {
            if enemy.active && self.camera.is_visible(enemy.body.x, 16.0) {
                self.draw_enemy(sprites, enemy, cam_x);
            }
        }

        // Draw Mario
        self.draw_mario(sprites, cam_x);

        // Draw fireballs
        for fb in &self.fireballs {
            if fb.active {
                if let Some(tex) = sprites.textures.get("fireball") {
                    draw_texture(&tex, fb.body.x.floor() - cam_x, fb.body.y.floor(), WHITE);
                }
            }
        }

        // Draw debris
        for d in &self.debris {
            if d.active {
                if let Some(tex) = sprites.textures.get("brick_debris") {
                    draw_texture(&tex, d.x.floor() - cam_x, d.y.floor(), WHITE);
                }
            }
        }

        // Draw score popups
        for popup in &self.score_popups {
            self.draw_text_at(sprites, &popup.amount.to_string(), popup.x - cam_x, popup.y, 0.8);
        }
    }

    fn draw_tile(&self, sprites: &SpriteGenerator, tile: &Tile, cam_x: f32) {
        let is_ug = self.current_area == LevelArea::Underground;
        let tex_name = match tile.tile_type {
            TileType::Ground => if is_ug { "ground_ug" } else { "ground" },
            TileType::Brick => if is_ug { "brick_ug" } else { "brick" },
            TileType::Question => {
                match tile.get_anim_frame() {
                    0 => "question0",
                    1 => "question1",
                    _ => "question2",
                }
            }
            TileType::QuestionUsed => "used_block",
            TileType::HardBlock => if is_ug { "hard_block_ug" } else { "hard_block" },
            TileType::PipeTopLeft => "pipe_tl",
            TileType::PipeTopRight => "pipe_tr",
            TileType::PipeBodyLeft => "pipe_bl",
            TileType::PipeBodyRight => "pipe_br",
            TileType::FlagPole => "flagpole",
            TileType::FlagTop => "flagtop",
            _ => return,
        };

        if let Some(tex) = sprites.textures.get(tex_name) {
            let draw_x = tile.grid_x as f32 * TILE_SIZE as f32 - cam_x;
            let draw_y = tile.grid_y as f32 * TILE_SIZE as f32 + tile.bump_offset;
            draw_texture(&tex, draw_x, draw_y, WHITE);
        }
    }

    fn draw_enemy(&self, sprites: &SpriteGenerator, enemy: &Enemy, cam_x: f32) {
        if !enemy.active { return; }
        let tex_name = enemy.get_texture_name();
        if let Some(tex) = sprites.textures.get(tex_name) {
            let mut draw_y = enemy.body.y;
            let mut flip_x = false;
            let mut flip_y = false;

            match enemy.enemy_type {
                EnemyType::Goomba => {
                    if enemy.is_stomped && !enemy.is_shell {
                        // Check if flat (goomba_flat texture)
                        if tex_name == "goomba_flat" {
                            draw_y = enemy.body.y - 14.0;
                        } else {
                            flip_y = true;
                        }
                    }
                }
                EnemyType::Koopa => {
                    if enemy.is_stomped && !enemy.is_shell {
                        flip_y = true;
                    } else {
                        flip_x = enemy.facing_right;
                    }
                }
            }

            draw_texture_ex(
                &tex,
                (enemy.body.x - 1.0).floor() - cam_x,
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

    fn draw_mario(&self, sprites: &SpriteGenerator, cam_x: f32) {
        if !self.mario.visible { return; }
        let tex_name = self.mario.get_texture_name();
        if let Some(tex) = sprites.textures.get(&tex_name) {
            let draw_x = self.mario.body.x - 1.0 - cam_x;
            let mut draw_y = self.mario.body.y;
            if self.mario.is_ducking {
                draw_y = self.mario.body.y - 16.0;
            }
            let flip = !self.mario.facing_right;
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

    fn draw_text_at(&self, sprites: &SpriteGenerator, text: &str, x: f32, y: f32, scale: f32) {
        let mut cx = x;
        for c in text.to_uppercase().chars() {
            let key = format!("font_{}", c);
            if let Some(tex) = sprites.textures.get(&key) {
                draw_texture_ex(
                    &tex,
                    cx,
                    y,
                    WHITE,
                    DrawTextureParams {
                        dest_size: Some(Vec2::new(5.0 * scale, 7.0 * scale)),
                        ..Default::default()
                    },
                );
            }
            cx += 6.0 * scale;
        }
    }

    pub fn draw_text(sprites: &SpriteGenerator, text: &str, x: f32, y: f32, scale: f32) {
        let mut cx = x;
        for c in text.to_uppercase().chars() {
            let key = format!("font_{}", c);
            if let Some(tex) = sprites.textures.get(&key) {
                draw_texture_ex(
                    &tex,
                    cx,
                    y,
                    WHITE,
                    DrawTextureParams {
                        dest_size: Some(Vec2::new(5.0 * scale, 7.0 * scale)),
                        ..Default::default()
                    },
                );
            }
            cx += 6.0 * scale;
        }
    }

    pub fn draw_text_colored(sprites: &SpriteGenerator, text: &str, x: f32, y: f32, scale: f32, color: Color) {
        let mut cx = x;
        for c in text.to_uppercase().chars() {
            let key = format!("font_{}", c);
            if let Some(tex) = sprites.textures.get(&key) {
                draw_texture_ex(
                    &tex,
                    cx,
                    y,
                    color,
                    DrawTextureParams {
                        dest_size: Some(Vec2::new(5.0 * scale, 7.0 * scale)),
                        ..Default::default()
                    },
                );
            }
            cx += 6.0 * scale;
        }
    }
}
