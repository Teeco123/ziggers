const std = @import("std");
const rl = @import("raylib");
const Map = @import("index.zig").Map;

const Vector2 = rl.Vector2;

pub fn addMap() Map {
    var map1 = Map{
        .id = 0,
        .name = "Map1",
        .positions = 5,
        .cords = try std.BoundedArray(Vector2, 100).init(0),
        .turretCords = try std.BoundedArray(Vector2, 10).init(0),
    };

    try map1.cords.append(Vector2.init(0, 300));
    try map1.cords.append(Vector2.init(400, 300));
    try map1.cords.append(Vector2.init(400, 500));
    try map1.cords.append(Vector2.init(800, 500));
    try map1.cords.append(Vector2.init(800, 150));
    try map1.cords.append(Vector2.init(1280, 150));

    try map1.turretCords.append(Vector2.init(200, 230));

    return map1;
}
