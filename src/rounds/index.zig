const std = @import("std");
const Enemy = @import("../enemies/index.zig").Enemy;

pub const Round = struct {
    enemies: std.BoundedArray(Enemy, 100),
};

const round1 = @import("round1.zig").addRound();
const round2 = @import("round2.zig").addRound();

pub const rounds = [_]Round{ round1, round2 };
