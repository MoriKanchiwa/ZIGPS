const std = @import("std");

pub const TestEnum = enum {
    debug,
    info,
    warn,
    error
};

pub fn main() !void {
    std.debug.print("Test enum works: {}\n", .{TestEnum.debug});
} 