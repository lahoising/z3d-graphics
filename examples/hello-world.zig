const std = @import("std");
const graphics = @import("z3d-graphics");

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
const UniformType = graphics.UniformType;

const Vec3 = @Vector(3, f32);
const Vec4 = @Vector(4, f32);

const Vertex = packed struct {
    position: Vec3,
    color: Vec4,
};

const Mat4x4 = struct {
    const Data = [4]Vec4;

    data: Data,

    pub fn identity() Mat4x4 {
        var data: Data = .{
            @splat(0.0),
            @splat(0.0),
            @splat(0.0),
            @splat(0.0),
        };
        data[0][0] = 1.0;
        data[1][1] = 1.0;
        data[2][2] = 1.0;
        data[3][3] = 1.0;
        return Mat4x4{ .data = data };
    }

    pub fn translate(self: Mat4x4, translation: Vec3) Mat4x4 {
        var translationMatrix = Mat4x4.identity();
        translationMatrix.data[3] += Vec4{ translation[0], translation[1], translation[2], 0.0 };
        return translationMatrix.multiply(self);
    }

    pub fn rotate(self: Mat4x4, rotation: Quat) Mat4x4 {
        return rotation.asMat4x4().multiply(self);
    }

    pub fn multiply(self: Mat4x4, other: Mat4x4) Mat4x4 {
        var selfRows: Data = undefined;

        for (0..4) |i| {
            for (0..4) |j| {
                selfRows[j][i] = self.data[i][j];
            }
        }

        var data: Data = undefined;
        for (0..4) |i| {
            for (0..4) |j| {
                data[j][i] = @reduce(std.builtin.ReduceOp.Add, selfRows[i] * other.data[j]);
            }
        }

        return Mat4x4{ .data = data };
    }

    pub fn print(self: Mat4x4) void {
        for (self.data) |col| {
            std.debug.print("{}\n", .{col});
        }
    }
};

fn vec3Cross(a: Vec3, b: Vec3) Vec3 {
    return Vec3{
        a[1] * b[2] - a[2] * b[1],
        -(a[0] * b[2] - a[2] * b[0]),
        a[0] * b[1] - a[1] * b[0],
    };
}

fn vec3Dot(a: Vec3, b: Vec3) f32 {
    return @reduce(std.builtin.ReduceOp.Add, a * b);
}

fn vec3Scale(a: Vec3, scale: f32) Vec3 {
    return Vec3{ scale * a[0], scale * a[1], scale * a[2] };
}

const Quat = struct {
    w: f32,
    xyz: Vec3,

    pub fn unit() Quat {
        return Quat{
            .w = 1.0,
            .xyz = Vec3{ 0.0, 0.0, 0.0 },
        };
    }

    pub fn rotationAroundX(radians: f32) Quat {
        const halfRadians = radians / 2.0;
        return Quat{
            .w = @cos(halfRadians),
            .xyz = Vec3{ @sin(halfRadians), 0.0, 0.0 },
        };
    }

    pub fn rotationAroundY(radians: f32) Quat {
        const halfRadians = radians / 2.0;
        return Quat{
            .w = @cos(halfRadians),
            .xyz = Vec3{ 0.0, @sin(halfRadians), 0.0 },
        };
    }

    pub fn rotationAroundZ(radians: f32) Quat {
        const halfRadians = radians / 2.0;
        return Quat{
            .w = @cos(halfRadians),
            .xyz = Vec3{ 0.0, 0.0, @sin(halfRadians) },
        };
    }

    pub fn multiply(self: Quat, other: Quat) Quat {
        return Quat{
            .w = self.w * other.w - vec3Dot(self.xyz, other.xyz),
            .xyz = vec3Scale(other.xyz, self.w) + vec3Scale(self.xyz, other.w) + vec3Cross(self.xyz, other.xyz),
        };
    }

    pub fn asMat4x4(self: Quat) Mat4x4 {
        const qxx = self.xyz[0] * self.xyz[0];
        const qyy = self.xyz[1] * self.xyz[1];
        const qzz = self.xyz[2] * self.xyz[2];
        const qxz = self.xyz[0] * self.xyz[2];
        const qxy = self.xyz[0] * self.xyz[1];
        const qyz = self.xyz[1] * self.xyz[2];
        const qwx = self.w * self.xyz[0];
        const qwy = self.w * self.xyz[1];
        const qwz = self.w * self.xyz[2];

        return Mat4x4{
            .data = .{
                Vec4{ 1 - 2 * (qyy + qzz), 2 * (qxy + qwz), 2 * (qxz - qwy), 0.0 },
                Vec4{ 2 * (qxy - qwz), 1 - 2 * (qxx + qzz), 2 * (qyz + qwx), 0.0 },
                Vec4{ 2 * (qxz + qwy), 2 * (qyz - qwx), 1 - 2 * (qxx + qyy), 0.0 },
                Vec4{ 0.0, 0.0, 0.0, 1.0 },
            },
        };
    }
};

pub const State = struct {
    running: bool,
    mesh: Mesh(Vertex),
    shader: Shader,
    clearColor: Vec4,
    position: Vec3,
    rotation: Quat,

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
    .position = Vec3{ 0.0, 0.0, 0.0 },
    .rotation = Quat.rotationAroundZ(std.math.pi / 4.0),
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

    Mat4x4.identity()
        .rotate(state.rotation)
        .translate(state.position)
        .print();

    state.running = true;
    while (state.running) {
        WindowManager.pollEvents();
        if (window.closeRequested()) {
            state.running = false;
        }
        update();

        window.renderFrame(render);
        window.swapBuffer();
    }
}

fn setup(window: *Window, _: Renderer) !void {
    try window.setKeyInputCallback(onKeyEvent);
    window.enableVSync(true);

    var data: [3]Vertex = [_]Vertex{
        .{
            .position = Vec3{ -0.5, -0.5, 0.0 },
            .color = Vec4{ 1.0, 0.0, 0.0, 1.0 },
        },
        .{
            .position = Vec3{ 0.5, -0.5, 0.0 },
            .color = Vec4{ 0.0, 1.0, 0.0, 1.0 },
        },
        .{
            .position = Vec3{ 0.0, 0.5, 0.0 },
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

fn onKeyEvent(_: *Window, key: Key, _: KeyModifier, action: KeyAction) void {
    const escapePressed = key == Key.ESCAPE and action == KeyAction.PRESSED;
    if (escapePressed) {
        state.running = false;
    }

    const speed: f32 = 0.1;
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
        } else if (key == Key.UP) {
            state.position[1] += speed;
        } else if (key == Key.DOWN) {
            state.position[1] -= speed;
        } else if (key == Key.RIGHT) {
            state.position[0] += speed;
        } else if (key == Key.LEFT) {
            state.position[0] -= speed;
        }
    }
}

fn update() void {
    const rotationalSpeed: f32 = std.math.pi / 120.0;
    state.rotation = Quat.rotationAroundZ(rotationalSpeed).multiply(state.rotation);
}

fn render(window: *Window, renderer: *Renderer) void {
    renderer.setClearColor(state.clearColor);
    const frameSize = window.getFrameSize();
    renderer.setViewport(0, 0, frameSize[0], frameSize[1]);
    renderer.clear(Renderer.ClearOptions.all());
    renderer.renderWithPipeline(state.shader, renderWithPipeline);
}

fn renderWithPipeline(renderer: *Renderer, shader: Shader) void {
    const transform = Mat4x4.identity()
        .rotate(state.rotation)
        .translate(state.position);
    shader.setUniform(UniformType.MAT4, "transform", transform.data);
    renderer.renderMesh(Vertex, state.mesh);
}
