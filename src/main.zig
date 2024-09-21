const std = @import("std");
const rl = @import("raylib");

const Map = @import("maps/index.zig").Map;
const Enemy = @import("enemies/index.zig").Enemy;
const Round = @import("rounds/index.zig").Round;

const maps = @import("maps/index.zig");
const enemies = @import("enemies/index.zig");
const rounds = @import("rounds/index.zig");

const Vector2 = rl.Vector2;
const math = std.math;
const mem = std.mem;

const Turret = struct {
    range: f32,
    enemies: std.BoundedArray(Enemy, 100),
};

const Game = struct {
    frame: usize,
    mousePos: Vector2,
    choosingMap: bool,
    choosenMap: Map,
    currentRound: usize,
    enemyToSpawn: usize,
    nextRoundTimer: usize,
    health: usize,
    maps: std.AutoArrayHashMap(usize, Map),
    enemies: std.ArrayList(Enemy),
    rounds: std.AutoArrayHashMap(usize, Round),
    turrets: std.ArrayList(Turret),
};

pub var game: Game = undefined;

const screenWidth = 1280;
const screenHeight = 720;

var selectorHeight: i32 = 0;

fn CheckNextRound(slice: anytype) bool {
    for (slice) |i| {
        if (i.isAlive) {
            return false;
        }
    }
    return true;
}

pub fn StartGame() !void {
    rl.initWindow(screenWidth, screenHeight, "Ziggers");
    rl.setTargetFPS(60);

    try game.maps.put(maps.map1.id, maps.map1);
    try game.maps.put(maps.map2.id, maps.map2);

    //Adding rounds to hashmap
    var i: usize = 0;
    while (i < rounds.rounds.len) : (i += 1) {
        try game.rounds.put(i, rounds.rounds[i]);
    }

    // const turret1 = Turret{
    //     .range = 150,
    //     .enemies = try std.BoundedArray(Enemy, 100).init(0),
    // };
    //
    // try game.turrets.append(turret1);
}

pub fn Update() !void {
    game.frame += 1;

    game.mousePos = rl.getMousePosition();
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
            game.choosenMap = game.maps.get(@intCast(@divFloor(selectorHeight, 25))).?;
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

    if (!game.choosingMap) {
        const currentRnd = game.rounds.getPtr(game.currentRound);
        const enemySlice = currentRnd.?.enemies.slice();

        if (game.frame % 180 == 0 and game.enemyToSpawn < enemySlice.len) {
            enemySlice[game.enemyToSpawn].isAlive = true;
            game.enemyToSpawn += 1;
        }

        //Check if all enemies are dead
        if (CheckNextRound(enemySlice) and game.frame > 200) {
            game.nextRoundTimer += 1;

            if (game.nextRoundTimer % 600 == 0) {
                game.enemyToSpawn = 0;
                game.nextRoundTimer = 0;
                game.currentRound += 1;
            }
        }

        for (enemySlice) |*enemy| {
            const mapPoint = game.choosenMap.cords.get(enemy.mapPoint);
            const lastPoint = game.choosenMap.cords.get(game.choosenMap.positions);

            if (enemy.isAlive) {
                //Handle enemy at end of the point
                if (enemy.position.equals(mapPoint) == 1 and enemy.mapPoint < game.choosenMap.positions) {
                    enemy.mapPoint += 1;
                }

                //Handle enemy at end of the map
                if (enemy.position.equals(lastPoint) == 1) {
                    enemy.isAlive = false;
                    game.health -= 1;
                }

                //Move enemy
                enemy.position = enemy.position.moveTowards(mapPoint, 1);
            }
        }

        //Check for button click for every turret spot
        for (game.choosenMap.turretSpots.slice()) |spot| {
            if (rl.checkCollisionPointCircle(game.mousePos, spot.position, 25) and rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
                std.log.info("huj", .{});
            }
        }
    }
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
        rl.drawLineStrip(game.choosenMap.cords.slice(), rl.Color.green);

        //Drawing Turret spots
        for (game.choosenMap.turretSpots.slice()) |spot| {
            rl.drawCircleLinesV(spot.position, 25, rl.Color.white);
        }

        //Drawing health
        rl.drawText(rl.textFormat("Health: %01i", .{game.health}), 10, 10, 15, rl.Color.white);

        //Drawing current round
        rl.drawText(rl.textFormat("Round: %01i", .{game.currentRound}), screenWidth - 70, 10, 15, rl.Color.white);

        //Drawing enemies
        const currentRnd = game.rounds.getPtr(game.currentRound);
        const enemySlice = currentRnd.?.enemies.slice();

        for (enemySlice) |enemy| {
            if (enemy.isAlive) {
                rl.drawPoly(enemy.position, 8, enemy.size, 0, rl.Color.red);
            }
        }
    }

    //for(game.turrets.items) |turret| {
    // var turretNmbr: u8 = 0;
    // for (game.maps.items) |map| {
    //     rl.drawPoly(map.turretCords.get(turretNmbr), 4, 8, 0, rl.Color.blue);
    //     rl.drawCircleLinesV(map.turretCords.get(turretNmbr), 150, rl.Color.alpha(rl.Color.gray, 0.7));
    //     turretNmbr += 1;
    // }
    //}

}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    game = .{
        .frame = 0,
        .mousePos = Vector2.init(0, 0),
        .choosingMap = true,
        .choosenMap = undefined,
        .currentRound = 0,
        .enemyToSpawn = 0,
        .nextRoundTimer = 0,
        .health = 100,
        .maps = std.AutoArrayHashMap(usize, Map).init(allocator),
        .enemies = std.ArrayList(Enemy).init(allocator),
        .rounds = std.AutoArrayHashMap(usize, Round).init(allocator),
        .turrets = std.ArrayList(Turret).init(allocator),
    };

    defer game.maps.deinit();
    defer game.enemies.deinit();
    defer game.rounds.deinit();
    defer game.turrets.deinit();

    try StartGame();

    while (!rl.windowShouldClose()) {
        try Update();
        try Draw();
    }

    rl.closeWindow();
}
