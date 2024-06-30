const zopengl = @import("zopengl");
const gl = zopengl.wrapper;

pub const IndexBuffer = struct {
    indices: []u8,
    buffer: gl.Buffer,

    pub fn create(indices: []u8) IndexBuffer {
        var buffer: gl.Buffer = undefined;
        gl.genBuffer(&buffer);
        gl.bindBuffer(gl.BufferTarget.element_array_buffer, buffer);
        defer gl.bindBuffer(gl.BufferTarget.element_array_buffer, gl.Buffer{ .name = 0 });
        gl.bufferData(gl.BufferTarget.element_array_buffer, @sizeOf(u8) * indices.len, @ptrCast(indices.ptr), gl.BufferUsage.static_draw);
        return IndexBuffer{ .indices = indices, .buffer = buffer };
    }

    pub fn destroy(self: *IndexBuffer) void {
        zopengl.bindings.deleteBuffers(1, &self.buffer.name);
        self.buffer = undefined;
    }
};
