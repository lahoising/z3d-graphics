const std = @import("std");
const testing = std.testing;
const input = @import("windowing/input.zig");
pub const WindowManager = @import("windowing/window-manager.zig");
pub const Window = WindowManager.Window;
pub const Key = input.Key;
pub const KeyModifier = input.KeyModifier;
pub const KeyAction = input.KeyAction;
