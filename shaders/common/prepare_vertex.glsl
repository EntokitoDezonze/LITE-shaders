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
uniform vec3 sunPosition;
uniform mat4 gbufferModelViewInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;
uniform float frameTime;
/* Ins / Outs */

varying vec3 up_vec;
varying vec3 hi_sky_color;
varying vec3 mid_sky_color;
varying vec3 low_sky_color;
varying vec3 final_sky_color;
varying vec3 pure_hi_sky_color;
varying vec3 pure_mid_sky_color;
varying vec3 pure_low_sky_color;

/* Utility functions */

#include "/lib/luma.glsl"
#include "/lib/downscale.glsl"

// MAIN FUNCTION ------------------

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    resize_vertex(gl_Position);

    #include "/src/hi_sky.glsl"
    #include "/src/mid_sky.glsl"
    #include "/src/low_sky.glsl"

    up_vec = normalize(gbufferModelView[1].xyz);
}
