shader_type canvas_item;

uniform int MAX_STEPS;
uniform float MAX_STEP_SIZE;
uniform vec3 CAMERA_POSITION;
uniform mat4 INVERSE_VIEW_MATRIX;
uniform mat4 INVERSE_CAMERA_PROJECTION;

uniform float test_distance;
uniform float alpha;

struct Ray
{
    vec3 origin;
    vec3 direction;
    float step_size;
    int steps;
};

float sdfSphere(vec3 origin, float radius, vec3 position)
{
    return length(position - origin) - radius;
}

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    // Called for every pixel the material is visible on.

    Ray ray;
    vec2 suv = SCREEN_UV;
    // suv.y = 1.0 - suv.y;
    // suv.x = 1.0 - suv.x;
    vec4 pos = vec4(2.0 * suv - 1.0, 1.0, 1.0);
    vec4 canvas_position = INVERSE_VIEW_MATRIX * INVERSE_CAMERA_PROJECTION * pos;
    vec3 canvas_world = canvas_position.xyz / canvas_position.w;
    // canvas_world = -canvas_world;
    // // canvas_world.x = -canvas_world.x;
    // canvas_world.z = -canvas_world.z;

    vec4 camera_world = INVERSE_VIEW_MATRIX * INVERSE_CAMERA_PROJECTION * vec4(0.0, 0.0, 0.0, 1.0);
    vec3 camera_world_position = camera_world.xyz / camera_world.w;

    // camera_world_position = (INVERSE_VIEW_MATRIX * vec4(0,0,0,1)).xyz;
    ray.origin = camera_world_position;
    ray.direction = normalize(canvas_world - ray.origin);
    // ray.direction.x = -ray.direction.x;
    ray.steps = MAX_STEPS;
    ray.step_size = MAX_STEP_SIZE;

    // COLOR = vec4(normalize(FRAGCOORD.xyz), 1.0);
    // COLOR = vec4(ray.direction, 1.0);
    // COLOR = vec4(0.0,canvas_position.y, 0.0, 1.0);
    // COLOR = vec4(0.0,ray.direction.yz, 1.0);
    // COLOR = vec4(SCREEN_UV, 1.0,1.0);
    // COLOR = vec4((ray.direction + 1.0) / 2.0, alpha);

    // COLOR = vec4(fract(canvas_world).xyz, alpha);
    COLOR = vec4((ray.direction + 1.0) / 2.0, alpha);

    bool inside_sphere = false;

    vec3 current_ray_position = ray.origin;
    for (int i = 0; i < ray.steps; i++)
    {
        // vec3 current_ray_position = ray.origin + ray.direction * ray.step_size * float(i);

        // inside_sphere = sdfSphere(vec3(0.0), 1.0, current_ray_position) < 0.0;

        inside_sphere = length(current_ray_position) < 1.0;

        // ALBEDO.rgb = vec3(sdfSphere(vec3(0.0), 1.0, current_ray_position));
        if (inside_sphere)
        {
            break;
        }
        current_ray_position += ray.direction * ray.step_size;
    }

    // vec4 c = vec4(sdfSphere(vec3(0,0,0), 1.0, ray.origin + ray.direction * test_distance));
    // c.w = alpha;
    // COLOR = c;

    // if (!inside_sphere)
    //     COLOR = vec4(0.5,1.0,0.5, alpha);
    // else
    //     COLOR = vec4(1.0,0.5,0.5, alpha);
}

//void light() {
//  // Called for every pixel for every light affecting the CanvasItem.
//  // Uncomment to replace the default light processing function with this one.
//}
