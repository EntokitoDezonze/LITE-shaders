#include "/lib/config.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;
varying vec3 cursed_sky;
varying float current_wetness;

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

/* Uniforms */

uniform float rainStrength;
uniform mat4 gbufferModelViewInverse;

/* Utility functions */

#include "/lib/luma.glsl"

// MAIN FUNCTION ------------------

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    tint_color = gl_Color;

    #ifndef CUSTOM_SKYFIX
        float C = 70.0; // Moon brightness

        sky_luma_correction = luma(day_blend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR));

        float log_base = log(C + 1.0);

        #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
            float day_blend_val = 3.0;
            sky_luma_correction = day_blend_val * log(sky_luma_correction * C + 1.0) / log_base;
        #else
            float day_blend_val  = day_blend_float(2.0, 2.25, 1.7);
            sky_luma_correction = day_blend_val * log(sky_luma_correction * C + 1.0) / log_base;
        #endif

        current_wetness = mix(1.0, 0.0, rainStrength);

        #if COLOR_SCHEME == 12
            cursed_sky = day_blend(vec3(2.0), vec3(1.0), vec3(4.0, 0.5, 0.5));
            sky_luma_correction *= day_blend_float(0.5, 0.0, 1.0);
        #endif

        sky_luma_correction *= day_blend_float(SUN_MUL, SUN_MUL, MOON_MUL);
    #else
        sky_luma_correction = 1.0;
        cursed_sky = vec3(1.0);
        current_wetness = mix(1.0, 0.0, rainStrength);
    #endif


    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    #if AA_TYPE > 0
        gl_Position.xy += taa_offset * gl_Position.w;
    #endif
}
