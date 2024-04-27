const std = @import("std");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});

pub const GlfwError = error{
    GlfwInitError,
};

pub fn init() GlfwError!void {
    _ = glfw.glfwSetErrorCallback(glfw_error_callback);

    const initOutcome = glfw.glfwInit();
    if (initOutcome != 1) {
        std.debug.print("GLFW failed to init. Error code: {d}\n", .{initOutcome});
        return error.GlfwInitError;
    }

    errdefer glfw.glfwTerminate();
}

fn glfw_error_callback(code: i32, description: [*c]const u8) callconv(.C) void {
    std.debug.print("GLFW error [{}]: {s}", .{ code, description });
}
