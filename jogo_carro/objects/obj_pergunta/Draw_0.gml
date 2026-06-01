draw_sprite_ext(
    sprite_index,
    image_index,
    x, y,
    1, 1,
    0,
    c_yellow,
    0.8 + 0.2 * sin(current_time * 0.005) // pulsa suavemente
);