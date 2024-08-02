const std = @import("std");
const vertexBufferModule = @import("vertex-buffer.zig");
const indexBufferModule = @import("index-buffer.zig");
const shaderModule = @import("shader.zig");
const meshModule = @import("mesh.zig");

const glBackend = @import("opengl/renderer.zig");

pub const VertexBuffer = vertexBufferModule.VertexBuffer;
pub const IndexBuffer = indexBufferModule.IndexBuffer;
pub const Shader = shaderModule.Shader;
pub const UniformType = shaderModule.UniformType;
pub const Mesh = meshModule.Mesh;

const GlRenderer = glBackend.GlRenderer;

pub const Renderer = union(enum) {
    glRenderer: GlRenderer,

    pub const RenderWithPipelineCallback = fn (renderer: *Renderer, shader: Shader) void;

    pub const Backend = enum {
        OpenGL,
    };

    pub const ClearOptions = struct {
        color: bool,
        depth: bool,
        stencil: bool,

        pub fn all() ClearOptions {
            return .{ .color = true, .depth = true, .stencil = true };
        }
    };

    pub const DepthTestFn = enum {
        DISABLED,
        LESS,
    };

    pub fn create(comptime backend: Backend) Renderer {
        return switch (backend) {
            Backend.OpenGL => Renderer{
                .glRenderer = GlRenderer.create(),
            },
        };
    }

    pub fn setDepthTest(self: *Renderer, depthTest: DepthTestFn) void {
        switch (self.*) {
            inline else => |*instance| instance.setDepthTest(depthTest),
        }
    }

    pub fn setViewport(self: Renderer, x: i32, y: i32, width: u16, height: u16) void {
        switch (self) {
            inline else => |instance| instance.setViewport(x, y, width, height),
        }
    }

    pub fn setClearColor(self: *Renderer, color: @Vector(4, f32)) void {
        switch (self.*) {
            inline else => |*instance| instance.setClearColor(color),
        }
    }

    pub fn clear(self: Renderer, options: ClearOptions) void {
        switch (self) {
            inline else => |instance| instance.clear(options),
        }
    }

    pub fn renderWithPipeline(self: *Renderer, shader: Shader, callback: RenderWithPipelineCallback) void {
        switch (self.*) {
            inline else => |*instance| instance.renderWithPipeline(shader, callback),
        }
    }

    pub fn renderIndexedVertices(self: Renderer, comptime VertexType: type, vertexBuffer: VertexBuffer(VertexType), indexBuffer: IndexBuffer) void {
        switch (self) {
            inline else => |instance| instance.renderIndexedVertices(VertexType, vertexBuffer, indexBuffer),
        }
    }

    pub fn renderMesh(self: Renderer, comptime VertexType: type, mesh: Mesh(VertexType)) void {
        self.renderIndexedVertices(VertexType, mesh.vertexBuffer, mesh.indexBuffer);
    }
};
