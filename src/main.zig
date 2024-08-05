const std = @import("std");
const mem = @import("mem");
const root = @import("root.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var conn = try std.net.tcpConnectToHost(allocator, "test.rebex.net", 21);
    try conn.writeAll("USER demo\r\n");
    try conn.writeAll("PASS password\r\n");
    var read_thread = try std.Thread.spawn(.{}, readFromStream, .{ allocator, &conn });

    read_thread.join();
}

fn readFromStream(allocator: std.mem.Allocator, conn: *std.net.Stream) !void {
    const buf = allocator.alloc(u8, 1024) catch unreachable;
    defer allocator.free(buf);

    while (true) {
        const bytes_read = try conn.read(buf);
        if (bytes_read == 0) break; // Connection closed

        std.debug.print("{s}", .{buf[0..bytes_read]});
    }
}
