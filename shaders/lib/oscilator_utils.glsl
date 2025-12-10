/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.7.3 - Oscilator_utils.glsl #include "/lib/oscilator_utils.glsl"
Oscilation Synced with daytime (ticks) - Oscilação vinculada ao tempo mundial (ticks) */

uniform float hour_world;
uniform int worldDay;
float continuousWorldDay = mod(worldDay, 50.0);
float TotalWorldTime = hour_world + (continuousWorldDay * 24.0) - 1.0;

float oscillation(float Aux, float minval, float maxval, float speed) {
    float range = maxval - minval;
    float center = minval + (range / 2.0);
    float oscillator = sin(Aux * CLOUD_HI_FACTOR * speed);
    return center + (oscillator * (range / 2.0));
}