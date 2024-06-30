const std = @import("std");
const zglfw = @import("zglfw");

const input = @import("input.zig");
const Key = input.Key;
const KeyModifier = input.KeyModifier;
const KeyAction = input.KeyAction;
const Renderer = @import("../rendering/renderer.zig").Renderer;

pub fn Window(comptime renderingBackend: Renderer.Backend) type {
    return struct {
        const Self = @This();
        windowHandle: *zglfw.Window,

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
            self.windowHandle.destroy();
        }

        pub fn closeRequested(self: Self) bool {
            return self.windowHandle.shouldClose();
        }

        pub fn setKeyInputCallback(self: *Self, callback: KeyInputCallback) !void {
            self.windowHandle.setUserPointer(self);
            const Handler = struct {
                fn onKeyInput(window: *zglfw.Window, key: zglfw.Key, scancode: i32, action: zglfw.Action, mods: zglfw.Mods) callconv(.C) void {
                    _ = scancode;
                    const convertedKey = input.convertBackendKeyToKey(key);
                    const convertedAction = input.convertBackendKeyActionToKeyAction(action);
                    const convertedMod = input.convertBackendKeyModifierToKeyModifier(mods);
                    const abstractedWindow = window.getUserPointer(Self).?;
                    callback(abstractedWindow, convertedKey, convertedMod, convertedAction);
                }
            };
            _ = self.windowHandle.setKeyCallback(Handler.onKeyInput);
        }

        pub fn renderFrame(self: *Self, context: anytype, comptime callback: RenderFrameCallback(@TypeOf(context))) void {
            zglfw.makeContextCurrent(self.windowHandle);

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

            zglfw.makeContextCurrent(self.windowHandle);

            if (Context == void) {
                try callback(self);
            } else {
                try callback(context, self);
            }
        }

        pub fn getFrameSize(self: Self) std.meta.Tuple(&.{ u16, u16 }) {
            const size = self.windowHandle.getFramebufferSize();
            return .{ @intCast(size[0]), @intCast(size[1]) };
        }

        pub fn swapBuffer(self: Self) void {
            self.windowHandle.swapBuffers();
        }

        pub fn enableVSync(self: Self, enable: bool) void {
            const originalContext = zglfw.getCurrentContext();
            zglfw.makeContextCurrent(self.windowHandle);

            const interval: i32 = if (enable) 1 else 0;
            zglfw.swapInterval(interval);

            zglfw.makeContextCurrent(originalContext);
        }
    };
}
