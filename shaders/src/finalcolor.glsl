float fog_correction;
#if VOL_LIGHT < 1
    fog_correction = mix(1.0, 1.275, final_sun_factor);
#else
    fog_correction = 1.0;
#endif

#if V_CLOUDS > 0
    fog_correction = mix(1.0, 1.35, final_sun_factor);
#else
    fog_correction = mix(1.0, 1.0, final_sun_factor);
#endif

#if VOL_LIGHT > 0 && V_CLOUDS > 0
    fog_correction /= mix(1.0, 1.35, final_sun_factor);
#endif


float fog_adj2 = mix(fog_adj, clamp(fog_adj * 1.75, 0.0, 2.0 - final_sun_factor), final_sun_factor);


#if defined THE_END
    #ifdef FOG_ACTIVE
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            block_color.rgb = mix(block_color.rgb, ZENITH_DAY_COLOR * 1.1 * vec3(1.2, 1.3, 1.2), fog_adj);
        }
    #endif
#elif defined NETHER
    #ifdef FOG_ACTIVE
        if(isEyeInWater == 0 && FOG_ADJUST < 15.0) {  // In the air
            block_color.rgb = mix(block_color.rgb, mix(fogColor * 0.25, vec3(0.5), 0.025), fog_adj);
        }
    #endif
#else
    #ifdef FOG_ACTIVE  // Fog active
        #if MC_VERSION >= 11900
            vec3 fog_texture;
            if(darknessFactor > .01) {
                fog_texture = vec3(0.0);
            } else {
                fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb * fog_correction;
            }
        #else
            vec3 fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb * fog_correction;
        #endif
        #if defined GBUFFER_ENTITIES
            if(isEyeInWater == 0 && entityId != 10101 && FOG_ADJUST < 15.0) {  // In the air
                block_color.rgb = mix(block_color.rgb, fog_texture, fog_adj);
            }
        #else
            if(isEyeInWater == 0) {  // In the air
                block_color.rgb = mix(block_color.rgb, fog_texture, fog_adj);
            }
        #endif
    #endif
#endif

#if MC_VERSION >= 11900
    if(blindness > .01 || darknessFactor > .01) {
        block_color.rgb = mix(block_color.rgb, vec3(0.0), max(blindness, darknessLightFactor) * gl_FogFragCoord * 0.0);
    }
#else
    if(blindness > .01) {
        block_color.rgb = mix(block_color.rgb, vec3(0.0), blindness * gl_FogFragCoord * 0.2);
    }
#endif