const std = @import("std");
const graphics = @import("graphics");

const WindowManager = graphics.WindowManager;
const Window = graphics.Window;
const Key = graphics.Key;
const KeyModifier = graphics.KeyModifier;
const KeyAction = graphics.KeyAction;

pub const State = struct {
    running: bool,
};

var state = State{ .running = false };

pub fn main() !void {
    try graphics.WindowManager.init();
    errdefer graphics.WindowManager.terminate();
    defer graphics.WindowManager.terminate();

    var window = WindowManager.createWindow(600, 480, "Hello World!") catch {
        std.debug.print("Failed to create window", .{});
        return error.HelloWorldFailed;
    };
    defer window.close();
    try window.setKeyInputCallback(onKeyEvent);

    state.running = true;
    while (state.running) {
        WindowManager.pollEvents();
        if (window.closeRequested()) {
            state.running = false;
        }
    }
}

fn onKeyEvent(window: *Window, key: Key, modifier: KeyModifier, action: KeyAction) void {
    _ = window;
    std.debug.print("Key event: {{{}, {}, {}}}\n", .{ key, modifier, action });
    const escapePressed = key == Key.ESCAPE and action == KeyAction.PRESSED;
    if (escapePressed) {
        state.running = false;
    }
}
