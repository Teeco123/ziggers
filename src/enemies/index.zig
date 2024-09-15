const rl = @import("raylib");

const Vector2 = rl.Vector2;

pub const Enemy = struct {
    position: Vector2,
    mapPoint: u8,
    size: f32,
    speed: f32,
    isAlive: bool,
};

pub const enemy1 = @import("enemy1.zig").addEnemy();
