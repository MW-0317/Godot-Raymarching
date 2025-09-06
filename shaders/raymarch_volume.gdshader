shader_type spatial;
render_mode unshaded, fog_disabled;

uniform vec3 light_color;
uniform vec3 light_position;

uniform vec3 fog_color;
uniform sampler3D noise_texture;

uniform sampler2D panorama : filter_linear, source_color, hint_default_black;

#include "res://shaders/raymarch.gdshaderinc"

vec2 forwardEquiProjection(vec3 direction)
{
    // 0 to 2pi, remap to 0 to 1
    vec2 spherical = vec2(
        acos(direction.y) * 1.0 / PI,
        sign(direction.x) * acos(-direction.z / (sqrt(direction.z*direction.z + direction.x*direction.x))) * 1.0 / (2.0 * PI)
    );
    return spherical.yx;
}

float ign(vec2 pixelCoords)
{
    return mod(52.9829189f * mod(0.06711056f*pixelCoords.x + 0.00583715f*pixelCoords.y, 1.0f), 1.0f);
}

void vertex() {
    // Called for every vertex the material is visible on.
}

// struct Ray
// {
//     vec3 origin;
//     vec3 position;
//     vec3 direction;
//     float step_size;
//     int steps;
//     float distance;
// };

void fragment() {
    vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, 0.0, 1.0);
    vec3 world_position = world.xyz / world.w;

    vec4 camera_world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(0.0, 0.0, 1.0, 1.0);
    vec3 camera_world_position = camera_world.xyz / camera_world.w;

    Ray ray;
    ray.direction = normalize(world_position - camera_world_position);
    ray.origin = camera_world_position + ign(FRAGCOORD.xy) * ray.direction;
    ray.position = ray.origin;
    ray.step_size = MIN_STEP_SIZE;
    ray.steps = 0;
    ray.distance = 0.0;

    Light light;
    light.position = light_position;
    light.color = light_color;

    vec3 space_color = texture(panorama, forwardEquiProjection(ray.direction)).rgb;
    vec4 pixel_color = raymarch(ray, light);
    ALBEDO.rgb = mix(pixel_color.rgb, space_color, pixel_color.a);
    // ALBEDO.rgb = space_color;
}

//void light() {
//  // Called for every pixel for every light affecting the material.
//  // Uncomment to replace the default light processing function with this one.
//}
