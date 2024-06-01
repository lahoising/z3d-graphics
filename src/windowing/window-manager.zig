const std = @import("std");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});
const gl = @import("zgl");

const input = @import("input.zig");
const Key = input.Key;
const KeyModifier = input.KeyModifier;
const KeyAction = input.KeyAction;
const Renderer = @import("../rendering/renderer.zig").Renderer;

pub const WindowManagerError = error{ InitError, UnableToCreateWindow, OutOfMemory, UnableToLoadGlExtensions, OnWindowCreatedFailed };

pub const OnWindowCreated = fn (*Window, Renderer) anyerror!void;

var backendWindowToWindow = std.AutoHashMap(*glfw.GLFWwindow, Window).init(std.heap.raw_c_allocator);
var hasLoadedGlExtensions = false;
var renderer: Renderer = undefined;

pub fn init() WindowManagerError!void {
    _ = glfw.glfwSetErrorCallback(glfw_error_callback);

    const initOutcome = glfw.glfwInit();
    if (initOutcome != 1) {
        std.debug.print("Window Manager failed to init. Error code: {d}\n", .{initOutcome});
        return error.InitError;
    }
    errdefer glfw.glfwTerminate();

    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 5);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);

    renderer = Renderer.create(Renderer.Backend.OpenGL);
}

pub fn pollEvents() void {
    glfw.glfwPollEvents();
}

pub fn terminate() void {
    backendWindowToWindow.clearAndFree();
    glfw.glfwTerminate();
}

pub fn createWindow(width: u16, height: u16, title: []const u8, onWindowCreated: OnWindowCreated) WindowManagerError!Window {
    const windowHandle = glfw.glfwCreateWindow(width, height, title.ptr, null, null) orelse return WindowManagerError.UnableToCreateWindow;

    glfw.glfwMakeContextCurrent(windowHandle);
    defer glfw.glfwMakeContextCurrent(null);
    loadGlExtensionsIfNeeded() catch return WindowManagerError.UnableToLoadGlExtensions;

    var window = Window{ .windowHandle = windowHandle, .keyInputCallback = null };
    errdefer window.close();
    try backendWindowToWindow.put(windowHandle, window);

    const windowPtr = backendWindowToWindow.getPtr(windowHandle).?;
    onWindowCreated(windowPtr, renderer) catch return WindowManagerError.OnWindowCreatedFailed;

    return window;
}

fn glfw_error_callback(code: i32, description: [*c]const u8) callconv(.C) void {
    std.debug.print("GLFW error [{}]: {s}", .{ code, description });
}

fn loadGlExtensionsIfNeeded() !void {
    if (hasLoadedGlExtensions) {
        return;
    }
    const unused: void = undefined;
    try gl.loadExtensions(unused, glExtensionsLoader);
    gl.debugMessageCallback(unused, debugMessageCallback);
    hasLoadedGlExtensions = true;
}

// Abstract this once we support other backends
fn glExtensionsLoader(_: void, ext: [:0]const u8) ?gl.binding.FunctionPointer {
    return glfw.glfwGetProcAddress(ext);
}

fn debugMessageCallback(source: gl.DebugSource, msgType: gl.DebugMessageType, id: usize, severity: gl.DebugSeverity, message: []const u8) void {
    std.debug.print("[{}] [{}] [{}] [{}] {s}\n", .{ source, msgType, id, severity, message });
}

pub const Window = struct {
    windowHandle: *glfw.GLFWwindow,
    keyInputCallback: ?*const KeyInputCallback,

    const KeyInputCallback = fn (*Window, Key, KeyModifier, KeyAction) void;
    const RenderFrameCallback = fn (*Window, *Renderer) void;

    pub fn close(self: Window) void {
        glfw.glfwDestroyWindow(self.windowHandle);
    }

    pub fn closeRequested(self: Window) bool {
        return glfw.glfwWindowShouldClose(self.windowHandle) != 0;
    }

    pub fn setKeyInputCallback(self: *Window, callback: *const KeyInputCallback) !void {
        self.keyInputCallback = callback;
        try backendWindowToWindow.put(self.windowHandle, self.*);
        _ = glfw.glfwSetKeyCallback(self.windowHandle, nativeKeyInputCallback);
    }

    fn nativeKeyInputCallback(window: ?*glfw.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.C) void {
        _ = scancode;
        if (window == null) {
            std.debug.print("no window found\n", .{});
            return;
        }
        const self = backendWindowToWindow.getPtr(window.?) orelse {
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

    pub fn renderFrame(self: *Window, callback: RenderFrameCallback) void {
        glfw.glfwMakeContextCurrent(self.windowHandle);
        defer glfw.glfwMakeContextCurrent(null);
        callback(self, &renderer);
    }

    pub fn getFrameSize(self: Window) std.meta.Tuple(&.{ u16, u16 }) {
        var width: c_int = 0;
        var height: c_int = 0;
        glfw.glfwGetFramebufferSize(self.windowHandle, &width, &height);
        return .{ @intCast(width), @intCast(height) };
    }

    pub fn swapBuffer(self: Window) void {
        glfw.glfwSwapBuffers(self.windowHandle);
    }

    pub fn enableVSync(self: Window, enable: bool) void {
        const originalContext = glfw.glfwGetCurrentContext();
        glfw.glfwMakeContextCurrent(self.windowHandle);

        const interval: c_int = if (enable) 1 else 0;
        glfw.glfwSwapInterval(interval);

        glfw.glfwMakeContextCurrent(originalContext);
    }
};
