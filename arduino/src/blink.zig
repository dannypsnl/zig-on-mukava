const arduino = @import("arduino");
const gpio = arduino.gpio;

// Necessary, and has the side effect of pulling in the needed _start method
pub const panic = arduino.start.panicHang;

const LED: u8 = 13;

pub fn main() void {
    gpio.setMode(LED, .output);

    while (true) {
        gpio.setPin(LED, .high);

        arduino.cpu.delayMilliseconds(500);

        gpio.setPin(LED, .low);

        arduino.cpu.delayMilliseconds(500);
    }
}
