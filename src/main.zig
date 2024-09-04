const std = @import("std");
const rl = @import("raylib");

const Vector2 = rl.Vector2;
const math = std.math;
const mem = std.mem;

const Map = struct {
    name: []const u8,
    positions: u8,
    cords: std.BoundedArray(Vector2, 100),
    turretCords: std.BoundedArray(Vector2, 10),
    isChoosen: bool,
};

const Enemy = struct {
    position: Vector2,
    mapPoint: u8,
    size: f32,
    speed: f32,
    isAlive: bool,
};

const Game = struct {
    frame: usize,
    choosingMap: bool,
    health: usize,
    maps: std.ArrayList(Map),
    enemies: std.ArrayList(Enemy),
};

var game: Game = undefined;

const screenWidth = 1280;
const screenHeight = 720;

pub fn StartGame() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");
    rl.setTargetFPS(60);

    var monkeyMeadow = Map{
        .name = "Monkey Meadow",
        .positions = 5,
        .cords = try std.BoundedArray(Vector2, 100).init(0),
        .turretCords = try std.BoundedArray(Vector2, 10).init(0),
        .isChoosen = true,
    };

    try monkeyMeadow.cords.append(Vector2.init(0, 300));
    try monkeyMeadow.cords.append(Vector2.init(400, 300));
    try monkeyMeadow.cords.append(Vector2.init(400, 500));
    try monkeyMeadow.cords.append(Vector2.init(800, 500));
    try monkeyMeadow.cords.append(Vector2.init(800, 150));
    try monkeyMeadow.cords.append(Vector2.init(1280, 150));

    try game.maps.append(monkeyMeadow);
}

pub fn Update() !void {
    game.frame += 1;

    if (game.frame % 180 == 0) {
        const enemy = Enemy{
            .position = Vector2.init(0, 300),
            .mapPoint = 1,
            .size = 8,
            .speed = 1,
            .isAlive = true,
        };
        try game.enemies.append(enemy);
    }

    for (game.enemies.items) |*enemyPtr| {
        for (game.maps.items) |map| {
            const mapPoint = map.cords.get(enemyPtr.mapPoint);
            const lastPoint = map.cords.get(map.positions);

            if (enemyPtr.position.equals(mapPoint) == 1 and enemyPtr.mapPoint < map.positions) {
                enemyPtr.mapPoint += 1;
            }

            if (enemyPtr.position.equals(lastPoint) == 1) {
                enemyPtr.isAlive = false;
            }
            enemyPtr.position = enemyPtr.position.moveTowards(mapPoint, 1);
        }
    }
}

pub fn Draw() !void {
    rl.beginDrawing();

    defer rl.endDrawing();

    rl.clearBackground(rl.Color.black);

    //Drawing map
    for (game.maps.items) |map| {
        rl.drawLineStrip(map.cords.slice(), rl.Color.pink);
    }

    //Draw enemies
    for (game.enemies.items) |enemy| {
        if (enemy.isAlive) {
            rl.drawPoly(enemy.position, 8, enemy.size, 0, rl.Color.red);
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    game = .{
        .frame = 0,
        .choosingMap = true,
        .health = 100,
        .maps = std.ArrayList(Map).init(allocator),
        .enemies = std.ArrayList(Enemy).init(allocator),
    };

    defer game.maps.deinit();
    defer game.enemies.deinit();

    try StartGame();

    while (!rl.windowShouldClose()) {
        try Update();
        try Draw();
    }

    rl.closeWindow();
}
