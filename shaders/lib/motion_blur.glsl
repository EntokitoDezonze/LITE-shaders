/* MakeUp - LITE shaders 4.9 - motion_blur.glsl
Motion blur functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 motion_blur(vec3 color, float the_depth, vec2 blur_velocity, sampler2D image) {
    if(fragment_cull()) discard;
    if ((the_depth > 0.75 && the_depth < 1.0) && all(greaterThan(color, vec3(0.2)))) {  // No hand, no clouds
        vec2 double_pixels = 2.0 * vec2(pixel_size_x, pixel_size_y) / RENDER_SCALE;
        vec3 m_blur = vec3(0.0);
        
        blur_velocity =
            (MOTION_BLUR_STRENGTH * blur_velocity) / ((1.0 + length(blur_velocity)) * (frameTime * 500));

        vec2 coord = texcoord - blur_velocity * 1.5 * RENDER_SCALE;

        float weight = 0.0;
        vec2 sample_coord;
        vec3 b_sample;
        for(int i = 0; i < clamp(MOTION_BLUR_SAMPLES * RENDER_SCALE, 2.0, 8.0); i++, coord += blur_velocity) {

            sample_coord = clamp(coord, double_pixels, 1.0 - double_pixels);

            b_sample = texture2D(image, sample_coord).rgb;
            m_blur += b_sample;
            weight++;
        }
        m_blur /= max(weight, 1.0);

        return m_blur;
    } else {
        return color.rgb;
    }
}