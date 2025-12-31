#include "/lib/config.glsl"

/* Uniforms */

uniform sampler2D tex;
uniform sampler2D noisetex;
varying vec3 worldPos;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float viewWidth;
uniform float viewHeight;

/* Ins / Outs */

varying vec2 texcoord;
varying float is_noshadow;
varying float visible_sky;

varying float is_water;

#include "/lib/caustics.glsl"
#include "/lib/luma.glsl"

#define FRAGMENT
#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
  
    #ifndef CAUSTICS
        if (is_water > 0.98) {
            discard;
        }
    #endif

    if (is_noshadow > 0.98) {
        discard;
    }

    vec4 block_color;

    #ifdef CAUSTICS
        if (is_water > 0.98) {
            #if WATER_TEXTURE == 0
                vec3 wave_normal = normal_waves(worldPos + cameraPosition.xyz);
                vec3 amplified_normal = wave_normal * 8.0 * CAUSTICS_INTENSITY;
                block_color.rgb = v3_luma(amplified_normal); 

                block_color.a = texture2D(tex, texcoord).a * 0.05 * amplified_normal.z * (CAUSTICS_INTENSITY * 0.5 + 0.5);
            #else
                block_color = texture2D(tex, texcoord);
                block_color.rgb *= pow(block_color.rgb, vec3(3.0));
                if (block_color.r < 0.325) {
                    block_color.a *= 0.6;
                }
                block_color.a *= 0.66;
            #endif
            
        } else {
            block_color = texture2D(tex, texcoord);
        }
    #else
        block_color = texture2D(tex, texcoord);
    #endif

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = block_color;
}
