const std = @import("std");

pub fn main() !void {
    var g = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = g.deinit();
    var map = std.StringHashMap(usize).init(g.allocator());
    defer map.deinit();
    _ = try map.put("abcdefghijklmnop", 0);
    _ = try map.put("fgmobeaijhdpkcln", 1);
    _ = try map.put("hjbagmnplkcfiedo", 2);
    _ = try map.put("chadeplfgojnmikb", 3);
    _ = try map.put("lgmknhfibepodacj", 4);
    std.debug.print("count {}\n", .{map.count()});

    std.debug.print("get {}\n", .{map.get("abcdefghijklmnop")});
}
