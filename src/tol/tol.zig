pub usingnamespace @cImport({
    @cInclude("tol/tiny_obj_loader_c.h");
});

pub const SUCCESS = @This().TINYOBJ_SUCCESS;
pub const Attrib = @This().tinyobj_attrib_t;
pub const Shape = @This().tinyobj_shape_t;
pub const Material = @This().tinyobj_material_t;
