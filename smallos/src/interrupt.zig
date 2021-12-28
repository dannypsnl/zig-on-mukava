const terminal = @import("./vga.zig").terminal;
const x64 = @import("x86_64");
const InterruptDescriptorTable = x64.structures.idt.InterruptDescriptorTable;
const InterruptStackFrame = x64.structures.idt.InterruptStackFrame;
const SegmentSelector = x64.structures.gdt.SegmentSelector;
const PrivilegeLevel = x64.PrivilegeLevel;

pub fn init_idt() void {
    var idt = InterruptDescriptorTable.init();
    idt.breakpoint.setHandler(breakpoint_handler, SegmentSelector.init(0, PrivilegeLevel.Ring0));
    idt.load();
}

fn breakpoint_handler(_: InterruptStackFrame) callconv(.Interrupt) void {
    terminal.write("EXCEPTION: BREAKPOINT\n");
}
