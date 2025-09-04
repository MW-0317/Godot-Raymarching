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

// // Modify ray direction based on gravity of black hole
// vec3 ray_sphere_distance = vec3(0.0, 0.0, 0.0) - current_ray_position;
// vec3 ray_sphere_direction = ray.step_size * ray_sphere_distance;
// // Blackhole gravity
// ray.direction += ray_sphere_direction * simpleGravity(GRAVITY_CONSTANT, length(ray_sphere_distance), 1.0);
// ray.direction = normalize(ray.direction);

Ray rayRedirect(Ray ray, vec3 blackhole_world_position)
{
    vec3 ray_sphere_difference = blackhole_world_position - ray.position;
    vec3 ray_sphere_vector = ray.step_size * ray_sphere_difference;
    ray.direction += ray_sphere_vector * simpleGravity(GRAVITY_CONSTANT, length(ray_sphere_difference), 1.0);
    ray.direction = normalize(ray.direction);
    return ray;
}