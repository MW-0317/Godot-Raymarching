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
}

void fragment() {
    vec4 canvas_position = INVERSE_VIEW_MATRIX * INVERSE_CAMERA_PROJECTION * vec4(2.0 * SCREEN_UV - 1.0, 0.0, 1.0);
    vec3 canvas_world = canvas_position.xyz / canvas_position.w;

    vec4 camera_world = INVERSE_VIEW_MATRIX * INVERSE_CAMERA_PROJECTION * vec4(0.0, 0.0, 1.0, 1.0);
    vec3 camera_world_position = camera_world.xyz / camera_world.w;

    Ray ray;
    ray.origin = camera_world_position;
    ray.direction = normalize(canvas_world - ray.origin);
    ray.step_size = MAX_STEP_SIZE;
    ray.steps = MAX_STEPS;

    bool inside_sphere = false;

    vec3 current_ray_position = ray.origin;
    for (int i = 0; i < ray.steps; i++)
    {
        inside_sphere = length(current_ray_position) < 1.0;

        // ALBEDO.rgb = vec3(sdfSphere(vec3(0.0), 1.0, current_ray_position));
        if (inside_sphere)
        {
            break;
        }
        current_ray_position += ray.direction * ray.step_size;
    }

    if (!inside_sphere)
        COLOR = vec4(0.5,1.0,0.5, alpha);
    else
        COLOR = vec4(1.0,0.5,0.5, alpha);
}

//void light() {
//  // Called for every pixel for every light affecting the CanvasItem.
//  // Uncomment to replace the default light processing function with this one.
//}
