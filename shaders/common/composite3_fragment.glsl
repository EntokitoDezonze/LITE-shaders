/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.8 - composite3_fragment.glsl
AMD FSR EASU. */ 

#include "/lib/config.glsl"
#include "/lib/luma.glsl"

// == Uniforms

uniform sampler2D colortex1;
uniform float viewWidth;
uniform float viewHeight;

// == Varyings

varying vec2 texcoord;

// == Utility

#define FRAGMENT
#include "/lib/downscale.glsl"

#ifdef FSR
    #include "/lib/fsr_easu.glsl"
#endif

// == Main function

void main(){
    vec2 res = vec2(viewWidth, viewHeight);

    #ifdef FSR
        vec3 color = easu(colortex1, texcoord, res);
    #else
        vec3 color = texture2D(colortex1, texcoord * RENDER_SCALE).rgb;
    #endif

    /* DRAWBUFFERS:1 */
    gl_FragData[0] = vec4(color, 1.0);
}
