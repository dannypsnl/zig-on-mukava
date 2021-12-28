const std = @import("std");
const print = std.debug.print;

const Tag = enum(u3) { VOID, INT, BOOLEAN, CLOSURE, ENV };
const Env = struct { t: Tag, env: ?[*]Value };
const Lambda = fn ([*]Value) *Value;
const Value = union {
    int: struct { t: Tag, value: i61 },
    bool: struct { t: Tag, value: bool },
    closure: struct { t: Tag, lam: Lambda, env: ?[*]Value },
    env: Env,
};
fn make_closure(lam: Lambda, env: Value) Value {
    return Value{ .closure = .{
        .t = Tag.CLOSURE,
        .lam = lam,
        .env = env.env.env,
    } };
}
fn make_int(n: i61) Value {
    return Value{ .int = .{ .t = Tag.INT, .value = n } };
}
fn make_bool(b: bool) Value {
    return Value{ .bool = .{ .t = Tag.BOOLEAN, .value = b } };
}
fn make_primitive(prim: Lambda) Value {
    return Value{ .closure = .{ .t = Tag.CLOSURE, .lam = prim, .env = null } };
}
fn make_env(env: ?[*]Value) Value {
    return Value{ .env = .{
        .t = Tag.ENV,
        .env = env,
    } };
}

fn prim_sum(e: [*]Value) *Value {
    return &make_int(e[0].int.value + e[1].int.value);
}

pub fn main() void {
    print("int(1) = {}\n", .{make_int(1).int});
    print("bool(true) = {}\n", .{make_bool(true).bool});
    print("prim(sum) = {}\n", .{make_primitive(prim_sum).closure});
}
