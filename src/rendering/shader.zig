const std = @import("std");
const zopengl = @import("zopengl");
const gl = zopengl.wrapper;

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
        gl.shaderSource(vertexShader, &.{@ptrCast(shaderSource.vertexShaderSource.items.ptr)}, &.{@intCast(shaderSource.vertexShaderSource.items.len)});
        gl.compileShader(vertexShader);
        if (try checkShaderCompilationError(allocator, vertexShader, ShaderType.VERTEX)) {
            return ShaderCompilationError.FailedToCompileVertexShader;
        }

        const fragmentShader = gl.createShader(gl.ShaderType.fragment);
        defer gl.deleteShader(fragmentShader);
        gl.shaderSource(fragmentShader, &.{@ptrCast(shaderSource.fragmentShaderSource.items.ptr)}, &.{@intCast(shaderSource.fragmentShaderSource.items.len)});
        gl.compileShader(fragmentShader);
        if (try checkShaderCompilationError(allocator, fragmentShader, ShaderType.FRAGMENT)) {
            return ShaderCompilationError.FailedToCompileFragmentShader;
        }

        const program = gl.createProgram();
        errdefer zopengl.bindings.deleteProgram(program.name);
        gl.attachShader(program, vertexShader);
        defer zopengl.bindings.detachShader(program.name, vertexShader.name);
        gl.attachShader(program, fragmentShader);
        defer zopengl.bindings.detachShader(program.name, fragmentShader.name);
        gl.linkProgram(program);
        if (try checkProgramLinkingError(allocator, program)) {
            return ShaderCompilationError.FailedToLinkProgram;
        }

        return Shader{
            .program = program,
        };
    }

    pub fn destroy(self: *Shader) void {
        zopengl.bindings.deleteProgram(self.program.name);
        self.program = undefined;
    }

    pub fn setUniform(self: Shader, uniformType: UniformType, name: [:0]const u8, data: UniformType.Data(uniformType)) !void {
        const location = gl.getUniformLocation(self.program, name) orelse {
            return error.UnableToFindUniformLocation;
        };
        switch (uniformType) {
            UniformType.MAT4 => gl.uniformMatrix4fv(location, 1, @intFromBool(false), uniformType.ptr(&data)),
        }
    }

    fn checkShaderCompilationError(comptime allocator: std.mem.Allocator, shader: gl.Shader, shaderType: ShaderType) !bool {
        if (gl.getShaderiv(shader, gl.ShaderParameter.compile_status) != 0) {
            return false;
        }
        const bufferLength: usize = @intCast(gl.getShaderiv(shader, gl.ShaderParameter.info_log_length));
        var buffer = try std.ArrayList(u8).initCapacity(allocator, bufferLength);
        defer buffer.deinit();
        try buffer.resize(bufferLength);
        const errorReason = gl.getShaderInfoLog(shader, buffer.items);
        std.debug.print("Error compiling {s} shader: {s}\n", .{ @tagName(shaderType), errorReason.? });
        return true;
    }

    fn checkProgramLinkingError(comptime allocator: std.mem.Allocator, program: gl.Program) !bool {
        if (gl.getProgramiv(program, @enumFromInt(gl.LINK_STATUS)) != 0) {
            return false;
        }
        const bufferLength: usize = @intCast(gl.getProgramiv(program, @enumFromInt(gl.INFO_LOG_LENGTH)));
        var buffer = try std.ArrayList(u8).initCapacity(allocator, bufferLength);
        defer buffer.deinit();
        try buffer.resize(bufferLength);
        const errorReason = gl.getProgramInfoLog(program, buffer.items);
        std.debug.print("Error linking GL program: {s}", .{errorReason.?});
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

    pub fn PtrType(comptime T: UniformType) type {
        return switch (T) {
            UniformType.MAT4 => [*]const f32,
        };
    }

    pub fn ptr(self: UniformType, data: *const Data(self)) PtrType(self) {
        return switch (self) {
            UniformType.MAT4 => {
                const opaqueData: *const Data(UniformType.MAT4) = data;
                return @ptrCast(opaqueData[0..].ptr);
            },
        };
    }
};
