const std = @import("std");
const rl = @import("raylib");

const Vector2 = rl.Vector2;

const Map = struct {
    positions: u8,
    cords: [10]Vector2,
};

const Enemy = struct {
    health: u8,
    position: Vector2,
    size: Vector2,
    speed: u8,
};

const screenWidth = 1280;
const screenHeight = 720;

var map: Map = undefined;
var enemy: Enemy = undefined;

pub fn StartGame() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");
    rl.setTargetFPS(60);

    enemy.position = Vector2.init(screenWidth / 2, screenHeight / 2);
    enemy.size = Vector2.init(15, 15);

    map.positions = 5;
    map.cords[0] = Vector2.init(0, 300);
    map.cords[1] = Vector2.init(400, 300);
    map.cords[2] = Vector2.init(400, 500);
    map.cords[3] = Vector2.init(800, 500);
    map.cords[4] = Vector2.init(800, 150);
    map.cords[5] = Vector2.init(1270, 150);
}

pub fn main() !void {
    try StartGame();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();

        rl.clearBackground(rl.Color.black);

        var i: u8 = 0;
        while (i < map.positions) {
            rl.drawLineV(map.cords[i], map.cords[i + 1], rl.Color.pink);
            i += 1;
        }

        defer rl.endDrawing();
    }
}
