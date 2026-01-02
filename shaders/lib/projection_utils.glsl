/* MakeUp - LITE shaders 4.9 - projection_utils.glsl
Projection generic functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)
#define projMAD(m, v) (diagonal3(m) * (v) + (m)[3].xyz)

#if defined FSR || defined PS1_LIKE
    vec3 camera_to_screen(vec3 fragpos) {
        vec4 pos = gbufferProjection * vec4(fragpos, 1.0);
        pos.xyz /= pos.w;
        vec3 screenPos = pos.xyz * 0.5 + 0.5;
        screenPos.xy *= RENDER_SCALE;

        return screenPos;
    }
#else
    vec3 camera_to_screen(vec3 fragpos) {
        vec4 pos  = gbufferProjection * vec4(fragpos, 1.0);
        pos /= pos.w;

        return pos.xyz * 0.5 + 0.5;
    }
#endif
