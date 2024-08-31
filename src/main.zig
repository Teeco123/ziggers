const std = @import("std");
const rl = @import("raylib");

const Vector2 = rl.Vector2;
const math = std.math;

const Map = struct {
    positions: u8,
    cords: [10]Vector2,
    turretCords: [10]Vector2,
    point: u8,
};

const Game = struct {
    frame: usize,
    health: usize,
    maps: std.ArrayList(Map),
};

var game: Game = undefined;

const screenWidth = 1280;
const screenHeight = 720;

pub fn StartGame() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");
    rl.setTargetFPS(60);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    game = .{
        .frame = 0,
        .health = 100,
        .maps = std.ArrayList(Map).init(allocator),
    };
}

pub fn Update() !void {}

pub fn Draw() !void {
    rl.beginDrawing();

    rl.clearBackground(rl.Color.black);

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
