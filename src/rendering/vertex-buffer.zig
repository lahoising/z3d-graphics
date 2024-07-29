const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.wrapper;

pub fn VertexBuffer(comptime Vertex: type) type {
    const typeInfo = @typeInfo(Vertex);
    const structFields = typeInfo.Struct.fields;
    const fields: [structFields.len]FieldInfo = try FieldInfo.fromTypeInfo(Vertex);

    return struct {
        const Self = @This();

        data: []Vertex,
        buffer: gl.Buffer,
        vertexArray: gl.VertexArrayObject,

        pub fn create(data: []Vertex) !Self {
            var buffer: gl.Buffer = undefined;
            gl.genBuffer(&buffer);
            gl.bindBuffer(gl.BufferTarget.array_buffer, buffer);
            defer gl.bindBuffer(gl.BufferTarget.array_buffer, gl.Buffer{ .name = 0 });
            gl.bufferData(gl.BufferTarget.array_buffer, @sizeOf(Vertex) * data.len, @ptrCast(data.ptr), gl.BufferUsage.static_draw);

            var vertexArray: gl.VertexArrayObject = undefined;
            gl.genVertexArray(&vertexArray);
            gl.bindVertexArray(vertexArray);
            defer gl.bindVertexArray(gl.VertexArrayObject{ .name = 0 });
            const vertexBuffer = Self{
                .data = data,
                .buffer = buffer,
                .vertexArray = vertexArray,
            };

            var offset: usize = 0;
            for (fields, 0..) |fieldInfo, i| {
                const idx: gl.VertexAttribLocation = gl.VertexAttribLocation{ .location = @intCast(i) };
                gl.enableVertexAttribArray(idx);
                gl.vertexAttribPointer(idx, fieldInfo.count, fieldInfo.type, @intFromBool(false), @sizeOf(Vertex), offset);
                offset += fieldInfo.size;
            }

            return vertexBuffer;
        }

        pub fn destroy(self: *Self) void {
            gl.deleteVertexArrays(&.{self.vertexArray});
            self.vertexArray = undefined;
            zopengl.bindings.deleteBuffers(1, &self.buffer.name);
            self.buffer = undefined;
            self.data = undefined;
        }
    };
}

const FieldInfo = struct {
    size: usize,
    count: u32,
    type: gl.VertexAttribType,

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
                    .type = gl.VertexAttribType.float,
                };
            },
            .Array => |array| {
                if (array.child != f32) {
                    std.debug.print("Error, only Arrays of f32 are supported\n", .{});
                    return error.UnsupportedArrayType;
                }

                return FieldInfo{
                    .size = array.len * @sizeOf(f32),
                    .count = array.len,
                    .type = gl.VertexAttribType.float,
                };
            },
            .Float => FieldInfo{
                .size = @sizeOf(f32),
                .count = 1,
                .type = gl.VertexAttribType.float,
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
