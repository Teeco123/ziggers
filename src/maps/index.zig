const std = @import("std");
const rl = @import("raylib");

const Vector2 = rl.Vector2;

pub const Map = struct {
    id: usize,
    name: [*:0]const u8,
    positions: u8,
    cords: std.BoundedArray(Vector2, 100),
    turretCords: std.BoundedArray(Vector2, 10),
};

pub const map1 = @import("map1.zig").addMap();
pub const map2 = @import("map2.zig").addMap();
