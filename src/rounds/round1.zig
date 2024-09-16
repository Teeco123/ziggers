const std = @import("std");
const Round = @import("index.zig").Round;
const Enemy = @import("../enemies/index.zig").Enemy;

const enemies = @import("../enemies/index.zig");

pub fn addRound() Round {
    var round1 = Round{
        .enemies = try std.BoundedArray(Enemy, 100).init(0),
    };

    try round1.enemies.append(enemies.enemy1);

    return round1;
}
