const gl = @import("zgl");
const renderer = @import("../renderer.zig");

const Renderer = renderer.Renderer;
const VertexBuffer = renderer.VertexBuffer;
const IndexBuffer = renderer.IndexBuffer;
const Shader = renderer.Shader;
const RenderWithPipelineCallback = renderer.Renderer.RenderWithPipelineCallback;
const ClearOptions = Renderer.ClearOptions;

pub const GlRenderer = struct {
    pub fn create() GlRenderer {
        return GlRenderer{};
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
        defer gl.useProgram(gl.Program.invalid);
        callback(@ptrCast(self), shader);
    }

    pub fn renderIndexedVertices(_: GlRenderer, comptime VertexType: type, vertexBuffer: VertexBuffer(VertexType), indexBuffer: IndexBuffer) void {
        gl.bindVertexArray(vertexBuffer.vertexArray);
        defer gl.bindVertexArray(gl.VertexArray.invalid);

        gl.bindBuffer(vertexBuffer.buffer, gl.BufferTarget.array_buffer);
        defer gl.bindBuffer(gl.Buffer.invalid, gl.BufferTarget.array_buffer);

        gl.bindBuffer(indexBuffer.buffer, gl.BufferTarget.element_array_buffer);
        defer gl.bindBuffer(gl.Buffer.invalid, gl.BufferTarget.element_array_buffer);

        gl.drawElements(gl.PrimitiveType.triangles, indexBuffer.indices.len, gl.ElementType.unsigned_byte, 0);
    }
};
