use crate::constants::*;

pub struct Camera {
    pub x: f32,
    pub max_x: f32,
}

impl Camera {
    pub fn new(level_width: f32) -> Self {
        Self {
            x: 0.0,
            max_x: level_width - NES_WIDTH as f32,
        }
    }

    pub fn follow(&mut self, target_x: f32) {
        let desired = target_x - NES_WIDTH as f32 / 2.0;
        if desired > self.x {
            self.x = desired;
        }
        if self.x < 0.0 {
            self.x = 0.0;
        }
        if self.x > self.max_x {
            self.x = self.max_x;
        }
    }

    pub fn is_visible(&self, entity_x: f32, width: f32) -> bool {
        entity_x + width > self.x - 16.0 && entity_x < self.x + NES_WIDTH as f32 + 16.0
    }

    pub fn reset(&mut self) {
        self.x = 0.0;
    }
}
