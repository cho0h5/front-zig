const std = @import("std");
const Client = std.http.Client;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const uri = try std.Uri.parse("http://localhost:8080/signup");

    var client = Client {
        .allocator = allocator,
    };

    var server_header_buffer: [4096]u8 = undefined;
    const request_options = Client.RequestOptions {
        .server_header_buffer = &server_header_buffer,
        .headers = .{
            .content_type = Client.Request.Headers.Value {
                .override = "application/json",
            },
        },
    };

    var request = try client.open(std.http.Method.POST, uri, request_options);
    const payload =
        \\{
        \\  "username": "measdf",
        \\  "password": "measdf"
        \\}
    ;
    request.transfer_encoding = .chunked;

    try request.send();
    try request.writeAll(payload);
    try request.finish();
    try request.wait();

    var buffer: [4096]u8 = undefined;
    const n = try request.readAll(&buffer);
    std.debug.print("{s}", .{buffer[0..n]});
}
