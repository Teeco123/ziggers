const std = @import("std");
const rl = @import("raylib");

const Vector2 = rl.Vector2;

const Enemy = struct {
    health: u8,
    position: Vector2,
    size: Vector2,
};

const screenWidth = 1280;
const screenHeight = 720;

var enemy: Enemy = undefined;

pub fn StartGame() !void {
    enemy.position = Vector2.init(screenWidth / 2, screenHeight / 2);
    enemy.size = Vector2.init(15, 15);
}

pub fn main() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");

    rl.setTargetFPS(60);

    try StartGame();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawRectangleV(enemy.position, enemy.size, rl.Color.white);

        defer rl.endDrawing();
    }
}
