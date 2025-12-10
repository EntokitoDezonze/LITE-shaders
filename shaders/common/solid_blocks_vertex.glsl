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
varying float ore_type_f;
varying float emitter_type_f;
varying float block_type_f;
varying float exposure;

#if defined GBUFFER_TERRAIN || defined GBUFFER_HAND
    varying float emmisive_type;
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

// MAIN FUNCTION ------------------

void main() {
    exposure = texture2D(gaux3, vec2(0.5)).r;

    vec2 eye_bright_smooth = vec2(eyeBrightnessSmooth);
    vec3 hi_sky_color;
    vec3 pure_hi_sky_color;
    float visible_sky;
    int mc_entity_x; 

    #include "/src/basiccoords_vertex.glsl"
    #include "/src/position_vertex.glsl"
    #include "/src/hi_sky.glsl"
    #include "/src/light_vertex.glsl"
    #include "/src/fog_vertex.glsl"

    position = gbufferModelViewInverse * gl_ModelViewMatrix * gl_Vertex;

    #if defined SHADOW_CASTING && !defined NETHER
        #include "/src/shadow_src_vertex.glsl"
    #endif

    #if defined FOLIAGE_V && !defined NETHER
        #ifdef SHADOW_CASTING
            direct_light_strength =
                mix(
                    direct_light_strength,
                    far_direct_light_strength,
                    step(0.2, is_foliage) * clamp((gl_Position.z / SHADOW_LIMIT) * 2.0 - 0.5, 0.0, 1.0)
                );
        #endif
    #endif

    #if defined GBUFFER_BLOCK   
        block_type_f = 0.0;
        if (blockEntityId == 10091) { // END PORTAL
           block_type_f = 1.0; 
        }
    #endif

    #if defined GBUFFER_TERRAIN 
        #if defined EMMISIVE_ORE || defined EMMISIVE_MATERIAL    
            mc_entity_x = int(mc_Entity.x);
        #endif
        
        #if defined EMMISIVE_ORE // ORES
            // ore_type == 0;
            float temp_ore_type = 0.0;

            if (mc_entity_x == 9000) { // ENTITY_GOLD_ORE
                temp_ore_type = 1.0;
            } else if (mc_entity_x == 9001) { // ENTITY_DIAMOND_ORE
                temp_ore_type = 2.0;
            } else if (mc_entity_x == 9002) { // ENTITY_IRON_ORE
                temp_ore_type = 3.0;
            } else if (mc_entity_x == 9003) { // ENTITY_EMERALD_ORE
                temp_ore_type = 4.0;
            } else if (mc_entity_x == 9004) { // ENTITY_REDSTONE_ORE
                temp_ore_type = 5.0;
            } else if (mc_entity_x == 9005) { // ENTITY_QUARTZ_ORE
                temp_ore_type = 6.0;
            } else if (mc_entity_x == 9006) { // ENTITY_LAPIS_ORE
                temp_ore_type = 7.0;
            } else if (mc_entity_x == 9007) { // ENTITY_COPPER_ORE
                temp_ore_type = 8.0;
            }
            ore_type_f = temp_ore_type;
        #endif

        #if defined EMMISIVE_MATERIAL // OTHER BLOCKS
            // emitter_type = 0;
            float temp_emitter_type = 0.0;
            
            if (mc_entity_x == 9008) { // ENTITY_EMMISIVE_REDSTONE
                temp_emitter_type = 1.0;
            } else if (mc_entity_x == 9009) { // ENTITY_SOLAR_PANEL
                temp_emitter_type = 2.0;
            } else if (mc_entity_x == 9010) { // ENTITY_CRYING_OBSIDIAN
                temp_emitter_type = 3.0;
            } else if (mc_entity_x == 9011) { // ENTITY_HIGHLIGHTS
                temp_emitter_type = 4.0;
            } else if (mc_entity_x == 9012) { // ENTITY_FIRE
                temp_emitter_type = 5.0;
            } else if (mc_entity_x == 9013) { // ENTITY_SCULK
                temp_emitter_type = 6.0;
            } else if (mc_entity_x == 10090) { // ENTITY_LAVA/MAGMA/BEACON
                temp_emitter_type = 7.0;
            } else if (mc_entity_x == 10089) { // ENTITY_LIGHTBLOCKS
                temp_emitter_type = 8.0;
            } else if (mc_entity_x == 10213 || mc_entity_x == 10214) { // FIRE
                temp_emitter_type = 9.0;
            } else if (mc_entity_x == 9014) { // RAIL
                temp_emitter_type = 10.0;
            } else if (mc_entity_x == 9015) { // END PORTAL FRAME
                temp_emitter_type = 11.0;
            }
            emitter_type_f = temp_emitter_type;
        #endif
    #endif



    #if defined MATERIAL_GLOSS && !defined NETHER
        /* Glossy
        #define ENTITY_METAL        10400.0   // Metal-like glossy blocks
        #define ENTITY_SAND         10410.0   // Sand-like glossy blocks
        #define ENTITY_STONE        10411.0  // Stone-like glossy blocks
        #define ENTITY_FABRIC       10440.0   // Fabric-like glossy blocks
        #define ENTITY_POLISHED     10420.0   // Polished-like glossy blocks
        #define ENTITY_ROUGH        10430.0   // Rough-like glossy blocks
        #define ENTITY_CONCRETE     10450.0  // Concrete glossy blocks

        // White glossy (to avoid peaks of brightness)
        #define ENTITY_WHITE_POLISHED      10421.0   // White polished-like glossy blocks
        #define ENTITY_WHITE        10415.0   // White blocks (to avoid peaks of brightness)
        */
        
        luma_factor = 1.5;
        luma_power = 2.0;
        gloss_power = 1.25;
        gloss_factor = 1.0;
        
        mc_entity_x = int(mc_Entity.x);

        if (mc_entity_x == 10410) { // Sand-like glossy blocks
            luma_factor = 1.1; 
            luma_power = 12.0;
            gloss_power = 4.0;
            gloss_factor = 2.5;
        } else if (mc_entity_x == 10411) { // Stone-like glossy blocks
            luma_factor = 1.75; 
            luma_power = 8.0;
            gloss_power = 4.0;
            gloss_factor = 1.0;
        } else if (mc_entity_x == 10400) { // Metal-like glossy blocks
            luma_factor = 1.5;  
            luma_power = 5.0; 
            gloss_power = 35.0;
            gloss_factor = 1.5;   
        } else if (mc_entity_x == 10440) { // Fabric-like glossy blocks
            luma_factor = 3.0;
            luma_power = 2.0;
            gloss_power = 3.0;
            gloss_factor = 0.1;
        } else if (mc_entity_x == 10420) { // Polished-like glossy blocks
            luma_factor = 1.75;  
            luma_power = 6.0; 
            gloss_power = 15.0;
            gloss_factor = 3.0;
        } else if (mc_entity_x == 10430) { // Rough-like glossy blocks
            luma_factor = 1.5;  
            luma_power = 10.0; 
            gloss_power = 15.0;
            gloss_factor = 0.3;     
        } else if (mc_entity_x == 10450) { // Concrete-like glossy blocks
            luma_factor = 6.5;  
            luma_power = 0.5; 
            gloss_power = 15.0;
            gloss_factor = 1.0;     
        } else if (mc_entity_x == 10421) { // White polished-like glossy blocks
            luma_factor = 2.0;  
            luma_power = 6.0; 
            gloss_power = 20.0;
            gloss_factor = 0.2; 
        } else if (mc_entity_x == 10415) { // White glossy (to avoid peaks of brightness)
            luma_factor = 1.0;
            luma_power = 1.0;
            gloss_power = 1.5;
            gloss_factor = 0.75;
        } else if (mc_entity_x == 10018) { // Leaves
            luma_factor = 1.25;
            luma_power = 0.25;
            gloss_power = 2.0;
            gloss_factor = 1.25;
        } else if (mc_entity_x == 10019) { // White Leaves
            luma_factor = 1.25;
            luma_power = 12.0;
            gloss_power = 3.0;
            gloss_factor = 0.1;
        }
        
        // GUILD FOR GLOSS PROPERTIES:
        // luma_factor: Whiteness of reflex. 
        // luma_power: Material property (Bigger = More metalic)
        // gloss_power: Size of light (0.0 = big, > 0.0 small.)
        // gloss_factor: Final multiplier.

        flat_normal = normal;
        sub_position3 = sub_position.xyz;
        sub_position3_norm = normalize(sub_position3);
        lmcoord_alt = lmcoord;      
    #endif

    #if defined GBUFFER_ENTITY_GLOW
        gl_Position.z *= 0.01;
    #endif
}