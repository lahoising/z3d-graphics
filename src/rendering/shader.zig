const std = @import("std");
const gl = @import("zgl");

pub const ShaderCompilationError = error{
    FailedToCompileVertexShader,
    FailedToCompileFragmentShader,
    FailedToLinkProgram,
};

pub const Shader = struct {
    program: gl.Program,

    pub fn create(sourceAbsolutePath: []const u8) !Shader {
        const allocator = std.heap.c_allocator;
        var shaderSource = ShaderSource.create(allocator);
        try shaderSource.readProgramSource(sourceAbsolutePath);
        defer shaderSource.destroy();

        const vertexShader = gl.createShader(gl.ShaderType.vertex);
        defer gl.deleteShader(vertexShader);
        gl.shaderSource(vertexShader, 1, (&shaderSource.vertexShaderSource.items)[0..1]);
        gl.compileShader(vertexShader);
        if (try checkShaderCompilationError(allocator, vertexShader, ShaderType.VERTEX)) {
            return ShaderCompilationError.FailedToCompileVertexShader;
        }

        const fragmentShader = gl.createShader(gl.ShaderType.fragment);
        defer gl.deleteShader(fragmentShader);
        gl.shaderSource(fragmentShader, 1, (&shaderSource.fragmentShaderSource.items)[0..1]);
        gl.compileShader(fragmentShader);
        if (try checkShaderCompilationError(allocator, fragmentShader, ShaderType.FRAGMENT)) {
            return ShaderCompilationError.FailedToCompileFragmentShader;
        }

        const program = gl.createProgram();
        errdefer gl.deleteProgram(program);
        gl.attachShader(program, vertexShader);
        defer gl.detachShader(program, vertexShader);
        gl.attachShader(program, fragmentShader);
        defer gl.detachShader(program, fragmentShader);
        gl.linkProgram(program);
        if (try checkProgramLinkingError(allocator, program)) {
            return ShaderCompilationError.FailedToLinkProgram;
        }

        return Shader{
            .program = program,
        };
    }

    pub fn destroy(self: *Shader) void {
        gl.deleteProgram(self.program);
    }

    pub fn setUniform(self: Shader, uniformType: UniformType, name: [:0]const u8, data: UniformType.Data(uniformType)) void {
        const location = gl.getUniformLocation(self.program, name);
        switch (uniformType) {
            UniformType.MAT4 => gl.uniformMatrix4fv(location, false, &.{data}),
        }
    }

    fn checkShaderCompilationError(comptime allocator: std.mem.Allocator, shader: gl.Shader, shaderType: ShaderType) !bool {
        if (gl.getShader(shader, gl.ShaderParameter.compile_status) != 0) {
            return false;
        }
        const errorReason = try gl.getShaderInfoLog(shader, allocator);
        defer allocator.free(errorReason);
        std.debug.print("Error compiling {s} shader: {s}\n", .{ @tagName(shaderType), errorReason });
        return true;
    }

    fn checkProgramLinkingError(comptime allocator: std.mem.Allocator, program: gl.Program) !bool {
        if (gl.getProgram(program, gl.ProgramParameter.link_status) != 0) {
            return false;
        }
        const errorReason = try gl.getProgramInfoLog(program, allocator);
        defer allocator.free(errorReason);
        std.debug.print("Error linking GL program: {s}", .{errorReason});
        return true;
    }
};

const ShaderType = enum {
    VERTEX,
    FRAGMENT,
    NONE,
};

const ShaderSource = struct {
    vertexShaderSource: std.ArrayList(u8),
    fragmentShaderSource: std.ArrayList(u8),

    pub fn create(comptime allocator: std.mem.Allocator) ShaderSource {
        return ShaderSource{
            .vertexShaderSource = std.ArrayList(u8).init(allocator),
            .fragmentShaderSource = std.ArrayList(u8).init(allocator),
        };
    }

    pub fn destroy(self: *ShaderSource) void {
        self.vertexShaderSource.clearAndFree();
        self.fragmentShaderSource.clearAndFree();
    }

    pub fn readProgramSource(self: *ShaderSource, sourceAbsolutePath: []const u8) !void {
        var file = try std.fs.openFileAbsolute(sourceAbsolutePath, .{});
        defer file.close();

        var bufReader = std.io.bufferedReader(file.reader());
        var inStream = bufReader.reader();

        var currentShaderType = ShaderType.NONE;
        var buffer: [1024]u8 = undefined;
        while (try inStream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
            if (std.mem.containsAtLeast(u8, line, 1, "// shader source vertex")) {
                currentShaderType = ShaderType.VERTEX;
            } else if (std.mem.containsAtLeast(u8, line, 1, "// shader source fragment")) {
                currentShaderType = ShaderType.FRAGMENT;
            } else if (currentShaderType == ShaderType.VERTEX) {
                try self.vertexShaderSource.appendSlice(line);
                try self.vertexShaderSource.append('\n');
            } else if (currentShaderType == ShaderType.FRAGMENT) {
                try self.fragmentShaderSource.appendSlice(line);
                try self.fragmentShaderSource.append('\n');
            }
        }
    }
};

pub const UniformType = enum {
    MAT4,

    pub fn Data(comptime T: UniformType) type {
        return switch (T) {
            UniformType.MAT4 => [4][4]f32,
        };
    }
};
