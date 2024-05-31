const std = @import("std");
const Client = std.http.Client;
const allocator = std.heap.page_allocator;

pub fn main() !void {
    var client = Client{
        .allocator = allocator,
    };

    const payload =
        \\{
        \\  "username": "yoyo",
        \\  "password": "yoyo"
        \\}
    ;
    const buffer1 = try post(&client, try std.Uri.parse("http://localhost:8080/signup"), payload);
    std.debug.print("{s}\n", .{buffer1});
    const buffer2 = try get(&client, try std.Uri.parse("http://localhost:8080/signin?username=yoyo&password=yoyo"));
    std.debug.print("{s}\n", .{buffer2});
    const buffer3 = try get(&client, try std.Uri.parse("http://localhost:8080/users?username=yoyo&password=yoyo"));
    std.debug.print("{s}\n", .{buffer3});
}

fn post(client: *Client, uri: std.Uri, payload: []const u8) ![]const u8 {
    var server_header_buffer: [4096]u8 = undefined;
    const request_options = Client.RequestOptions{
        .server_header_buffer = &server_header_buffer,
        .headers = .{
            .content_type = Client.Request.Headers.Value{
                .override = "application/json",
            },
        },
    };

    var request = try client.open(std.http.Method.POST, uri, request_options);
    request.transfer_encoding = .chunked;

    try request.send();
    try request.writeAll(payload);
    try request.finish();
    try request.wait();

    var buffer: [4096]u8 = undefined;
    const n = try request.readAll(&buffer);
    return buffer[0..n];
}

fn get(client: *Client, uri: std.Uri) ![]const u8 {
    var server_header_buffer: [4096]u8 = undefined;
    const request_options = Client.RequestOptions{
        .server_header_buffer = &server_header_buffer,
    };

    var request = try client.open(std.http.Method.GET, uri, request_options);

    try request.send();
    try request.wait();

    var buffer: [4096]u8 = undefined;
    const n = try request.readAll(&buffer);
    return buffer[0..n];
}
