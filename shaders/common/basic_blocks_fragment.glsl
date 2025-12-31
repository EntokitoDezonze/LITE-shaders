#include "/lib/config.glsl"

/* Uniforms, ins, outs */
uniform float viewWidth;
uniform float viewHeight;

varying vec4 tint_color;
varying vec2 texcoord;
varying vec3 basic_light;


#define FRAGMENT
#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    if(fragment_cull()) discard;
    vec4 block_color = tint_color;
    block_color.rgb *= basic_light;

    #include "/src/writebuffers.glsl"
}
