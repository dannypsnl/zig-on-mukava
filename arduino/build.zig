const std = @import("std");
const deps = @import("deps.zig");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const uno = std.zig.CrossTarget{
        .cpu_arch = .avr,
        .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
        .os_tag = .freestanding,
        .abi = .none,
    };

    const exe = b.addExecutable("arduino", "src/main.zig");
    deps.addAllTo(exe);
    exe.setTarget(uno);
    exe.setBuildMode(mode);
    exe.setBuildMode(.ReleaseSmall); // ReleaseSafe or Fast tend to unroll loops and seem to reorder volatile writes?
    exe.bundle_compiler_rt = false;
    exe.setLinkerScriptPath(.{ .path = deps.dirs._ie76bs50j4tl ++ "/src/linker.ld" });
    exe.install();

    const tty = b.option(
        []const u8,
        "tty",
        "Specify the port to which the Arduino is connected (defaults to /dev/ttyACM0)",
    ) orelse "/dev/ttyACM0";

    const bin_path = b.getInstallPath(exe.install_step.?.dest_dir, exe.out_filename);
    const upload = b.step("upload", "Upload the code to an Arduino device using avrdude");
    const avrdude = b.addSystemCommand(&.{
        "avrdude",
        "-carduino",
        "-patmega328p",
        "-D",
        "-P",
        tty,
        "-Uflash:w:",
        bin_path,
        ":e",
    });
    upload.dependOn(&avrdude.step);
    avrdude.step.dependOn(&exe.install_step.?.step);

    const monitor = b.step("monitor", "Opens a monitor to the serial output");
    const screen = b.addSystemCommand(&.{
        "screen",
        tty,
        "115200",
    });
    monitor.dependOn(&screen.step);
}
