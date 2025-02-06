const std = @import("std");
const alloc = @import("../alloc.zig");

const dlog = std.log.debug;

pub usingnamespace @cImport({
    @cInclude("tol/tiny_obj_loader_c.h");
});

pub const SUCCESS = @This().TINYOBJ_SUCCESS;
pub const Attrib = @This().tinyobj_attrib_t;
pub const Shape = @This().tinyobj_shape_t;
pub const Material = @This().tinyobj_material_t;

const LoadFileFN = *const fn (ctx: ?*anyopaque, file_name: [*:0]const u8, is_mtl: c_int, obj_file_name: [*:0]const u8, buffer: *?[*]u8, len: *usize) callconv(.C) void;
extern fn tinyobj_parse_obj(attrib: *Attrib, shapes: *[*]Shape, num_shapes: *usize, materials: *[*]Material, num_materials: *usize, file_name: [*:0]const u8, loadFile: LoadFileFN, ctx: ?*anyopaque, flags: c_uint) callconv(.C) c_int;

pub fn parseObj(file_name: [:0]const u8, attrib: *Attrib, shapes: *[]Shape, materials: *[]Material) !void {
    var _shapes: [*]Shape = undefined;
    var num_shapes: usize = undefined;
    var _materials: [*]Material = undefined;
    var num_materials: usize = undefined;

    const result = tinyobj_parse_obj(attrib, &_shapes, &num_shapes, &_materials, &num_materials, file_name, loadFile, null, @This().TINYOBJ_FLAG_TRIANGULATE);

    shapes.* = _shapes[0..num_shapes];
    materials.* = _materials[0..num_materials];

    if (result != SUCCESS) {
        return error.ParseOBJFailed;
    }
}

fn loadFile(ctx: ?*anyopaque, _file_name: [*:0]const u8, is_mtl: c_int, obj_filename: [*:0]const u8, buffer: *?[*]u8, len: [*c]usize) callconv(.C) void {
    _ = ctx;
    _ = is_mtl;
    _ = obj_filename;

    var string_size: usize = 0;
    var read_size: usize = 0;

    const file_name = std.mem.span(_file_name);

    if (std.fs.cwd().openFile(file_name, .{})) |file| {
        defer file.close();

        const fstat = file.stat() catch unreachable;
        string_size = fstat.size;
        const buflen = fstat.size + 1;

        // TODO: FIXME: Use custom allocator. The default calls free(c) on this buffer, so it must be allocated with malloc(c).
        const _buffer: []u8 = malloc(@sizeOf(u8) * buflen)[0..buflen];
        buffer.* = _buffer.ptr;

        read_size = file.read(_buffer) catch 0;
        _buffer[string_size] = 0;

        if (string_size != read_size) {
            alloc.gpa.free(_buffer);
            buffer.* = null;
        }
    } else |_| {}

    len.* = read_size;
}
extern fn malloc(size: usize) callconv(.C) [*c]u8;
