#include "/lib/config.glsl"
#include "/lib/luma.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform sampler2D gaux4;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float rainStrength;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;
uniform float frameTime;
#if STAR_SLIDER == 2 || defined THE_END
    uniform float frameTimeCounter;
    uniform vec3 cameraPosition;
    uniform mat4 gbufferModelViewInverse;
    uniform float sunAngle;
#endif

#if COLOR_SCHEME == 8
    uniform vec3 sunPosition;
#endif

#if MC_VERSION < 11604
    uniform vec4 lightningBoltPosition;
#endif

/* Ins / Outs */

#if MC_VERSION < 11604
    varying vec3 hi_sky_color;
    varying vec3 mid_sky_color;
    varying vec3 low_sky_color;
    varying vec3 pure_hi_sky_color;
    varying vec3 pure_mid_sky_color;
    varying vec3 pure_low_sky_color;
#endif

varying vec4 star_data;
varying vec3 up_vec;
varying vec4 position;

/* Utility functions */

#if STAR_SLIDER == 2 || AA_TYPE > 0
    #include "/lib/dither.glsl"
#endif

#if (STAR_SLIDER == 2 || defined THE_END) && !defined NETHER
    #include "/lib/stars.glsl"
#endif

#include "/lib/biome_sky.glsl"
#define FRAGMENT
#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    if(fragment_cull()) discard;
    #if (STAR_SLIDER == 2 || defined THE_END) && !defined NETHER
        vec4 star_color = vec4(stars(), 1.0);
    #endif
    
    float vanilla_mul;
    #if defined THE_END
        vec4 background_color = vec4(ZENITH_DAY_COLOR, 1.0) + star_color;
        vec4 block_color = vec4(ZENITH_DAY_COLOR + star_color.rgb, 1.0);
        vanilla_mul = 1.0;
    #elif defined NETHER  // Unused
        vec4 background_color = vec4(mix(fogColor * 0.1, vec3(1.0), 0.04), 1.0);
        vec4 block_color = vec4(mix(fogColor * 0.1, vec3(1.0), 0.04), 1.0);
        vanilla_mul = 1.0;
    #else
        #if MC_VERSION < 11604
            #include "/src/get_sky.glsl"
        #else
            vec4 background_color = texture2DLod(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y), 0);
            vec3 sky_color = vec3(0.0);
        #endif

        #if STAR_SLIDER == 2
            #if MC_VERSION >= 11604
                if (star_data.r > 0.0) discard;
                vec4 block_color = vec4(sky_color + star_color.rgb, 1.0);
            #else
                vec4 block_color = star_data * STARS_BRIGHTNESS;
            #endif
        #elif STAR_SLIDER == 1
            vec4 block_color = star_data * STARS_BRIGHTNESS;
        #else
            if (star_data.r > 0.0) discard;
            vec4 block_color = vec4(0.0);
        #endif

        #if COLOR_SCHEME == 11// LITE Vanilla
            vanilla_mul = 1.2;
        #else
            vanilla_mul = 1.0;
        #endif

        block_color = mix(background_color, block_color * vanilla_mul, block_color);

        #if MC_VERSION >= 11604
            block_color.a = star_data.a;
        #endif
    #endif
    
    #include "/src/writebuffers.glsl"
}
