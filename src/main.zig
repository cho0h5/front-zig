const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const uri = try std.Uri.parse("http://localhost:8080/signin");

    var client = std.http.Client {
        .allocator = allocator,
    };

    var server_header_buffer: [4096]u8 = undefined;
    const request_options = std.http.Client.RequestOptions {
        .server_header_buffer = &server_header_buffer,
    };

    var request = try client.open(std.http.Method.POST, uri, request_options);
    try request.send();
    try request.wait();

    var buffer: [4096]u8 = undefined;
    const n = try request.readAll(&buffer);
    std.debug.print("{s}", .{buffer[0..n]});
}
