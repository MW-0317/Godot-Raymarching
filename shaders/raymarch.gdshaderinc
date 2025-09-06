uniform int MAX_STEPS;
uniform float MIN_STEP_SIZE;
uniform float MAX_DISTANCE;

struct Ray
{
    vec3 origin;
    vec3 position;
    vec3 direction;
    float step_size;
    int steps;
    float distance;
};

struct Light
{
    vec3 position;
    vec3 color;
};

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

vec4 sampleDensity(Ray ray, out bool inside_sdf)
{
    // inside_sdf = sdfSphere(vec3(0.0), 1.0, ray.position) < 0.0;
    inside_sdf = sdfBox(ray.position, vec3(3.0)) < 0.0;
    if (!inside_sdf)
        return vec4(0.0);

    vec3 position = ray.position;
    position.y -= TIME / 3.0;
    float noise = texture(noise_texture, mod((position), 1.0)).r;
    // density = smoothstep(density, 0.0, distance(ray.position, vec3(0.0)));
    float falloff = smoothstep(0.0, 1.0, length(ray.position) - noise * 1.0);
    float density = noise * (1.0 - falloff);
    return vec4(fog_color, density * 10.0);
}

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

vec4 raymarch(Ray ray, Light light)
{
    ray.steps = 0;
    vec4 pixel_color = vec4(vec3(0.0), 1.0);
    float test_color = 0.0;
    while (ray.steps < MAX_STEPS && ray.distance < MAX_DISTANCE)
    {
        bool inside_sdf;
        vec4 scattering_extinction = sampleDensity(ray, inside_sdf);
        vec3 scattering = scattering_extinction.rgb;
        float transmittance = exp(-scattering_extinction.a * ray.step_size);

        vec3 luminance = light.color;

        Ray light_ray;
        light_ray.origin = ray.position;
        light_ray.direction = normalize(light.position);
        light_ray.position = light_ray.origin;
        light_ray.step_size = MIN_STEP_SIZE;
        light_ray.steps = 0;
        light_ray.distance = 0.0;
        while (light_ray.steps < MAX_STEPS && light_ray.distance < MAX_DISTANCE)
        {
            float density = sampleDensity(light_ray, inside_sdf).a;
            if (!inside_sdf)
                break;

            luminance *= exp(-density * light_ray.step_size);
            test_color += 1.0;

            light_ray.position += light_ray.direction * light_ray.step_size;
            light_ray.distance += light_ray.step_size;
            light_ray.steps++;
        }

        float r = (3.0 / 16.0 / PI) * (1.0 + pow(dot(light_ray.direction, ray.direction), 2));
        luminance *= r;

        pixel_color.rgb += scattering * luminance * pixel_color.a * ray.step_size;
        pixel_color.a *= transmittance;

        ray.position += ray.direction * ray.step_size;
        ray.distance += ray.step_size;
        ray.steps++;
    }
    
    // return vec4(vec3(test_color/1e5), 0.0);
    return pixel_color;
}