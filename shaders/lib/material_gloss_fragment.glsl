#if defined THE_END
    vec3 material_gloss(vec3 reflected_vector, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal, vec3 lightColor) {
        vec3 astro_pos = (gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
        float astro_vector = max(dot(normalize(reflected_vector), normalize(astro_pos)), 0.0) * step(0.0001, dot(astro_pos, flat_normal));

        #if MC_VERSION < 11400
            return vec3(clamp(mix(0.0, 1.0, pow(clamp(astro_vector * 2.0 - 1.0, 0.0, 1.0), 5.0)), 0.0, 0.1));
        #else
            return vec3(clamp(mix(0.0, 1.0, pow(clamp(astro_vector * 2.0 - 1.0, 0.0, 1.0), 5.0)), 0.0, 0.5));
        #endif
    }  
#else
    vec3 material_gloss(vec3 reflected_vector, vec2 lmcoord_alt, float gloss_power, vec3 flat_normal, vec3 lightColor) {
        vec3 astro_pos = mix(-sunPosition, sunPosition, light_mix);
        float astro_vector = max(dot(normalize(reflected_vector), normalize(astro_pos)), 0.0) * step(0.0001, dot(astro_pos, flat_normal));
        float base_gloss_intensity = pow(clamp(astro_vector * 2.0 - 1.0, 0.0, 1.0), gloss_power);

        return clamp(
            base_gloss_intensity * saturate(lightColor, 0.25) * day_blend_float(2.0, 0.7, 3.0) * clamp(lmcoord_alt.y, 0.0, 1.0) * (1.1 - rainStrength) * abs(mix(1.333, -1.0, light_mix)),
            0.0,
            1.0
        );
    }
#endif

// SIMPLIFIED.