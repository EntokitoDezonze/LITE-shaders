/* MakeUp - LITE shaders 4.9 - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

/* ---------------*/

#if AA_TYPE == 3
    vec3 fast_taa(vec3 block_color, vec2 texcoord_past) {
        vec3 current = block_color;

        #ifndef FSR
            vec3 previous = texture2DLod(colortex3, texcoord_past, 0.0).rgb;
        #else
            vec3 previous = texture2DLod(colortex3, texcoord, 0.0).rgb;
        #endif

        vec2 px = vec2(pixel_size_x, pixel_size_y);

        vec3 n0 = texture2DLod(colortex1, texcoord + vec2(-px.x, 0.0), 0.0).rgb;
        vec3 n1 = texture2DLod(colortex1, texcoord + vec2( px.x, 0.0), 0.0).rgb;
        vec3 n2 = texture2DLod(colortex1, texcoord + vec2(0.0, -px.y), 0.0).rgb;
        vec3 n3 = texture2DLod(colortex1, texcoord + vec2(0.0,  px.y), 0.0).rgb;

        vec3 nmin = min(current, min(n0, min(n1, min(n2, n3))));
        vec3 nmax = max(current, max(n0, max(n1, max(n2, n3))));

        vec3 edgeColor = current * 4.0 - (n0 + n1 + n2 + n3);
        float edge = clamp(length(edgeColor) * 0.5773502691896258, 0.0, 1.0);
        edge = smoothstep(0.2, 0.8, edge);

        vec3 center = (nmin + nmax) * 0.5;
        float radius = max(length(nmax - center), 1e-5);

        vec3 delta = previous - center;
        float delta_len = length(delta);
        if (delta_len > radius) {
            delta *= radius / delta_len;
        }
        previous = center + delta;
        
        float blend = 0.65 + edge * 0.25;

        return mix(current, previous, blend);
    }
#else
    vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
        if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
            return current_color;
        } else {
            vec3 previous = texture2DLod(colortex3, texcoord_past, 0.0).rgb;

            vec3 near_color0 = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, 0.0), 0.0).rgb;
            vec3 near_color1 = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, 0.0), 0.0).rgb;
            vec3 near_color2 = texture2DLod(colortex1, texcoord + vec2(0.0, -pixel_size_y), 0.0).rgb;
            vec3 near_color3 = texture2DLod(colortex1, texcoord + vec2(0.0, pixel_size_y), 0.0).rgb;
            
            vec3 nmin =
                min(current_color, min(near_color0, min(near_color1, min(near_color2, near_color3))));
            vec3 nmax =
                max(current_color, max(near_color0, max(near_color1, max(near_color2, near_color3))));
            
            vec3 edge_color = -near_color0;
            edge_color -= near_color1;
            edge_color += current_color * 4.0;
            edge_color -= near_color2;
            edge_color -= near_color3;

            edge_color = edge_color / (current_color * 2.0);
            float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);
            edge = smoothstep(0.25, 0.75, edge);

            vec3 center = (nmin + nmax) * 0.5;
            float radio = length(nmax - center);

            vec3 color_vector = previous - center;
            float color_dist = length(color_vector);

            float factor = 1.0;
            if (color_dist > radio) {
                factor = radio / color_dist;
            }
            previous = center + (color_vector * factor);

            return mix(current_color, previous, 0.65 + (edge * 0.25));
        }
    }
#endif


vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
    if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
        return current_color;
    } else {
        vec4 previous = texture2DLod(colortex3, texcoord_past, 0.0);

        vec4 near_color0 = texture2DLod(colortex1, texcoord + vec2(-pixel_size_x, 0.0), 0.0);
        vec4 near_color1 = texture2DLod(colortex1, texcoord + vec2(pixel_size_x, 0.0), 0.0);
        vec4 near_color2 = texture2DLod(colortex1, texcoord + vec2(0.0, -pixel_size_y), 0.0);
        vec4 near_color3 = texture2DLod(colortex1, texcoord + vec2(0.0, pixel_size_y), 0.0);

        vec4 nmin =
            min(current_color, min(near_color0, min(near_color1, min(near_color2, near_color3))));
        vec4 nmax =
            max(current_color, max(near_color0, max(near_color1, max(near_color2, near_color3))));  

        vec3 edge_color = -near_color0.rgb;
        edge_color -= near_color1.rgb;
        edge_color += current_color.rgb * 4.0;
        edge_color -= near_color2.rgb;
        edge_color -= near_color3.rgb;

        edge_color = edge_color / (current_color.rgb * 2.0);
        float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);
        edge = smoothstep(0.25, 0.75, edge);

        vec3 center = (nmin.rgb + nmax.rgb) * 0.5;
        float radio = length(nmax.rgb - center);

        vec3 color_vector = previous.rgb - center;
        float color_dist = length(color_vector);

        float factor = 1.0;
        if (color_dist > radio) {
            factor = radio / color_dist;
        }
        previous = vec4(center + (color_vector * factor), previous.a);

        return mix(current_color, previous, 0.65 + (edge * 0.25));
    }
}