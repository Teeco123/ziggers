const std = @import("std");
const rl = @import("raylib");
const Enemy = @import("index.zig").Enemy;

const Vector2 = rl.Vector2;

pub fn addEnemy() Enemy {
    const enemy1 = Enemy{
        .position = Vector2.init(0, 300),
        .mapPoint = 0,
        .size = 8,
        .speed = 1,
        .isAlive = true,
    };
    return enemy1;
}
