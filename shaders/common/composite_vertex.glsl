#include "/lib/config.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    uniform int isEyeInWater;
#endif

#if VOL_LIGHT == 1 && !defined NETHER
    uniform float light_mix;
    uniform vec3 sunPosition;
    uniform vec3 moonPosition;
    uniform mat4 gbufferProjection;
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    uniform mat4 gbufferModelViewInverse;
    uniform mat4 gbufferProjectionInverse;
#endif

uniform sampler2D colortex1;
uniform sampler2D gaux3;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTime;
uniform float frameTimeCounter;

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 direct_light_color;
varying vec3 direct_light_strength;

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    varying vec3 vol_light_color;  // Flat
#endif

varying float exposure;  // Flat

#if VOL_LIGHT == 1 && !defined NETHER
    varying vec2 lightpos;  // Flat
    varying vec3 astro_pos;  // Flat
#endif

#if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    varying mat4 modeli_times_projectioni;
#endif

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    direct_light_color = day_blend_lgcy(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    direct_light_color = mix(direct_light_color, ZENITH_SKY_RAIN_COLOR * luma(direct_light_color), rainStrength);
    direct_light_strength = v3_luma(direct_light_color * 2);

    // Exposure
    #if !defined SIMPLE_AUTOEXP
        float mipmap_level = log2(min(viewWidth, viewHeight)) - 1.0;

        vec3 exposure_col = texture2DLod(colortex1, vec2(0.5), mipmap_level).rgb;
        exposure_col += texture2DLod(colortex1, vec2(0.25), mipmap_level).rgb;
        exposure_col += texture2DLod(colortex1, vec2(0.75), mipmap_level).rgb;
        exposure_col += texture2DLod(colortex1, vec2(0.25, 0.75), mipmap_level).rgb;
        exposure_col += texture2DLod(colortex1, vec2(0.75, 0.25), mipmap_level).rgb;
        
        exposure = clamp(luma(exposure_col), 0.0005, 100.0);

        float prev_exposure = texture2D(gaux3, vec2(0.5)).r;

        exposure = (exp(-exposure) * 3.25) + 0.6;
        exposure = mix(exposure, prev_exposure, exp(-frameTime * 1.5));
    #else
        exposure = 1.0;
    #endif

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        float vol_attenuation;
        if(isEyeInWater == 0) {
            vol_attenuation = 1.0;
        } else {
            vol_attenuation = 0.5 + (eye_bright_smooth.y * 0.002);
        }

        #ifdef THE_END
            vol_light_color = saturate(LIGHT_SUNSET_COLOR * 0.75, 2.0) * vol_attenuation,
        #else
            vol_light_color = day_blend(
                saturate(LIGHT_SUNSET_COLOR * day_blend_float(1.0, 1.0, 0.0), day_blend_float_lgcy(1.0, 1.0, 0.0)) * vol_attenuation,
                LIGHT_DAY_COLOR * vol_attenuation,
                LIGHT_NIGHT_COLOR * 0.85);
        #endif
    #endif

    #if VOL_LIGHT == 1 && !defined NETHER
        astro_pos = sunPosition * smoothstep(0.1, 0.8, light_mix) * 2.0 + moonPosition;
        vec4 tpos = vec4(astro_pos, 1.0) * gbufferProjection;
        tpos = vec4(tpos.xyz / tpos.w, 1.0);
        vec2 pos1 = tpos.xy / tpos.z;
        lightpos = pos1 * 0.5 + 0.5;
    #endif

    #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
        modeli_times_projectioni = gbufferModelViewInverse * gbufferProjectionInverse;
    #endif
}
