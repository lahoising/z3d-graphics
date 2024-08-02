const zopengl = @import("zopengl");
const renderer = @import("../renderer.zig");
const gl = zopengl.wrapper;

const Renderer = renderer.Renderer;
const VertexBuffer = renderer.VertexBuffer;
const IndexBuffer = renderer.IndexBuffer;
const Shader = renderer.Shader;
const RenderWithPipelineCallback = renderer.Renderer.RenderWithPipelineCallback;
const ClearOptions = Renderer.ClearOptions;
const DepthTestFn = Renderer.DepthTestFn;

pub const GlRenderer = struct {
    pub fn create() GlRenderer {
        return GlRenderer{};
    }

    pub fn setDepthTest(_: *GlRenderer, depthTest: DepthTestFn) void {
        switch (depthTest) {
            DepthTestFn.DISABLED => gl.disable(gl.Capability.depth_test),
            DepthTestFn.LESS => {
                gl.enable(gl.Capability.depth_test);
                gl.depthFunc(gl.Func.less);
            },
        }
    }

    pub fn setViewport(_: GlRenderer, x: i32, y: i32, width: u16, height: u16) void {
        gl.viewport(x, y, width, height);
    }

    pub fn setClearColor(_: *GlRenderer, color: @Vector(4, f32)) void {
        gl.clearColor(color[0], color[1], color[2], color[3]);
    }

    pub fn clear(_: GlRenderer, options: ClearOptions) void {
        gl.clear(.{
            .color = options.color,
            .depth = options.depth,
            .stencil = options.stencil,
        });
    }

    pub fn renderWithPipeline(self: *GlRenderer, shader: Shader, callback: RenderWithPipelineCallback) void {
        gl.useProgram(shader.program);
        defer gl.useProgram(gl.Program{ .name = 0 });
        callback(@ptrCast(self), shader);
    }

    pub fn renderIndexedVertices(_: GlRenderer, comptime VertexType: type, vertexBuffer: VertexBuffer(VertexType), indexBuffer: IndexBuffer) void {
        gl.bindVertexArray(vertexBuffer.vertexArray);
        defer gl.bindVertexArray(gl.VertexArrayObject{ .name = 0 });

        gl.bindBuffer(gl.BufferTarget.array_buffer, vertexBuffer.buffer);
        defer gl.bindBuffer(gl.BufferTarget.array_buffer, gl.Buffer{ .name = 0 });

        gl.bindBuffer(gl.BufferTarget.element_array_buffer, indexBuffer.buffer);
        defer gl.bindBuffer(gl.BufferTarget.element_array_buffer, gl.Buffer{ .name = 0 });

        zopengl.bindings.drawElements(gl.TRIANGLES, @intCast(indexBuffer.indices.len), gl.UNSIGNED_INT, null);
    }
};
