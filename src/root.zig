const std = @import("std");
const testing = std.testing;
const input = @import("windowing/input.zig");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});
const gl = @import("zgl");
pub const rendering = @import("rendering/renderer.zig");
pub const windows = @import("windowing/windows.zig");
pub const Window = windows.Window;
pub const Key = input.Key;
pub const KeyModifier = input.KeyModifier;
pub const KeyAction = input.KeyAction;
pub const Renderer = rendering.Renderer;
pub const VertexBuffer = rendering.VertexBuffer;
pub const IndexBuffer = rendering.IndexBuffer;
pub const Shader = rendering.Shader;
pub const Mesh = rendering.Mesh;
pub const UniformType = rendering.UniformType;

pub fn Z3DG(comptime renderingBackend: Renderer.Backend) type {
    return struct {
        const Self = @This();
        var instance = create();

        mainWindow: Window(renderingBackend),

        pub fn init(self: *Self) !void {
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

            const windowHandle = glfw.glfwCreateWindow(800, 600, "Title", null, null) orelse return error.UnableToCreateWindow;

            glfw.glfwMakeContextCurrent(windowHandle);
            defer glfw.glfwMakeContextCurrent(null);

            switch (renderingBackend) {
                Renderer.Backend.OpenGL => {
                    gl.loadExtensions(self, glExtensionsLoader) catch return error.UnableToLoadGlExtensions;
                    gl.debugMessageCallback(self, debugMessageCallback);
                },
            }

            var window = Window(renderingBackend){
                .windowHandle = windowHandle,
            };
            errdefer window.close();

            self.mainWindow = window;
        }

        pub fn terminate(self: *Self) void {
            self.mainWindow.close();
            glfw.glfwTerminate();
        }

        pub fn pollEvents(_: *Self) void {
            glfw.glfwPollEvents();
        }

        pub fn createWindow(_: *Self, width: u16, height: u16, title: []const u8) !Window {
            const windowHandle = glfw.glfwCreateWindow(width, height, title.ptr, null, null) orelse return error.UnableToCreateWindow;
            var window = Window{
                .windowHandle = windowHandle,
            };
            errdefer window.close();

            return window;
        }

        fn create() Self {
            return Self{
                .mainWindow = undefined,
            };
        }

        pub fn mutSingleton() *Self {
            return &instance;
        }

        pub fn singleton() Self {
            return instance;
        }

        // Abstract this once we support other backends
        fn glExtensionsLoader(_: *Self, ext: [:0]const u8) ?gl.binding.FunctionPointer {
            return glfw.glfwGetProcAddress(ext);
        }

        fn debugMessageCallback(_: *Self, source: gl.DebugSource, msgType: gl.DebugMessageType, id: usize, severity: gl.DebugSeverity, message: []const u8) void {
            std.debug.print("[{}] [{}] [{}] [{}] {s}\n", .{ source, msgType, id, severity, message });
        }

        fn glfw_error_callback(code: i32, description: [*c]const u8) callconv(.C) void {
            std.debug.print("GLFW error [{}]: {s}", .{ code, description });
        }
    };
}
