const std = @import("std");

const Foo = struct {
    const Self = @This();
    fooFn: fn (self: *Self) i64,
    pub fn foo(self: *Self) i64 {
        return self.fooFn(self);
    }
};

const Bar = struct {
    r: std.rand.DefaultPrng,
    // implement the interface
    interface: Foo,

    fn init() Bar {
        return .{
            .r = std.rand.DefaultPrng.init(0),
            // point the interface function pointer to our function
            .interface = .{ .fooFn = foo },
        };
    }

    fn foo(iface: *Foo) i64 {
        const self = @fieldParentPtr(Bar, "interface", iface);
        return self.r.random().intRangeAtMost(i64, 10, 20);
    }
};

test "random fun" {
    var bar = Bar.init();
    var foo = &bar.interface;
    for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
        std.debug.print("{}\n", .{foo.foo()});
    }
}
