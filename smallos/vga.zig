const std = @import("std");
const expect = std.testing.expect;

const VgaColor = enum(u8) { Black, Blue, Green, Cyan, Red, Magenta, Brown, LightGrey, DarkGrey, LightBlue, LightGreen, LightCyan, LightRed, LightMagenta, LightBrown, White };
const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;

fn vga_entry_color(fg: VgaColor, bg: VgaColor) u8 {
    return @enumToInt(fg) | (@enumToInt(bg) << 4);
}
fn vga_entry(uc: u8, color: u8) u16 {
    return uc | (@as(u16, color) << 8);
}

test "vga color" {
    // 0 | (1 << 4)
    try expect(vga_entry_color(VgaColor.Black, VgaColor.Blue) == 16);
}
