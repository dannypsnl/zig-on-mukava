const std = @import("std");
const c = @cImport({
    @cInclude("vte/vte.h");
});

const max_input_size: usize = 0x10000;

fn child_ready(terminal: [*c]c.VteTerminal, pid: c.GPid, _: [*c]c.GError, _: c.gpointer) callconv(.C) void {
    if (terminal != null) return;
    if (pid == -1) c.gtk_main_quit();
}

pub fn main() anyerror!void {
    c.gtk_init(0, @intToPtr([*c][*c][*c]u8, 0));

    var terminal = c.vte_terminal_new();
    var window = c.gtk_window_new(c.GTK_WINDOW_TOPLEVEL);
    c.gtk_window_set_title(@ptrCast([*c]c.GtkWindow, window), "zig-term");

    c.vte_terminal_spawn_async(
        @ptrCast([*c]c.VteTerminal, terminal),
        c.VTE_PTY_DEFAULT,
        null,
        null,
        null,
        0,
        null,
        null,
        null,
        -1,
        null,
        child_ready,
        null,
    );
    //c.g_signal_connect(window, "delete-event", c.gtk_main_quit, null);
    //c.g_signal_connect(terminal, "child-exited", c.gtk_main_quit, null);

    c.gtk_container_add(@ptrCast([*c]c.GtkContainer, window), terminal);
    c.gtk_widget_show_all(window);
    c.gtk_main();
}
