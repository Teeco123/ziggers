const std = @import("std");
const rl = @import("raylib");

const Map = @import("maps/index.zig").Map;
const maps = @import("maps/index.zig");

const Vector2 = rl.Vector2;
const math = std.math;
const mem = std.mem;

const Enemy = struct {
    id: u64,
    position: Vector2,
    mapPoint: u8,
    size: f32,
    speed: f32,
    isAlive: bool,
};

const Turret = struct {
    range: f32,
    enemies: std.BoundedArray(Enemy, 100),
};

const Game = struct {
    frame: usize,
    choosingMap: bool,
    choosenMap: i32,
    health: usize,
    maps: std.AutoArrayHashMap(usize, Map),
    enemies: std.ArrayList(Enemy),
    turrets: std.ArrayList(Turret),
};

var game: Game = undefined;

const screenWidth = 1280;
const screenHeight = 720;

var selectorHeight: i32 = 0;

pub fn StartGame() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");
    rl.setTargetFPS(60);

    try game.maps.put(maps.map1.id, maps.map1);

    // const turret1 = Turret{
    //     .range = 150,
    //     .enemies = try std.BoundedArray(Enemy, 100).init(0),
    // };
    //
    // try game.turrets.append(turret1);
}

pub fn Update() !void {
    game.frame += 1;

    if (game.choosingMap) {
        const nmbrOfMaps: i32 = @intCast(game.maps.count());

        //Handle up / down input
        if (rl.isKeyPressed(rl.KeyboardKey.key_up)) {
            selectorHeight -= 25;
        }
        if (rl.isKeyPressed(rl.KeyboardKey.key_down)) {
            selectorHeight += 25;
        }

        //Choose map
        if (rl.isKeyPressed(rl.KeyboardKey.key_enter)) {
            game.choosenMap = @divFloor(selectorHeight, 25);
            game.choosingMap = false;
        }

        //Handle selector out of maps count
        if (selectorHeight < 0) {
            selectorHeight = (nmbrOfMaps - 1) * 25;
        }
        if (selectorHeight > (game.maps.count() - 1) * 25) {
            selectorHeight = 0;
        }
    }

    // if (game.frame % 180 == 0) {
    //     const enemy = Enemy{
    //         .id = game.frame / 180,
    //         .position = Vector2.init(0, 300),
    //         .mapPoint = 0,
    //         .size = 8,
    //         .speed = 1,
    //         .isAlive = true,
    //     };
    //     try game.enemies.append(enemy);
    // }
    //
    // var turretNmbr: u8 = 0;
    // for (game.enemies.items) |*enemyPtr| {
    //     if (enemyPtr.isAlive) {
    //         for (game.maps.items) |map| {
    //             for (game.turrets.items) |*turretPtr| {
    //                 //Check for collision with turrets range
    //                 if (rl.checkCollisionPointCircle(enemyPtr.position, map.turretCords.get(0), turretPtr.range)) {
    //                     std.log.info("Enemy in range {}", .{enemyPtr.id});
    //                 }
    //
    //                 const mapPoint = map.cords.get(enemyPtr.mapPoint);
    //                 const lastPoint = map.cords.get(map.positions);
    //
    //                 //Change point to where enemy moves to
    //                 if (enemyPtr.position.equals(mapPoint) == 1 and enemyPtr.mapPoint < map.positions) {
    //                     enemyPtr.mapPoint += 1;
    //                 }
    //
    //                 //Unalive enemy when it's at the end
    //                 if (enemyPtr.position.equals(lastPoint) == 1) {
    //                     enemyPtr.isAlive = false;
    //
    //                     game.health -= 1;
    //                 }
    //
    //                 //Move enemy
    //                 enemyPtr.position = enemyPtr.position.moveTowards(mapPoint, 1);
    //
    //                 if (game.turrets.items.len < turretNmbr) {
    //                     turretNmbr += 1;
    //                 }
    //             }
    //         }
    //     }
    // }
}

pub fn Draw() !void {
    rl.beginDrawing();

    defer rl.endDrawing();

    rl.clearBackground(rl.Color.black);

    if (game.choosingMap) {
        //Drawing arrow selector
        rl.drawText("<-", 200, selectorHeight, 25, rl.Color.white);

        //Drawing all maps names
        var mapsIterator = game.maps.iterator();
        var height: i32 = 0;
        while (mapsIterator.next()) |map| {
            rl.drawText(map.value_ptr.name, 0, height, 20, rl.Color.white);
            height += 25;
        }
    }

    if (!game.choosingMap) {
        //Drawing map
        const currentMap = game.maps.get(@intCast(game.choosenMap));
        rl.drawLineStrip(currentMap.?.cords.slice(), rl.Color.green);
    }

    //Draw enemies
    // for (game.enemies.items) |enemy| {
    //     if (enemy.isAlive) {
    //         rl.drawPoly(enemy.position, 8, enemy.size, 0, rl.Color.red);
    //     }
    // }

    //for(game.turrets.items) |turret| {
    // var turretNmbr: u8 = 0;
    // for (game.maps.items) |map| {
    //     rl.drawPoly(map.turretCords.get(turretNmbr), 4, 8, 0, rl.Color.blue);
    //     rl.drawCircleLinesV(map.turretCords.get(turretNmbr), 150, rl.Color.alpha(rl.Color.gray, 0.7));
    //     turretNmbr += 1;
    // }
    //}

    //Drawing health
    //rl.drawText(rl.textFormat("Health: %01i", .{game.health}), 10, 10, 15, rl.Color.white);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    game = .{
        .frame = 0,
        .choosingMap = true,
        .choosenMap = 0,
        .health = 100,
        .maps = std.AutoArrayHashMap(usize, Map).init(allocator),
        .enemies = std.ArrayList(Enemy).init(allocator),
        .turrets = std.ArrayList(Turret).init(allocator),
    };

    defer game.maps.deinit();
    defer game.enemies.deinit();
    defer game.turrets.deinit();

    try StartGame();

    while (!rl.windowShouldClose()) {
        try Update();
        try Draw();
    }

    rl.closeWindow();
}
