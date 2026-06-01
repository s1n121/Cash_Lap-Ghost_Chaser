// --- TILT DE BOOST ---
var _tilt = 0;
if (speed > 5) {
    _tilt = sin(get_timer() / 50000) * 5;
}

// --- SPRAY DE ÁGUA NA CHUVA ---
if (instance_exists(obj_hud) && obj_hud.chuva_ativa && abs(vel) > 2) {
    var _alpha_spray = min(abs(vel) / 8, 0.6);
    draw_set_alpha(_alpha_spray);
    draw_set_color(make_color_rgb(150, 200, 255));
    var _bx = x - lengthdir_x(16, image_angle);
    var _by = y - lengthdir_y(16, image_angle);
    draw_circle(_bx + irandom_range(-4, 4), _by + irandom_range(-4, 4), irandom_range(2, 5), false);
    draw_circle(_bx + irandom_range(-4, 4), _by + irandom_range(-4, 4), irandom_range(1, 3), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// --- CARRO ---
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle + _tilt, image_blend, image_alpha);