/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.8 - downscale.glsl #include "/lib/downscale.glsl"
Downscale functions. - Funções de downscale.*/ 

#define viewSize vec2(viewWidth, viewHeight)

#if RENDER_SCALE_INT == 100 || !defined FSR && !defined PS1_LIKE
    void resize_vertex(inout vec4 glPosition) {
    }
#else
    void resize_vertex(inout vec4 glPosition) {
        glPosition.xy *= RENDER_SCALE; 
        glPosition.xy -= glPosition.w * (1 - RENDER_SCALE);
    }
#endif

#if defined FRAGMENT && RENDER_SCALE_INT == 100 || !defined FSR && !defined PS1_LIKE
    bool fragment_cull() {
        return false;
    }
#elif defined FRAGMENT
    bool fragment_cull() {
        vec2 max_limit = ceil(viewSize * RENDER_SCALE);
        return any(greaterThan(gl_FragCoord.xy, max_limit));
    }
#endif
