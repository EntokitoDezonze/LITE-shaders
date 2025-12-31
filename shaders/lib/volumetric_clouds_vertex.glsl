#if MC_VERSION >= 11300
    umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .25;
#else
    umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .45;
#endif

#if COLOR_SCHEME == 12
    umbral *= 0.75;
#endif

umbral *= CLOUD_DENSITY;

bool check = (lightningBoltPosition.w > 0.001);
float lightning = float(check);

vec3 antiRed = day_blend(vec3(1.0), vec3(0.0, 1.5, 1.0), vec3(1.0)); // Avoid red color in transition during tick 0 to ~3000

#if CLOUD_VOL_STYLE == 0
    dark_cloud_color = day_blend(
        ZENITH_SUNSET_COLOR,
        saturate(ZENITH_DAY_COLOR, 2.0) * 0.8,
        ZENITH_NIGHT_COLOR
    );
    
    vec3 cloud_color_aux = mix(
        day_blend(
            saturate(LIGHT_SUNSET_COLOR, 0.5) * day_blend_float(0.5, 0.5, 0.25),
            LIGHT_DAY_COLOR * 0.9,
            LIGHT_NIGHT_COLOR * 1.333
        ),
        ZENITH_SKY_RAIN_COLOR * day_blend_float(1.0, 0.75, 1.0) * saturate(dark_cloud_color, 0.2),
        rainStrength
    );
#else
    dark_cloud_color = day_blend(
        ZENITH_SUNSET_COLOR * 0.5,
        #if COLOR_SCHEME == 11
            ZENITH_DAY_COLOR * 0.5,
        #else
            ZENITH_DAY_COLOR * 1.5,
        #endif
        ZENITH_NIGHT_COLOR * 0.5
    );
    
    vec3 cloud_color_aux = mix(
        day_blend(
            saturate(LIGHT_SUNSET_COLOR, 0.5) * day_blend_float(0.6, 0.5, 0.15),
            LIGHT_DAY_COLOR * 0.9,
            saturate(LIGHT_NIGHT_COLOR, 0.5) * 1.5
        ),
        ZENITH_SKY_RAIN_COLOR * saturate(dark_cloud_color, 0.2) * day_blend_float(1.0, 0.85, 1.5),
        rainStrength
    );
#endif

dark_cloud_color = mix(
    dark_cloud_color,
    ZENITH_SKY_RAIN_COLOR * color_average(dark_cloud_color * day_blend_float(1.1, 1.0, 1.25)),
    rainStrength
);

cloud_color = mix(
    clamp(mix(v3_luma(cloud_color_aux), cloud_color_aux, 0.5) * vec3(1.5), 0.0, 1.4),
    day_blend(
        (MID_SUNSET_COLOR + HORIZON_SUNSET_COLOR) * day_blend_float(0.333, 0.333, 0.1) * antiRed,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR
    ),
    0.3
);

cloud_color = mix(cloud_color, (HORIZON_SKY_RAIN_COLOR + (HORIZON_SKY_RAIN_COLOR * lightning)) * luma(cloud_color_aux) * 5.0, rainStrength);

#if CLOUD_VOL_STYLE == 0
    dark_cloud_color = mix(dark_cloud_color, cloud_color, clamp(0.2 / (CLOUD_DENSITY), -1.0, 0.5));
#else
    dark_cloud_color = mix(dark_cloud_color, cloud_color, 0.3);
#endif

dark_cloud_color = mix(
    dark_cloud_color,
    day_blend(
        cloud_color_aux,
        dark_cloud_color,
        dark_cloud_color
    ),
    0.4
);

#if COLOR_SCHEME == 11
    cloud_color *= mix(1.75, 0.5, rainStrength);
    dark_cloud_color *= mix(1.75, 0.5, rainStrength);
#endif