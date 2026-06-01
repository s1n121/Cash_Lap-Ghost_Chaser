if (global.tem_fantasma && ds_list_size(global.fantasma_gravar_x) > 0) {
    var _f = frame_atual;
    if (_f >= 0 && _f < ds_list_size(global.fantasma_gravar_x)) {
        var _fx = global.fantasma_gravar_x[| _f];
        var _fy = global.fantasma_gravar_y[| _f];
        var _fa = global.fantasma_gravar_angle[| _f];

        draw_sprite_ext(
            spr_carro,
            0,
            _fx,
            _fy,
            1,
            1,
            _fa,
            c_aqua,
            0.4
        );
    }
}