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

fn count_down() void {
    comptime var count = 9;
    inline while (count >= 0) : (count -= 1) {
        evenSegWrite(count);
        arduino.cpu.delayMilliseconds(500);
    }
}

pub fn main() void {
    arduino.uart.init(arduino.cpu.CPU_FREQ, 115200);

    gpio.setMode(2, .output);
    gpio.setMode(3, .output);
    gpio.setMode(4, .output);
    gpio.setMode(5, .output);
    gpio.setMode(6, .output);
    gpio.setMode(7, .output);
    gpio.setMode(8, .output);
    gpio.setMode(9, .output);

    while (true) {
        count_down();
    }
}
