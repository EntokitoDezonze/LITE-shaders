/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.9 - fps_correction.glsl #include "/lib/fps_correction.glsl"
Reduce quality of some effects on low fps for stabilize performance. - Reduzir a qualidade de alguns efeitos em baixo fps para estabilizar performance */

float fps = 1 / frameTime;

float fps_correction(float fps, float minc, float maxc) {
    const float MIN_FPS = 9.0; // Margin of error, target = 10

    float check = clamp(fps / MIN_FPS, 0.0, 1.0);
    float smooth_check = smoothstep(0.0, 1.0, check); 
    
    float fps_correction = mix(maxc, minc, smooth_check);
    
    return fps_correction;
}