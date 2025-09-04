shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D panorama : filter_linear, source_color, hint_default_black;
uniform sampler3D noise_texture;

uniform vec3 light_position;
uniform vec3 light_color;
uniform vec3 fog_color;
uniform float SIZE;
uniform float INTENSITY;
uniform float DENSITY_COEFFICIENT;
uniform float DISTANCE_POWER;
uniform float OFFSET;

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

float simpleDither(float luminosity)
{
    return mod(52.9829189f * mod(0.06711056f*luminosity, 1.0f), 1.0f);
}

float sdfSphere(vec3 origin, float radius, vec3 position)
{
    return distance(origin, position) - radius;
}

float sdfBox(vec3 position, vec3 cube_corner)
{
    // Position in relation to the corner of the box. Where the corner of the
    // box is reflected along all octants.
    vec3 corner_relation = abs(position) - cube_corner;
    return length(max(corner_relation, 0.0)) 
            + min(
                max(corner_relation.x, 
                max(corner_relation.y,
                    corner_relation.z)), 
                0.0);
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

float getDensity(vec3 position)
{
    float dist = distance(vec3(0.0), abs(position));
    // position.y /= 100.0;
    // float l = length(position.xz);
    // position.xz += vec2(position.y, cos(OFFSET));
    // position.xz = normalize(position.xz) * l;
    // x' = x cos θ − y sin θ
    // y' = x sin θ + y cos θ
    vec2 tempPosition = position.xz;
    float t = TIME;
    position.x = tempPosition.x * cos(OFFSET*dist + t / 10.0) - tempPosition.y * sin(OFFSET*dist + t / 10.0);
    position.z = tempPosition.x * sin(OFFSET*dist + t / 10.0) + tempPosition.y * cos(OFFSET*dist + t / 10.0);
    position.y /= 100.0;
    return DENSITY_COEFFICIENT * (1.0 - dist / SIZE) * texture(noise_texture, (abs(position)) / SIZE).r * (1.0-abs(position.y));
}

// Create sampleMedia that would integrate all volumes in scene

////////////////////////////////////////////////////////////////////////////////
// =============================================================================
// Physically Based Sky, Atmosphere and Cloud Rendering in Frostbite |  5.6.1  | 
// =============================================================================
// // Contains integrated scattered luminance ( in rgb ) and trasmittance ( in a ) along a ray .
// float4 intScattTrans = float4 (0.0 , 0.0 , 0.0 , 1.0) ;
// for ( uint samplerIt = 0; samplerIt < smapleCount ; ++ samplerIt )
// {
//     float4 scatteringExtinction = takeMediaSample ( coord ) ;
//     const float3 scattering = scatteringExtinction . rgb ;
//     const float transmittance = exp ( - scatteringExtinction . a * ds );

//     // Get sun luminance according to volumetric shadow and phase function
//     const float3 luminance = sunLuminance ( coord , sunDir , viewDir );

//     intScattTrans . rgb += scattering * luminance * intScattTrans . a * ds; // ( S ) step
//     intScattTrans . a *= transmittance ; // ( T ) step
// }
////////////////////////////////////////////////////////////////////////////////

void vertex() {
    // POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    float depth = texture(depth_texture, SCREEN_UV).x;
    vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
    vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
    view.xyz /= view.w;
    float linear_depth = -view.z;

    vec3 test_color = vec3(1.0,1.0,1.0);

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

    ray.origin += ign(FRAGCOORD.xy) * ray.step_size * ray.direction;

    // ALBEDO.rgb = vec3(forwardEquiProjection(ray.direction), 0.0);

    bool inside_sphere = false;
    bool inside_box = false;
    bool inside_bh = false;

    // TODO: Implement ray-sphere intersection

    int i = 0;
    // float origin_offset = 0.0; //ign(FRAGCOORD.xy)
    vec3 current_ray_position = ray.origin;

    // Redoing scattering
    vec4 pixel_color = vec4(fog_color, 1.0);
    for (; ray.step_size * float(i) < ray.distance; i++)
    {
        inside_box = sdfBox(current_ray_position, vec3(SIZE, SIZE / 100.0, SIZE)) < 0.0;
        inside_sphere = sdfSphere(vec3(0.0), SIZE, current_ray_position) < 0.0;
        inside_bh = sdfSphere(vec3(0.0), 0.3, current_ray_position) < 0.0;
        if (inside_bh)
        {
            pixel_color.a = 0.0;
            break;
        }

        if (inside_box && inside_sphere)
        {
            float density = getDensity(current_ray_position);
            vec3 scattering = fog_color;
            float transmittance = exp(-density * ray.step_size);

            Ray light_ray;
            light_ray.origin = current_ray_position;
            light_ray.direction = normalize(light_position - light_ray.origin);

            vec2 ign_light = vec2(
                // 0.0, 0.0
                (dot(light_ray.direction, vec3(0.0, 1.0, 0.0)) + 1.0)/2.0, 
                (dot(light_ray.direction, vec3(0.0, 0.0, 1.0)) + 1.0)/2.0
            );
            // test_color.xy = ign_light;
            // ign(FRAGCOORD.xy)
            // test_color = vec3(ign(ign_light * 1e8));

            light_ray.step_size = MAX_STEP_SIZE;
            light_ray.distance = length(light_position - light_ray.origin);

            light_ray.origin += ign(ign_light * 1e8) * light_ray.step_size * light_ray.direction;

            vec4 luminance = vec4(light_color, INTENSITY / pow(light_ray.distance, DISTANCE_POWER));

            // float cos_theta = 3.0 * (1.0 + pow(dot(light_ray.direction, ray.direction), 2.0)) / (16.0 * PI);
            // luminance *= cos_theta;

            vec3 current_light_ray_position = light_ray.origin;
            int j = 0;
            for (; light_ray.step_size * float(j) < light_ray.distance; j++)
            {
                current_light_ray_position += light_ray.direction * light_ray.step_size;

                inside_box = sdfBox(current_light_ray_position, vec3(SIZE, SIZE / 100.0, SIZE)) < 0.0;
                inside_sphere = sdfSphere(vec3(0.0), SIZE, current_light_ray_position) < 0.0;
                inside_bh = sdfSphere(vec3(0.0), 1.0, current_light_ray_position) < 0.0;
                if (!inside_box || !inside_sphere || inside_bh)
                    break;

                float to_light_density = getDensity(current_light_ray_position);
                vec3 to_light_scattering = fog_color;
                float to_light_transmittance = exp(-to_light_density * light_ray.step_size);

                // Luminance??
                vec4 to_light_luminance = vec4(light_color, INTENSITY / pow(light_ray.distance - light_ray.step_size * float(j), DISTANCE_POWER));

                // float cos_theta = 3.0 * (1.0 + pow(1.0, 2.0)) / (16.0 * PI);
                // to_light_luminance *= cos_theta;

                luminance.rgb += to_light_scattering * to_light_luminance.rgb * to_light_luminance.a * luminance.a * light_ray.step_size;
                luminance.a *= to_light_transmittance;
            }

            pixel_color.rgb += scattering * luminance.rgb * pixel_color.a * luminance.a * ray.step_size;
            pixel_color.a *= transmittance;
        }
        
        // Modify ray direction based on gravity of black hole
        vec3 ray_sphere_distance = vec3(0.0, 0.0, 0.0) - current_ray_position;
        vec3 ray_sphere_direction = ray.step_size * ray_sphere_distance;
        // Blackhole gravity
        ray.direction += ray_sphere_direction * simpleGravity(GRAVITY_CONSTANT, length(ray_sphere_distance), 1.0);
        ray.direction = normalize(ray.direction);

        current_ray_position += ray.direction * ray.step_size;
    }

    // Depth
    vec4 projection_position = PROJECTION_MATRIX * VIEW_MATRIX * vec4(current_ray_position, 1.0);
    DEPTH = projection_position.z / projection_position.w;

    // ALBEDO.rgb = vec3(1.0 - transmittance);
    // ALPHA = transmittance;

    vec3 space_color = texture(panorama, forwardEquiProjection(ray.direction)).rgb;
    // space_color = vec3(0.0);
    ALBEDO.rgb = mix(pixel_color.rgb, space_color, pixel_color.a);
    // ALBEDO.rgb = test_color;
    // ALBEDO.rgb = fog_color;
    // ALBEDO.rgb = vec3(pixel_color.a);
}

void light() {
    DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI;
}