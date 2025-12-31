#include "/lib/config.glsl"

/* Color utils */

#if defined THE_END
    #include "/lib/color_utils_end.glsl"
#elif defined NETHER
    #include "/lib/color_utils_nether.glsl"
#else
    #include "/lib/color_utils.glsl"
#endif

/* Uniforms */

uniform sampler2D gaux3;
uniform float viewWidth;
uniform float viewHeight;
uniform vec3 sunPosition;
uniform int isEyeInWater;
uniform float light_mix;
uniform float far;
uniform float rainStrength;
uniform float wetness;
uniform ivec2 eyeBrightnessSmooth;
uniform mat4 gbufferProjectionInverse;
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

#if defined FOLIAGE_V || defined THE_END || defined NETHER
    uniform mat4 gbufferModelView;
#endif

uniform mat4 gbufferModelViewInverse;

#if defined MATERIAL_GLOSS && !defined NETHER
    uniform int worldTime;
    uniform vec3 moonPosition;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform vec3 shadowLightPosition;
#endif

#if WAVING == 1
    uniform vec3 cameraPosition;
    uniform float frameTimeCounter;
#endif

#if defined IS_IRIS && defined THE_END && MC_VERSION >= 12109
    uniform float endFlashIntensity;
#endif

/* Ins / Outs */

varying vec2 texcoord;
varying vec4 tint_color;
varying float fog_adj;
varying vec3 direct_light_color;
varying vec3 candle_color;
varying float direct_light_strength;
varying vec3 omni_light;
varying float block_type_f;
varying float exposure;
varying float depth;

#if defined EMMISIVE_MATERIAL || defined EMMISIVE_ORE
    varying float ore_type_f;
    varying float emitter_type_f;
#endif

#ifdef FOLIAGE_V
    varying float is_foliage;
#endif

#if defined SHADOW_CASTING && !defined NETHER
    varying vec3 shadow_pos;
    varying float shadow_diffuse;
#endif

#if defined MATERIAL_GLOSS && !defined NETHER
    varying vec3 flat_normal;
    varying vec3 sub_position3;
    varying vec3 sub_position3_norm;
    varying vec2 lmcoord_alt;
    varying float gloss_factor;
    varying float gloss_power;
    varying float luma_factor;
    varying float luma_power;
#endif

#if defined GBUFFER_BLOCK || defined FOLIAGE_V || defined GBUFFER_TERRAIN || defined GBUFFER_WATER || defined GBUFFER_HAND || (defined MATERIAL_GLOSS && !defined NETHER)
    attribute vec4 mc_Entity;
    attribute int blockEntityId;
#endif

varying vec4 position;

#if WAVING == 1
    attribute vec2 mc_midTexCoord;
#endif

/* Utility functions */

#if AA_TYPE > 0
    #include "/src/taa_offset.glsl"
#endif

#include "/lib/basic_utils.glsl"

#if defined SHADOW_CASTING && !defined NETHER
    #include "/lib/shadow_vertex.glsl"
#endif

#if WAVING == 1
    #include "/lib/vector_utils.glsl"
#endif

#include "/lib/luma.glsl"

#define FOG_BIOME
#include "/lib/biome_sky.glsl"
#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    exposure = texture2D(gaux3, vec2(0.5)).r;
    position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
    vec3 hi_sky_color;
    vec3 pure_hi_sky_color;
    float visible_sky;
    int mc_entity_x_int; 

    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"
    resize_vertex(gl_Position);
    #include "/src/hi_sky.glsl"
    #include "/src/light_vertex.glsl"
    #include "/src/fog_vertex.glsl"

    depth = length(gl_ModelViewMatrix * gl_Vertex);

    #if defined SHADOW_CASTING && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"
    #endif

    #if defined FOLIAGE_V && !defined NETHER
        #ifdef SHADOW_CASTING
            float foliage_mask = step(0.2, is_foliage);
            float shadow_fade = clamp((gl_Position.z / SHADOW_LIMIT) * 2.0 - 0.5, 0.0, 1.0);
            direct_light_strength = mix(direct_light_strength, far_direct_light_strength, foliage_mask * shadow_fade);
        #endif
    #endif

    #if defined GBUFFER_BLOCK   
        block_type_f = step(10090.5, float(blockEntityId)) * step(float(blockEntityId), 10091.5); 
    #endif

    #if defined GBUFFER_TERRAIN 
        float eid = float(mc_Entity.x);

        #if defined EMMISIVE_ORE
            float is_ore = step(8999.5, eid) * step(eid, 9007.5);
            ore_type_f = (eid - 8999.0) * is_ore;
        #endif
        
        #if defined EMMISIVE_MATERIAL
            float m_rangeA = step(9007.5, eid) * step(eid, 9015.5);
            float typeA = (eid - 9007.0) + (step(9013.5, eid) * 3.0);

            float m_rangeB = step(10088.5, eid) * step(eid, 10090.5);
            float typeB = mix(8.0, 7.0, step(10089.5, eid));

            float m_rangeC = step(10212.5, eid) * step(eid, 10214.5);
            float typeC = 9.0;

            emitter_type_f = (typeA * m_rangeA) + (typeB * m_rangeB) + (typeC * m_rangeC);
        #endif
    #endif

    // --- LÓGICA DE MATERIAL GLOSS ---
    #if defined MATERIAL_GLOSS && !defined NETHER
        float id = float(mc_Entity.x);

        luma_factor = 1.5; luma_power = 2.0; gloss_power = 1.25; gloss_factor = 1.0;

        float m_sand     = step(10409.5, id) * step(id, 10410.5);
        float m_stone    = step(10410.5, id) * step(id, 10411.5);
        float m_metal    = step(10399.5, id) * step(id, 10400.5);
        float m_fabric   = step(10439.5, id) * step(id, 10440.5);
        float m_polished = step(10419.5, id) * step(id, 10420.5);
        float m_rough    = step(10429.5, id) * step(id, 10430.5);
        float m_concrete = step(10449.5, id) * step(id, 10450.5);
        float m_w_pol    = step(10420.5, id) * step(id, 10421.5);
        float m_white    = step(10414.5, id) * step(id, 10415.5);
        float m_leaves   = step(10017.5, id) * step(id, 10018.5);
        float m_w_leaves = step(10018.5, id) * step(id, 10019.5);

        luma_factor = mix(luma_factor, 1.1,  m_sand);
        luma_factor = mix(luma_factor, 1.75, m_stone + m_polished);
        luma_factor = mix(luma_factor, 3.0,  m_fabric);
        luma_factor = mix(luma_factor, 6.5,  m_concrete);
        luma_factor = mix(luma_factor, 2.0,  m_w_pol);
        luma_factor = mix(luma_factor, 1.0,  m_white);
        luma_factor = mix(luma_factor, 1.25, m_leaves + m_w_leaves);

        luma_power = mix(luma_power, 12.0, m_sand + m_w_leaves);
        luma_power = mix(luma_power, 8.0,  m_stone);
        luma_power = mix(luma_power, 5.0,  m_metal);
        luma_power = mix(luma_power, 6.0,  m_polished + m_w_pol);
        luma_power = mix(luma_power, 10.0, m_rough);
        luma_power = mix(luma_power, 0.5,  m_concrete);
        luma_power = mix(luma_power, 1.0,  m_white);
        luma_power = mix(luma_power, 0.25, m_leaves);

        gloss_power = mix(gloss_power, 4.0,  m_sand + m_stone);
        gloss_power = mix(gloss_power, 35.0, m_metal);
        gloss_power = mix(gloss_power, 3.0,  m_fabric + m_w_leaves);
        gloss_power = mix(gloss_power, 15.0, m_polished + m_rough + m_concrete);
        gloss_power = mix(gloss_power, 20.0, m_w_pol);
        gloss_power = mix(gloss_power, 1.5,  m_white);
        gloss_power = mix(gloss_power, 2.0,  m_leaves);

        gloss_factor = mix(gloss_factor, 2.5,  m_sand);
        gloss_factor = mix(gloss_factor, 1.5,  m_metal);
        gloss_factor = mix(gloss_factor, 0.1,  m_fabric + m_w_leaves);
        gloss_factor = mix(gloss_factor, 3.0,  m_polished);
        gloss_factor = mix(gloss_factor, 0.3,  m_rough);
        gloss_factor = mix(gloss_factor, 0.2,  m_w_pol);
        gloss_factor = mix(gloss_factor, 0.75, m_white);
        gloss_factor = mix(gloss_factor, 1.25, m_leaves);

        flat_normal = normal;
        sub_position3 = sub_position.xyz;
        sub_position3_norm = normalize(sub_position3);
        lmcoord_alt = lmcoord;      
    #endif

    #if defined GBUFFER_ENTITY_GLOW
        gl_Position.z *= 0.01;
    #endif
}