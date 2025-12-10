#ifdef UNKNOWN_DIM
    vec3 hi_sky_color_rgb = skyColor;
    hi_sky_color = rgb_to_xyz(hi_sky_color_rgb);
#else
    #if COLOR_SCHEME == 8
    vec3 hi_sky_color_rgb = day_blend(
            saturate(ZENITH_SUNSET_COLOR, day_blend_float_lgcy(1.0, 1.0, 1.5)) * day_blend(vec3(1.0), vec3(1.0), vec3(1.6, 1.1, 1.0) * 0.5),
            ZENITH_DAY_COLOR,
            saturate(ZENITH_NIGHT_COLOR, 0.25) * day_blend_float_lgcy(1.0, 1.0, 1.25)
        );

        hi_sky_color_rgb = mix(
            hi_sky_color_rgb,
            ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb) * day_blend_float(1.0, 1.0, 1.25),
            rainStrength
        );

        hi_sky_color = rgb_to_xyz(hi_sky_color_rgb);
    #else
        vec3 hi_sky_color_rgb = day_blend(
            ZENITH_SUNSET_COLOR,
            ZENITH_DAY_COLOR,
            ZENITH_NIGHT_COLOR
        );

        #if COLOR_SCHEME == 11
            hi_sky_color_rgb = mix(
                hi_sky_color_rgb,
                ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb) * 0.333,
                rainStrength
            );
        #else
            hi_sky_color_rgb = mix(
                hi_sky_color_rgb,
                ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color_rgb),
                rainStrength
            );
        #endif

        hi_sky_color = rgb_to_xyz(hi_sky_color_rgb);
    #endif
#endif

vec3 pure_hi_sky_color_rgb = day_blend(
        ZENITH_SUNSET_COLOR,
        ZENITH_DAY_COLOR,
        saturate(ZENITH_NIGHT_COLOR, 0.5)
    );

    pure_hi_sky_color_rgb = mix(
        pure_hi_sky_color_rgb,
        ZENITH_SKY_RAIN_COLOR * luma(pure_hi_sky_color_rgb),
        rainStrength
    );

    pure_hi_sky_color = rgb_to_xyz(pure_hi_sky_color_rgb);