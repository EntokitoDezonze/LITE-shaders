/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.9 - render_aux.glsl
Render auxiliary calculations. - Cálculos auxiliares de renderização.
*/

float hash21(vec2 p) {
    float n = p.x * 12.9898 + p.y * 78.233;
    n = fract(n * 0.0031); 
    n *= n + 33.33;        
    n *= n + n;            
    return fract(n);
}

float noise2D_grid(vec2 p) {
    vec2 i = floor(p); 
    return hash21(i);
}

/*
float noise2D_grid_inclined(vec2 p) {
    float shear_factor = 0.5; 
    vec2 p_inclined = vec2(p.x + p.y * shear_factor, p.y);
    vec2 i = floor(p_inclined); 
    
    return hash21(i);
}
Uncomment when needed. */

vec3 reconstructWorldPosition(float depth, vec2 resolution) {
    vec2 ndc_xy = (gl_FragCoord.xy / RENDER_SCALE / resolution) * 2.0 - 1.0;
    vec4 frag_clip_space = vec4(ndc_xy, depth, 1.0);
    vec4 frag_view_space = gbufferProjectionInverse * frag_clip_space;
    frag_view_space /= frag_view_space.w; 
    vec4 frag_world_space = gbufferModelViewInverse * frag_view_space;

    vec3 worldPos_unstable = frag_world_space.xyz;
    vec3 viewCenterWorldSpace = gbufferModelViewInverse[3].xyz;
    vec3 worldPos_stable = worldPos_unstable - viewCenterWorldSpace;
    
    return worldPos_stable;
} // Fixed sway with view bobbing.

vec2 cubic_uv(vec3 direction) {
    vec3 abs_dir = abs(direction);
    
    float max_comp = max(max(abs_dir.x, abs_dir.y), abs_dir.z); 

    if (max_comp == abs_dir.x) {
        return (direction.yz / max_comp) * 0.5 + 0.5; // Face X
    } else if (max_comp == abs_dir.y) {
        return (direction.xz / max_comp) * 0.5 + 0.5; // Face Y
    } else {
        return (direction.xy / max_comp) * 0.5 + 0.5; // Face Z
    }
}