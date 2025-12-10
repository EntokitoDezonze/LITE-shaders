/* MakeUp - LITE shaders 4.7.3 - volumetric_clouds.glsl
Fast volumetric clouds - MakeUp & LITE shaders implementation
*/

// Constants for the second cloud layer
#ifdef CIRRUS
    #define CLOUD_PLANE_2 (CLOUD_PLANE + 800.0)
    #define CLOUD_PLANE_SUP_2 (CLOUD_PLANE_SUP + 1000.0)
    #define CLOUD_PLANE_CENTER_2 (CLOUD_PLANE_CENTER + 800.0)
    #define CLOUD_X_OFFSET 800.0
#endif

vec3 get_cloud(vec3 view_vector, vec3 block_color, float bright, float dither, vec3 base_pos, int samples, float umbral, vec3 cloud_color_orig, vec3 dark_cloud_color_orig, float dynamicValue) {
    float plane_distance;
    float cloud_value;
    float density;
    vec3 intersection_pos;
    vec3 intersection_pos_sup;
    float dif_inf;
    float dif_sup;
    float dist_aux_coeff;
    float current_value;
    float surface_inf;
    float surface_sup;
    bool first_contact = true;
    float opacity_dist;
    vec3 increment;
    float increment_dist;
    float view_y_inv = 1.0 / view_vector.y;
    float distance_aux;
    float dist_aux_coeff_blur;

    // Cirrus clouds variables
    #ifdef CIRRUS
        float cloud_value_2;
        float density_2;
        vec3 intersection_pos_2;
        vec3 intersection_pos_sup_2;
        float dif_inf_2;
        float dif_sup_2;
        float opacity_dist_2;
        vec3 increment_2;
        float increment_dist_2;
        bool first_contact_2 = true;
        float current_value2;
    #endif

    #if VOL_LIGHT == 0
        block_color.rgb *=
            clamp(bright + ((dither - .5) * .1), 0.0, 1.0) * .3 + 1.0;
    #endif

    #if defined DISTANT_HORIZONS && defined DEFERRED_SHADER
        float d_dh = texture2D(dhDepthTex0, vec2(gl_FragCoord.x / viewWidth, gl_FragCoord.y / viewHeight)).r;
        float linear_d_dh = ld_dh(d_dh);
        if (linear_d_dh < 0.9999) {
            return block_color;
        }
    #endif

    if (view_vector.y > 0.0) {
        // 1st layer
        plane_distance = (CLOUD_PLANE - base_pos.y) * view_y_inv;
        intersection_pos = (view_vector * plane_distance) + base_pos;

        plane_distance = (CLOUD_PLANE_SUP - base_pos.y) * view_y_inv;
        intersection_pos_sup = (view_vector * plane_distance) + base_pos;

        dif_sup = (CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER) / CLOUD_DENSITY;
        dif_inf = (CLOUD_PLANE_CENTER - CLOUD_PLANE) / CLOUD_DENSITY;
        dist_aux_coeff = (CLOUD_PLANE_SUP - CLOUD_PLANE) * 0.075 / CLOUD_DENSITY;
        dist_aux_coeff_blur = dist_aux_coeff * 0.3;

        opacity_dist = dist_aux_coeff * 2.0 * view_y_inv;

        #if CLOUD_VOL_STYLE == 0
            increment = (intersection_pos_sup - intersection_pos) / 7;
            float sample_fix = 0.0;
        #else
            increment = (intersection_pos_sup - intersection_pos) / samples;
            float sample_fix = 2.0;
        #endif
        increment_dist = length(increment);

        cloud_value = 0.0;

        intersection_pos += (increment * dither);

        for (int i = 0; i < samples + sample_fix; i++) {
            current_value =
                texture2D(
                    gaux2,
                    (intersection_pos.xz * 0.0002777777777777778) + (frameTimeCounter * (WIND_FORCE * 0.55 + 0.5) * CLOUD_HI_FACTOR)
                ).r;


            #if V_CLOUDS == 2 && CLOUD_VOL_STYLE == 0
                current_value +=
                    texture2D(
                        gaux2,
                        (intersection_pos.zx * 0.0002777777777777778) + (frameTimeCounter * (WIND_FORCE * 0.55 + 0.5) * CLOUD_LOW_FACTOR)
                    ).r;

                current_value *= 0.5;
                current_value = smoothstep(0.05, 0.95, current_value);
            #endif
            
            // Ajuste por umbral
            #if CLOUD_VOL_STYLE == 0
                current_value = (current_value - umbral) / (0.1 + dynamicValue - umbral);
            #else
                current_value = (current_value - umbral) / (1.0 - umbral); 
            #endif

            // Superficies inferior y superior de nubes
            surface_inf = CLOUD_PLANE_CENTER - (current_value * dif_inf);
            surface_sup = CLOUD_PLANE_CENTER + (current_value * dif_sup);

            if (  // Dentro de la nube
                intersection_pos.y > surface_inf &&
                intersection_pos.y < surface_sup
                ) {
                    cloud_value += min(increment_dist, surface_sup - surface_inf);

                    if (first_contact) {
                        first_contact = false;
                        density =
                        (surface_sup - intersection_pos.y) /
                        (CLOUD_PLANE_SUP - CLOUD_PLANE);
                    }
            }
            else if (surface_inf < surface_sup && i > 0) {  // Fuera de la nube
                distance_aux = min(
                    abs(intersection_pos.y - surface_inf),
                    abs(intersection_pos.y - surface_sup)
                );

                if (distance_aux < dist_aux_coeff_blur) {
                    cloud_value += min(
                        (clamp(dist_aux_coeff_blur - distance_aux, 0.0, dist_aux_coeff_blur) / dist_aux_coeff_blur) * increment_dist,
                        surface_sup - surface_inf
                    );

                    if (first_contact) {
                        first_contact = false;
                        density =
                        (surface_sup - intersection_pos.y) /
                        (CLOUD_PLANE_SUP - CLOUD_PLANE);
                    }
                }
            }

            intersection_pos += increment;
        }

        cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);
        density = clamp(density, 0.0001, 1.0);

        float att_factor = mix(1.0, 0.75, bright * (1.0 - rainStrength));

        vec3 cloud_color_1 = vec3(0.0);
        cloud_color_1 = mix(cloud_color_orig * att_factor, dark_cloud_color_orig * att_factor, pow(density, 0.4));

        vec3 light_color = day_blend(
            LIGHT_SUNSET_COLOR * 1.66,
            LIGHT_DAY_COLOR,
            LIGHT_NIGHT_COLOR * vec3(0.8, 0.6, 1.0)
        );

        // Sun halo.
        cloud_color_1 =
            mix(cloud_color_1, cloud_color_1 + light_color * day_blend_float(1.5, 3.0, 0.0), (1.0 - pow(cloud_value, 0.2)) * bright * (1.0 - rainStrength));

        cloud_color_1 =
            mix(cloud_color_1, cloud_color_1 + light_color * day_blend_float(0.0, 0.0, 0.25), (pow(cloud_value, 1.0)) * bright * bright * bright * (1.0 - rainStrength));

        #if CLOUD_VOL_STYLE == 0
        block_color = mix(
            block_color,
            cloud_color_1,
            cloud_value * clamp((view_vector.y - 0.025) * mix(50.0, 6.0, rainStrength), 0.0, 1.0) * mix(1.0, 0.0, arid * rainStrength)
        );
        #else
            block_color = mix(
            block_color,
            cloud_color_1,
            cloud_value * clamp((view_vector.y - 0.06) * 5.0, 0.0, 1.0)
        );
        #endif

    #ifdef CIRRUS
        if (CLOUD_DENSITY >= 1.0) {
            umbral *= 1.0 / pow(CLOUD_DENSITY, 3.5);
        } else {
            umbral /= CLOUD_DENSITY * 3.0;
        }
        
        #if CLOUD_VOL_STYLE == 0
            // 2nd layer CIRRUS clouds
            plane_distance = (CLOUD_PLANE_2 - base_pos.y) * view_y_inv;
            intersection_pos_2 = (view_vector * plane_distance) + base_pos;

            plane_distance = (CLOUD_PLANE_SUP_2 - base_pos.y) * view_y_inv;
            intersection_pos_sup_2 = (view_vector * plane_distance) + base_pos;

            dif_sup_2 = (CLOUD_PLANE_SUP_2 - CLOUD_PLANE_CENTER_2) / CLOUD_DENSITY;
            dif_inf_2 = (CLOUD_PLANE_CENTER_2 - CLOUD_PLANE_2) / CLOUD_DENSITY;
            dist_aux_coeff = (CLOUD_PLANE_SUP_2 - CLOUD_PLANE_2) * 0.075;
            dist_aux_coeff_blur = dist_aux_coeff * 0.3;

            opacity_dist_2 = dist_aux_coeff * 2.0 * view_y_inv;

            increment_2 = (intersection_pos_sup_2 - intersection_pos_2) / 10;
            increment_dist_2 = length(increment_2);

            cloud_value_2 = 0.0;
            intersection_pos_2 += (increment_2 * dither);

            for (int i = 0; i < CIRRUS_STEPS_AVG; i++) {
                #if CLOUD_VOL_STYLE == 0
                    current_value2 =
                        texture2D(
                            gaux2,
                            ((intersection_pos_2.xz + vec2(CLOUD_X_OFFSET, 0.0)) * 0.0002777777777777778) + (frameTimeCounter * (WIND_FORCE * 0.55 + 0.5) * CLOUD_HI_FACTOR)
                        ).r;
                #else
                    current_value2 = 0.0;
                #endif

                #if V_CLOUDS == 2 && CLOUD_VOL_STYLE == 0
                    current_value2 +=
                        texture2D(
                            gaux2,
                            ((intersection_pos_2.zx + vec2(0.0, CLOUD_X_OFFSET)) * 0.0002777777777777778) + (frameTimeCounter * (WIND_FORCE * 0.55 + 0.5) * CLOUD_LOW_FACTOR)
                        ).r;
                    current_value2 *= 0.5;
                    current_value2 = smoothstep(0.05, 0.95, current_value2);
                #endif

                #if CLOUD_VOL_STYLE == 0
                    current_value2 = (current_value2 - umbral) / (-4.0 - clamp(umbral, 0.0, 0.2)) + 0.225 - (dynamicValue * 0.25);
                #else
                    current_value2 = (current_value2 - umbral) / (1.0 - umbral);
                #endif

                surface_inf = CLOUD_PLANE_CENTER_2 - (current_value2 * dif_inf_2);
                surface_sup = CLOUD_PLANE_CENTER_2 + (current_value2 * dif_sup_2);

                if (intersection_pos_2.y > surface_inf && intersection_pos_2.y < surface_sup) {
                    cloud_value_2 += min(increment_dist_2, surface_sup - surface_inf);
                    if (first_contact_2) {
                        first_contact_2 = false;
                        density_2 = (surface_sup - intersection_pos_2.y) / (CLOUD_PLANE_SUP_2 - CLOUD_PLANE_2);
                    }
                }
                else if (surface_inf < surface_sup && i > 0) {
                    distance_aux = min(
                        abs(intersection_pos_2.y - surface_inf),
                        abs(intersection_pos_2.y - surface_sup)
                    );
                    if (distance_aux < dist_aux_coeff_blur) {
                        cloud_value_2 += min(
                            (clamp(dist_aux_coeff_blur - distance_aux, 0.0, dist_aux_coeff_blur) / dist_aux_coeff_blur) * increment_dist_2,
                            surface_sup - surface_inf
                        );
                        if (first_contact_2) {
                            first_contact_2 = false;
                            density_2 = (surface_sup - intersection_pos_2.y) / (CLOUD_PLANE_SUP_2 - CLOUD_PLANE_2);
                        }
                    }
                }
                intersection_pos_2 += increment_2;
            }

            cloud_value_2 = clamp(cloud_value_2 / opacity_dist_2, 0.0, 1.0);
            density_2 = clamp(density_2, 0.0001, 1.0);

            vec3 cloud_color_2 = vec3(0.0);
            cloud_color_2 = mix(cloud_color_orig * att_factor, dark_cloud_color_orig * att_factor, pow(density_2, 0.4));

            cloud_color_2 =
                mix(cloud_color_2, cloud_color_2 + light_color * day_blend_float(2.5, 4.0, 1.0), (1.0 - pow(cloud_value_2, 0.2)) * bright * (1.0 - rainStrength));

            cloud_color_2 =
                mix(cloud_color_2, cloud_color_2 + light_color * day_blend_float(0.0, 0.5, 1.0), (pow(cloud_value_2, 0.1)) * bright * bright * bright * (1.0 - rainStrength));

            // Blend the second layer with the first
            float second_layer_opacity = cloud_value_2 * clamp((view_vector.y - 0.025) * 2, 0.0, 1.0) * (1.0 - cloud_value);
            block_color = mix(
                block_color,
                cloud_color_2,
                second_layer_opacity
            );
        #endif
    #endif
    }

    return block_color;
}