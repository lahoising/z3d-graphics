const std = @import("std");
const gl = @import("zgl");

pub fn VertexBuffer(comptime Vertex: type) type {
    const typeInfo = @typeInfo(Vertex);
    const structFields = typeInfo.Struct.fields;
    const fields: [structFields.len]FieldInfo = try FieldInfo.fromTypeInfo(Vertex);

    return struct {
        const Self = @This();

        data: []Vertex,
        buffer: gl.Buffer,
        vertexArray: gl.VertexArray,

        pub fn create(data: []Vertex) !Self {
            const buffer = gl.Buffer.gen();
            gl.bindBuffer(buffer, gl.BufferTarget.array_buffer);
            defer gl.bindBuffer(gl.Buffer.invalid, gl.BufferTarget.array_buffer);
            gl.bufferData(gl.BufferTarget.array_buffer, Vertex, data, gl.BufferUsage.static_draw);

            const vertexArray = gl.VertexArray.gen();
            gl.bindVertexArray(vertexArray);
            defer gl.bindVertexArray(gl.VertexArray.invalid);
            const vertexBuffer = Self{
                .data = data,
                .buffer = buffer,
                .vertexArray = vertexArray,
            };

            var offset: usize = 0;
            for (fields, 0..) |fieldInfo, i| {
                const idx: u32 = @intCast(i);
                gl.enableVertexAttribArray(idx);
                gl.vertexAttribPointer(idx, fieldInfo.count, fieldInfo.type, false, @sizeOf(Vertex), offset);
                offset += fieldInfo.size;
            }

            return vertexBuffer;
        }

        pub fn destroy(self: *Self) void {
            gl.deleteVertexArray(self.vertexArray);
            self.vertexArray = undefined;
            gl.deleteBuffer(self.buffer);
            self.buffer = undefined;
            self.data = undefined;
        }
    };
}

const FieldInfo = struct {
    size: usize,
    count: u32,
    type: gl.Type,

    fn create(comptime T: type) !FieldInfo {
        const typeInfo = @typeInfo(T);
        return switch (typeInfo) {
            .Vector => |info| {
                if (info.child != f32) {
                    std.debug.print("Error, only Vectors of f32 are supported\n", .{});
                    return error.UnsupportedVectorType;
                }

                return FieldInfo{
                    .size = info.len * @sizeOf(f32),
                    .count = info.len,
                    .type = gl.Type.float,
                };
            },
            .Float => FieldInfo{
                .size = @sizeOf(f32),
                .count = 1,
                .type = gl.Type.float,
            },
            else => error.InvalidFieldType,
        };
    }

    fn fromTypeInfo(comptime T: type) ![std.meta.fields(T).len]FieldInfo {
        const typeInfo = @typeInfo(T);
        const structFields = typeInfo.Struct.fields;
        var fields: [structFields.len]FieldInfo = undefined;
        for (structFields, 0..) |f, i| {
            fields[i] = try FieldInfo.create(f.type);
        }
        return fields;
    }
};
