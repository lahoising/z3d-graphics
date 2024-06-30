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

pub fn Window(comptime renderingBackend: Renderer.Backend) type {
    return struct {
        const Self = @This();
        windowHandle: *glfw.GLFWwindow,

        const KeyInputCallback = fn (*Self, Key, KeyModifier, KeyAction) void;
        fn RenderFrameCallback(comptime Context: type) type {
            return if (Context == void) {
                return fn (window: *Self, renderer: *Renderer) void;
            } else {
                return fn (context: Context, window: *Self, renderer: *Renderer) void;
            };
        }

        fn ProcessCallback(comptime Context: type) type {
            return if (Context == void) {
                return fn (window: *Self) anyerror!void;
            } else {
                return fn (context: Context, window: *Self) anyerror!void;
            };
        }

        pub fn close(self: Self) void {
            glfw.glfwDestroyWindow(self.windowHandle);
        }

        pub fn closeRequested(self: Self) bool {
            return glfw.glfwWindowShouldClose(self.windowHandle) != 0;
        }

        pub fn setKeyInputCallback(self: *Self, callback: KeyInputCallback) !void {
            glfw.glfwSetWindowUserPointer(self.windowHandle, self);
            const Handler = struct {
                fn onKeyInput(window: ?*glfw.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) callconv(.C) void {
                    _ = scancode;
                    if (window == null) {
                        std.debug.print("no window found\n", .{});
                        return;
                    }
                    const convertedKey = input.convertBackendKeyToKey(key);
                    const convertedAction = input.convertBackendKeyActionToKeyAction(action);
                    const convertedMod = input.convertBackendKeyModifierToKeyModifier(mods);
                    const abstractedWindow = @as(*Self, @ptrFromInt(@intFromPtr(glfw.glfwGetWindowUserPointer(window).?)));
                    callback(abstractedWindow, convertedKey, convertedMod, convertedAction);
                }
            };
            _ = glfw.glfwSetKeyCallback(self.windowHandle, Handler.onKeyInput);
        }

        pub fn renderFrame(self: *Self, context: anytype, comptime callback: RenderFrameCallback(@TypeOf(context))) void {
            glfw.glfwMakeContextCurrent(self.windowHandle);
            defer glfw.glfwMakeContextCurrent(null);

            var renderer = Renderer.create(renderingBackend);
            const Context = @TypeOf(context);
            if (Context == void) {
                callback(self, &renderer);
            } else {
                callback(context, self, &renderer);
            }
        }

        pub fn process(self: *Self, context: anytype, comptime callback: ProcessCallback(@TypeOf(context))) !void {
            const Context = @TypeOf(context);

            glfw.glfwMakeContextCurrent(self.windowHandle);
            defer glfw.glfwMakeContextCurrent(null);

            if (Context == void) {
                try callback(self);
            } else {
                try callback(context, self);
            }
        }

        pub fn getFrameSize(self: Self) std.meta.Tuple(&.{ u16, u16 }) {
            var width: c_int = 0;
            var height: c_int = 0;
            glfw.glfwGetFramebufferSize(self.windowHandle, &width, &height);
            return .{ @intCast(width), @intCast(height) };
        }

        pub fn swapBuffer(self: Self) void {
            glfw.glfwSwapBuffers(self.windowHandle);
        }

        pub fn enableVSync(self: Self, enable: bool) void {
            const originalContext = glfw.glfwGetCurrentContext();
            glfw.glfwMakeContextCurrent(self.windowHandle);

            const interval: c_int = if (enable) 1 else 0;
            glfw.glfwSwapInterval(interval);

            glfw.glfwMakeContextCurrent(originalContext);
        }
    };
}
