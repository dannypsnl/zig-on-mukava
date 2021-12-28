const std = @import("std");
const expect = std.testing.expect;

pub const VgaColor = enum(u8) { Black, Blue, Green, Cyan, Red, Magenta, Brown, LightGrey, DarkGrey, LightBlue, LightGreen, LightCyan, LightRed, LightMagenta, LightBrown, White };

fn vga_entry_color(fg: VgaColor, bg: VgaColor) u8 {
    return @enumToInt(fg) | (@enumToInt(bg) << 4);
}
fn vga_entry(uc: u8, color: u8) u16 {
    return uc | (@as(u16, color) << 8);
}

const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

pub const terminal = struct {
    var row: usize = 0;
    var column: usize = 0;

    var color = vga_entry_color(VgaColor.LightGrey, VgaColor.Black);

    const buffer = @intToPtr([*]volatile u16, 0xb8000);

    pub fn initialize() void {
        var y: usize = 0;
        while (y < VGA_HEIGHT) : (y += 1) {
            var x: usize = 0;
            while (x < VGA_WIDTH) : (x += 1) {
                putCharAt(' ', color, x, y);
            }
        }
    }

    pub fn setColor(fg: VgaColor, bg: VgaColor) void {
        color = vga_entry_color(fg, bg);
    }

    fn putCharAt(c: u8, new_color: u8, x: usize, y: usize) void {
        const index = y * VGA_WIDTH + x;
        buffer[index] = vga_entry(c, new_color);
    }

    fn putChar(c: u8) void {
        putCharAt(c, color, column, row);
        column += 1;
        if (column == VGA_WIDTH) {
            column = 0;
            row += 1;
            if (row == VGA_HEIGHT)
                row = 0;
        }
    }

    pub fn write(data: []const u8) void {
        for (data) |c|
            putChar(c);
    }
};

test "vga color" {
    // 0 | (1 << 4)
    try expect(vga_entry_color(VgaColor.Black, VgaColor.Blue) == 16);
}
