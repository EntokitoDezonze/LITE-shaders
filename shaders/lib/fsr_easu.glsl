/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.9 - fsr_easu.glsl #include "/lib/fsr_easu.glsl"
FSR EASU. */

/*
AMD FidelityFX Super Resolution Edge-Adaptive Spatial Upsampling (FSR 1.0)
Based on: https://github.com/GPUOpen-Effects/FidelityFX-FSR
MIT license
Simplified.
*/

float sinc(float x) {
    x = abs(x);
    if (x < 1e-5) return 1.0;
    x *= 3.14159265;
    return sin(x) / x;
}

float lanczos(float x, float a) {
    x = abs(x);
    if (x >= a) return 0.0;
    return sinc(x) * sinc(x / a);
}

vec3 easu(sampler2D t, vec2 uv, vec2 fullRes) {
    vec2 lowRes = fullRes * RENDER_SCALE;
    
    vec2 pos = uv * lowRes - 0.5;
    ivec2 base = ivec2(floor(pos));
    vec2 f = pos - vec2(base);

    const float A = 4.0; // sharpness

    vec3 sum = vec3(0.0);
    float wsum = 0.0;

    // janela 4x4
    for (int y = -1; y <= 2; y++) {
        float wy = lanczos(float(y) - f.y, A);
        for (int x = -1; x <= 2; x++) {
            float wx = lanczos(float(x) - f.x, A);
            float w = wx * wy;

            vec3 c = texelFetch(t, base + ivec2(x, y), 0).rgb;
            sum += c * w;
            wsum += w;
        }
    }

    vec3 res = sum / max(wsum, 1e-5);

    vec3 c00 = texelFetch(t, base + ivec2(0, 0), 0).rgb;
    vec3 c10 = texelFetch(t, base + ivec2(1, 0), 0).rgb;
    vec3 c01 = texelFetch(t, base + ivec2(0, 1), 0).rgb;
    vec3 c11 = texelFetch(t, base + ivec2(1, 1), 0).rgb;

    vec3 cMin = min(min(c00, c10), min(c01, c11));
    vec3 cMax = max(max(c00, c10), max(c01, c11));

    return clamp(res, cMin, cMax);
}

