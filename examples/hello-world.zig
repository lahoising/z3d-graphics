const std = @import("std");
const graphics = @import("graphics");

pub fn main() !void {
    try graphics.window_manager.init();
}
