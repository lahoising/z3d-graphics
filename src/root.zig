const std = @import("std");
const testing = std.testing;
const input = @import("windowing/input.zig");
const zglfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.wrapper;
const zgui = @import("zgui");

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

const DepthTestFn = Renderer.DepthTestFn;

pub fn Z3DG(comptime renderingBackend: Renderer.Backend) type {
    return struct {
        const Self = @This();
        var instance = create();

        mainWindow: Window(renderingBackend),

        pub fn init(self: *Self) !void {
            try zglfw.init();
            errdefer zglfw.terminate();

            zglfw.windowHint(zglfw.WindowHint.context_version_major, 4);
            zglfw.windowHint(zglfw.WindowHint.context_version_minor, 5);
            zglfw.windowHintTyped(zglfw.WindowHint.opengl_profile, zglfw.OpenGLProfile.opengl_core_profile);

            const windowHandle = try zglfw.Window.create(800, 600, "Title", null);

            zglfw.makeContextCurrent(windowHandle);

            switch (renderingBackend) {
                Renderer.Backend.OpenGL => {
                    zopengl.loadCoreProfile(glExtensionsLoader, 4, 5) catch return error.UnableToLoadGlExtensions;
                    gl.debugMessageCallback(debugMessageCallback, self);
                },
            }

            var window = Window(renderingBackend){
                .windowHandle = windowHandle,
            };
            errdefer window.close();

            self.mainWindow = window;

            const allocator = std.heap.page_allocator;
            zgui.init(allocator);
            zgui.backend.init(windowHandle);

            var rend = Renderer.create(renderingBackend);
            rend.setDepthTest(DepthTestFn.LESS);
        }

        pub fn terminate(self: *Self) void {
            self.mainWindow.close();
            zglfw.terminate();
        }

        pub fn pollEvents(_: *Self) void {
            zglfw.pollEvents();
        }

        pub fn createWindow(_: *Self, width: u16, height: u16, title: []const u8) !Window {
            const windowHandle = try zglfw.Window.create(width, height, title.ptr, null);
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
        fn glExtensionsLoader(ext: [:0]const u8) ?*const anyopaque {
            return zglfw.getProcAddress(ext);
        }

        fn debugMessageCallback(source: gl.DebugSource, msgType: gl.DebugType, id: c_uint, severity: gl.DebugSeverity, messageLength: u32, message: [*]const u8, _: ?*const anyopaque) void {
            std.debug.print("[{}] [{}] [{}] [{}] {s}\n", .{ source, msgType, id, severity, message[0..messageLength] });
        }

        fn glfw_error_callback(code: i32, description: [*c]const u8) callconv(.C) void {
            std.debug.print("GLFW error [{}]: {s}", .{ code, description });
        }
    };
}
