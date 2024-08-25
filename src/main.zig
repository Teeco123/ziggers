const std = @import("std");
const rl = @import("raylib");

const Vector2 = rl.Vector2;
const math = std.math;

const Game = struct {
    frame: u32,
    second: u32,
    maxEnemies: u32,
};

const Map = struct {
    positions: u8,
    cords: [10]Vector2,
    point: u8,
};

const Enemy = struct {
    health: u8,
    position: Vector2,
    size: f32,
    speed: f32,
};

const screenWidth = 1280;
const screenHeight = 720;

var game: Game = undefined;
var map: Map = undefined;
var enemy = std.mem.zeroes([500]Enemy);

pub fn StartGame() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");
    rl.setTargetFPS(60);

    game.frame = 0;
    game.second = 0;
    game.maxEnemies = 0;

    map.positions = 5;
    map.point = 0;
    map.cords[0] = Vector2.init(0, 300);
    map.cords[1] = Vector2.init(400, 300);
    map.cords[2] = Vector2.init(400, 500);
    map.cords[3] = Vector2.init(800, 500);
    map.cords[4] = Vector2.init(800, 150);
    map.cords[5] = Vector2.init(1280, 150);

    var enemyNr: u32 = 0;
    while (enemyNr <= 499) : (enemyNr += 1) {
        std.log.info("start enemy loop - {}", .{enemyNr});
        enemy[enemyNr].health = 10;
        enemy[enemyNr].position = Vector2.init(map.cords[0].x, map.cords[0].y);
        enemy[enemyNr].speed = 0.6;
        enemy[enemyNr].size = 10;
    }
}

pub fn Update() !void {
    game.frame += 1;
    game.second = game.frame / 60;

    var enemyNr: u32 = 0;

    if (game.frame % 600 == 0) {
        game.maxEnemies += 1;
    }

    while (enemyNr <= game.maxEnemies) : (enemyNr += 1) {
        while (map.point <= map.positions) {
            enemy[enemyNr].position = enemy[enemyNr].position.moveTowards(map.cords[map.point], enemy[enemyNr].speed);

            if (rl.Vector2.equals(enemy[enemyNr].position, map.cords[map.point]) == 1) {
                map.point += 1;
            }
            break;
        }
        std.log.info("enemyNr - {}", .{enemyNr});
        std.log.info("maxEnemies - {}", .{game.maxEnemies});
    }
}

pub fn Draw() !void {
    rl.beginDrawing();

    rl.clearBackground(rl.Color.black);

    var drawPoint: u8 = 0;
    while (drawPoint < map.positions) {
        rl.drawLineV(map.cords[drawPoint], map.cords[drawPoint + 1], rl.Color.pink);
        drawPoint += 1;
    }

    rl.drawPoly(enemy[0].position, 8, enemy[0].size, 0, rl.Color.blue);

    defer rl.endDrawing();
}

pub fn main() !void {
    try StartGame();

    while (!rl.windowShouldClose()) {
        try Update();
        try Draw();
    }
    rl.closeWindow();
}
