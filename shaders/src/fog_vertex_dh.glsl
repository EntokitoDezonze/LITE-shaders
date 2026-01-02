#if !defined THE_END && !defined NETHER
    float fog_density_coeff2 = day_blend_float_lgcy(
        FOG_SUNSET * 1.25,
        FOG_DAY,
        FOG_NIGHT * 1.5
    ) * FOG_ADJUST;

    float fog_intensity_coeff = max(eye_bright_smooth.y * 0.004166666666666667, visible_sky);
    #if COLOR_SCHEME == 12
    fog_adj = pow(
        clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fog_intensity_coeff,
        mix(fog_density_coeff2 * 0.1, 0.8, rainStrength)
    );
    #else
    fog_adj = pow(
        clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0) * fog_intensity_coeff,
        clamp(mix(fog_density_coeff2 * biome_fog * 0.3, fog_density_coeff * 0.2 * biome_fog, rainStrength), 0.6, 100.0)
    );
    #endif
#else
    fog_adj = sqrt(clamp(gl_FogFragCoord / dhRenderDistance, 0.0, 1.0));
#endif