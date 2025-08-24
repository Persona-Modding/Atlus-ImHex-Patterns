struct f32RGBA {
    float r;
    float g;
    float b;
    float a;
}[[hex::inline_visualize("color", r * 255, g * 255, b * 255, a * 255)]];

struct f32RGB {
    float r;
    float g;
    float b;
}[[hex::inline_visualize("color", r * 255, g * 255, b * 255, 255)]];

struct u8RGBA {
    u8 r;
    u8 g;
    u8 b;
    u8 a;
}[[hex::inline_visualize("color", r, g, b, a)]];