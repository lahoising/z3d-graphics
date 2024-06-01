const std = @import("std");
const graphics = @import("graphics");

const WindowManager = graphics.WindowManager;
const Window = graphics.Window;
const Key = graphics.Key;
const KeyModifier = graphics.KeyModifier;
const KeyAction = graphics.KeyAction;
const Renderer = graphics.Renderer;
const VertexBuffer = graphics.VertexBuffer;
const IndexBuffer = graphics.IndexBuffer;
const Shader = graphics.Shader;
const Mesh = graphics.Mesh;

const Vec3 = @Vector(3, f32);
const Vec4 = @Vector(4, f32);

const Vertex = packed struct {
    position: Vec3,
    color: Vec4,
};

pub const State = struct {
    running: bool,
    mesh: Mesh(Vertex),
    shader: Shader,
    clearColor: Vec4,

    pub fn destroy(self: *State) void {
        self.mesh.destroy();
        self.shader.destroy();
    }
};

var state = State{
    .running = false,
    .mesh = undefined,
    .shader = undefined,
    .clearColor = Vec4{ 0.0, 0.0, 0.0, 1.0 },
};

pub fn main() !void {
    try graphics.WindowManager.init();
    defer graphics.WindowManager.terminate();

    var window = WindowManager.createWindow(600, 480, "Hello World!", setup) catch |err| {
        std.debug.print("Failed to create window or setup resources: {}\n", .{err});
        return error.HelloWorldFailed;
    };
    defer window.close();
    defer state.destroy();

    state.running = true;
    while (state.running) {
        WindowManager.pollEvents();
        if (window.closeRequested()) {
            state.running = false;
        }

        window.renderFrame(render);
        window.swapBuffer();
    }
}

fn setup(window: *Window, _: Renderer) !void {
    try window.setKeyInputCallback(onKeyEvent);
    window.enableVSync(true);

    var data: [3]Vertex = [_]Vertex{
        .{
            .position = Vec3{ -1.0, -1.0, 0.0 },
            .color = Vec4{ 1.0, 0.0, 0.0, 1.0 },
        },
        .{
            .position = Vec3{ 1.0, -1.0, 0.0 },
            .color = Vec4{ 0.0, 1.0, 0.0, 1.0 },
        },
        .{
            .position = Vec3{ 0.0, 1.0, 0.0 },
            .color = Vec4{ 0.0, 0.0, 1.0, 1.0 },
        },
    };
    var vertexBuffer = try VertexBuffer(Vertex).create(&data);
    errdefer vertexBuffer.destroy();

    const shaderSourceRelativePath = "examples/resources/hello-world.shader";
    const shaderSourceAbsolutePath = try std.fs.cwd().realpath(shaderSourceRelativePath, undefined);
    state.shader = try Shader.create(shaderSourceAbsolutePath);
    errdefer state.shader.destroy();

    var indices = [_]u8{
        0, 1, 2,
    };
    var indexBuffer = IndexBuffer.create(&indices);
    errdefer indexBuffer.destroy();

    state.mesh = Mesh(Vertex).create(vertexBuffer, indexBuffer);
    errdefer state.mesh.destroy();
}

fn onKeyEvent(window: *Window, key: Key, modifier: KeyModifier, action: KeyAction) void {
    _ = window;
    std.debug.print("Key event: {{{}, {}, {}}}\n", .{ key, modifier, action });
    const escapePressed = key == Key.ESCAPE and action == KeyAction.PRESSED;
    if (escapePressed) {
        state.running = false;
    }

    if (action == KeyAction.PRESSED) {
        if (key == Key.Q) {
            state.clearColor[0] = @min(state.clearColor[0] + 0.1, 1.0);
        } else if (key == Key.A) {
            state.clearColor[0] = @max(state.clearColor[0] - 0.1, 0.0);
        } else if (key == Key.W) {
            state.clearColor[1] = @min(state.clearColor[1] + 0.1, 1.0);
        } else if (key == Key.S) {
            state.clearColor[1] = @max(state.clearColor[1] - 0.1, 0.0);
        } else if (key == Key.E) {
            state.clearColor[2] = @min(state.clearColor[2] + 0.1, 1.0);
        } else if (key == Key.D) {
            state.clearColor[2] = @max(state.clearColor[2] - 0.1, 0.0);
        }
    }
}

fn render(window: *Window, renderer: *Renderer) void {
    renderer.setClearColor(state.clearColor);
    const frameSize = window.getFrameSize();
    renderer.setViewport(0, 0, frameSize[0], frameSize[1]);
    renderer.clear(Renderer.ClearOptions.all());
    renderer.renderWithPipeline(state.shader, renderWithPipeline);
}

fn renderWithPipeline(renderer: *Renderer, shader: Shader) void {
    _ = shader;
    renderer.renderMesh(Vertex, state.mesh);
}
