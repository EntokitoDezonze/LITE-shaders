/* MakeUp - LITE shaders 4.7.3 - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;
uniform int moonPhase;
uniform vec3 fogColor;
uniform vec3 skyColor;


#define NIGHT_BRIGHT_PHASE clamp(NIGHT_BRIGHT + (NIGHT_BRIGHT * (abs(4.0 - moonPhase) * 0.25)), 1.0, 1.2)

#define MID_SUNSET_COLOR HORIZON_SUNSET_COLOR
#define MID_DAY_COLOR HORIZON_DAY_COLOR
#define MID_NIGHT_COLOR HORIZON_NIGHT_COLOR

#if COLOR_SCHEME == 0  // Ethereal
    #define OMNI_TINT 0.4
    #define LIGHT_SUNSET_COLOR vec3(0.887528, 0.443394, 0.301044)
    #define LIGHT_DAY_COLOR vec3(0.90, 0.84, 0.79)
    #define LIGHT_NIGHT_COLOR vec3(0.0317353, 0.0467353, 0.0637353) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.2617647, 0.33529412, 0.52352941)
    #define ZENITH_DAY_COLOR vec3(0.0785098, 0.24352941, 0.54901961)
    #define ZENITH_NIGHT_COLOR vec3(0.0168, 0.0228, 0.03) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.0, 0.6, 0.394)
    #define HORIZON_DAY_COLOR vec3(0.65, 0.91, 1.3)
    #define HORIZON_NIGHT_COLOR vec3(0.02556, 0.03772, 0.05244) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.05, 0.1, 0.11)
#elif COLOR_SCHEME == 1  // New shoka
    #define OMNI_TINT 0.25
    #define LIGHT_SUNSET_COLOR vec3(1.0, 0.588, 0.3555)
    #define LIGHT_DAY_COLOR vec3(0.90, 0.84, 0.79)
    #define LIGHT_NIGHT_COLOR vec3(0.04786874, 0.05175001, 0.06112969) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.143, 0.24394118, 0.36450981)
    #define ZENITH_DAY_COLOR vec3(0.143, 0.24394118, 0.36450981)
    #define ZENITH_NIGHT_COLOR vec3(0.014, 0.019, 0.025) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.0, 0.648, 0.37824)
    #define HORIZON_DAY_COLOR vec3(0.65, 0.91, 1.3)
    #define HORIZON_NIGHT_COLOR vec3(0.0213, 0.0306, 0.0387) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.05, 0.1, 0.11)
#elif COLOR_SCHEME == 2  // Shoka
    #define OMNI_TINT 0.5
    #define LIGHT_SUNSET_COLOR vec3(0.70656, 0.44436, 0.2898)
    #define LIGHT_DAY_COLOR vec3(0.91640625, 0.91640625, 0.635375)
    #define LIGHT_NIGHT_COLOR vec3(0.04786874, 0.05175001, 0.06112969) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.104, 0.17741177, 0.26509804)
    #define ZENITH_DAY_COLOR vec3(0.13, 0.22176471, 0.33137255)
    #define ZENITH_NIGHT_COLOR vec3(0.014, 0.019, 0.025) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(0.715 , 0.5499, 0.416)
    #define HORIZON_DAY_COLOR vec3(0.364 , 0.6825, 0.91)
    #define HORIZON_NIGHT_COLOR vec3(0.0213, 0.0306, 0.0387) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)
#elif COLOR_SCHEME == 3  // Legacy
    #define OMNI_TINT 0.5
    #define LIGHT_SUNSET_COLOR vec3(0.96876, 0.4356254, 0.26002448)
    #define LIGHT_DAY_COLOR vec3(0.88504, 0.88504, 0.8372)
    #define LIGHT_NIGHT_COLOR vec3(0.04693014, 0.0507353 , 0.05993107) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.09410295, 0.20145588, 0.34905882)
    #define ZENITH_DAY_COLOR vec3(0.182, 0.351, 0.754)
    #define ZENITH_NIGHT_COLOR vec3(0.00841175, 0.01651763, 0.025) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(0.81, 0.44165647, 0.25293529)
    #define HORIZON_DAY_COLOR vec3(0.572, 1.014, 1.248)
    #define HORIZON_NIGHT_COLOR vec3(0.01078431, 0.02317647, 0.035) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)
#elif COLOR_SCHEME == 4  // Captain
    #define OMNI_TINT 0.5
    #define LIGHT_SUNSET_COLOR vec3(0.84456, 0.52992, 0.26496001)
    #define LIGHT_DAY_COLOR vec3(0.83064961, 0.93448079, 1.1032065)
    #define LIGHT_NIGHT_COLOR vec3(0.02597646, 0.05195295, 0.069) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.18135 , 0.230256, 0.332592)
    #define ZENITH_DAY_COLOR vec3(0.104, 0.26, 0.507)
    #define ZENITH_NIGHT_COLOR vec3(0.004, 0.01, 0.0195) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.3, 0.8632, 0.3952)
    #define HORIZON_DAY_COLOR vec3(0.65, 0.91, 1.3)
    #define HORIZON_NIGHT_COLOR vec3(0.025, 0.035, 0.05) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.05, 0.1, 0.11)
#elif COLOR_SCHEME == 5  // Psychedelic
    #define OMNI_TINT 0.45
    #define LIGHT_SUNSET_COLOR vec3(0.85 , 0.47058824, 0.17921569)
    #define LIGHT_DAY_COLOR vec3(0.91021875, 0.95771875, 0.6)
    #define LIGHT_NIGHT_COLOR vec3(0.04223712, 0.04566177, 0.05393796) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.18135 , 0.230256, 0.332592)
    #define ZENITH_DAY_COLOR vec3(0.104, 0.26, 0.507)
    #define ZENITH_NIGHT_COLOR vec3(0.004 ,0.01, 0.0195) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.3, 0.8632, 0.3952)
    #define HORIZON_DAY_COLOR vec3(0.65, 0.91, 1.3)
    #define HORIZON_NIGHT_COLOR vec3(0.025, 0.035, 0.05) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
#elif COLOR_SCHEME == 6  // Cocoa
    #define OMNI_TINT 0.4
    #define LIGHT_SUNSET_COLOR vec3(0.918528, 0.5941728, 0.2712528)
    #define LIGHT_DAY_COLOR vec3(0.897, 0.897, 0.5718375)
    #define LIGHT_NIGHT_COLOR vec3(0.04693014, 0.0507353, 0.05993107) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.117, 0.26, 0.494)
    #define ZENITH_DAY_COLOR vec3(0.234, 0.403, 0.676)
    #define ZENITH_NIGHT_COLOR vec3(0.014, 0.019, 0.031) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.183, 0.858, 0.611)
    #define HORIZON_DAY_COLOR vec3(0.52, 0.975, 1.3)
    #define HORIZON_NIGHT_COLOR vec3(0.022, 0.029, 0.049) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.0196, 0.1804, 0.3216)
#elif COLOR_SCHEME == 7  // Testigo
    #define OMNI_TINT 0.65
    #define LIGHT_SUNSET_COLOR vec3(0.70656, 0.44436, 0.2898)
    #define LIGHT_DAY_COLOR vec3(0.88504, 0.88504, 0.8372)
    #define LIGHT_NIGHT_COLOR vec3(0.04786874, 0.05175001, 0.06112969) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.104, 0.17741177, 0.26509804)
    #define ZENITH_DAY_COLOR vec3(0.05098, 0.25990, 0.44313)
    #define ZENITH_NIGHT_COLOR vec3(0.004 ,0.01, 0.0195) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(0.715 , 0.5499, 0.416)
    #define HORIZON_DAY_COLOR vec3(0.65, 0.91, 1.3)
    #define HORIZON_NIGHT_COLOR vec3(0.025, 0.035, 0.05) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.03098, 0.22990, 0.41313)
#elif COLOR_SCHEME == 8  // LITE Realistic Plus (3 color layers)
    #define OMNI_TINT 0.5
    #define LIGHT_SUNSET_COLOR vec3(0.6, 0.27, 0.145)
    #define LIGHT_DAY_COLOR vec3(1.0, 0.8, 0.75)
    #define LIGHT_NIGHT_COLOR vec3(0.015, 0.02, 0.035) * NIGHT_BRIGHT_PHASE
    
    #if SIMPLE_SKY == 0 // LITE 4.7.3
        #define ZENITH_SUNSET_COLOR vec3(0.055, 0.0863, 0.1373)
        #define ZENITH_DAY_COLOR vec3(0.13, 0.31, 0.65)
        #define ZENITH_NIGHT_COLOR vec3(0.0075, 0.015, 0.0225) * NIGHT_BRIGHT_PHASE
        
        #define HORIZON_SUNSET_COLOR vec3(0.7, 0.3216, 0.1686)
        #define HORIZON_DAY_COLOR vec3(1.15)
        #define HORIZON_NIGHT_COLOR vec3(0.005, 0.015, 0.03) * NIGHT_BRIGHT_PHASE
    #else // LITE 4.1 Legacy
        #define ZENITH_SUNSET_COLOR vec3(0.3, 0.35, 0.45)
        #define ZENITH_DAY_COLOR vec3(0.45, 0.65, 1.0)
        #define ZENITH_NIGHT_COLOR vec3(0.01, 0.02, 0.03) * NIGHT_BRIGHT_PHASE

        #define HORIZON_SUNSET_COLOR vec3(0.6118, 0.4588, 0.4196)
        #define HORIZON_DAY_COLOR vec3(0.6, 0.8, 1.0)
        #define HORIZON_NIGHT_COLOR vec3(0.025, 0.03, 0.04) * NIGHT_BRIGHT_PHASE 
    #endif

    #undef  MID_SUNSET_COLOR // Avoiding error in Optifine, do not remove undef!
    #undef  MID_DAY_COLOR
    #undef  MID_NIGHT_COLOR

    #define MID_SUNSET_COLOR vec3(0.1137, 0.1647, 0.2039)
    #define MID_DAY_COLOR vec3(0.25, 0.55, 0.9)
    #define MID_NIGHT_COLOR vec3(0.0166, 0.02, 0.025) * NIGHT_BRIGHT_PHASE * 1.333

    #define WATER_COLOR vec3(0.0, 0.105, 0.1375)
#elif COLOR_SCHEME == 9  // LITE Realistic (pollution)
    #define OMNI_TINT 0.25
    #define LIGHT_SUNSET_COLOR vec3(1.0, 0.5, 0.3)
    #define LIGHT_DAY_COLOR vec3(0.9, 0.75, 0.75)
    #define LIGHT_NIGHT_COLOR vec3(0.04, 0.05, 0.06) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.2, 0.3, 0.5)
    #define ZENITH_DAY_COLOR vec3(0.3, 0.5, 0.6)
    #define ZENITH_NIGHT_COLOR vec3(0.01, 0.02, 0.04) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.0, 0.5, 0.3)
    #define HORIZON_DAY_COLOR vec3(0.8, 0.7, 0.7)
    #define HORIZON_NIGHT_COLOR vec3(0.03, 0.03, 0.04) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.04, 0.06, 0.06)
#elif COLOR_SCHEME == 10  // LITE Realistic Legacy (3.3)
    #define OMNI_TINT 0.3
 
    #define LIGHT_SUNSET_COLOR vec3(0.8, 0.4, 0.2)
    #define LIGHT_DAY_COLOR vec3(0.9, 0.85, 0.8)
    #define LIGHT_NIGHT_COLOR vec3(0.07, 0.07, 0.08) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.3, 0.45, 0.625)
    #define ZENITH_DAY_COLOR vec3(0.25, 0.54, 0.93)
    #define ZENITH_NIGHT_COLOR vec3(0.015, 0.03, 0.045) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(1.0, 0.75, 0.7)
    #define HORIZON_DAY_COLOR vec3(0.6, 0.9, 1.0)
    #define HORIZON_NIGHT_COLOR vec3(0.02, 0.03, 0.04) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.1, 0.1, 0.15)
#elif COLOR_SCHEME == 11  // LITE Vanilla (Very hard too simulate Vanilla omg)
    #define OMNI_TINT 1.0

    #define LIGHT_SUNSET_COLOR vec3(0.66, 0.5, 0.5)
    #define LIGHT_DAY_COLOR vec3(0.9, 0.9, 1.0)
    #define LIGHT_NIGHT_COLOR vec3(0.075, 0.075, 0.1) * 0.3

    #define ZENITH_SUNSET_COLOR saturate(vec3(0.2, 0.4, 1.0), day_blend_float(0.6, 1.0, 0.2)) * 2.3 * day_blend_float(1.0, 1.0, 0.0) * day_blend(vec3(1.0), vec3(1.0), vec3(1.2, 1.1, 0.8))
    #define ZENITH_DAY_COLOR vec3(0.29, 0.42, 1.0) * 2.3
    #define ZENITH_NIGHT_COLOR saturate(vec3(0.25, 0.4078, 1.0), 0.0) * skyColor * day_blend_float(1.0, 0.2, 1.0) * NIGHT_BRIGHT_PHASE * day_blend(vec3(2.2, 1.8, 0.0), vec3(1.0), vec3(1.0))

    #define HORIZON_SUNSET_COLOR saturate(fogColor, day_blend_float(1.0, 1.0, 5.0)) * 2 * vec3(1.0, 0.8, 0.7) * day_blend_float(1.0, 1.0, 0.4)
    #define HORIZON_DAY_COLOR fogColor * 2.2 * vec3(0.75, 0.8, 1.0)
    #define HORIZON_NIGHT_COLOR saturate(fogColor, day_blend_float(0.0, 0.0, 0.6)) * day_blend_float(1.5, 0.35, 0.2) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.0314, 0.1373, 0.4784)
#elif COLOR_SCHEME == 12  // LITE Cursed
    #define OMNI_TINT 1.0

    #undef  MID_SUNSET_COLOR // Avoiding error in Optifine, do not remove undef!
    #undef  MID_DAY_COLOR
    #undef  MID_NIGHT_COLOR

    #define LIGHT_SUNSET_COLOR vec3(0.025)
    #define LIGHT_DAY_COLOR vec3(0.05)
    #define LIGHT_NIGHT_COLOR vec3(0.01) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(0.015)
    #define ZENITH_DAY_COLOR vec3(0.0706)
    #define ZENITH_NIGHT_COLOR vec3(0.01) * NIGHT_BRIGHT_PHASE

    #define MID_SUNSET_COLOR vec3(0.04)
    #define MID_DAY_COLOR vec3(0.0941, 0.0941, 0.0941)
    #define MID_NIGHT_COLOR vec3(0.005) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(0.0941, 0.0784, 0.0745)
    #define HORIZON_DAY_COLOR vec3(0.1255, 0.1255, 0.1255)
    #define HORIZON_NIGHT_COLOR vec3(0.01) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(0.0, 0.0, 0.0)
#elif COLOR_SCHEME == 99 // Custom
    #define OMNI_TINT OMNI_TINT_CUSTOM
    #define LIGHT_SUNSET_COLOR vec3(LIGHT_SUNSET_COLOR_R, LIGHT_SUNSET_COLOR_G, LIGHT_SUNSET_COLOR_B)
    #define LIGHT_DAY_COLOR vec3(LIGHT_DAY_COLOR_R, LIGHT_DAY_COLOR_G, LIGHT_DAY_COLOR_B)
    #define LIGHT_NIGHT_COLOR vec3(LIGHT_NIGHT_COLOR_R, LIGHT_NIGHT_COLOR_G, LIGHT_NIGHT_COLOR_B) * NIGHT_BRIGHT_PHASE

    #define ZENITH_SUNSET_COLOR vec3(ZENITH_SUNSET_COLOR_R, ZENITH_SUNSET_COLOR_G, ZENITH_SUNSET_COLOR_B)
    #define ZENITH_DAY_COLOR vec3(ZENITH_DAY_COLOR_R, ZENITH_DAY_COLOR_G, ZENITH_DAY_COLOR_B)
    #define ZENITH_NIGHT_COLOR vec3(ZENITH_NIGHT_COLOR_R, ZENITH_NIGHT_COLOR_G, ZENITH_NIGHT_COLOR_B) * NIGHT_BRIGHT_PHASE

    #define HORIZON_SUNSET_COLOR vec3(HORIZON_SUNSET_COLOR_R, HORIZON_SUNSET_COLOR_G, HORIZON_SUNSET_COLOR_B)
    #define HORIZON_DAY_COLOR vec3(HORIZON_DAY_COLOR_R, HORIZON_DAY_COLOR_G, HORIZON_DAY_COLOR_B)
    #define HORIZON_NIGHT_COLOR vec3(HORIZON_NIGHT_COLOR_R, HORIZON_NIGHT_COLOR_G, HORIZON_NIGHT_COLOR_B) * NIGHT_BRIGHT_PHASE

    #define WATER_COLOR vec3(WATER_COLOR_R, WATER_COLOR_G, WATER_COLOR_B)
#endif

#define NV_COLOR vec3(NV_COLOR_R, NV_COLOR_G, NV_COLOR_B)

#include "/lib/day_blend.glsl"

// Fog parameter per hour
#if VOL_LIGHT == 1 || (VOL_LIGHT == 2 && defined SHADOW_CASTING) || defined UNKNOWN_DIM
    #define FOG_DENSITY 3.0
#endif
    
#define FOG_DAY 2.75
#define FOG_SUNSET 2.75
#define FOG_NIGHT 2.0


#include "/lib/color_conversion.glsl"
