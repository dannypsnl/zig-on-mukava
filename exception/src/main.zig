const std = @import("std");

pub fn main() anyerror!void {
    std.log.info("throw some thing", .{});
    try throw();
}

const MyError = error{HelloError};
fn throw() MyError!void {
    return MyError.HelloError;
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
