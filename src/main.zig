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
    point: u8,
    isChoosen: bool,
};

const Game = struct {
    frame: usize,
    choosingMap: bool,
    health: usize,
    maps: std.ArrayList(Map),
};

var game: Game = undefined;

const screenWidth = 1280;
const screenHeight = 720;

pub fn StartGame() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");
    rl.setTargetFPS(60);

    var monkeyMeadow = Map{
        .name = "Monkey Meadow",
        .positions = 4,
        .cords = try std.BoundedArray(Vector2, 100).init(0),
        .turretCords = try std.BoundedArray(Vector2, 10).init(0),
        .point = 0,
        .isChoosen = true,
    };

    try monkeyMeadow.cords.append(Vector2.init(0, 300));
    try monkeyMeadow.cords.append(Vector2.init(400, 300));
    try monkeyMeadow.cords.append(Vector2.init(400, 500));
    try monkeyMeadow.cords.append(Vector2.init(800, 500));
    try monkeyMeadow.cords.append(Vector2.init(800, 150));
    try monkeyMeadow.cords.append(Vector2.init(1280, 150));

    try game.maps.append(monkeyMeadow);

    const cord = monkeyMeadow.cords.get(0);

    const items = game.maps.items;

    std.log.info("items {any}", .{items});
    std.log.info("cord {}", .{cord});
}

pub fn Update() !void {
    for (game.maps.items) |map| {
        std.log.info("{any}", .{map.name});
    }
}

pub fn Draw() !void {
    rl.beginDrawing();

    defer rl.endDrawing();

    rl.clearBackground(rl.Color.black);
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
    };

    defer game.maps.deinit();

    try StartGame();

    while (!rl.windowShouldClose()) {
        try Update();
        try Draw();
    }

    rl.closeWindow();
}
