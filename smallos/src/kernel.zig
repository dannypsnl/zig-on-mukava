const builtin = @import("std").builtin;
const vga = @import("./vga.zig");
const idt = @import("./idt.zig");
const terminal = vga.terminal;
const VgaColor = vga.VgaColor;

const MultiBoot = packed struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

export var stack_bytes: [16 * 1024]u8 align(16) linksection(".bss") = undefined;
const stack_bytes_slice = stack_bytes[0..];

fn init() void {
    idt.init();
}

export fn _start() callconv(.Naked) noreturn {
    terminal.initialize();

    init();
    @call(.{ .stack = stack_bytes_slice }, kmain, .{});

    while (true) {}
}

pub fn panic(msg: []const u8, _: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    terminal.write("KERNEL PANIC: ");
    terminal.write(msg);
    while (true) {}
}

fn kmain() void {
    terminal.write("Hello, ");
    terminal.setColor(VgaColor.Black, VgaColor.Red);
    terminal.write("Kernel");
    terminal.setColor(VgaColor.LightGrey, VgaColor.Black);
    terminal.write(" World!");
}
