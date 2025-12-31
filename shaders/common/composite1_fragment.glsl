#include "/lib/config.glsl"

#ifdef DOF
    const bool colortex1MipmapEnabled = true;
#endif

#ifdef BLOOM
    const bool gaux1MipmapEnabled = true;
#endif

/* Uniforms */

uniform sampler2D colortex1;
uniform sampler2D gaux1;
uniform float inv_aspect_ratio;
uniform float frameTime;
uniform float viewWidth;
uniform float viewHeight;
uniform int frameCounter;

#ifdef DOF
    uniform float centerDepthSmooth;
    uniform float fov_y_inv;
#endif

#if defined DOF || defined MOTION_BLUR
    uniform float pixel_size_x;
    uniform float pixel_size_y;
#endif

#if AA_TYPE > 0 || defined MOTION_BLUR
    uniform sampler2D colortex3;  // TAA past averages
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferModelViewInverse;
    uniform vec3 cameraPosition;
    uniform vec3 previousCameraPosition;
    uniform mat4 gbufferPreviousProjection;
    uniform mat4 gbufferPreviousModelView;
    uniform sampler2D depthtex1;
#endif

/* Ins / Outs */

varying vec2 texcoord;

/* Utility functions */
#define FRAGMENT
#include "/lib/downscale.glsl"

#include "/lib/fps_correction.glsl"
#include "/lib/bloom.glsl"

#if defined BLOOM || defined DOF || defined MOTION_BLUR
    #include "/lib/dither.glsl"
#endif

#ifdef DOF
    #include "/lib/blur.glsl"
#endif

#ifdef MOTION_BLUR
    #include "/lib/motion_blur.glsl"
#endif

// MAIN FUNCTION ------------------

void main() {
    if (fragment_cull()) discard;
    vec4 block_color = texture2DLod(colortex1, texcoord, 0);

    #if defined MOTION_BLUR
        // Retrojection of previous frame
        float z_depth = texture2DLod(depthtex1, texcoord, 0).r;
        vec2 texcoord_past;
        vec3 curr_view_pos;
        vec3 curr_feet_player_pos;
        vec3 prev_feet_player_pos;
        vec3 prev_view_pos;
        vec2 final_pos;

        if(z_depth < 0.56) {
            texcoord_past = texcoord * RENDER_SCALE;
        } else {
            curr_view_pos =
                vec3(vec2(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y) * (texcoord * 2.0 - 1.0) + gbufferProjectionInverse[3].xy, gbufferProjectionInverse[3].z);
            curr_view_pos /= (gbufferProjectionInverse[2].w * (z_depth * 2.0 - 1.0) + gbufferProjectionInverse[3].w);
            curr_feet_player_pos = mat3(gbufferModelViewInverse) * curr_view_pos + gbufferModelViewInverse[3].xyz;

            prev_feet_player_pos =
                z_depth > 0.56 ? curr_feet_player_pos + cameraPosition - previousCameraPosition : curr_feet_player_pos;
            prev_view_pos = mat3(gbufferPreviousModelView) * prev_feet_player_pos + gbufferPreviousModelView[3].xyz;
            final_pos =
                vec2(gbufferPreviousProjection[0].x, gbufferPreviousProjection[1].y) * prev_view_pos.xy + gbufferPreviousProjection[3].xy;
            texcoord_past = (final_pos / -prev_view_pos.z) * 0.5 + 0.5;
            texcoord_past *= (RENDER_SCALE);
        }

    #endif

    #if defined BLOOM || defined DOF || defined MOTION_BLUR
        #if AA_TYPE > 0
            float dither = shifted_dither_makeup(gl_FragCoord.xy);
        #else
            float dither = dither_makeup(gl_FragCoord.xy);
        #endif
    #endif

    #ifdef MOTION_BLUR
        // "Speed"
        vec2 velocity = (texcoord * RENDER_SCALE) - texcoord_past;
        block_color.rgb = motion_blur(block_color.rgb, z_depth, velocity, colortex1);
    #endif
    
    #ifdef DOF
        block_color.rgb = noised_blur(block_color, colortex1, texcoord, DOF_STRENGTH, dither);
    #endif

    #ifdef BLOOM
        vec3 bloom = mipmap_bloom(gaux1, texcoord, dither);
        block_color.rgb += bloom;
    #endif

    block_color = clamp(block_color, vec4(0.0), vec4(vec3(50.0), 1.0));
    /* DRAWBUFFERS:1 */
    gl_FragData[0] = block_color;
}
