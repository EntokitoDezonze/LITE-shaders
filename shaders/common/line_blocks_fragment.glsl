/* Utility functions */

#include "/lib/config.glsl"

/* Ins / Outs & Uniforms */

varying vec4 tint_color;
uniform float viewWidth;
uniform float viewHeight;

#define FRAGMENT
#include "/lib/downscale.glsl"


void main() {
    if(fragment_cull()) discard;
    vec4 block_color = tint_color;

    #include "/src/writebuffers.glsl"
}
