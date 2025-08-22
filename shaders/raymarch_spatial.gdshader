shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;

uniform sampler2D depth_texture : hint_depth_texture;

struct Ray
{
    vec3 origin;
    vec3 direction;
    float step_size;
    int steps;
};

float sdfSphere(vec3 origin, float radius, vec3 position)
{
    return distance(origin, position) - radius;
}

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, 0.0, 1.0);
    vec3 world_position = world.xyz / world.w;

    vec4 camera_world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(0.0, 0.0, 1.0, 1.0);
    vec3 camera_world_position = camera_world.xyz / camera_world.w;

    Ray ray;
    ray.origin = camera_world_position;
    ray.direction = normalize(world_position - ray.origin);
    ray.step_size = 0.1;
    ray.steps = 1000;

    bool inside_sphere = false;

    vec3 current_ray_position = ray.origin;
    for (int i = 0; i < ray.steps; i++)
    {
        inside_sphere = length(current_ray_position) < 1.0;

        if (inside_sphere)
        {
            break;
        }
        current_ray_position += ray.direction * ray.step_size;
    }

    if (!inside_sphere)
        ALBEDO.rgb = vec3(0.5,1.0,0.5);
    else
        ALBEDO.rgb = vec3(1.0,0.5,0.5);
}