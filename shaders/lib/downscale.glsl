/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.7.3 - downscale.glsl #include "/lib/downscale.glsl"
Downscale functions. - Funções de downscale.
THIS CODE IS NOT USED ON THIS VERSION, BUT PLANNED FOR NEXT. (4.8)

#define CUSTOM_SCALE 0.5
#define viewSize vec2(viewWidth, viewHeight)

void resize_vertex(inout vec4 glPosition) {
    glPosition.xy *= CUSTOM_SCALE; 
    glPosition.xy -= glPosition.w * CUSTOM_SCALE;
}

#ifdef FRAGMENT
    bool fragment_cull() {
        vec2 max_limit = ceil(viewSize * CUSTOM_SCALE);
        return any(greaterThan(gl_FragCoord.xy, max_limit));
    }
#endif
*/ 