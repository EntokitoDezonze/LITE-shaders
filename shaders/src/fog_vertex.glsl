#if !defined THE_END && !defined NETHER

    // Fog intensity calculation
    float fog_density_coeff = day_blend_float_lgcy(
        FOG_SUNSET,
        FOG_DAY,
        mix(FOG_NIGHT, FOG_NIGHT * 1.5, rainStrength)
    ) * FOG_ADJUST;

    float fog_intensity_coeff = max(eye_bright_smooth.y * 0.004166666666666667, visible_sky);

    #ifdef DISTANT_HORIZONS
        #if COLOR_SCHEME == 12
        fog_adj = pow(
            clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fog_intensity_coeff,
            mix(fog_density_coeff * 0.1, 0.8, rainStrength)
        );
        #else
        fog_adj = pow(
            clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fog_intensity_coeff,
            mix(fog_density_coeff * biome_fog * 0.3, fog_density_coeff * 0.2 * biome_fog, rainStrength)
        );
        #endif
    #else
        #if COLOR_SCHEME == 12
        fog_adj = pow(
            clamp(gl_FogFragCoord / far, 0.0, 1.0) * fog_intensity_coeff,
            mix(fog_density_coeff * 0.1, 0.8, rainStrength)
        );
        #else
        fog_adj = pow(
            clamp(gl_FogFragCoord / far, 0.0, 1.0) * fog_intensity_coeff,
            mix(fog_density_coeff * biome_fog, fog_density_coeff * biome_fog * 0.2, rainStrength)
        );
        #endif
    #endif

#else
    #if defined NETHER
        #if NETHER_FOG_DISTANCE == 1
            float sight = NETHER_SIGHT;
        #else
            #if defined DISTANT_HORIZONS
                float sight = dhRenderDistance;
            #else
                float sight = clamp(NETHER_SIGHT * (FOG_ADJUST * 0.5), 0.0, far * 1.5);
            #endif
        #endif
    #else
        #if defined DISTANT_HORIZONS
            float sight = dhRenderDistance;
        #else
            float sight = far  * 0.75;
        #endif
    #endif
    
    fog_adj = sqrt(clamp(gl_FogFragCoord / sight, 0.0, 1.0));
#endif
