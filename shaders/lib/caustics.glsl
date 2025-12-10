vec3 normal_waves(vec3 pos) {
    float speed = frameTimeCounter * 0.04;
    vec2 wave_1 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.1) + vec2(speed, speed)).rg;
    wave_1 = wave_1 - .5;
    wave_1 *= 0.66;
    vec2 wave_2 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.03125) - speed).rg;
    wave_2 = wave_2 - .5;
    vec2 wave_3 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.125) + vec2(speed, -speed)).rg;
    wave_3 = wave_3 - .5;
    wave_3 *= 1.2;

    vec2 partial_wave = wave_1 + wave_2 + wave_3;
    vec3 final_wave = vec3(partial_wave, WATER_TURBULENCE - (rainStrength * 0.5 * WATER_TURBULENCE * visible_sky));

    return normalize(final_wave);
}