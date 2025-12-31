tint_color = gl_Color;

// Native light (lmcoord.x: candel, lmcoord.y: sky) ----
vec2 illumination = lmcoord;
illumination.y = max(illumination.y - 0.065, 0.0) * 1.06951871657754;
visible_sky = clamp(illumination.y, 0.0, 1.0);

// Underwater light adjust
if (isEyeInWater == 1) {
    visible_sky = (visible_sky * .95) + .05;
}

#if defined UNKNOWN_DIM
    visible_sky = (visible_sky * 0.99) + 0.01;
#endif

// Candels color and intensity
// --- OPTIMIZATION #1: Replace pow(x, 1.5) to x * sqrt(x) --- //
// LITE optimization: Replace pow(x, 15.0) to direct multiplications.

float light_pow;
#if defined GBUFFER_ENTITIES
    light_pow = 0.7;
#else
    light_pow = 1.2;
#endif

float illuminationx_2 = illumination.x * illumination.x * light_pow;
float illuminationx_4 = illuminationx_2 * illuminationx_2;
float illuminationx_8 = illuminationx_4 * illuminationx_4;
float illuminationx_15 = illuminationx_8 * illuminationx_4 * illuminationx_2 * illumination.x;

#if COLOR_SCHEME == 12
    candle_color = CANDLE_BASELIGHT * (illumination.x + illuminationx_8);
#else
    candle_color = CANDLE_BASELIGHT * (illuminationx_2 + illuminationx_15);
#endif

#ifdef DYN_HAND_LIGHT
    if (heldItemId == 11001 || heldItemId2 == 11001 || heldItemId == 11002 || heldItemId2 == 11002) {
        float dist_offset = (heldItemId == 11001 || heldItemId2 == 11001) ? 0.0 : 0.0;
        float hand_dist = (1.0 - clamp((gl_FogFragCoord * 0.06666666666666667) + dist_offset, 0.0, 1.0));

        float hand_dist_2 = hand_dist * hand_dist * light_pow;
        float hand_dist_4 = hand_dist_2 * hand_dist_2;
        float hand_dist_8 = hand_dist_4 * hand_dist_4;
        float hand_dist_15 = hand_dist_8 * hand_dist_4 * hand_dist_2 * hand_dist;

        // --- OPTIMIZATION #1 (again): Replace pow(x, 1.5) ---
        vec3 hand_light = CANDLE_BASELIGHT * (hand_dist * sqrt(hand_dist) + hand_dist_15);
        candle_color = max(candle_color, hand_light);
    }
#endif

#if defined GBUFFER_HAND
    candle_color *= 0.333 * vec3(0.9, 0.95, 1.0);
#endif

candle_color = clamp(candle_color, vec3(0.0), vec3(4.0));

// Atenuation by light angle ===================================
#if defined THE_END || defined NETHER
    vec3 sun_vec = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    vec3 sun_vec = sunPosition * 0.01;
#endif

vec3 normal = gl_NormalMatrix * gl_Normal;
float sun_light_strength;
// --- OPTIMIZATION #2: Avoid length() in condicional ---
if (dot(normal, normal) > 0.0001) { // Workaround for undefined normals
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

// Omni light intensity changes by angle
float omni_strength = (direct_light_strength * .125) + 1.0;

// Direct light color
#ifdef UNKNOWN_DIM
    direct_light_color = texture2D(lightmap, vec2(0.0, lmcoord.y)).rgb * day_blend_lgcy(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR * 1.5);
#else
    direct_light_color = day_blend_lgcy(
    LIGHT_SUNSET_COLOR * day_blend_lgcy(vec3(1.0), vec3(1.0, 1.0, 1.25), vec3(0.25)),  
    LIGHT_DAY_COLOR * day_blend_lgcy(vec3(1.0, 1.0, 1.25), vec3(1.25), vec3(1.0)), 
    LIGHT_NIGHT_COLOR * day_blend_float_lgcy(0.25, 1.0, 1.0));

    #if COLOR_SCHEME == 11
    direct_light_color *= day_blend_float(2.0, 1.25, 2.0);
    #endif
    
    #if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
        direct_light_color += (endFlashIntensity * endFlashIntensity * 0.05);
    #endif
#endif

// Direct light strength --
#ifdef FOLIAGE_V  // This shader has foliage
    float far_direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
    if (mc_Entity.x != ENTITY_LEAVES || mc_Entity.x != ENTITY_WHITE_LEAVES) {
        far_direct_light_strength = far_direct_light_strength * 0.75 + 0.25;
    }
    if (is_foliage > .2) {  // It's foliage, light is atenuated by angle
        #ifdef SHADOW_CASTING
            direct_light_strength = sqrt(abs(direct_light_strength));
        #else
            direct_light_strength = (clamp(direct_light_strength, 0.0, 1.0) * 0.5 + 0.5) * 0.5;
        #endif

        omni_strength = 1.0;
    } else {
        direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
    }
#else
    direct_light_strength = clamp(direct_light_strength, 0.0, 1.0);
#endif

#ifdef GBUFFER_TERRAIN
    if (mc_Entity.x == ENTITY_WHITE || mc_Entity.x == ENTITY_WHITE_POLISHED) {
    direct_light_strength *= 0.85;
    }
#endif

float vis_sky_2 = visible_sky * visible_sky;
float vis_sky_4 = vis_sky_2 * vis_sky_2;
float vis_sky_8 = vis_sky_4 * vis_sky_4;

// Omni light color
#if defined THE_END
    omni_light = LIGHT_DAY_COLOR;
#elif defined NETHER
    omni_light = LIGHT_DAY_COLOR * 2.0;
#else
    #if COLOR_SCHEME == 11
        float rain_mul = day_blend_float(0.5, 0.4, 0.4);
    #else
        float rain_mul = day_blend_float(0.4, 0.2, 0.333);
    #endif
    
    direct_light_color = mix(
        direct_light_color,
        ZENITH_SKY_RAIN_COLOR * luma(direct_light_color) * rain_mul,
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
        float luma_ratio = clamp(AVOID_DARK_LEVEL / omni_color_luma * 0.01, day_blend_float(0.7, 0.4, 0.0) / 4 * AVOID_DARK_LEVEL, 10.0);    
    #elif defined SIMPLE_AUTOEXP && COLOR_SCHEME == 11
        float luma_ratio = clamp(AVOID_DARK_LEVEL / omni_color_luma * 0.01, day_blend_float(0.4, 0.45, 0.6) / 4 * AVOID_DARK_LEVEL, 10.0);
    #else
        float luma_ratio = clamp(AVOID_DARK_LEVEL / omni_color_luma * 0.01, 0.03125 * AVOID_DARK_LEVEL, 10.0);
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

// Avoid flat illumination in caves for entities
#ifdef CAVEENTITY_V
    float candle_cave_strength = (direct_light_strength * .5) + .5;
    candle_cave_strength = mix(candle_cave_strength, 1.0, visible_sky);
    candle_color *= candle_cave_strength;
#endif

#if !defined THE_END && !defined NETHER
    #ifndef SHADOW_CASTING
        // Fake shadows
        if (isEyeInWater == 0) {
            direct_light_strength = mix(0.0, direct_light_strength, vis_sky_8 * vis_sky_2);
        } else {
            direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
        }
    #else
        direct_light_strength = mix(0.0, direct_light_strength, visible_sky);
    #endif
#endif