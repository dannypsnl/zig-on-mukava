const arduino = @import("arduino");
const gpio = arduino.gpio;

// Necessary, and has the side effect of pulling in the needed _start method
pub const panic = arduino.start.panicLogUart;

const seven_seg_digits = [_][7]u8{
    [_]u8{ 1, 1, 1, 1, 1, 1, 0 }, // = 0
    [_]u8{ 0, 1, 1, 0, 0, 0, 0 }, // = 1
    [_]u8{ 1, 1, 0, 1, 1, 0, 1 }, // = 2
    [_]u8{ 1, 1, 1, 1, 0, 0, 1 }, // = 3
    [_]u8{ 0, 1, 1, 0, 0, 1, 1 }, // = 4
    [_]u8{ 1, 0, 1, 1, 0, 1, 1 }, // = 5
    [_]u8{ 1, 0, 1, 1, 1, 1, 1 }, // = 6
    [_]u8{ 1, 1, 1, 0, 0, 0, 0 }, // = 7
    [_]u8{ 1, 1, 1, 1, 1, 1, 1 }, // = 8
    [_]u8{ 1, 1, 1, 0, 0, 1, 1 }, // = 9
};

fn evenSegWrite(digit: usize) void {
    comptime var pin = 2;
    comptime var seg = 0;
    inline while (seg < 7) : (seg += 1) {
        if (seven_seg_digits[digit][seg] == 1) {
            gpio.setPin(pin, .high);
        } else {
            gpio.setPin(pin, .low);
        }
        pin += 1;
    }
}

pub fn main() void {
    arduino.uart.init(arduino.cpu.CPU_FREQ, 115200);

    comptime var pin = 2;
    inline while (pin <= 9) : (pin += 1) {
        gpio.setMode(pin, .output);
    }

    var count: usize = 9;
    while (count >= 0) : (count -= 1) {
        evenSegWrite(count);
        arduino.cpu.delayMilliseconds(500);
        if (count == 0) {
            count = 9;
        }
    }
}
