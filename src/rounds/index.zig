const std = @import("std");
const Enemy = @import("../enemies/index.zig").Enemy;

pub const Round = struct {
    enemies: std.BoundedArray(Enemy, 100),
};

pub const round1 = @import("round1.zig").addRound();
