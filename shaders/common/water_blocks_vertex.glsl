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

uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float light_mix;
uniform float far;
uniform float nightVision;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float rainStrength;
uniform float wetness;
uniform mat4 gbufferProjectionInverse;
uniform vec4 lightningBoltPosition;
uniform float viewWidth; 
uniform float viewHeight; 
uniform int frameCounter;
uniform float frameTime;
#ifdef DISTANT_HORIZONS
    uniform int dhRenderDistance;
#endif

#ifdef DYN_HAND_LIGHT
    uniform int heldItemId;
    uniform int heldItemId2;
#endif

#ifdef UNKNOWN_DIM
    uniform sampler2D lightmap;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

#if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
    uniform float endFlashIntensity;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 tint_color;
varying float fog_adj;
varying vec3 water_normal;
varying float block_type;
varying vec4 worldposition;
varying vec3 fragposition;
varying vec3 tangent;
varying vec3 binormal;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying float visible_sky;
varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 mid_sky_color;
varying vec3 low_sky_color;
varying vec3 pure_hi_sky_color;
varying vec3 pure_mid_sky_color;
varying vec3 pure_low_sky_color;

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 shadow_pos;
    varying float shadow_diffuse;
#endif

#if (V_CLOUDS > 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
    varying float umbral;
    varying vec3 cloud_color;
    varying vec3 dark_cloud_color;
#endif

attribute vec4 mc_Entity;
attribute vec4 at_tangent;

/* Utility functions */

#if AA_TYPE > 1
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

/* Utility functions */

#include "/lib/luma.glsl"

#define FOG_BIOME
#define PREPARE_SHADER
#include "/lib/biome_sky.glsl"
#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);

    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex_water.glsl"
    
    resize_vertex(gl_Position);
    
    // Sky color calculation
    #include "/src/hi_sky.glsl"
    #include "/src/mid_sky.glsl"
    #include "/src/low_sky.glsl"

    #include "/src/light_vertex.glsl"

    water_normal = normal;

    tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
    binormal = normalize(gl_NormalMatrix * -cross(gl_Normal, at_tangent.xyz));

    // Special entities 3 - Water, 2 - Glass, -1 - Nether portal, ? - Other
    float is_water = step(abs(mc_Entity.x - ENTITY_WATER), 0.5);
    float is_stained_glass = max(step(abs(mc_Entity.x - ENTITY_STAINED), 0.5), step(abs(mc_Entity.x - ENTITY_ICE), 0.5));
    float is_white_glass = step(abs(mc_Entity.x - ENTITY_GLASS_WHITE), 0.5);
    float is_portal = step(abs(mc_Entity.x - ENTITY_PORTAL), 0.5);
    float is_ice = step(abs(mc_Entity.x - ENTITY_ICE), 0.5);

    block_type = mix(0.0, 3.0, is_water);
    block_type = mix(block_type, 2.0, is_stained_glass);
    block_type = mix(block_type, 2.2, is_white_glass);
    block_type = mix(block_type, 0.1, is_portal);
    block_type = mix(block_type, 2.4, is_ice);
    
    up_vec = normalize(gbufferModelView[1].xyz);

    #include "/src/fog_vertex.glsl"

    #if defined SHADOW_CASTING && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"
    #endif

    #if (V_CLOUDS > 0 && !defined UNKNOWN_DIM) && !defined NO_CLOUDY_SKY
        #include "/lib/volumetric_clouds_vertex.glsl"
    #endif
}
