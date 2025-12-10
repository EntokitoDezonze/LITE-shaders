/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.7.3 - post_processing.glsl #include "/lib/post_processing.glsl"
Utilities, effects and fake effects. - Utilidades, efeitos e efeitos falsos. */


#ifdef VIGNETTE
    float vignette(vec2 uv) {
    vec2 pos = uv - 0.5;
        float dist = length(pos * VIGNETTE_FACTOR);
    return smoothstep(0.8, 0.4, dist);
    }
#endif // Vignette

#ifdef FAKE_BLOOM
    vec3 fakeBloom(vec3 color, float threshold) {
        vec3 bloom = max(color - threshold, 0.0);
        return color + bloom * 0.1 * BLOOM_STRENGTH;
    } // Fake Bloom
#endif

#ifdef FILM_GRAIN
    float noise(vec2 uv) {
        return fract(sin(dot(uv, vec2(12.9898, 78.233))) * frameCounter * 10);
    }

    vec3 filmGrain(vec3 color, float grainIntensity, vec2 uv) {
        float grain = noise(uv * 10.0); 
        grain = (grain - 0.5) * 2.0;
        return color + grain * grainIntensity;
    } // Film grain
#endif

#if AA_TYPE == 3
    // Sharpening filter.
    // Unsharp Masking Principles - https://thebookofshaders.com/
    // Adapted.

    vec3 sharpen(sampler2D image, vec3 color, vec2 coords) {
        float force = SHARP_FORCE;
        float sample_radius_px = 1.0;
        float threshold = 0.0;

        vec2 offset_x = vec2(sample_radius_px * pixel_size_x, 0.0);
        vec2 offset_y = vec2(0.0, sample_radius_px * pixel_size_y);

        vec3 left_c    = texture2DLod(image, coords - offset_x, 0.0).rgb;
        vec3 right_c   = texture2DLod(image, coords + offset_x, 0.0).rgb;
        vec3 top_c     = texture2DLod(image, coords - offset_y, 0.0).rgb;
        vec3 bottom_c  = texture2DLod(image, coords + offset_y, 0.0).rgb;

        vec3 blurred_color_sum = color;
        blurred_color_sum += left_c;
        blurred_color_sum += right_c;
        blurred_color_sum += top_c;
        blurred_color_sum += bottom_c;

        vec3 blurred_color = blurred_color_sum / 5.0;

        vec3 high_pass_details = color - blurred_color;
        vec3 sharpened_color = color + high_pass_details * force;

        float brightness = luma(color);

        float contrast = max(
            max(length(color - left_c), length(color - right_c)),
            max(length(color - top_c),  length(color - bottom_c))
        );

        // Adaptative contrast
        float haloFade = clamp(1.0 - contrast, 0.0, 1.0);
        float brightnessFactor = clamp(1.0 - brightness, 0.0, 1.0);
        float thresholdMix = smoothstep(0.0, threshold, contrast);

        float finalMix = brightnessFactor * haloFade * thresholdMix;

        return mix(color, sharpened_color, finalMix);
    }
#endif