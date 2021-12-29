const std = @import("std");
const pc_keyboard = @import("pc_keyboard");
const ScancodeSet2 = pc_keyboard.ScancodeSet.ScancodeSet2;
const HandleControl = pc_keyboard.HandleControl;
const KeyEvent = pc_keyboard.KeyEvent;

pub fn main() anyerror!void {
    std.log.info("pc_keyboard", .{});
    var keyboard = pc_keyboard.Keyboard.init(ScancodeSet2, pc_keyboard.KeyboardLayout.Us104Key, HandleControl.MapLettersToUnicode);
    var dk = keyboard.processKeyevent(KeyEvent{ .code = .Escape, .state = .Down });
    std.log.info("{}", .{dk});
}
