float absSunRotation = abs(sunPathRotation); // Absolute value of Sun path rotation.

vec3 day_blend_lgcy(vec3 sunset, vec3 day, vec3 night) {
    // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
    // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

    vec3 day_color = mix(sunset, day, day_mixer);
    vec3 night_color = mix(sunset, night, night_mixer);

    return mix(day_color, night_color, smoothstep(0.45, 0.52 + (absSunRotation / 900), day_moment));
}

float day_blend_float_lgcy(float sunset, float day, float night) {
    // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
    // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

    float day_value = mix(sunset, day, day_mixer);
    float night_value = mix(sunset, night, night_mixer + 0.1);

    return mix(day_value, night_value, smoothstep(0.45, 0.52 + (absSunRotation / 600), day_moment));
}

#if COLOR_SCHEME == 8
    vec3 day_blend(vec3 sunset, vec3 day, vec3 night) {
        // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
        // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

        vec3 day_color = mix(sunset, day, day_mixer);
        vec3 night_color = mix(sunset, night, clamp(night_mixer - day_blend_float_lgcy(1.0, 0.0, 0.1), 0.0, 1.0));

        return mix(day_color, night_color, smoothstep(0.45, 0.52 + (absSunRotation / 900), day_moment));
    }

    float day_blend_float(float sunset, float day, float night) {
        // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
        // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

        float day_value = mix(sunset, day, day_mixer);
        float night_value = mix(day_value, night, clamp(night_mixer - day_blend_float_lgcy(1.0, 0.0, 0.1), 0.0, 1.0));

        return mix(day_value, night_value, smoothstep(0.45, 0.52 + (absSunRotation / 900), day_moment));
    }
#else
    vec3 day_blend(vec3 sunset, vec3 day, vec3 night) {
        // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
        // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

        vec3 day_color = mix(sunset, day, day_mixer);
        vec3 night_color = mix(sunset, night, night_mixer);

        return mix(day_color, night_color, smoothstep(0.45, 0.52 + (absSunRotation / 900), day_moment));
    }

    float day_blend_float(float sunset, float day, float night) {
        // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
        // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

        float day_value = mix(sunset, day, day_mixer);
        float night_value = mix(sunset, night, night_mixer);

        return mix(day_value, night_value, smoothstep(0.45, 0.52 + (absSunRotation / 900), day_moment));
    }
#endif