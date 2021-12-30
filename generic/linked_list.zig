fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,
        };
        first: ?*Node = null,
        last: ?*Node = null,
        len: usize = 0,

        pub fn init() LinkedList(T) {
            return LinkedList(T){};
        }
    };
}

test "linked list" {
    const std = @import("std");

    var lst = LinkedList(i64).init();
    std.debug.print("{}\n", .{lst});
}
