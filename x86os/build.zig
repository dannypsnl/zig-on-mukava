const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;
const CrossTarget = std.zig.CrossTarget;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const target = CrossTarget{
        .cpu_arch = std.Target.Cpu.Arch.i386,
        .os_tag = std.Target.Os.Tag.freestanding,
        .abi = std.Target.Abi.none,
    };

    const exe = b.addExecutable("kernel.bin", "src/kernel.zig");
    exe.setBuildMode(mode);
    exe.setTarget(target);
    exe.setLinkerScriptPath(.{ .path = "./linker.ld" });
    exe.install();

    const run_step = b.step("run", "Run up kernel");
    run_step.dependOn(&exe.step);
    const cmd = b.addSystemCommand(&[_][]const u8{ "qemu-system-i386", "-kernel" });
    cmd.addArtifactArg(exe);
    run_step.dependOn(&cmd.step);

    const test_step = b.step("test", "Test the program");
    if (!isRunnableTarget(target)) {
        const exe_tests = b.addTest("src/vga.zig");
        exe_tests.setTarget(b.standardTargetOptions(.{}));
        exe_tests.setBuildMode(mode);
        test_step.dependOn(&exe_tests.step);
    }
}

fn isRunnableTarget(t: CrossTarget) bool {
    if (t.isNative()) return true;

    return (t.getOsTag() == builtin.os.tag and
        t.getCpuArch() == builtin.cpu.arch);
}
