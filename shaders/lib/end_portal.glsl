/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.9 - end_portal.glsl #include "/lib/end_portal.glsl"
End portal render. - Renderização do portal do End. */

#include "/lib/render_aux.glsl"

vec3 end_portal() {
    const int max_layers = 10;
    const float depth_falloff_speed = 6.0;
    const float layer_scale_factor = 10.0;
    const vec2 flow_direction = vec2(0.618034);
    const float flow_speed = 0.333;
    const float noise_base_scale = 5;
    const float color_mix_speed = 0.67; // sixseven!!
    const float clip_min = 0.75;
    const float clip_max = 1.0;
    const vec3 base_color = vec3(0.0, 0.0, 0.0);

    const vec3 C0 = vec3(0.3137, 0.1255, 0.4314);
    const vec3 C1 = vec3(0.1961, 0.3529, 0.9882);
    const vec3 C2 = vec3(0.1608, 0.3961, 0.4941);

    vec2 resolution = vec2(viewWidth, viewHeight);
    float time = mod(frameTimeCounter, 1000.0);

    vec3 world_pos_current = reconstructWorldPosition(gl_FragCoord.z, resolution);

    // --- PT: CORREÇÃO AQUI: USAR POSIÇÃO MUNDIAL ABSOLUTA PARA NOISE ENG: FIX HERE: USE ABSOLUTE WORLD POSITION FOR NOISE ---
    
    vec3 final_color = base_color;
    float t_mix = time * color_mix_speed;
    vec3 current_layer_color = mix(C0, C1, sin(t_mix) * 0.5 + 0.5);
    current_layer_color = mix(current_layer_color, C2, cos(t_mix * 0.7) * 0.5 + 0.5);

    vec2 flow_offset = flow_direction * time * flow_speed;
    vec2 base_uv = world_pos_current.xz + cameraPosition.xz;
    base_uv += world_pos_current.y;

    base_uv += flow_offset;
    base_uv += cameraPosition.y * 2;


    for (int i = 0; i < max_layers; i++) {
        float layer_factor = float(i) / float(max_layers);
        float inverse_factor = 1.0 - layer_factor;
        
        float scale_factor = noise_base_scale * (1.0 + layer_factor * layer_scale_factor);
        float flow_scale = inverse_factor * 10.0;
        
        // PT: A coordenada para o noise é a posição mundial ajustada (base_uv) e escalada ENG: Coordinate for noise is world position scaled (base_uv)
        vec2 uv_layer = base_uv * scale_factor;
        uv_layer += flow_offset * flow_scale;

        float noise_val = noise2D_grid(uv_layer);
        float base_intensity = pow(noise_val, 5.0);
        float intensity = smoothstep(clip_min, clip_max, base_intensity);

        float layer_fade = pow(inverse_factor, depth_falloff_speed);
        final_color += current_layer_color * intensity * layer_fade * 3.0;

        if (layer_fade < 0.01) break;
    }

    float depth_val = gl_FragCoord.z;
    float overall_depth_fade = 1.0 / (1.0 + depth_val * depth_val * 0.0001);
    final_color *= overall_depth_fade;
    final_color = pow(final_color, vec3(1.6)) * 6.7; // SIX-SEVEN AHH!!

    return final_color;
}