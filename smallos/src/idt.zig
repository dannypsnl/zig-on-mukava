const terminal = @import("./vga.zig").terminal;

const GateDesc = struct {
    func_offset_low_word: u16,
    selector: u16,
    dcount: u8,
    attribute: u8,
    func_offset_high_word: u16,
    pub fn missing() GateDesc {
        return .{
            .func_offset_low_word = 0,
            .selector = 0,
            .dcount = 0,
            .attribute = 0,
            .func_offset_high_word = 0,
        };
    }
    pub fn setHandler(self: *GateDesc, attr: u8, handler: HandlerFunc) void {
        const handler_ptr = @truncate(u32, @ptrToInt(&handler));
        // zig fmt: off
        self.* = .{
            .func_offset_low_word = @truncate(u16, handler_ptr & 0x0000FFFF),
            .selector = SELECTOR_K_CODE,
            .dcount = 0,
            .attribute = attr,
            .func_offset_high_word = @truncate(u16, (handler_ptr & 0xFFFF0000) >> 16)
        };
        // zig fmt: on
    }
};

const IDT_DESC_CNT = 0x21;
const IDT_DESC_P = 1;
const IDT_DESC_32_TYPE = 0xE;
const IDT_DESC_DPL0 = 0;
const IDT_DESC_ATTR_DPL0 = ((IDT_DESC_P << 7) + (IDT_DESC_DPL0 << 5) + IDT_DESC_32_TYPE);
const RPL0 = 0;
const TI_GDT = 0;
const SELECTOR_K_CODE = ((1 << 3) + (TI_GDT << 2) + RPL0);

var idt: [IDT_DESC_CNT]GateDesc = [_]GateDesc{
    GateDesc.missing(),
} ** IDT_DESC_CNT;

const InterruptStackFrame = extern struct {
    /// This value points to the instruction that should be executed when the interrupt
    /// handler returns. For most interrupts, this value points to the instruction immediately
    /// following the last executed instruction. However, for some exceptions (e.g., page faults),
    /// this value points to the faulting instruction, so that the instruction is restarted on
    /// return.
    instruction_pointer: u32,
    /// The code segment selector, padded with zeros.
    code_segment: u32,
    /// The flags register before the interrupt handler was invoked.
    cpu_flags: u32,
    /// The stack pointer at the time of the interrupt.
    stack_pointer: u32,
    /// The stack segment descriptor at the time of the interrupt (often zero in 64-bit mode).
    stack_segment: u32,
};
const HandlerFunc = fn (interrupt_stack_frame: InterruptStackFrame) callconv(.Interrupt) void;
const intr_entry_table: [IDT_DESC_CNT]HandlerFunc = [IDT_DESC_CNT]HandlerFunc{
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
    breakpoint_handler,
};

fn breakpoint_handler(_: InterruptStackFrame) callconv(.Interrupt) void {
    terminal.write("EXCEPTION: BREAKPOINT\n");
}

fn idt_desc_init() void {
    var i: usize = 0;
    while (i < IDT_DESC_CNT) {
        idt[i].setHandler(IDT_DESC_ATTR_DPL0, intr_entry_table[i]);
        i += 1;
    }
    terminal.write("IDT: idt_desc_init done\n");
}

fn outb(port: u16, data: u8) void {
    asm volatile ("outb %[data], %[port]"
        :
        : [data] "{al}" (data),
          [port] "N{dx}" (port),
    );
}
const PIC_M_CTRL = 0x20;
const PIC_M_DATA = 0x21;
const PIC_S_CTRL = 0xa0;
const PIC_S_DATA = 0xa1;
fn pic_init() void {
    // init main board
    outb(PIC_M_CTRL, 0x11);
    outb(PIC_M_DATA, 0x20);
    outb(PIC_M_DATA, 0x04);
    outb(PIC_M_DATA, 0x01);
    // init sub board
    outb(PIC_S_CTRL, 0x11);
    outb(PIC_S_DATA, 0x28);
    outb(PIC_S_DATA, 0x02);
    outb(PIC_S_DATA, 0x01);
    // open main board IR0
    outb(PIC_M_DATA, 0xfe);
    outb(PIC_S_DATA, 0xff);
    terminal.write("IDT: pic_init done\n");
}

pub fn init() void {
    terminal.write("IDT: interrupt descriptor table init\n");

    idt_desc_init();
    pic_init();
    const idt_operand: u64 = (@sizeOf(@TypeOf(idt)) - 1) | (@ptrToInt(&idt) << 16);
    asm volatile ("lidt (%[idt_operand])"
        :
        : [idt_operand] "r" (idt_operand),
        : "memory"
    );

    terminal.write("IDT: interrupt descriptor table init done\n");
}
