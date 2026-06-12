
if (!mostrar_pergunta) exit;

var _cx = display_get_gui_width()  / 2;
var _cy = display_get_gui_height() / 2;
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(opcoes_texto); i++) {
    var _by = _cy - 30 + (i * 60);
    
    if (_mx > _cx - 180 && _mx < _cx + 180 &&
        _my > _by - 18  && _my < _by + 18) {
        
        if (opcoes_texto[i] == resposta_correta) {
            boost_ativo = true;
            boost_timer = room_speed * 4;
            with (obj_carro) { speed += 2; }
        } else {
            with (obj_carro) { speed *= 0.2; }
        }
        
        mostrar_pergunta = false;
        // Desbloqueia o carro
        with (obj_carro) { em_pergunta = false; }
        break;
    }
}