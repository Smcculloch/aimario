use macroquad::prelude::*;
use std::collections::HashMap;

pub struct SpriteGenerator {
    pub textures: HashMap<String, Texture2D>,
}

// Color palette - Classic NES
const T: [u8; 4] = [0, 0, 0, 0]; // Transparent
const BLK: [u8; 4] = [0, 0, 0, 255];
const WHT: [u8; 4] = [252, 252, 252, 255];
const RED: [u8; 4] = [200, 36, 0, 255];
const DRK_RED: [u8; 4] = [136, 20, 0, 255];
const BRN: [u8; 4] = [136, 76, 0, 255];
const SKIN: [u8; 4] = [252, 188, 148, 255];
const GRN: [u8; 4] = [0, 168, 0, 255];
const DRK_GRN: [u8; 4] = [0, 120, 0, 255];
const BLU: [u8; 4] = [32, 56, 236, 255];
const ORG: [u8; 4] = [228, 92, 16, 255];
const YLW: [u8; 4] = [248, 184, 0, 255];
const TAN: [u8; 4] = [228, 148, 88, 255];
const DRK_TAN: [u8; 4] = [136, 112, 0, 255];
const PIPE_GRN: [u8; 4] = [0, 168, 68, 255];
const PIPE_DRK: [u8; 4] = [0, 120, 0, 255];
const PIPE_LIT: [u8; 4] = [128, 208, 16, 255];
const GRY: [u8; 4] = [188, 188, 188, 255];

// Underground palette
const UG_BLU: [u8; 4] = [32, 56, 236, 255];
const UG_DRK: [u8; 4] = [16, 28, 128, 255];
const UG_GND: [u8; 4] = [60, 60, 100, 255];
const UG_GND_LIT: [u8; 4] = [80, 80, 140, 255];

type C = [u8; 4];

fn make_texture(w: u16, h: u16, pixels: &[C]) -> Texture2D {
    let mut bytes = Vec::with_capacity(w as usize * h as usize * 4);
    for c in pixels {
        bytes.extend_from_slice(c);
    }
    let tex = Texture2D::from_rgba8(w, h, &bytes);
    tex.set_filter(FilterMode::Nearest);
    tex
}

fn grid_to_texture(w: usize, h: usize, grid: &[C]) -> Texture2D {
    make_texture(w as u16, h as u16, grid)
}

fn make_solid_block(fill: C, border: C) -> Vec<C> {
    let mut g = vec![fill; 16 * 16];
    for y in 0..16usize {
        for x in 0..16usize {
            if x == 0 || x == 15 || y == 0 || y == 15 {
                g[y * 16 + x] = border;
            }
        }
    }
    g
}

impl SpriteGenerator {
    pub fn new() -> Self {
        Self {
            textures: HashMap::new(),
        }
    }

    pub fn generate(&mut self) {
        self.generate_tiles();
        self.generate_mario();
        self.generate_enemies();
        self.generate_items();
        self.generate_fireball();
        self.generate_font();
    }

    fn generate_tiles(&mut self) {
        // Ground tile
        #[rustfmt::skip]
        let ground: [C; 256] = [
            ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG,
            ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN,
            ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN,
            ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN,
            ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN,
            ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN,
            ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN,
            ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN,
            ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG, ORG,
            BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN,
            BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN,
            BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN,
            BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN,
            BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN,
            BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN,
            BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN, BRN, BRN, BRN, ORG, BRN, BRN, BRN, BRN,
        ];
        self.textures.insert("ground".into(), grid_to_texture(16, 16, &ground));

        // Brick tile
        #[rustfmt::skip]
        let brick: [C; 256] = [
            BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK,
            BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK,
            BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK,
            BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK,
            BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK,
            BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK,
            BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK,
            BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK,
            BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK,
            RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED,
            RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED,
            RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED,
            RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED,
            RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED,
            RED, RED, RED, BLK, BLK, DRK_RED, RED, RED, RED, RED, RED, BLK, BLK, DRK_RED, RED, RED,
            BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK, BLK,
        ];
        self.textures.insert("brick".into(), grid_to_texture(16, 16, &brick));

        // Question blocks
        self.textures.insert("question0".into(), self.gen_question_block(YLW, ORG));
        self.textures.insert("question1".into(), self.gen_question_block([200, 168, 40, 255], [168, 120, 20, 255]));
        self.textures.insert("question2".into(), self.gen_question_block([160, 128, 20, 255], [120, 80, 10, 255]));

        // Used block
        self.textures.insert("used_block".into(), grid_to_texture(16, 16, &make_solid_block(DRK_TAN, BLK)));

        // Hard block
        self.textures.insert("hard_block".into(), grid_to_texture(16, 16, &make_solid_block(GRY, BLK)));

        // Pipe textures
        self.generate_pipe_textures();

        // Underground tile variants
        self.generate_underground_tiles();

        // Flagpole
        self.textures.insert("flagpole".into(), self.gen_flagpole());
        self.textures.insert("flagtop".into(), self.gen_flagtop());
        self.textures.insert("flag".into(), self.gen_flag());
    }

    fn gen_question_block(&self, main: C, dark: C) -> Texture2D {
        let mut g = make_solid_block(main, BLK);
        // ? mark
        for x in 6..=10 { g[3 * 16 + x] = WHT; }
        g[4 * 16 + 5] = WHT; g[4 * 16 + 11] = WHT;
        g[5 * 16 + 11] = WHT; g[6 * 16 + 10] = WHT;
        g[7 * 16 + 9] = WHT; g[8 * 16 + 8] = WHT;
        g[10 * 16 + 8] = WHT; g[11 * 16 + 8] = WHT;
        // Shadow
        for x in 1..15 { g[14 * 16 + x] = dark; }
        for y in 1..15 { g[y * 16 + 14] = dark; }
        grid_to_texture(16, 16, &g)
    }

    fn generate_pipe_textures(&mut self) {
        // Pipe top left
        let mut ptl = vec![T; 256];
        for y in 0..16 {
            for x in 0..16 {
                ptl[y * 16 + x] = if y < 2 || x < 2 { BLK }
                    else if x < 5 { PIPE_LIT }
                    else { PIPE_GRN };
            }
        }
        self.textures.insert("pipe_tl".into(), grid_to_texture(16, 16, &ptl));

        // Pipe top right
        let mut ptr = vec![T; 256];
        for y in 0..16 {
            for x in 0..16 {
                ptr[y * 16 + x] = if y < 2 || x > 13 { BLK }
                    else if x > 10 { PIPE_DRK }
                    else { PIPE_GRN };
            }
        }
        self.textures.insert("pipe_tr".into(), grid_to_texture(16, 16, &ptr));

        // Pipe body left
        let mut pbl = vec![T; 256];
        for y in 0..16 {
            for x in 0..16 {
                pbl[y * 16 + x] = if x < 4 { BLK }
                    else if x < 7 { PIPE_LIT }
                    else { PIPE_GRN };
            }
        }
        self.textures.insert("pipe_bl".into(), grid_to_texture(16, 16, &pbl));

        // Pipe body right
        let mut pbr = vec![T; 256];
        for y in 0..16 {
            for x in 0..16 {
                pbr[y * 16 + x] = if x > 11 { BLK }
                    else if x > 8 { PIPE_DRK }
                    else { PIPE_GRN };
            }
        }
        self.textures.insert("pipe_br".into(), grid_to_texture(16, 16, &pbr));
    }

    fn generate_underground_tiles(&mut self) {
        // Underground ground tile (blue-tinted brick pattern)
        let mut ug_ground = [UG_GND; 256];
        for y in 0..16usize {
            for x in 0..16usize {
                if y == 0 || y == 8 {
                    ug_ground[y * 16 + x] = UG_GND_LIT;
                } else if (y < 8 && (x == 0 || x == 8)) || (y >= 8 && (x == 4 || x == 12)) {
                    ug_ground[y * 16 + x] = UG_GND_LIT;
                }
            }
        }
        self.textures.insert("ground_ug".into(), grid_to_texture(16, 16, &ug_ground));

        // Underground brick tile
        let mut ug_brick = [UG_BLU; 256];
        for y in 0..16usize {
            for x in 0..16usize {
                if x == 0 || x == 15 || y == 0 || y == 7 || y == 8 || y == 15 {
                    ug_brick[y * 16 + x] = BLK;
                } else if x == 1 || (y > 8 && x == 5) || (y > 8 && x == 13) || (y <= 7 && x == 8) {
                    ug_brick[y * 16 + x] = UG_DRK;
                }
            }
        }
        self.textures.insert("brick_ug".into(), grid_to_texture(16, 16, &ug_brick));

        // Underground hard block
        self.textures.insert("hard_block_ug".into(), grid_to_texture(16, 16, &make_solid_block(UG_DRK, BLK)));
    }

    fn gen_flagpole(&self) -> Texture2D {
        let mut g = vec![T; 256];
        for y in 0..16 {
            for x in 7..=8 {
                g[y * 16 + x] = GRY;
            }
        }
        grid_to_texture(16, 16, &g)
    }

    fn gen_flagtop(&self) -> Texture2D {
        let mut g = vec![T; 256];
        // Ball on top
        for y in 2..=6 {
            for x in 5..=10 {
                g[y * 16 + x] = GRN;
            }
        }
        // Pole below
        for y in 7..16 {
            g[y * 16 + 7] = GRY;
            g[y * 16 + 8] = GRY;
        }
        grid_to_texture(16, 16, &g)
    }

    fn gen_flag(&self) -> Texture2D {
        let mut g = vec![T; 256];
        for y in 0..14 {
            let w = 14 - y;
            for x in 0..w.min(16) {
                g[y * 16 + x] = GRN;
            }
        }
        grid_to_texture(16, 16, &g)
    }

    fn generate_mario(&mut self) {
        // Small Mario standing
        #[rustfmt::skip]
        let stand: [C; 256] = [
            T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T,
            T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,
            T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T,
            T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, BLU, RED, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   RED, RED, RED, BLU, RED, RED, BLU, RED, RED, RED, T,   T,   T,
            T,   T,   RED, RED, RED, RED, BLU, BLU, BLU, BLU, RED, RED, RED, RED, T,   T,
            T,   T,   SKIN,SKIN,RED, BLU, YLW, BLU, BLU, YLW, BLU, RED, SKIN,SKIN,T,   T,
            T,   T,   SKIN,SKIN,SKIN,BLU, BLU, BLU, BLU, BLU, BLU, SKIN,SKIN,SKIN,T,   T,
            T,   T,   SKIN,SKIN,BLU, BLU, BLU, BLU, BLU, BLU, BLU, BLU, SKIN,SKIN,T,   T,
            T,   T,   T,   T,   BLU, BLU, BLU, T,   T,   BLU, BLU, BLU, T,   T,   T,   T,
            T,   T,   T,   BRN, BRN, BRN, T,   T,   T,   T,   BRN, BRN, BRN, T,   T,   T,
            T,   T,   BRN, BRN, BRN, BRN, T,   T,   T,   T,   BRN, BRN, BRN, BRN, T,   T,
        ];
        self.textures.insert("mario_small_stand".into(), grid_to_texture(16, 16, &stand));

        // Small Mario walk1
        #[rustfmt::skip]
        let walk1: [C; 256] = [
            T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T,
            T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,
            T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T,
            T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, RED, BLU, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   RED, RED, RED, BLU, BLU, RED, RED, RED, T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, BLU, BLU, BLU, BLU, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   BLU, BLU, BLU, BLU, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   BRN, BRN, RED, RED, RED, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   BRN, BRN, BRN, BRN, RED, T,   T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   BRN, BRN, T,   BRN, BRN, BRN, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   BRN, BRN, BRN, BRN, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("mario_small_walk1".into(), grid_to_texture(16, 16, &walk1));

        // Walk frame 2
        #[rustfmt::skip]
        let walk2: [C; 256] = [
            T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T,
            T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,
            T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T,
            T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,
            T,   T,   T,   T,   T,   RED, RED, BLU, RED, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, RED, BLU, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, BLU, BLU, BLU, BLU, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   BRN, BLU, BLU, BLU, BRN, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   BRN, BRN, BRN, RED, BRN, BRN, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   BRN, BRN, BRN, BRN, BRN, T,   T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   BRN, BRN, BRN, T,   T,   T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("mario_small_walk2".into(), grid_to_texture(16, 16, &walk2));

        // Walk frame 3 reuses walk1
        let walk1_tex = self.textures.get("mario_small_walk1").unwrap().clone();
        self.textures.insert("mario_small_walk3".into(), walk1_tex);

        // Jump frame
        #[rustfmt::skip]
        let jump: [C; 256] = [
            T,   T,   T,   T,   T,   T,   T,   T,   T,   SKIN,T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   RED, RED, RED, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, RED, RED, RED, RED, RED, RED, RED, T,   T,   T,
            T,   T,   T,   T,   BRN, BRN, BRN, SKIN,SKIN,BLK, SKIN,T,   T,   T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   T,   BRN, SKIN,BRN, BRN, SKIN,SKIN,SKIN,BLK, SKIN,SKIN,SKIN,T,   T,
            T,   T,   T,   BRN, BRN, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, T,   T,   T,
            T,   T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,
            T,   T,   RED, RED, RED, RED, BLU, RED, RED, BLU, T,   T,   T,   T,   T,   T,
            SKIN,RED, RED, RED, RED, RED, BLU, BLU, BLU, BLU, RED, T,   T,   T,   T,   T,
            SKIN,SKIN,T,   RED, BLU, YLW, BLU, BLU, YLW, BLU, RED, RED, T,   T,   T,   T,
            T,   T,   T,   BLU, BLU, BLU, BLU, BLU, BLU, BLU, BLU, T,   T,   T,   T,   T,
            T,   T,   BLU, BLU, BLU, BLU, BLU, T,   BLU, BLU, T,   T,   T,   T,   T,   T,
            T,   BRN, BRN, BRN, T,   T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T,   T,
            T,   BRN, BRN, BRN, BRN, T,   T,   T,   T,   T,   BRN, BRN, T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("mario_small_jump".into(), grid_to_texture(16, 16, &jump));

        // Death = jump
        let jump_tex = self.textures.get("mario_small_jump").unwrap().clone();
        self.textures.insert("mario_small_death".into(), jump_tex);

        // Big Mario variants
        self.textures.insert("mario_big_stand".into(), self.gen_big_mario(false, 0));
        self.textures.insert("mario_big_walk1".into(), self.gen_big_mario(false, 1));
        self.textures.insert("mario_big_walk2".into(), self.gen_big_mario(false, 2));
        let bw1 = self.textures.get("mario_big_walk1").unwrap().clone();
        self.textures.insert("mario_big_walk3".into(), bw1);
        self.textures.insert("mario_big_jump".into(), self.gen_big_mario(false, 3));
        self.textures.insert("mario_big_duck".into(), self.gen_big_mario_duck(false));

        // Fire Mario variants
        self.textures.insert("mario_fire_stand".into(), self.gen_big_mario(true, 0));
        self.textures.insert("mario_fire_walk1".into(), self.gen_big_mario(true, 1));
        self.textures.insert("mario_fire_walk2".into(), self.gen_big_mario(true, 2));
        let fw1 = self.textures.get("mario_fire_walk1").unwrap().clone();
        self.textures.insert("mario_fire_walk3".into(), fw1);
        self.textures.insert("mario_fire_jump".into(), self.gen_big_mario(true, 3));
        self.textures.insert("mario_fire_duck".into(), self.gen_big_mario_duck(true));
    }

    fn gen_big_mario(&self, fire: bool, frame: i32) -> Texture2D {
        let hat = if fire { WHT } else { RED };
        let overalls = if fire { BRN } else { BLU };

        let mut g = vec![T; 16 * 32];
        let s = |g: &mut Vec<C>, y: usize, x: usize, c: C| { g[y * 16 + x] = c; };

        // Head
        for x in 4..=9 { s(&mut g, 1, x, hat); }
        for x in 3..=12 { s(&mut g, 2, x, hat); }
        for x in 3..=13 { s(&mut g, 3, x, hat); }
        // Face
        for x in 3..=5 { s(&mut g, 4, x, BRN); }
        for x in 6..=8 { s(&mut g, 4, x, SKIN); }
        s(&mut g, 4, 9, BLK); s(&mut g, 4, 10, SKIN);
        s(&mut g, 5, 2, BRN); s(&mut g, 5, 3, BRN);
        s(&mut g, 5, 4, SKIN); s(&mut g, 5, 5, BRN);
        for x in 6..=8 { s(&mut g, 5, x, SKIN); }
        s(&mut g, 5, 9, BLK);
        for x in 10..=12 { s(&mut g, 5, x, SKIN); }
        s(&mut g, 6, 2, BRN); s(&mut g, 6, 3, SKIN); s(&mut g, 6, 4, BRN); s(&mut g, 6, 5, BRN);
        for x in 6..=8 { s(&mut g, 6, x, SKIN); }
        s(&mut g, 6, 9, BLK);
        for x in 10..=13 { s(&mut g, 6, x, SKIN); }
        for x in 3..=4 { s(&mut g, 7, x, BRN); }
        for x in 5..=9 { s(&mut g, 7, x, SKIN); }
        for x in 10..=12 { s(&mut g, 7, x, BLK); }
        for x in 5..=11 { s(&mut g, 8, x, SKIN); }

        // Torso
        for x in 3..=11 { s(&mut g, 10, x, hat); }
        s(&mut g, 10, 6, overalls);
        for x in 2..=12 { s(&mut g, 11, x, hat); }
        s(&mut g, 11, 5, overalls); s(&mut g, 11, 7, overalls);
        for x in 2..=12 { s(&mut g, 12, x, hat); }
        s(&mut g, 12, 5, overalls); s(&mut g, 12, 6, hat); s(&mut g, 12, 7, overalls);
        for x in 2..=12 { s(&mut g, 13, x, hat); }
        s(&mut g, 13, 4, overalls); s(&mut g, 13, 5, hat); s(&mut g, 13, 6, overalls);
        s(&mut g, 13, 7, hat); s(&mut g, 13, 8, overalls);

        // Overalls
        for x in 2..=12 { s(&mut g, 15, x, overalls); }
        s(&mut g, 15, 4, YLW); s(&mut g, 15, 10, YLW);
        for x in 2..=12 { s(&mut g, 16, x, overalls); }
        for x in 2..=12 { s(&mut g, 17, x, overalls); }
        s(&mut g, 17, 4, YLW); s(&mut g, 17, 10, YLW);
        for x in 2..=12 { s(&mut g, 18, x, overalls); }
        for x in 2..=12 { s(&mut g, 19, x, overalls); }
        for x in 2..=12 { s(&mut g, 20, x, overalls); }
        for x in 3..=11 { s(&mut g, 21, x, overalls); }

        // Legs by frame
        match frame {
            0 => { // standing
                for x in 3..=5 { s(&mut g, 22, x, overalls); s(&mut g, 23, x, overalls); s(&mut g, 24, x, overalls); s(&mut g, 25, x, overalls); }
                for x in 9..=11 { s(&mut g, 22, x, overalls); s(&mut g, 23, x, overalls); s(&mut g, 24, x, overalls); s(&mut g, 25, x, overalls); }
                for x in 2..=6 { s(&mut g, 26, x, BRN); s(&mut g, 27, x, BRN); }
                for x in 8..=12 { s(&mut g, 26, x, BRN); s(&mut g, 27, x, BRN); }
                for x in 1..=6 { s(&mut g, 28, x, BRN); }
                for x in 8..=13 { s(&mut g, 28, x, BRN); }
                for x in 1..=7 { s(&mut g, 29, x, BRN); }
                for x in 8..=14 { s(&mut g, 29, x, BRN); }
            }
            1 => { // walk1
                for i in [4,5,6] { s(&mut g, 22, i, overalls); }
                s(&mut g, 22, 9, overalls); s(&mut g, 22, 10, overalls);
                for i in [4,5,6,7] { s(&mut g, 23, i, overalls); }
                s(&mut g, 23, 9, overalls); s(&mut g, 23, 10, overalls);
                for i in [5,6,7] { s(&mut g, 24, i, overalls); }
                s(&mut g, 24, 10, overalls); s(&mut g, 24, 11, overalls);
                for x in 6..=8 { s(&mut g, 25, x, BRN); }
                s(&mut g, 25, 10, BRN); s(&mut g, 25, 11, BRN);
                for x in 6..=9 { s(&mut g, 26, x, BRN); }
                s(&mut g, 26, 11, BRN); s(&mut g, 26, 12, BRN);
                for x in 7..=10 { s(&mut g, 27, x, BRN); }
                s(&mut g, 27, 12, BRN); s(&mut g, 27, 13, BRN);
            }
            2 => { // walk2
                s(&mut g, 22, 5, overalls); s(&mut g, 22, 6, overalls);
                s(&mut g, 22, 8, overalls); s(&mut g, 22, 9, overalls);
                s(&mut g, 23, 5, overalls); s(&mut g, 23, 6, overalls);
                s(&mut g, 23, 8, overalls); s(&mut g, 23, 9, overalls);
                s(&mut g, 24, 4, overalls); s(&mut g, 24, 5, overalls);
                s(&mut g, 24, 9, overalls); s(&mut g, 24, 10, overalls);
                for x in 3..=6 { s(&mut g, 25, x, BRN); }
                for x in 9..=11 { s(&mut g, 25, x, BRN); }
                for x in 3..=6 { s(&mut g, 26, x, BRN); }
                for x in 9..=12 { s(&mut g, 26, x, BRN); }
                for x in 2..=5 { s(&mut g, 27, x, BRN); }
                for x in 9..=12 { s(&mut g, 27, x, BRN); }
            }
            _ => { // jump
                s(&mut g, 9, 2, SKIN); s(&mut g, 9, 3, SKIN);
                s(&mut g, 22, 3, overalls); s(&mut g, 22, 4, overalls); s(&mut g, 22, 5, hat);
                s(&mut g, 22, 10, overalls); s(&mut g, 22, 11, overalls);
                s(&mut g, 23, 2, overalls); s(&mut g, 23, 3, overalls); s(&mut g, 23, 4, hat);
                s(&mut g, 23, 11, overalls); s(&mut g, 23, 12, overalls);
                s(&mut g, 24, 1, BRN); s(&mut g, 24, 2, BRN); s(&mut g, 24, 3, BRN);
                s(&mut g, 24, 12, overalls); s(&mut g, 24, 13, overalls);
                s(&mut g, 25, 1, BRN); s(&mut g, 25, 2, BRN); s(&mut g, 25, 3, BRN);
                s(&mut g, 25, 13, BRN); s(&mut g, 25, 14, BRN);
                s(&mut g, 26, 1, BRN); s(&mut g, 26, 2, BRN);
                s(&mut g, 26, 13, BRN); s(&mut g, 26, 14, BRN);
            }
        }

        grid_to_texture(16, 32, &g)
    }

    fn gen_big_mario_duck(&self, fire: bool) -> Texture2D {
        let hat = if fire { WHT } else { RED };
        let overalls = if fire { BRN } else { BLU };

        let mut g = vec![T; 16 * 32];
        let s = |g: &mut Vec<C>, y: usize, x: usize, c: C| { g[y * 16 + x] = c; };
        let oy = 16usize;

        for x in 4..=9 { s(&mut g, oy, x, hat); }
        for x in 3..=12 { s(&mut g, oy + 1, x, hat); }
        for x in 3..=12 { s(&mut g, oy + 2, x, hat); }
        for x in 3..=5 { s(&mut g, oy + 3, x, BRN); }
        for x in 6..=8 { s(&mut g, oy + 3, x, SKIN); }
        s(&mut g, oy + 3, 9, BLK); s(&mut g, oy + 3, 10, SKIN);
        for x in 5..=11 { s(&mut g, oy + 4, x, SKIN); }

        for x in 3..=11 { s(&mut g, oy + 5, x, hat); }
        for x in 2..=12 { s(&mut g, oy + 6, x, hat); }
        for x in 2..=12 { s(&mut g, oy + 7, x, overalls); }
        s(&mut g, oy + 7, 4, YLW); s(&mut g, oy + 7, 10, YLW);
        for x in 2..=12 { s(&mut g, oy + 8, x, overalls); }
        for x in 2..=12 { s(&mut g, oy + 9, x, overalls); }
        for x in 3..=11 { s(&mut g, oy + 10, x, overalls); }
        for x in 2..=5 { s(&mut g, oy + 11, x, BRN); }
        for x in 9..=12 { s(&mut g, oy + 11, x, BRN); }
        for x in 1..=6 { s(&mut g, oy + 12, x, BRN); }
        for x in 8..=13 { s(&mut g, oy + 12, x, BRN); }

        grid_to_texture(16, 32, &g)
    }

    fn generate_enemies(&mut self) {
        let gb: C = [172, 80, 0, 255];
        let gd: C = [116, 52, 0, 255];

        // Goomba frame 0
        #[rustfmt::skip]
        let goomba0: [C; 256] = [
            T,   T,   T,   T,   T,   T,   gb,  gb,  gb,  gb,  T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   gb,  gb,  gb,  gb,  gb,  gb,  T,   T,   T,   T,   T,
            T,   T,   T,   T,   gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  T,   T,   T,   T,
            T,   T,   T,   gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  T,   T,   T,
            T,   T,   gb,  gb,  BLK, BLK, gb,  gb,  gb,  gb,  BLK, BLK, gb,  gb,  T,   T,
            T,   gb,  gb,  BLK, WHT, BLK, gb,  gb,  gb,  gb,  BLK, WHT, BLK, gb,  gb,  T,
            T,   gb,  gb,  BLK, BLK, gb,  gb,  gb,  gb,  gb,  gb,  BLK, BLK, gb,  gb,  T,
            T,   gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  T,
            T,   T,   gb,  gb,  gb,  gb,  gd,  gd,  gd,  gd,  gb,  gb,  gb,  gb,  T,   T,
            T,   T,   T,   T,   gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  T,   T,   T,   T,
            T,   T,   T,   gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  T,   T,   T,
            T,   T,   gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  T,   T,
            T,   T,   T,   SKIN,SKIN,gd,  gd,  gd,  gd,  gd,  gd,  SKIN,SKIN,T,   T,   T,
            T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T,
            T,   BLK, BLK, BLK, SKIN,SKIN,T,   T,   T,   T,   SKIN,SKIN,BLK, BLK, BLK, T,
            BLK, BLK, BLK, BLK, BLK, T,   T,   T,   T,   T,   T,   BLK, BLK, BLK, BLK, BLK,
        ];
        self.textures.insert("goomba0".into(), grid_to_texture(16, 16, &goomba0));

        // Goomba frame 1
        #[rustfmt::skip]
        let goomba1: [C; 256] = [
            T,   T,   T,   T,   T,   T,   gb,  gb,  gb,  gb,  T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   gb,  gb,  gb,  gb,  gb,  gb,  T,   T,   T,   T,   T,
            T,   T,   T,   T,   gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  T,   T,   T,   T,
            T,   T,   T,   gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  T,   T,   T,
            T,   T,   gb,  gb,  BLK, BLK, gb,  gb,  gb,  gb,  BLK, BLK, gb,  gb,  T,   T,
            T,   gb,  gb,  BLK, WHT, BLK, gb,  gb,  gb,  gb,  BLK, WHT, BLK, gb,  gb,  T,
            T,   gb,  gb,  BLK, BLK, gb,  gb,  gb,  gb,  gb,  gb,  BLK, BLK, gb,  gb,  T,
            T,   gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  gb,  T,
            T,   T,   gb,  gb,  gb,  gb,  gd,  gd,  gd,  gd,  gb,  gb,  gb,  gb,  T,   T,
            T,   T,   T,   T,   gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  T,   T,   T,   T,
            T,   T,   T,   gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  T,   T,   T,
            T,   T,   gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  gd,  T,   T,
            T,   T,   T,   gd,  gd,  SKIN,SKIN,T,   T,   SKIN,SKIN,gd,  gd,  T,   T,   T,
            T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T,   T,   T,   SKIN,SKIN,SKIN,SKIN,T,   T,
            T,   SKIN,SKIN,BLK, BLK, BLK, T,   T,   T,   T,   BLK, BLK, BLK, SKIN,SKIN,T,
            T,   T,   BLK, BLK, BLK, BLK, BLK, T,   T,   BLK, BLK, BLK, BLK, BLK, T,   T,
        ];
        self.textures.insert("goomba1".into(), grid_to_texture(16, 16, &goomba1));

        // Goomba flat
        let mut flat = vec![T; 256];
        for x in 1..=14 { flat[14 * 16 + x] = gd; }
        for x in 2..=13 { flat[15 * 16 + x] = gd; }
        flat[14 * 16 + 4] = BLK; flat[14 * 16 + 5] = BLK;
        flat[14 * 16 + 10] = BLK; flat[14 * 16 + 11] = BLK;
        self.textures.insert("goomba_flat".into(), grid_to_texture(16, 16, &flat));

        // Koopa
        self.textures.insert("koopa0".into(), self.gen_koopa(0));
        self.textures.insert("koopa1".into(), self.gen_koopa(1));
        self.textures.insert("koopa_shell".into(), self.gen_shell());
    }

    fn gen_koopa(&self, frame: i32) -> Texture2D {
        let mut g = vec![T; 16 * 24];
        let s = |g: &mut Vec<C>, y: usize, x: usize, c: C| { g[y * 16 + x] = c; };

        // Head (offset by 10 to bottom-align in 24px)
        let oy = 10;
        for x in 7..=12 { s(&mut g, oy, x, GRN); }
        for x in 6..=13 { s(&mut g, oy + 1, x, GRN); }
        for x in 6..=13 { s(&mut g, oy + 2, x, GRN); }
        s(&mut g, oy + 2, 10, WHT); s(&mut g, oy + 2, 11, WHT);
        for x in 6..=13 { s(&mut g, oy + 3, x, GRN); }
        s(&mut g, oy + 3, 10, WHT); s(&mut g, oy + 3, 11, BLK); s(&mut g, oy + 3, 12, SKIN);
        for x in 7..=13 { s(&mut g, oy + 4, x, GRN); }
        s(&mut g, oy + 4, 12, SKIN); s(&mut g, oy + 4, 13, SKIN);
        for x in 8..=11 { s(&mut g, oy + 5, x, GRN); }

        // Shell
        for x in 3..=11 { s(&mut g, oy + 6, x, GRN); }
        for x in 2..=12 { s(&mut g, oy + 7, x, GRN); }
        for x in 2..=12 { s(&mut g, oy + 8, x, DRK_GRN); }
        s(&mut g, oy + 8, 5, YLW); s(&mut g, oy + 8, 6, YLW);
        s(&mut g, oy + 8, 9, YLW); s(&mut g, oy + 8, 10, YLW);
        for x in 2..=12 { s(&mut g, oy + 9, x, DRK_GRN); }
        for x in 2..=12 { s(&mut g, oy + 10, x, GRN); }
        for x in 3..=11 { s(&mut g, oy + 11, x, GRN); }

        // Feet
        if frame == 0 {
            for x in 3..=5 { s(&mut g, oy + 12, x, SKIN); }
            for x in 9..=11 { s(&mut g, oy + 12, x, SKIN); }
            for x in 2..=5 { s(&mut g, oy + 13, x, SKIN); }
            for x in 9..=12 { s(&mut g, oy + 13, x, SKIN); }
        } else {
            for x in 4..=6 { s(&mut g, oy + 12, x, SKIN); }
            for x in 8..=10 { s(&mut g, oy + 12, x, SKIN); }
            for x in 5..=7 { s(&mut g, oy + 13, x, SKIN); }
            for x in 7..=9 { s(&mut g, oy + 13, x, SKIN); }
        }

        grid_to_texture(16, 24, &g)
    }

    fn gen_shell(&self) -> Texture2D {
        let mut g = vec![T; 256];
        let s = |g: &mut Vec<C>, y: usize, x: usize, c: C| { g[y * 16 + x] = c; };

        for x in 4..=11 { s(&mut g, 2, x, GRN); }
        for x in 3..=12 { s(&mut g, 3, x, GRN); }
        for x in 2..=13 { s(&mut g, 4, x, GRN); }
        for x in 2..=13 { s(&mut g, 5, x, DRK_GRN); }
        s(&mut g, 5, 5, YLW); s(&mut g, 5, 6, YLW); s(&mut g, 5, 9, YLW); s(&mut g, 5, 10, YLW);
        for x in 2..=13 { s(&mut g, 6, x, DRK_GRN); }
        for x in 2..=13 { s(&mut g, 7, x, DRK_GRN); }
        for x in 2..=13 { s(&mut g, 8, x, GRN); }
        for x in 2..=13 { s(&mut g, 9, x, GRN); }
        for x in 3..=12 { s(&mut g, 10, x, GRN); }
        for x in 3..=12 { s(&mut g, 11, x, WHT); }
        for x in 4..=11 { s(&mut g, 12, x, WHT); }
        for x in 5..=10 { s(&mut g, 13, x, WHT); }

        grid_to_texture(16, 16, &g)
    }

    fn generate_items(&mut self) {
        // Coin
        #[rustfmt::skip]
        let coin: [C; 256] = [
            T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   YLW, YLW, ORG, ORG, YLW, YLW, T,   T,   T,   T,   T,
            T,   T,   T,   T,   YLW, YLW, ORG, YLW, YLW, ORG, YLW, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, ORG, YLW, YLW, YLW, YLW, ORG, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   YLW, YLW, ORG, YLW, YLW, ORG, YLW, YLW, T,   T,   T,   T,
            T,   T,   T,   T,   T,   YLW, YLW, ORG, ORG, YLW, YLW, T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("coin".into(), grid_to_texture(16, 16, &coin));
        let coin_tex = self.textures.get("coin").unwrap().clone();
        self.textures.insert("coin_popup".into(), coin_tex);

        // Mushroom
        let mr: C = [200, 36, 0, 255];
        #[rustfmt::skip]
        let mushroom: [C; 256] = [
            T,   T,   T,   T,   T,   mr,  mr,  mr,  mr,  mr,  mr,  T,   T,   T,   T,   T,
            T,   T,   T,   mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  T,   T,   T,
            T,   T,   mr,  mr,  WHT, WHT, mr,  mr,  mr,  mr,  WHT, WHT, mr,  mr,  T,   T,
            T,   mr,  mr,  WHT, WHT, WHT, WHT, mr,  mr,  WHT, WHT, WHT, WHT, mr,  mr,  T,
            T,   mr,  WHT, WHT, WHT, WHT, mr,  mr,  mr,  mr,  WHT, WHT, WHT, WHT, mr,  T,
            mr,  mr,  mr,  WHT, WHT, mr,  mr,  mr,  mr,  mr,  mr,  WHT, WHT, mr,  mr,  mr,
            mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,
            mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,  mr,
            T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,
            T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T,
            T,   SKIN,BLK, BLK, BLK, BLK, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, SKIN,T,
            T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T,
            T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,
            T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("mushroom".into(), grid_to_texture(16, 16, &mushroom));

        // Fire flower
        let fo: C = [228, 92, 16, 255];
        #[rustfmt::skip]
        let fireflower: [C; 256] = [
            T,   T,   T,   T,   T,   T,   RED, RED, RED, RED, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   RED, RED, RED, YLW, YLW, RED, RED, RED, T,   T,   T,   T,
            T,   T,   T,   RED, RED, YLW, fo,  fo,  fo,  fo,  YLW, RED, RED, T,   T,   T,
            T,   T,   RED, RED, YLW, fo,  fo,  WHT, WHT, fo,  fo,  YLW, RED, RED, T,   T,
            T,   T,   RED, YLW, fo,  fo,  WHT, WHT, WHT, WHT, fo,  fo,  YLW, RED, T,   T,
            T,   T,   RED, YLW, fo,  fo,  WHT, WHT, WHT, WHT, fo,  fo,  YLW, RED, T,   T,
            T,   T,   RED, RED, YLW, fo,  fo,  fo,  fo,  fo,  fo,  YLW, RED, RED, T,   T,
            T,   T,   T,   RED, RED, YLW, fo,  fo,  fo,  fo,  YLW, RED, RED, T,   T,   T,
            T,   T,   T,   T,   T,   GRN, GRN, GRN, GRN, GRN, GRN, T,   T,   T,   T,   T,
            T,   T,   T,   T,   GRN, GRN, T,   GRN, GRN, T,   GRN, GRN, T,   T,   T,   T,
            T,   T,   T,   GRN, GRN, T,   T,   GRN, GRN, T,   T,   GRN, GRN, T,   T,   T,
            T,   T,   T,   GRN, T,   T,   T,   GRN, GRN, T,   T,   T,   GRN, T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   GRN, GRN, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   GRN, GRN, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   GRN, GRN, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("fireflower".into(), grid_to_texture(16, 16, &fireflower));

        // Star
        #[rustfmt::skip]
        let star: [C; 256] = [
            T,   T,   T,   T,   T,   T,   T,   YLW, YLW, T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   YLW, YLW, YLW, YLW, YLW, YLW, T,   T,   T,   T,   T,
            YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW,
            T,   YLW, YLW, YLW, YLW, YLW, ORG, ORG, ORG, ORG, YLW, YLW, YLW, YLW, YLW, T,
            T,   T,   YLW, YLW, YLW, ORG, ORG, BLK, BLK, ORG, ORG, YLW, YLW, YLW, T,   T,
            T,   T,   T,   YLW, YLW, ORG, BLK, ORG, ORG, BLK, ORG, YLW, YLW, T,   T,   T,
            T,   T,   T,   YLW, YLW, ORG, ORG, ORG, ORG, ORG, ORG, YLW, YLW, T,   T,   T,
            T,   T,   T,   YLW, YLW, YLW, ORG, ORG, ORG, ORG, YLW, YLW, YLW, T,   T,   T,
            T,   T,   T,   T,   YLW, YLW, YLW, YLW, YLW, YLW, YLW, YLW, T,   T,   T,   T,
            T,   T,   T,   YLW, YLW, YLW, YLW, T,   T,   YLW, YLW, YLW, YLW, T,   T,   T,
            T,   T,   YLW, YLW, YLW, T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, T,   T,
            T,   YLW, YLW, YLW, T,   T,   T,   T,   T,   T,   T,   T,   YLW, YLW, YLW, T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("star".into(), grid_to_texture(16, 16, &star));

        // 1-Up mushroom
        #[rustfmt::skip]
        let oneup: [C; 256] = [
            T,   T,   T,   T,   T,   GRN, GRN, GRN, GRN, GRN, GRN, T,   T,   T,   T,   T,
            T,   T,   T,   GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, T,   T,   T,
            T,   T,   GRN, GRN, WHT, WHT, GRN, GRN, GRN, GRN, WHT, WHT, GRN, GRN, T,   T,
            T,   GRN, GRN, WHT, WHT, WHT, WHT, GRN, GRN, WHT, WHT, WHT, WHT, GRN, GRN, T,
            T,   GRN, WHT, WHT, WHT, WHT, GRN, GRN, GRN, GRN, WHT, WHT, WHT, WHT, GRN, T,
            GRN, GRN, GRN, WHT, WHT, GRN, GRN, GRN, GRN, GRN, GRN, WHT, WHT, GRN, GRN, GRN,
            GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN,
            GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN, GRN,
            T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,
            T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T,
            T,   SKIN,BLK, BLK, BLK, BLK, SKIN,SKIN,SKIN,SKIN,BLK, BLK, BLK, BLK, SKIN,T,
            T,   SKIN,SKIN,BLK, BLK, SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,BLK, BLK, SKIN,SKIN,T,
            T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,
            T,   T,   T,   SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,SKIN,T,   T,   T,
            T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,   T,
        ];
        self.textures.insert("oneup".into(), grid_to_texture(16, 16, &oneup));

        // Brick debris (8x8)
        let mut debris = vec![T; 64];
        for y in 0..8 {
            for x in 0..8 {
                debris[y * 8 + x] = if x == 0 || x == 7 || y == 0 || y == 7 { BLK } else { RED };
            }
        }
        self.textures.insert("brick_debris".into(), grid_to_texture(8, 8, &debris));
    }

    fn generate_fireball(&mut self) {
        let fr: C = [252, 152, 56, 255];
        let mut g = vec![T; 64];
        for x in 2..=5 { g[1 * 8 + x] = fr; }
        for x in 1..=6 { g[2 * 8 + x] = YLW; }
        for x in 1..=6 { g[3 * 8 + x] = YLW; }
        for x in 1..=6 { g[4 * 8 + x] = fr; }
        for x in 1..=6 { g[5 * 8 + x] = fr; }
        for x in 2..=5 { g[6 * 8 + x] = RED; }
        self.textures.insert("fireball".into(), grid_to_texture(8, 8, &g));
    }

    fn generate_font(&mut self) {
        let chars = [
            "0","1","2","3","4","5","6","7","8","9",
            "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
            "-","x","!",".",":"," ",
        ];

        let patterns: &[&[u8]] = &[
            &[0x0E,0x11,0x13,0x15,0x19,0x11,0x0E], // 0
            &[0x04,0x0C,0x04,0x04,0x04,0x04,0x0E], // 1
            &[0x0E,0x11,0x01,0x06,0x08,0x10,0x1F], // 2
            &[0x0E,0x11,0x01,0x06,0x01,0x11,0x0E], // 3
            &[0x02,0x06,0x0A,0x12,0x1F,0x02,0x02], // 4
            &[0x1F,0x10,0x1E,0x01,0x01,0x11,0x0E], // 5
            &[0x06,0x08,0x10,0x1E,0x11,0x11,0x0E], // 6
            &[0x1F,0x01,0x02,0x04,0x08,0x08,0x08], // 7
            &[0x0E,0x11,0x11,0x0E,0x11,0x11,0x0E], // 8
            &[0x0E,0x11,0x11,0x0F,0x01,0x02,0x0C], // 9
            &[0x0E,0x11,0x11,0x1F,0x11,0x11,0x11], // A
            &[0x1E,0x11,0x11,0x1E,0x11,0x11,0x1E], // B
            &[0x0E,0x11,0x10,0x10,0x10,0x11,0x0E], // C
            &[0x1E,0x11,0x11,0x11,0x11,0x11,0x1E], // D
            &[0x1F,0x10,0x10,0x1E,0x10,0x10,0x1F], // E
            &[0x1F,0x10,0x10,0x1E,0x10,0x10,0x10], // F
            &[0x0E,0x11,0x10,0x17,0x11,0x11,0x0F], // G
            &[0x11,0x11,0x11,0x1F,0x11,0x11,0x11], // H
            &[0x0E,0x04,0x04,0x04,0x04,0x04,0x0E], // I
            &[0x07,0x02,0x02,0x02,0x02,0x12,0x0C], // J
            &[0x11,0x12,0x14,0x18,0x14,0x12,0x11], // K
            &[0x10,0x10,0x10,0x10,0x10,0x10,0x1F], // L
            &[0x11,0x1B,0x15,0x15,0x11,0x11,0x11], // M
            &[0x11,0x11,0x19,0x15,0x13,0x11,0x11], // N
            &[0x0E,0x11,0x11,0x11,0x11,0x11,0x0E], // O
            &[0x1E,0x11,0x11,0x1E,0x10,0x10,0x10], // P
            &[0x0E,0x11,0x11,0x11,0x15,0x12,0x0D], // Q
            &[0x1E,0x11,0x11,0x1E,0x14,0x12,0x11], // R
            &[0x0E,0x11,0x10,0x0E,0x01,0x11,0x0E], // S
            &[0x1F,0x04,0x04,0x04,0x04,0x04,0x04], // T
            &[0x11,0x11,0x11,0x11,0x11,0x11,0x0E], // U
            &[0x11,0x11,0x11,0x11,0x0A,0x0A,0x04], // V
            &[0x11,0x11,0x11,0x15,0x15,0x1B,0x11], // W
            &[0x11,0x11,0x0A,0x04,0x0A,0x11,0x11], // X
            &[0x11,0x11,0x0A,0x04,0x04,0x04,0x04], // Y
            &[0x1F,0x01,0x02,0x04,0x08,0x10,0x1F], // Z
            &[0x00,0x00,0x00,0x1F,0x00,0x00,0x00], // -
            &[0x00,0x11,0x0A,0x04,0x0A,0x11,0x00], // x
            &[0x04,0x04,0x04,0x04,0x04,0x00,0x04], // !
            &[0x00,0x00,0x00,0x00,0x00,0x00,0x04], // .
            &[0x00,0x04,0x00,0x00,0x00,0x04,0x00], // :
            &[0x00,0x00,0x00,0x00,0x00,0x00,0x00], // space
        ];

        for (i, ch) in chars.iter().enumerate() {
            let mut data = vec![T; 5 * 7];
            for y in 0..7 {
                for x in 0..5 {
                    if (patterns[i][y] >> (4 - x)) & 1 == 1 {
                        data[y * 5 + x] = WHT;
                    }
                }
            }
            let tex = grid_to_texture(5, 7, &data);
            self.textures.insert(format!("font_{}", ch), tex);
        }
    }

    // 1x1 white pixel texture
    pub fn create_pixel(&self) -> Texture2D {
        let tex = Texture2D::from_rgba8(1, 1, &[255, 255, 255, 255]);
        tex.set_filter(FilterMode::Nearest);
        tex
    }
}
