/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.7.3 - biome_sky.glsl #include "/lib/biome_sky.glsl"
Biome-based sky color calculation. Cálculo de cores do céu baseado em bioma. */

uniform float swamp;
uniform float arid;
uniform float jungle;
uniform float pale_garden;
uniform float snow;
uniform float taiga;
uniform float hill;

float taiga_snow = clamp(taiga + snow + hill, 0.0, 1.0); // Pre-calculated

/* PREPARE FRAGMENT SHADER */

#if defined PREPARE_SHADER || defined DEFERRED_SHADER || defined GBUFFER_SKYBASIC && (!defined THE_END && !defined NETHER)
    #ifdef BIOME_SKY
        /* SWAMP */
        vec3 swamp_sky_color = day_blend(vec3(1.0, 0.65, 0.5) * 2.0, vec3(1.0, 0.65, 0.5) * 2.0, vec3(1.0));
        vec3 swamp_sky = mix(vec3(1.0), swamp_sky_color, swamp);
        
        vec3 swamp_sky2_color = day_blend(vec3(0.75, 1.0, 0.75) * 1.15, vec3(0.5, 1.0, 0.5) * 1.15, vec3(1.0));
        vec3 swamp_sky2 = mix(vec3(1.0), swamp_sky2_color, clamp(swamp + jungle, 0.0, 1.0));

        /* ARID BIOMES & SANDSTORM */
        vec3 arid_day_blend = day_blend(vec3(0.85, 0.7, 0.6) * 1.5, vec3(0.75, 1.0, 1.0) * 1.15, vec3(1.0));
        vec3 arid_sky0 = mix(vec3(1.0), arid_day_blend, arid);

        vec3 arid_mix_val = mix(vec3(0.75), vec3(1.0, 0.7, 0.4), arid) * 2.0;
        vec3 arid_sky = mix(arid_sky0, arid_mix_val, rainStrength);

        vec3 arid_day_blend02 = day_blend(vec3(1.0, 0.65, 0.4), vec3(1.0, 0.65, 0.4) * 1.5, vec3(1.0));
        vec3 arid_sky02 = mix(vec3(1.0), arid_day_blend02, arid);

        float arid_wetness_factor = rainStrength * day_blend_float(0.0, 0.0, 1.0);
        vec3 arid_mix_val2 = mix(vec3(0.75), vec3(0.8, 0.5, 0.3), arid) * 2.0;
        vec3 arid_sky2 = mix(arid_sky02, arid_mix_val2, arid_wetness_factor);

        /* PALE_GARDEN */
        vec3 pale_day_blend = day_blend(vec3(0.4, 0.25, 0.2) * 5.0, vec3(0.666, 0.3, 0.2) * 3.0, vec3(1.0));
        vec3 pale_garden_sky = mix(vec3(1.0), pale_day_blend, pale_garden);

        vec3 pale_garden_sky2 = mix(vec3(1.0), vec3(1.1), pale_garden);

        /* SNOWY AND TAIGA */
        vec3 taiga_day_blend = day_blend(vec3(1.0, 0.65, 0.5) * 2.0, vec3(1.0, 0.55, 0.4) * 2.0, vec3(1.0));
        vec3 taiga_sky = mix(vec3(1.0), taiga_day_blend, taiga_snow);
        
        vec3 taiga_day_blend2 = day_blend(vec3(0.75, 0.75, 1.0) * 1.5, vec3(0.8) * 1.5, vec3(1.0));
        vec3 taiga_sky2 = mix(vec3(1.0), taiga_day_blend2, taiga_snow);

        /* FINAL TRANSFORMATION */
        vec3 pre_biome_sky = swamp_sky * arid_sky * pale_garden_sky * taiga_sky;
        vec3 pre2_biome_sky = mix(pre_biome_sky, vec3(1.0), rainStrength);
        
        vec3 biome_sky = pre2_biome_sky * arid_sky; 
        
        vec3 pre_biome_sky2 = pale_garden_sky2 * swamp_sky2 * taiga_sky2;
        vec3 pre_biome_sky_low = mix(pre_biome_sky2, vec3(1.0), rainStrength);
        vec3 biome_sky_low = pre_biome_sky_low * arid_sky2;
    #else
        vec3 biome_sky = vec3(1.0);
        vec3 biome_sky_low = vec3(1.0);
    #endif
#endif

/* FOG VERTEX SHADER */

#if defined BIOME_FOG && (!defined THE_END && !defined NETHER)
    /* GENERAL BIOMES */
    float swamp_fog_base = mix(1.0, 0.333, swamp);
    float swamp_fog = mix(swamp_fog_base, 1.0, rainStrength);

    float snow_fog_dry = mix(1.0, 0.2, taiga_snow);
    float snow_fog_wet = mix(1.0, 0.5, taiga_snow);
    float snow_fog = mix(snow_fog_dry, snow_fog_wet, rainStrength);

    /* SANDSTORM */
    #ifdef SANDSTORM
        float arid_fog_dry = mix(1.0, 0.5, arid);
        float arid_fog_wet = mix(1.0, 0.2, arid);
        float arid_fog = mix(arid_fog_dry, arid_fog_wet, rainStrength);
    #else
        float arid_fog = mix(1.0, 0.5, arid);
    #endif

    float biome_fog = swamp_fog * arid_fog * snow_fog;
#else
    float biome_fog = 1.0;
#endif
