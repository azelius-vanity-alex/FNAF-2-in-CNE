#pragma header

uniform float iTime;

float hash(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main()
{
    vec2 uv = openfl_TextureCoordv;

    // Low-resolution / pixelated look
    float pixelSize = 320.0;
    vec2 pixelUV = floor(uv * pixelSize) / pixelSize;

    vec4 tex = flixel_texture2D(bitmap, pixelUV);

    // Subtle horizontal scanlines
    float scanline = sin(uv.y * 500.0) * 0.035;
    tex.rgb -= scanline;

    // Slight RGB separation
    float chroma = 0.0015;

    float r = flixel_texture2D(bitmap, pixelUV + vec2(chroma, 0.0)).r;
    float g = tex.g;
    float b = flixel_texture2D(bitmap, pixelUV - vec2(chroma, 0.0)).b;

    tex.rgb = vec3(r, g, b);

    // Subtle analogue noise
    float noise = (hash(vec2(
        floor(uv.x * 320.0),
        floor(uv.y * 240.0) + floor(iTime * 12.0)
    )) - 0.5) * 0.045;

    tex.rgb += noise;

    // Slightly crush the blacks
    tex.rgb = max(tex.rgb - 0.015, 0.0);

    gl_FragColor = tex;
}