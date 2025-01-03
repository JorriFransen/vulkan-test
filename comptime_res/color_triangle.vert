#version 450

layout(set = 0, binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 proj;
} ubo;

layout(location = 0) in vec2 inPosition;
layout(location = 1) in vec3 inColor;

layout(location = 0) out vec3 frag_color;

void main( ) {

    // gl_Position = /*ubo.proj * ubo.view * */ ubo.model * vec4(inPosition, 0.0, 1.0);
    gl_Position = mat4(1) * vec4(inPosition, 0.0, 1.0);
    frag_color = inColor;
}
