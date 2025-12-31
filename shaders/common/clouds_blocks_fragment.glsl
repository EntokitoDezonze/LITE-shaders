#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;
uniform float far;
uniform float blindness;
uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;
uniform float viewWidth;
uniform float viewHeight;

#if MC_VERSION >= 11900
    uniform float darknessFactor;
    uniform float darknessLightFactor;
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    uniform float pixel_size_x;
    uniform float pixel_size_y;
    uniform sampler2D gaux4;
#endif

/* Ins / Outs */

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
    varying vec2 texcoord;
    varying vec4 tint_color;
#endif

#include "/lib/day_blend.glsl"
#include "/lib/luma.glsl"

#define FRAGMENT
#include "/lib/downscale.glsl"

// Main function ---------

void main() {
    if(fragment_cull()) discard;
    #if V_CLOUDS == 0 || defined UNKNOWN_DIM
        vec4 block_color = texture2D(tex, texcoord * RENDER_SCALE) * tint_color;
        #if COLOR_SCHEME == 11
            block_color.rgb *= day_blend_float(1.0, 1.9, 0.25);
            block_color.rgb = saturate(block_color.rgb, day_blend_float(1.0, 0.0, 0.5));
        #elif COLOR_SCHEME == 8
            block_color.rgb *= day_blend_float(0.333, 1.25, 0.333);
        #elif COLOR_SCHEME == 12
            block_color.rgb *= day_blend_float(0.05, 0.1, 0.025);
        #endif

        block_color.a = 0.95;
        block_color.rgb *= 0.8;
        #include "/src/cloudfinalcolor.glsl"
        #include "/src/writebuffers.glsl"
    #elif MC_VERSION <= 11300
        vec4 block_color = vec4(0.0);
        #include "/src/writebuffers.glsl"
    #endif
}
