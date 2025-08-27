shader_type spatial;
// Prevent the quad from being affected by lighting and fog. This also improves performance.
render_mode unshaded, fog_disabled;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D panorama : filter_linear, source_color, hint_default_black;

// 10^-11 m^3 kg^-1 s^-2
const float GRAVITATIONAL_CONSTANT = 6.674e-11;

// kg / m^3
// Ultramassive black hole: 1e11 M☉
// Supermassive: 1e6 M☉
// Intermediate: 1e2 M☉
// M☉ = 2e30 kg
const float BLACK_HOLE_DENSITY = 1e35;
// m^2 / s
const float SPEED_OF_LIGHT = 300000000.0;

// uniform int MAX_STEPS;
uniform float MAX_STEP_SIZE;
uniform float MAX_DISTANCE;

uniform float GRAVITY_CONSTANT;

struct Ray
{
    vec3 origin;
    vec3 direction;
    float step_size;
    int steps;
    float distance;
};

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

float sdfSphere(vec3 origin, float radius, vec3 position)
{
    return distance(origin, position) - radius;
}

// Gravitational force between the two objects
// F = G * (m1 * m2) / r^2
float gravity(float distance, float mass_1, float mass_2)
{
    // Assuming each unit in godot is a meter
    return (GRAVITATIONAL_CONSTANT * mass_1 * mass_2) / (pow(distance, 3));
}

float simplifiedGravity(float distance, float mass)
{
    return 4.0 * GRAVITATIONAL_CONSTANT * mass / (distance * SPEED_OF_LIGHT * SPEED_OF_LIGHT);
}

float simpleGravity(float gravity_constant, float distance, float mass)
{
    return (gravity_constant * mass) / (pow(distance, 3));
}

void vertex() {
    // POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    float depth = texture(depth_texture, SCREEN_UV).x;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
    vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view.xyz /= view.w;
    float linear_depth = -view.z;

    vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, 0.0, 1.0);
    vec3 world_position = world.xyz / world.w;

    vec4 camera_world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(0.0, 0.0, 1.0, 1.0);
    vec3 camera_world_position = camera_world.xyz / camera_world.w;

    Ray ray;
    ray.origin = camera_world_position;
    ray.direction = normalize(world_position - ray.origin);
    ray.step_size = MAX_STEP_SIZE;
    // ray.steps = MAX_STEPS;
    ray.distance = MAX_DISTANCE;

    // ALBEDO.rgb = vec3(forwardEquiProjection(ray.direction), 0.0);

    bool inside_sphere = false;

    // TODO: Implement ray-sphere intersection

    int i = 0;
    float origin_offset = 0.0; //ign(FRAGCOORD.xy)
    vec3 position_offset = ray.direction * origin_offset;
    vec3 current_ray_position = ray.origin + position_offset;
    for (; ray.step_size * float(i) < ray.distance; i++)
    {
        if (inside_sphere)
        {
            break;
        }

        // TODO: Check if ray is within range of black hole to matter
            // TODO: Modify ray direction based on gravity of black hole

        vec3 ray_sphere_distance = vec3(0.0, 0.0, 0.0) - current_ray_position;
        vec3 ray_sphere_direction = ray.step_size * ray_sphere_distance;

        // ray.direction += ray_sphere_direction * gravity(length(ray_sphere_distance), 1.0, BLACK_HOLE_DENSITY);
        // ray.direction += ray_sphere_direction * simplifiedGravity(length(ray_sphere_distance), 100000000.0);
        ray.direction += ray_sphere_direction * simpleGravity(GRAVITY_CONSTANT, length(ray_sphere_distance), 1.0);
        ray.direction = normalize(ray.direction);
        
        // current_ray_position = ray.origin + position_offset + ray.direction * ray.step_size * float(i);
        current_ray_position += ray.direction * ray.step_size;

        inside_sphere = sdfSphere(vec3(0.0, 0.0, 0.0), 0.1, current_ray_position) < 0.0;
    }

    // TODO: Make the depth work
    vec4 projection_position = PROJECTION_MATRIX * VIEW_MATRIX * vec4(current_ray_position, 1.0);
    DEPTH = projection_position.z / projection_position.w;
    // ALBEDO.rgb = vec3(projection_position.z / projection_position.w);

    if (inside_sphere)
    {
        // NORMAL = normalize(-(current_ray_position - ray.origin)).xyz;
        // ALBEDO.rgb = vec3(0.5,1.0,0.5);
        ALBEDO.rgb = vec3(0.0,0.0,0.0);
    }
    else
    {
        // TODO: Implement skybox
        ALBEDO.rgb = texture(panorama, forwardEquiProjection(ray.direction)).rgb;
        // ALPHA = 0.0;
    }

    // if (!inside_sphere)
    //     ALBEDO.rgb = vec3(0.5,1.0,0.5);
    // else
    //     ALBEDO.rgb = vec3(1.0,0.5,0.5);

    // ALBEDO.rgb = vec3(1.0, 1.0, 1.0);
}

void light() {
    DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
}