const graphics = @import("renderer.zig");

const VertexBuffer = graphics.VertexBuffer;
const IndexBuffer = graphics.IndexBuffer;

pub fn Mesh(comptime VertexType: type) type {
    return struct {
        const Self = @This();

        vertexBuffer: VertexBuffer(VertexType),
        indexBuffer: IndexBuffer,

        pub fn create(vertexBuffer: VertexBuffer(VertexType), indexBuffer: IndexBuffer) Self {
            return Self{
                .vertexBuffer = vertexBuffer,
                .indexBuffer = indexBuffer,
            };
        }

        pub fn destroy(self: *Self) void {
            self.vertexBuffer.destroy();
            self.vertexBuffer = undefined;

            self.indexBuffer.destroy();
            self.indexBuffer = undefined;
        }
    };
}
