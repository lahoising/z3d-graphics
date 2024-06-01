const gl = @import("zgl");

pub const IndexBuffer = struct {
    indices: []u8,
    buffer: gl.Buffer,

    pub fn create(indices: []u8) IndexBuffer {
        const buffer = gl.Buffer.gen();
        gl.bindBuffer(buffer, gl.BufferTarget.element_array_buffer);
        defer gl.bindBuffer(gl.Buffer.invalid, gl.BufferTarget.element_array_buffer);
        gl.bufferData(gl.BufferTarget.element_array_buffer, u8, indices, gl.BufferUsage.static_draw);
        return IndexBuffer{ .indices = indices, .buffer = buffer };
    }

    pub fn destroy(self: *IndexBuffer) void {
        gl.deleteBuffer(self.buffer);
        self.buffer = gl.Buffer.invalid;
    }
};
