const std = @import("std");
const rl = @import("raylib");
const Map = @import("index.zig").Map;

const Vector2 = rl.Vector2;

pub fn addMap() Map {
    var map2 = Map{
        .id = 1,
        .name = "Map2",
        .positions = 5,
        .cords = try std.BoundedArray(Vector2, 100).init(0),
        .turretCords = try std.BoundedArray(Vector2, 10).init(0),
    };

    try map2.cords.append(Vector2.init(0, 300));
    try map2.cords.append(Vector2.init(400, 300));
    try map2.cords.append(Vector2.init(400, 500));
    try map2.cords.append(Vector2.init(800, 500));
    try map2.cords.append(Vector2.init(800, 150));
    try map2.cords.append(Vector2.init(1280, 150));

    try map2.turretCords.append(Vector2.init(200, 230));

    return map2;
}
