/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.7.3 - stars.glsl
Stars render fixed in world space. - Renderização de estrelas fixas no espaço do mundo. 

Based on https://www.shadertoy.com/view/Md2SR3
*/

#include "/lib/render_aux.glsl"

float NoisyStarField(in vec2 p_grid_coord, float fThreshhold) {
    float StarVal = noise2D_grid_inclined(p_grid_coord);
    
    if (StarVal >= fThreshhold) {
        StarVal = pow((StarVal - fThreshhold) / (1.0 - fThreshhold), 10.0); // <- Calculate stars
        
        #ifdef THE_END
            if (StarVal < 0.3) return 0.0;
        #else
            if (StarVal < 0.3) discard;
        #endif

        return clamp(StarVal, 0.1, 1.0);
    }

    #ifndef THE_END
        float discard_day = day_blend_float(0.1, 0.0, 1.0);
        if(discard_day < 0.01) return 0.0; // <- Discard stars during daytime on overworld
    #endif

    return 0.0;
}

vec3 stars() {
    #if (STAR_SLIDER == 2 && !defined THE_END && !defined NETHER) || (defined END_STARS && defined THE_END)
        
        vec2 resolution = vec2(viewWidth, viewHeight);
        
        vec3 dir = reconstructWorldPosition(gl_FragCoord.z, resolution); // <- Expensive function but necessary, prepare vertex calculates the position incorrectly.

    #ifndef THE_END
        if (sunPathRotation != 0.0) {
            float path_rotation_rad = sunPathRotation * 0.0174532925; // <- Degrees to radians.
            float tilt_c = cos(path_rotation_rad);
            float tilt_s = sin(-path_rotation_rad);

            float tilted_y = dir.y * tilt_c - dir.z * tilt_s;
            float tilted_z = dir.y * tilt_s + dir.z * tilt_c;
            
            dir.y = tilted_y;
            dir.z = tilted_z;
            
            float angle = sunAngle * 6.4 - 0.12;
            float c = cos(angle);
            float s = sin(angle);
            float new_x = dir.x * s - dir.z * c;
            float new_z = dir.x * c + dir.z * s;
            dir.x = new_x;
            dir.z = new_z;
        } else {
            float inv_y = dir.y;
            dir.y = dir.z; 
            dir.z = -inv_y; 
            float angle = sunAngle * 6.28318530718;
            float c = cos(angle);
            float s = sin(angle);
        
            float new_x = dir.x * c - dir.z * s;
            float new_z = dir.x * s + dir.z * c;
            
            dir.x = new_x;
            dir.z = new_z;
        }
    #endif
    // This calc makes the stars to follow the moon.

        vec2 p_spherical = cubic_uv(dir); 
        float star_scale = 400.0;
        vec2 p_continuous = p_spherical * star_scale;
        float star_density_threshold = 0.9925 - (0.015 * STARS_COVERAGE * STARS_COVERAGE);
        float star_brightness = STARS_BRIGHTNESS * 0.75;
        float star_intensity = NoisyStarField(p_continuous, star_density_threshold); // <- Draw stars
        vec3 final_color = vec3(star_intensity);

        #ifndef THE_END
            final_color *= day_blend_float_lgcy(0.1, 0.0, 1.0) * (star_brightness * 0.5 + 0.5);
        #endif

        #ifdef THE_END
            final_color *= vec3(0.75, 0.5, 1.0) * 2 * star_brightness;
        #endif

    #else
        vec3 final_color = vec3(0.0);
    #endif
    
    #if defined THE_END && !defined NETHER
        return (final_color * final_color * final_color);
    #else
        return final_color * final_color * final_color * 0.8;
    #endif
}