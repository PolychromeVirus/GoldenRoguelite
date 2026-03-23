varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_amount;  // 0 = normal, 1 = fully frozen

void main()
{
    vec4 tex = texture2D(gm_BaseTexture, v_vTexcoord);
    // Cyan ice tint: strong push toward icy cyan
    vec3 ice = vec3(0.4, 0.85, 1.0);
    float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 tinted = mix(tex.rgb, ice * (lum * 0.5 + 0.5), u_amount);
    gl_FragColor = vec4(tinted, tex.a);
}
