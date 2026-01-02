/* MakeUp - LITE shaders 4.9 - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform vec3 skyColor;
uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;

#define MID_SUNSET_COLOR HORIZON_SUNSET_COLOR
#define MID_DAY_COLOR HORIZON_DAY_COLOR
#define MID_NIGHT_COLOR HORIZON_NIGHT_COLOR

#define OMNI_TINT 1.0
#define LIGHT_SUNSET_COLOR vec3(0.2, 0.12, 0.2)
#define LIGHT_DAY_COLOR LIGHT_SUNSET_COLOR
#define LIGHT_NIGHT_COLOR LIGHT_SUNSET_COLOR

#define ZENITH_SUNSET_COLOR vec3(0.041, 0.0275, 0.0571) * 0.75
#define ZENITH_DAY_COLOR vec3(0.041, 0.0275, 0.0571) * 0.75
#define ZENITH_NIGHT_COLOR ZENITH_SUNSET_COLOR

#define HORIZON_SUNSET_COLOR vec3(0.0) // UNUSED
#define HORIZON_DAY_COLOR HORIZON_SUNSET_COLOR
#define HORIZON_NIGHT_COLOR HORIZON_SUNSET_COLOR

#define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)

#include "/lib/day_blend.glsl"

// Fog parameter per hour
#define FOG_DAY 1.0
#define FOG_SUNSET 1.0
#define FOG_NIGHT 1.0
#define FOG_DENSITY 3.0

#include "/lib/color_conversion.glsl"