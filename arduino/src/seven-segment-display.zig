const arduino = @import("arduino");
const gpio = arduino.gpio;
const PinState = gpio.PinState;

// Necessary, and has the side effect of pulling in the needed _start method
pub const panic = arduino.start.panicLogUart;

const seven_seg_digits = [_][7]PinState{
    [_]PinState{ .high, .high, .high, .high, .high, .high, .low }, // = 0
    [_]PinState{ .low, .high, .high, .low, .low, .low, .low }, // = 1
    [_]PinState{ .high, .high, .low, .high, .high, .low, .high }, // = 2
    [_]PinState{ .high, .high, .high, .high, .low, .low, .high }, // = 3
    [_]PinState{ .low, .high, .high, .low, .low, .high, .high }, // = 4
    [_]PinState{ .high, .low, .high, .high, .low, .high, .high }, // = 5
    [_]PinState{ .high, .low, .high, .high, .high, .high, .high }, // = 6
    [_]PinState{ .high, .high, .high, .low, .low, .low, .low }, // = 7
    [_]PinState{ .high, .high, .high, .high, .high, .high, .high }, // = 8
    [_]PinState{ .high, .high, .high, .low, .low, .high, .high }, // = 9
};

fn evenSegWrite(digit: usize) void {
    comptime var pin = 2;
    comptime var seg = 0;
    inline while (seg < 7) : (seg += 1) {
        gpio.setPin(pin, seven_seg_digits[digit][seg]);
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
