const std = @import("std");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});

const input = @import("input.zig");
const Key = input.Key;
const KeyModifier = input.KeyModifier;
const KeyAction = input.KeyAction;

pub const WindowManagerError = error{ InitError, UnableToCreateWindow, OutOfMemory };

var backendWindowToWindow = std.AutoHashMap(*glfw.GLFWwindow, *Window).init(std.heap.raw_c_allocator);

pub fn init() WindowManagerError!void {
    _ = glfw.glfwSetErrorCallback(glfw_error_callback);

    const initOutcome = glfw.glfwInit();
    if (initOutcome != 1) {
        std.debug.print("Window Manager failed to init. Error code: {d}\n", .{initOutcome});
        return error.InitError;
    }

    errdefer glfw.glfwTerminate();
}

pub fn pollEvents() void {
    glfw.glfwPollEvents();
}

pub fn terminate() void {
    backendWindowToWindow.clearAndFree();
    glfw.glfwTerminate();
}

pub fn createWindow(width: u16, height: u16, title: []const u8) WindowManagerError!Window {
    const windowHandle = glfw.glfwCreateWindow(width, height, title.ptr, null, null) orelse return WindowManagerError.UnableToCreateWindow;
    return Window{ .windowHandle = windowHandle, .keyInputCallback = null };
}

fn glfw_error_callback(code: i32, description: [*c]const u8) callconv(.C) void {
    std.debug.print("GLFW error [{}]: {s}", .{ code, description });
}

pub const Window = struct {
    windowHandle: *glfw.GLFWwindow,
    keyInputCallback: ?*const KeyInputCallback,

    const KeyInputCallback = fn (*Window, Key, KeyModifier, KeyAction) void;

    pub fn close(self: Window) void {
        glfw.glfwDestroyWindow(self.windowHandle);
    }

    pub fn closeRequested(self: Window) bool {
        return glfw.glfwWindowShouldClose(self.windowHandle) != 0;
    }

    pub fn setKeyInputCallback(self: *Window, callback: *const KeyInputCallback) !void {
        self.keyInputCallback = callback;
        try backendWindowToWindow.put(self.windowHandle, self);
        _ = glfw.glfwSetKeyCallback(self.windowHandle, nativeKeyInputCallback);
    }

    pub fn nativeKeyInputCallback(window: ?*glfw.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.C) void {
        _ = scancode;
        if (window == null) {
            std.debug.print("no window found\n", .{});
            return;
        }
        const self = backendWindowToWindow.get(window.?) orelse {
            std.debug.print("no window mapped\n", .{});
            return;
        };
        const convertedKey = input.convertBackendKeyToKey(key);
        const convertedAction = input.convertBackendKeyActionToKeyAction(action);
        const convertedMod = input.convertBackendKeyModifierToKeyModifier(mods);
        if (self.keyInputCallback) |keyInputCallback| {
            keyInputCallback(self, convertedKey, convertedMod, convertedAction);
        } else {
            std.debug.print("no fn found\n", .{});
        }
    }
};
