#if COLOR_SCHEME == 8
vec3 mid_sky_color_rgb = day_blend(
        saturate(MID_SUNSET_COLOR, day_blend_float_lgcy(1.0, 1.0, 0.333)) * day_blend(vec3(1.0), vec3(1.0), vec3(1.6, 1.6, 1.5) * 1.25),
        MID_DAY_COLOR,
        saturate(MID_NIGHT_COLOR, day_blend_float(1.0, 1.0, 0.0)) * day_blend_float(1.0, 1.0, 1.25)
    );

    mid_sky_color_rgb = mix(
        mid_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(mid_sky_color_rgb * day_blend_float(1.0, 1.0, 0.75)),
        rainStrength
    );

    mid_sky_color = rgb_to_xyz(mid_sky_color_rgb);
#else
vec3 mid_sky_color_rgb = day_blend(
        MID_SUNSET_COLOR,
        MID_DAY_COLOR,
        MID_NIGHT_COLOR
    );

    mid_sky_color_rgb = mix(
        mid_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(mid_sky_color_rgb * 1.25),
        rainStrength
    );

    mid_sky_color = rgb_to_xyz(mid_sky_color_rgb);
#endif

vec3 pure_mid_sky_color_rgb = day_blend(
        saturate(MID_SUNSET_COLOR, 0.5),
        MID_DAY_COLOR,
        MID_NIGHT_COLOR
    );

    pure_mid_sky_color_rgb = mix(
        pure_mid_sky_color_rgb,
        HORIZON_SKY_RAIN_COLOR * luma(pure_mid_sky_color_rgb * 1.25) * day_blend_float(1.0, 1.0, 2.0),
        (rainStrength - 0.05)
    );

    pure_mid_sky_color = rgb_to_xyz(pure_mid_sky_color_rgb);