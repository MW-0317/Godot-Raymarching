shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;

uniform sampler2D depth_texture : hint_depth_texture;

// 10^-11 m^3 kg^-1 s^-2
const float GRAVITATIONAL_CONSTANT = 6.674 / 100000000000.0;

// kg / m^3
const float BLACK_HOLE_DENSITY = 1.0;

uniform int MAX_STEPS;
uniform float MAX_STEP_SIZE;

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

// Gravitational force between the two objects
// F = G * (m1 * m2) / r^2
float gravity(float distance, float mass_1, float mass_2)
{
    // Assuming each unit in godot is a meter
    return (GRAVITATIONAL_CONSTANT * mass_1 * mass_2) / (distance * distance);
}

void vertex() {
    // POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, 0.0, 1.0);
    vec3 world_position = world.xyz / world.w;

    vec4 camera_world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(0.0, 0.0, 1.0, 1.0);
    vec3 camera_world_position = camera_world.xyz / camera_world.w;

    Ray ray;
    ray.origin = camera_world_position;
    ray.direction = normalize(world_position - ray.origin);
    ray.step_size = MAX_STEP_SIZE;
    ray.steps = MAX_STEPS;

    bool inside_sphere = false;

    // TODO: Implement ray-sphere intersection

    for (int i = 0; i < ray.steps; i++)
    {
        if (inside_sphere)
        {
            break;
        }

        // TODO: Check if ray is within range of black hole to matter
            // TODO: Modify ray direction based on gravity of black hole
        
        vec3 current_ray_position = ray.origin + ray.direction * ray.step_size * float(i);

        inside_sphere = sdfSphere(vec3(0.0, 0.0, 0.0), 1.0, current_ray_position) < 0.0;
    }

    if (inside_sphere)
        ALBEDO.rgb = vec3(0.5,1.0,0.5);
    else
    {
        // TODO: Implement skybox
        ALPHA = 0.0;
    }

    // if (!inside_sphere)
    //     ALBEDO.rgb = vec3(0.5,1.0,0.5);
    // else
    //     ALBEDO.rgb = vec3(1.0,0.5,0.5);

    // ALBEDO.rgb = vec3(1.0, 1.0, 1.0);
}