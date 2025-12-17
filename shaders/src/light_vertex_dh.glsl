tint_color = gl_Color;

// Luz nativa (lmcoord.x: candela, lmcoord.y: cielo) ----
#if defined THE_END || defined NETHER
    vec2 illumination = vec2(lmcoord.x, 1.0);
#else
    vec2 illumination = lmcoord;
#endif

// OPTIMIZACIÓN: Reemplazar (max(x, c) - c) con max(x - c, 0), que puede ser marginalmente más rápido.
illumination.y = max(illumination.y - 0.065, 0.0) * 1.06951871657754;
visible_sky = clamp(illumination.y, 0.0, 1.0);

#if defined UNKNOWN_DIM
    visible_sky = (visible_sky * 0.6) + 0.4;
#endif

// Intensidad y color de luz de candelas
// --- OPTIMIZATION #1: Replace pow(x, 1.5) to x * sqrt(x) --- //
// LITE optimization: Replace pow(x, 1.5) to direct multiplications.

float illuminationx_2 = illumination.x * illumination.x * 1.3;
float illuminationx_4 = illuminationx_2 * illuminationx_2;
float illuminationx_8 = illuminationx_4 * illuminationx_4;
float illuminationx_15 = illuminationx_8 * illuminationx_4 * illuminationx_2 * illumination.x;

candle_color = CANDLE_BASELIGHT * (illumination.x * sqrt(illumination.x) + illuminationx_15);
candle_color = clamp(candle_color, vec3(0.0), vec3(4.0));

// Atenuación por dirección de luz directa ===================================
#if defined THE_END || defined NETHER
    vec3 sun_vec = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 sun_vec = sunPosition * 0.01;
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float sun_light_strength;

// --- OPTIMIZATION #2: Avoid length() in condicional ---
// Checking the squared length (dot product) is much faster than checking the length (sqrt).
if (dot(normal, normal) > 0.0001) {  // Workaround for undefined normals
    normal = normalize(normal);
    sun_light_strength = dot(normal, sun_vec);
} else {
    normal = vec3(0.0, 1.0, 0.0);
    sun_light_strength = 1.0;
}

#if defined THE_END || defined NETHER
    direct_light_strength = sun_light_strength;
#else
    direct_light_strength = mix(-sun_light_strength, sun_light_strength, light_mix);
#endif

// Intensidad por dirección
float omni_strength = (direct_light_strength * .125) + 1.0;     

// Direct light color
#ifdef UNKNOWN_DIM
    direct_light_color = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb * day_blend_lgcy(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR * 1.5);
#else
    direct_light_color = day_blend_lgcy(
    LIGHT_SUNSET_COLOR * day_blend_float_lgcy(1.0, 1.5, 0.0), 
    LIGHT_DAY_COLOR * day_blend_lgcy(vec3(1.0, 1.0, 1.5), vec3(1.25), vec3(1.0)), 
    LIGHT_NIGHT_COLOR * day_blend_float_lgcy(0.0, 1.0, 1.0));

    #if COLOR_SCHEME == 11
    direct_light_color *= day_blend_float(2.0, 1.25, 2.0);
    #endif
    
    #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
        direct_light_color += (endFlashIntensity * endFlashIntensity * 0.05);
    #endif
#endif

direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);

float vis_sky_2 = visible_sky * visible_sky;
float vis_sky_4 = vis_sky_2 * vis_sky_2;
float vis_sky_8 = vis_sky_4 * vis_sky_4;

// Omni light color
#if defined THE_END
    omni_light = LIGHT_DAY_COLOR;
#elif defined NETHER
    omni_light = LIGHT_DAY_COLOR * 2.0;
#else
    direct_light_color = mix(
        direct_light_color,
        ZENITH_SKY_RAIN_COLOR * luma(direct_light_color) * day_blend_float(0.4, 0.2, 1.5),
        rainStrength
    );

    // Minimal light / Omni color
    #if COLOR_SCHEME == 8
        vec3 omni_color = saturate(mix(hi_sky_color_rgb * day_blend_float(4.0, 3.75, 4.0) * (OMNI_MUL + 0.15), direct_light_color * day_blend_float(1.5, 0.3, 7.0) * OMNI_MUL, OMNI_TINT), 0.333);
    #elif COLOR_SCHEME == 11
        vec3 omni_color = direct_light_color * (OMNI_MUL + day_blend_float(0.1, 0.1, 0.5));
    #else
        vec3 omni_color = mix(hi_sky_color_rgb, direct_light_color * 0.45, OMNI_TINT) * (OMNI_MUL + 0.7);
    #endif

    float omni_color_luma = luma(omni_color);
    
    #if defined SIMPLE_AUTOEXP && COLOR_SCHEME != 11
        float luma_ratio = clamp(AVOID_DARK_LEVEL / omni_color_luma * 0.01, day_blend_float(0.7, 0.4, 0.0), 1.0);    
    #elif defined SIMPLE_AUTOEXP && COLOR_SCHEME == 11
        float luma_ratio = clamp(AVOID_DARK_LEVEL / omni_color_luma * 0.01, day_blend_float(0.4, 0.45, 0.6), 1.0);
    #else
        float luma_ratio = clamp(AVOID_DARK_LEVEL / omni_color_luma * 0.01, 0.125, 1.0);
    #endif
    
    vec3 omni_color_min = omni_color * luma_ratio;
    omni_color = max(omni_color, omni_color_min);

    #ifndef SIMPLE_AUTOEXP
        omni_color_min = mix(omni_color_min, omni_color_min * day_blend_float(1.0, 10.0, 1.5), vis_sky_2);
    #endif

    #if defined SIMPLE_AUTOEXP
        omni_light = mix(omni_color_min, omni_color * 2, vis_sky_4);
    #else
        omni_light = mix(omni_color_min, omni_color, vis_sky_4);
    #endif
#endif

if (isEyeInWater == 0) {
    direct_light_strength = mix(0.0, direct_light_strength, vis_sky_8 * vis_sky_2);
} else {
    direct_light_strength = mix(0.0, direct_light_strength, vis_sky_4);
}

if (dhMaterialId == DH_BLOCK_ILLUMINATED) {
    direct_light_strength = 10.0;
} else if (dhMaterialId == DH_BLOCK_LAVA) {
    direct_light_strength = 1.0;
}