vec3 get_shadow(vec3 the_shadow_pos, float dither) {
    float shadow_sample = 1.0;

    #if SHADOW_TYPE == 0 // Pixelated
        shadow_sample = shadow2D(shadowtex1, the_shadow_pos).r;
    #elif SHADOW_TYPE == 1 // Soft
        float current_radius = dither;
        float dither_angle = dither * 6.283185307179586;
        
        vec2 offset = (vec2(cos(dither_angle), sin(dither_angle)) * current_radius * SHADOW_BLUR) / shadowMapResolution;
        float z_bias = dither_angle * 0.00002;

        float sample1 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
        float sample2 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;

        shadow_sample = (sample1 + sample2) * 0.5;
    #endif

    return vec3(shadow_sample);
}

#if defined COLORED_SHADOW

    vec3 get_colored_shadow(vec3 the_shadow_pos, float dither) {
        #if SHADOW_TYPE == 0 // Pixelated
            float shadow_detector = shadow2D(shadowtex0, the_shadow_pos).r;
            float shadow_black = shadow2D(shadowtex1, the_shadow_pos).r;
            
            vec3 final_color = vec3(1.0);
            if (shadow_detector < 1.0) {
                if (shadow_black != shadow_detector) {
                    vec4 colored_tex = texture2D(shadowcolor0, the_shadow_pos.xy);
                    float alpha_complement = 1.0 - colored_tex.a;
                    colored_tex.rgb = mix(colored_tex.rgb, vec3(1.0), alpha_complement) * alpha_complement;
                    final_color = colored_tex.rgb;
                }
            }

            final_color = mix(final_color, vec3(0.0), 1.0 - shadow_black);
            final_color = saturate(final_color, 3.0);
            final_color = clamp(final_color * (1.0 - shadow_detector) + shadow_detector, vec3(0.0), vec3(1.0));
            
            return final_color;

        #elif SHADOW_TYPE == 1 // Soft
            float current_radius = dither;
            float dither_angle = dither * 6.283185307179586;
            
            vec2 offset = (vec2(cos(dither_angle), sin(dither_angle)) * current_radius * SHADOW_BLUR) / shadowMapResolution;
            float z_bias = dither_angle * 0.00002;

            vec3 final_color;

            // Sample 1
            float detector1 = shadow2D(shadowtex0, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
            float black1 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy + offset, the_shadow_pos.z - z_bias)).r;
            vec4 color1 = texture2D(shadowcolor0, the_shadow_pos.xy + offset);

            // Sample 2
            float detector2 = shadow2D(shadowtex0, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;
            float black2 = shadow2D(shadowtex1, vec3(the_shadow_pos.xy - offset, the_shadow_pos.z - z_bias)).r;
            vec4 color2 = texture2D(shadowcolor0, the_shadow_pos.xy - offset);

            vec3 processed_color1 = vec3(1.0);
            if (detector1 < 1.0 && black1 != detector1) {
                float alpha_complement = 1.0 - color1.a;
                processed_color1 = mix(color1.rgb, vec3(1.0), alpha_complement) * alpha_complement;
            }
            processed_color1 = mix(processed_color1, vec3(0.0), 1.0 - black1);

            vec3 processed_color2 = vec3(1.0);
            if (detector2 < 1.0 && black2 != detector2) {
                float alpha_complement = 1.0 - color2.a;
                processed_color2 = mix(color2.rgb, vec3(1.0), alpha_complement) * alpha_complement;
            }
            processed_color2 = mix(processed_color2, vec3(0.0), 1.0 - black2);

            final_color = (processed_color1 + processed_color2) * 0.5;
            final_color = saturate(final_color, 3.0);
            float final_detector = (detector1 + detector2) * 0.5;
            
            return clamp(mix(final_color, vec3(1.0), final_detector), vec3(0.0), vec3(1.0));
        #endif
    }
#endif