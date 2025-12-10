#include "/lib/config.glsl"

/* Color utils */

#ifdef THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform mat4 gbufferModelView;
uniform float rainStrength;
uniform float wetness;
uniform float viewWidth;
uniform float viewHeight;
uniform vec4 lightningBoltPosition;
uniform float frameTime;

/* Ins / Outs */

varying vec2 texcoord;
varying vec3 up_vec;
varying vec3 direct_light_color;
varying vec3 direct_light_strength;

#if (V_CLOUDS > 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying float dynamicValue;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

#if AO == 1
    varying float fog_density_coeff;
#endif

/* Utility functions */

#include "/lib/luma.glsl"
#include "/lib/oscilator_utils.glsl"
#include "/lib/biome_sky.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    texcoord = gl_MultiTexCoord0.xy;

    up_vec = normalize(gbufferModelView[1].xyz);

    direct_light_color = day_blend(LIGHT_SUNSET_COLOR, LIGHT_DAY_COLOR, LIGHT_NIGHT_COLOR);
    direct_light_color = mix(direct_light_color, ZENITH_SKY_RAIN_COLOR * luma(direct_light_color), rainStrength);
    direct_light_strength = v3_luma(direct_light_color * 2);

    #if AO == 1
        fog_density_coeff = day_blend_float_lgcy(FOG_SUNSET, FOG_DAY, FOG_NIGHT) * FOG_ADJUST * 0.1;
    #endif

    #if (V_CLOUDS > 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
        float minVal = 0.95;
        float maxVal = 1.25;
        float oscillatorSpeed = WIND_FORCE;
        dynamicValue = oscillation(TotalWorldTime * 251.32741228718345, minVal, maxVal, oscillatorSpeed); // ~18000 ticks cycle
        #include "/lib/volumetric_clouds_vertex.glsl"
        #if CLOUD_VOL_STYLE == 0
            umbral *= dynamicValue;
        #endif
    #endif
}