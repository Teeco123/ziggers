const std = @import("std");
const rl = @import("raylib");

const Vector2 = rl.Vector2;
const math = std.math;

const Game = struct {
    frame: u32,
    second: u32,
    health: u32,
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
    mapPoint: u8,
    size: f32,
    speed: f32,
    isAlive: bool,
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
    game.health = 100;
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
        enemy[enemyNr].mapPoint = 0;
        enemy[enemyNr].speed = 1;
        enemy[enemyNr].size = 10;
        enemy[enemyNr].isAlive = true;
    }
}

pub fn Update() !void {
    game.frame += 1;
    game.second = game.frame / 60;

    var enemyNr: u32 = 0;

    if (game.frame % 180 == 0) {
        game.maxEnemies += 1;
    }

    while (enemyNr <= game.maxEnemies) : (enemyNr += 1) {
        while (enemy[enemyNr].mapPoint <= map.positions) {
            enemy[enemyNr].position = enemy[enemyNr].position.moveTowards(map.cords[enemy[enemyNr].mapPoint], enemy[enemyNr].speed);

            if (rl.Vector2.equals(enemy[enemyNr].position, map.cords[enemy[enemyNr].mapPoint]) == 1) {
                enemy[enemyNr].mapPoint += 1;
            }

            if (enemy[enemyNr].mapPoint == map.positions + 1) {
                enemy[enemyNr].isAlive = false;
                game.health -= 1;
            }
            break;
        }
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

    var enemyNr: u32 = 0;
    while (enemyNr <= game.maxEnemies) : (enemyNr += 1) {
        if (enemy[enemyNr].isAlive) {
            rl.drawPoly(enemy[enemyNr].position, 8, enemy[enemyNr].size, 0, rl.Color.blue);
        }
    }

    rl.drawText(rl.textFormat("Health: %01i", .{game.health}), 10, 10, 15, rl.Color.white);

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
