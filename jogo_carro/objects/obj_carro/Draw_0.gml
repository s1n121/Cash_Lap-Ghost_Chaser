var _tilt = 0;
if (speed > 5) {
    // Faz o carro abanar ligeiramente para os lados durante o boost
    _tilt = sin(get_timer()/50000) * 5; 
}
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle + _tilt, image_blend, image_alpha);