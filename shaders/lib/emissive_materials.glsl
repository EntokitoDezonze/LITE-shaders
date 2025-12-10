/* __   ______________
  / /  /  _/_  __/ __/
 / /___/ /  / / / _/
/____/___/ /_/ /___/

LITE shaders 4.7.3 - emissive_materials.glsl #include "/lib/emissive_materials.glsl"
Emissive properties for ores, some materials, particles and entities. - Propriedades emissivas para minérios, alguns materiais, partículas e entidades. */

vec3 emmisive_color = vec3(1.0);

#if (defined EMMISIVE_ORE || defined EMMISIVE_MATERIAL) && defined GBUFFER_TERRAIN
    float correct_light = 1.0;
    float correct_light_ore = 1.0;  
    vec3 color = pure_block_color.rgb;
    vec3 sqrt_color = sqrt(pure_block_color.rgb);
    float luma_color = luma(sqrt(pure_block_color.rgb)); 

    // * luma_color = pow(x, 1.5);
    // * luma(color) = pow(x, 2.0);

    if (luma(color) < 0.05 && ore_type == 0 && emitter_type == 0) {
    } else 
    
    if (ore_type > 0 || emitter_type > 0) {
        
        float saturation = 0.0;
        float luminance = 0.0;
        correct_light_ore = clamp(luma(1.0 - real_light), 0.5, 1.0);
        correct_light = clamp(luma(2.0 - real_light), 0.5, 1.0);
        
        float min_color = min(min(color.r, color.g), color.b);
        float max_color = max(max(color.r, color.g), color.b);
        saturation = (max_color - min_color) / (max_color + 0.0001);
        luminance = block_luma;


    #if defined EMMISIVE_ORE && defined GBUFFER_TERRAIN
        float factor_gold = step(1.0, float(ore_type)) * step(float(ore_type), 1.0);
        float factor_diamond = step(2.0, float(ore_type)) * step(float(ore_type), 2.0);
        float factor_iron = step(3.0, float(ore_type)) * step(float(ore_type), 3.0);
        float factor_emerald = step(4.0, float(ore_type)) * step(float(ore_type), 4.0);
        float factor_redstone = step(5.0, float(ore_type)) * step(float(ore_type), 5.0);
        float factor_quartz = step(6.0, float(ore_type)) * step(float(ore_type), 6.0);
        float factor_lapis = step(7.0, float(ore_type)) * step(float(ore_type), 7.0);
        float factor_copper = step(8.0, float(ore_type)) * step(float(ore_type), 8.0);
        
        // GOLD (ore_type == 1)
        vec3 target_color_gold = vec3(1.0, 1.0, 0.0);
        float match_cond_1_gold = step(dot(color - target_color_gold, color - target_color_gold), 1.0) * step(0.1, saturation) * step(0.31, luminance);
        float match_cond_2_gold = float(all(greaterThan(color, vec3(0.9))));
        float gold_match = clamp(match_cond_1_gold + match_cond_2_gold, 0.0, 1.0);
        emmisive_color = mix(emmisive_color, emmisive_color * 8.0 * luma_color * vec3(1.0, 0.66, 0.66) * correct_light_ore, gold_match * factor_gold);

        // DIAMOND (ore_type == 2)
        vec3 target_color_dark_diamond = vec3(0.0, 1.0, 1.0);
        vec3 target_color_light_diamond = vec3(1.0, 1.0, 1.0);
        float match_cond_1_diamond = step(dot(color - target_color_dark_diamond, color - target_color_dark_diamond), 0.49);
        float match_cond_2_diamond = step(dot(color - target_color_light_diamond, color - target_color_light_diamond), 0.09);
        float diamond_match = clamp(match_cond_1_diamond + match_cond_2_diamond, 0.0, 1.0);
        emmisive_color = mix(emmisive_color, emmisive_color * 7.5 * luma(color) * correct_light_ore, diamond_match * factor_diamond);

        // IRON (ore_type == 3)
        vec3 target_color_iron = vec3(0.816, 0.667, 0.557);
        float iron_match = step(dot(color - target_color_iron, color - target_color_iron), 1.0) * step(0.1, saturation) * step(0.2, luminance);
        emmisive_color = mix(emmisive_color, emmisive_color * 10.0 * luma(color) * vec3(1.0, 0.6, 0.5) * correct_light_ore, iron_match * factor_iron);

        // EMERALD (ore_type == 4)
        vec3 target_color_dark_emerald = vec3(0.0, 0.4, 0.0);
        vec3 target_color_light_emerald = vec3(0.6, 1.0, 0.6);
        float match_cond_1_emerald = step(dot(color - target_color_dark_emerald, color - target_color_dark_emerald), 0.09);
        float match_cond_2_emerald = step(dot(color - target_color_light_emerald, color - target_color_light_emerald), 0.49);
        float emerald_match = clamp(match_cond_1_emerald + match_cond_2_emerald, 0.0, 1.0);
        emerald_match *= step(0.14, saturation) * step(0.2, luminance);
        emmisive_color = mix(emmisive_color, emmisive_color * 10.0 * luma_color * vec3(0.25, 0.6, 0.2) * correct_light_ore, emerald_match * factor_emerald);

        // REDSTONE (ore_type == 5)
        vec3 target_color_dark_redstone = vec3(1.0, 0.0, 0.0);
        vec3 target_color_light_redstone = vec3(1.0, 0.5, 0.5);
        float match_cond_1_redstone = step(dot(color - target_color_dark_redstone, color - target_color_dark_redstone), 0.49);
        float match_cond_2_redstone = step(dot(color - target_color_light_redstone, color - target_color_light_redstone), 0.49);
        float redstone_match = clamp(match_cond_1_redstone + match_cond_2_redstone, 0.0, 1.0);
        redstone_match *= step(0.35, saturation) * step(0.01, luminance);
        emmisive_color = mix(emmisive_color, emmisive_color * 15.0 * color * correct_light_ore, redstone_match * factor_redstone);

        // QUARTZ (ore_type == 6)
        vec3 target_color_dark_quartz = vec3(0.443, 0.325, 0.224);
        vec3 target_color_light_quartz = vec3(1.0);
        float match_cond_1_quartz = step(dot(color - target_color_dark_quartz, color - target_color_dark_quartz), 0.49);
        float match_cond_2_quartz = step(dot(color - target_color_light_quartz, color - target_color_light_quartz), 0.5625);
        float quartz_match = clamp(match_cond_1_quartz + match_cond_2_quartz, 0.0, 1.0);
        quartz_match *= step(0.45, luminance);
        emmisive_color = mix(emmisive_color, emmisive_color * 12.0 * luma(color) * vec3(0.6, 0.5, 0.5) * correct_light_ore, quartz_match * factor_quartz);

        // LAPIS (ore_type == 7)
        vec3 target_color_lapis = vec3(0.0, 0.0, 1.0);
        float lapis_match = step(dot(color - target_color_lapis, color - target_color_lapis), 0.5625) * step(0.1, saturation) * step(0.1, luminance);
        emmisive_color = mix(emmisive_color, emmisive_color * 20.0 * luma(color) * vec3(0.5, 0.5, 1.0) * correct_light_ore, lapis_match * factor_lapis);

        // COPPER (ore_type == 8)
        vec3 target_color_dark_copper = vec3(0.847,0.486,0.282);
        vec3 target_color_light_copper = vec3(0.341,0.737,0.616);
        float base_match_copper = step(0.3, saturation) * step(0.1, luminance);
        
        float match_dark_copper = step(dot(color - target_color_dark_copper, color - target_color_dark_copper), 0.25) * base_match_copper;
        float match_light_copper = step(dot(color - target_color_light_copper, color - target_color_light_copper), 0.3) * base_match_copper;
        
        vec3 factor_dark_luma = 15.0 * luma(color) * vec3(1.0, 0.7, 0.5) * correct_light_ore;
        vec3 factor_light_luma = 15.0 * luma(color)* vec3(0.5, 1.0, 0.7) * correct_light_ore;
        
        vec3 final_copper_emissive = mix(vec3(1.0), factor_dark_luma, match_dark_copper);
        final_copper_emissive = mix(final_copper_emissive, factor_light_luma, match_light_copper);
        
        float copper_total_match = clamp(match_dark_copper + match_light_copper, 0.0, 1.0);
        
        emmisive_color = mix(emmisive_color, emmisive_color * final_copper_emissive, copper_total_match * factor_copper);

    #endif

    #if defined EMMISIVE_MATERIAL && defined GBUFFER_TERRAIN
        float factor_redmat = step(1.0, float(emitter_type)) * step(float(emitter_type), 1.0); // Redstone
        float factor_solar = step(2.0, float(emitter_type)) * step(float(emitter_type), 2.0); // Solar panel
        float factor_cobs = step(3.0, float(emitter_type)) * step(float(emitter_type), 3.0); // Crying obsidian
        float factor_wh = step(4.0, float(emitter_type)) * step(float(emitter_type), 4.0); // White highlights
        float factor_fire = step(5.0, float(emitter_type)) * step(float(emitter_type), 5.0); // Fire
        float factor_sculk = step(6.0, float(emitter_type)) * step(float(emitter_type), 6.0); // Sculk
        float factor_lba = step(7.0, float(emitter_type)) * step(float(emitter_type), 7.0); // Lava, beacon, etc
        float factor_frog = step(8.0, float(emitter_type)) * step(float(emitter_type), 8.0); // Froglight
        float factor_fake = step(9.0, float(emitter_type)) * step(float(emitter_type), 9.0); // Fake emmisors
        float factor_rail = step(10.0, float(emitter_type)) * step(float(emitter_type), 10.0); // Rails
        float factor_end = step(11.0, float(emitter_type)) * step(float(emitter_type), 11.0); // End Portal frame
        
        // REDSTONE MATERIAL (emitter_type == 1)
        vec3 target_color_alt_redmat = vec3(1.0);
        vec3 target_color_alt2_redmat = vec3(0.75, 0.5, 0.0);
        vec3 target_color_redmat = vec3(1.0, 0.0, 0.0);
        vec3 target_color_light_redmat = vec3(1.0, 0.0, 0.0);
        
        float base_sat_lum_redmat = step(0.15, saturation) * step(0.1, luminance);
        float match_1_redmat = step(dot(color - target_color_redmat, color - target_color_redmat), 0.3) * base_sat_lum_redmat;
        float match_2_redmat = step(dot(color - target_color_light_redmat, color - target_color_light_redmat), 0.12) * step(luminance, 0.8) * step(0.3, saturation);
        float match_3_redmat = step(dot(color - target_color_alt_redmat, color - target_color_alt_redmat), 0.07);
        float match_4_redmat = step(dot(color - target_color_alt2_redmat, color - target_color_alt2_redmat), 0.8) * step(0.9, luminance) * step(0.15, saturation);
        
        vec3 final_emissive_redmat = vec3(1.0);
        float total_match_redmat = 0.0;
        
        final_emissive_redmat = mix(final_emissive_redmat, vec3(1.0, 0.5, 0.5) * vec3(25.0 * correct_light), match_1_redmat);
        total_match_redmat = max(total_match_redmat, match_1_redmat);
        final_emissive_redmat = mix(final_emissive_redmat, vec3(20.0 * correct_light) * vec3(1.0, 0.5, 0.5), match_2_redmat);
        total_match_redmat = max(total_match_redmat, match_2_redmat);
        final_emissive_redmat = mix(final_emissive_redmat, vec3(1.0, 0.5, 0.5) * 5.0 * correct_light, match_3_redmat); 
        total_match_redmat = max(total_match_redmat, match_3_redmat);
        final_emissive_redmat = mix(final_emissive_redmat, vec3(1.0, 0.5, 0.5) * vec3(12.5 * correct_light), match_4_redmat);
        total_match_redmat = max(total_match_redmat, match_4_redmat);
        
        emmisive_color = mix(emmisive_color, emmisive_color * final_emissive_redmat, total_match_redmat * factor_redmat);
        
        // SOLAR PANEL (emitter_type == 2)
        vec3 target_color_dark_solar = vec3(1.0);
        float solar_match = step(dot(color - target_color_dark_solar, color - target_color_dark_solar), 0.49) * step(0.00, saturation) * step(0.1, luminance);
        emmisive_color = mix(emmisive_color, emmisive_color * 10.0 * correct_light * color * color * block_luma, solar_match * factor_solar);
        
        // CRYING OBSIDIAN (emitter_type == 3)
        vec3 target_color_dark_cobs = vec3(0.25, 0.0, 0.5);
        vec3 target_color_light_cobs = vec3(0.75, 0.0, 1.0);
        float base_sat_cobs = step(0.5, saturation);
        float match_1_cobs = step(dot(color - target_color_dark_cobs, color - target_color_dark_cobs), 0.01) * base_sat_cobs;
        float match_2_cobs = step(dot(color - target_color_light_cobs, color - target_color_light_cobs), 0.25) * step(0.15, saturation);

        float factor_cobs_1 = 5.0 * correct_light;
        float factor_cobs_2 = luma(color) * 30.0 * correct_light;
        
        vec3 final_emissive_cobs = mix(vec3(1.0), vec3(factor_cobs_1), match_1_cobs);
        final_emissive_cobs = mix(final_emissive_cobs, vec3(factor_cobs_2), match_2_cobs);
        
        float total_match_cobs = clamp(match_1_cobs + match_2_cobs, 0.0, 1.0);
        
        emmisive_color = mix(emmisive_color, emmisive_color * final_emissive_cobs, total_match_cobs * factor_cobs);
        
        // WHITE HIGHLIGHTS (emitter_type == 4)
        vec3 target_color_dark_wh = vec3(0.5, 1.0, 1.0);
        vec3 target_color_dark_2_wh = vec3(0.75, 0.25, 0.5);
        vec3 target_color_light_wh = vec3(0.75);
        vec3 target_color_light_2_wh = vec3(0.686,0.686,0.525);
        
        float match_1_wh = step(dot(color - target_color_dark_wh, color - target_color_dark_wh), 0.49) * step(0.5, saturation) * step(0.2, luminance);
        float match_2_wh = step(dot(color - target_color_light_wh, color - target_color_light_wh), 0.65) * step(0.99, luminance);
        float match_3_wh = step(dot(color - target_color_light_2_wh, color - target_color_light_2_wh), 0.04) * step(0.1, saturation);
        float match_4_wh = step(dot(color - target_color_dark_2_wh, color - target_color_dark_2_wh), 0.28) * step(0.3, saturation) * step(0.0, luminance);
        
        vec3 final_emissive_wh = vec3(1.0);
        float total_match_wh = 0.0;
        
        final_emissive_wh = mix(final_emissive_wh, vec3(10.0) * correct_light * block_luma, match_1_wh);
        total_match_wh = max(total_match_wh, match_1_wh);
        final_emissive_wh = mix(final_emissive_wh, vec3(5.0) * correct_light * block_luma, match_2_wh);
        total_match_wh = max(total_match_wh, match_2_wh);
        final_emissive_wh = mix(final_emissive_wh, vec3(10.0) * correct_light * block_luma, match_3_wh);
        total_match_wh = max(total_match_wh, match_3_wh);
        final_emissive_wh = mix(final_emissive_wh, vec3(2.5) * correct_light, match_4_wh);
        total_match_wh = max(total_match_wh, match_4_wh);
        
        emmisive_color = mix(emmisive_color, emmisive_color * final_emissive_wh, total_match_wh * factor_wh);
        
        // FIRE (emitter_type == 5)
        vec3 target_color_dark_fire = vec3(1.0, 0.5, 0.0);
        vec3 target_color_light_fire = vec3(1.0);
        
        float match_1_fire = step(dot(color - target_color_dark_fire, color - target_color_dark_fire), 0.16) * step(0.0, saturation) * step(0.2, luminance);
        float match_2_fire = step(dot(color - target_color_light_fire, color - target_color_light_fire), 0.49) * step(-0.1, saturation) * step(0.9, luminance);
        
        vec3 final_emissive_fire = vec3(1.0);
        float total_match_fire = 0.0;

        final_emissive_fire = mix(final_emissive_fire, 15.0 * correct_light * vec3(1.0, 0.5, 0.0) * block_luma, match_1_fire);
        total_match_fire = max(total_match_fire, match_1_fire);
        final_emissive_fire = mix(final_emissive_fire, vec3(15.0) * correct_light * block_luma, match_2_fire);
        total_match_fire = max(total_match_fire, match_2_fire);

        emmisive_color = mix(emmisive_color, emmisive_color * final_emissive_fire, total_match_fire * factor_fire);
        
        // SCULK (emitter_type == 6)
        vec3 target_color_sculk = vec3(0.05, 0.7, 0.8);
        float distance_to_target_sculk = distance(color, target_color_sculk);
        float brightness_sculk = smoothstep(0.6, 0.0, distance_to_target_sculk) * 10.0;
        float match_sculk = step(0.5, saturation) * step(0.2, luminance);
        emmisive_color = mix(emmisive_color, emmisive_color * (1.0 + brightness_sculk * correct_light), match_sculk * factor_sculk);
        
        // LAVA/MAGMA/ETC. (emitter_type == 7)
        vec3 target_color_dark_lba = vec3(1.0, 0.5, 0.0);
        vec3 target_color_dark_2_lba = vec3(1.0, 0.0, 0.0);
        vec3 target_color_light_lba = vec3(0.0, 0.651, 1.0);
        
        float match_1_lba = step(dot(color - target_color_dark_lba, color - target_color_dark_lba), 0.5) * step(0.5, saturation) * step(0.2, luminance);
        float match_2_lba = step(dot(color - target_color_dark_2_lba, color - target_color_dark_2_lba), 0.6) * step(saturation, 0.67) * step(luminance, 0.6); 
        float match_3_lba = step(dot(color - target_color_light_lba, color - target_color_light_lba), 1.0);

        emmisive_color = mix(emmisive_color, emmisive_color * 1.75 * correct_light * vec3(1.0, 0.55, 1.0), match_1_lba * factor_lba);
        emmisive_color -= mix(vec3(0.0), v3_luma(candle_color * 0.8) * correct_light, match_2_lba * factor_lba);
        emmisive_color -= mix(vec3(0.0), (candle_color * 0.5) - v3_luma(candle_color * 0.5) * correct_light, match_3_lba * factor_lba);
        
        // FROGLIGHT (emitter_type == 8)
        emmisive_color = mix(emmisive_color, emmisive_color * color * 1.4, factor_frog);
        emmisive_color -= mix(vec3(0.0), (candle_color * 0.25) * correct_light, factor_frog);
        
        // FAKE EMISSORS (emitter_type == 9)
        vec3 target_color_fake = vec3(0.4353, 0.3373, 0.2745);
        float match_fake = step(0.12, dot(color - target_color_fake, color - target_color_fake)) * step(-0.1, saturation) * step(0.0, luminance); 
        emmisive_color = (mix(emmisive_color, emmisive_color * 2.75 * color * correct_light, match_fake * factor_fake));
        
        // RAIL (emitter_type == 10)
        vec3 target_color_rail = vec3(1.0, 0.0, 0.0);
        float rail_match = step(dot(color - target_color_rail, color - target_color_rail), 0.25);
        emmisive_color = mix(emmisive_color, emmisive_color * 10.0 * vec3(1.0, 0.0, 0.0) * correct_light, rail_match * factor_rail);

        // END PORTAL FRAME (emitter_type == 11)
        vec3 target_color_end = vec3(1.0, 1.0, 1.0);
        vec3 target_color_end2 = vec3(0.0, 0.7765, 0.5412);
        
        float end_match = step(dot(color - target_color_end, color - target_color_end), 20.25) * step(0.0, saturation) * step(0.0, luminance);
        float end_match2 = step(dot(color - target_color_end2, color - target_color_end2), 0.5) * step(0.0, saturation);
        
        emmisive_color = mix(emmisive_color, emmisive_color * 3.5 * color * correct_light, end_match2 * factor_end);

        emmisive_color -= mix(vec3(0.0), v3_luma(final_candle_color * 0.75) * correct_light, end_match * factor_end);
    #endif
    }
#endif

#if defined GBUFFER_TEXTURED
    vec3 target_color_rain = vec3(0.0, 0.7098, 1.0);
    float match_rain = step(dot(pure_block_color.rgb - target_color_rain, pure_block_color.rgb - target_color_rain), 0.3);
    block_color = mix(block_color, saturate_v4(block_color * 1.5, 0.25), match_rain);
#endif

#if defined GBUFFER_ENTITIES
    if(entityId == 10200) { // DROWNED
        vec3 target_color_dr = vec3(0.561, 0.945, 0.843);
        vec3 target_color_dr2 = vec3(0.192, 0.678, 0.718);
        vec3 target_color_dr3 = vec3(0.396, 0.878, 0.867);

        float drowned_match = step(dot(pure_block_color.rgb - target_color_dr, pure_block_color.rgb - target_color_dr), 0.01);
        float drowned_match2 = step(dot(pure_block_color.rgb - target_color_dr2, pure_block_color.rgb - target_color_dr2), 0.01);
        float drowned_match3 = step(dot(pure_block_color.rgb - target_color_dr3, pure_block_color.rgb - target_color_dr3), 0.01);

        emmisive_color = mix(emmisive_color, emmisive_color * 5, drowned_match);
        emmisive_color = mix(emmisive_color, emmisive_color * 5, drowned_match2);
        emmisive_color = mix(emmisive_color, emmisive_color * 5, drowned_match3);
    }
#endif

block_color.rgb *= emmisive_color;