#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
};

vertex Vertex vertex_func(constant Vertex *vertices [[buffer(0)]],
                          constant Uniforms &uniforms [[buffer(1)]],
                          uint vid [[vertex_id]]) {
    float4x4 matrix = uniforms.modelMatrix;
    Vertex in = vertices[vid];
    Vertex out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    return out;
}

fragment float4 fragment_func(Vertex vert [[stage_in]]) {
    return vert.color;
}

float dist(float2 point, float2 center, float radius) {
    return length(point - center) - radius;
}

float smootherstep(float e1, float e2, float x) {
    x = clamp((x - e1) / (e2 - e1), 0.0, 1.0);
    return x * x * x * (x * (x * 6 - 15) + 10);
}

kernel void compute(texture2d<float, access::write> output [[texture(0)]],
                    uint2 gid [[thread_position_in_grid]]) {
    int width = output.get_width();
    int height = output.get_height();
    float2 uv = float2(gid) / float2(width, height);
    uv = uv * 2.0 - 1.0;
    float distance = dist(uv, float2(0), 0.5);
    float xMax = width/height;
    float4 sun = float4(1, 0.7, 0, 1) * (1 - distance);
    float4 planet = float4(0);
    float radius = 0.5;
    float m = smootherstep(radius - 0.005, radius + 0.005, length(uv - float2(xMax-1, 0)));
    float4 pixel = mix(planet, sun, m);
    output.write(pixel, gid);
}
