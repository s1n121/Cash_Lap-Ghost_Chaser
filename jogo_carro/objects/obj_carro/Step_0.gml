
// --- 1. INPUTS ---
var _up    = keyboard_check(vk_up)    || keyboard_check(ord("W"));
var _down  = keyboard_check(vk_down)  || keyboard_check(ord("S"));
var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));


// =====================================================
// REBOQUE
// =====================================================

if (aguardando_reboque) {

    if (keyboard_check_pressed(ord("R"))) {

        var _pit = instance_find(obj_spawn_pit, 0);

        if (_pit != noone) {

            x = _pit.x;
            y = _pit.y;

            vel = 0;

            image_angle = 0;
            direction = image_angle;

            combustivel = combustivel_maximo * 0.5;

            aguardando_reboque = false;
            pode_mover = true;
        }
    }
}


// =====================================================
// MOVIMENTO
// =====================================================

if (pode_mover && !em_pergunta && !aguardando_reboque) {

    // --- 2. CONTROLO DA VELOCIDADE MÁXIMA ---
    // A velocidade máxima atual segue diretamente o valor de max_speed, 
    // que é controlado de forma segura pela base e pelos modificadores do Quiz.
    max_speed_atual = max_speed;
    turn_speed = turn_speed_original;


    // --- 3. ACELERAÇÃO ---
    if (_up && combustivel > 0) {

        vel = min(vel + accel, max_speed_atual);

    } else if (_down) {

        vel = max(vel - accel, -2);

    } else {

        if (vel > 0) vel = max(0, vel - friction_power);
        if (vel < 0) vel = min(0, vel + friction_power);
    }


    // --- 4. COMBUSTÍVEL ---
    if (abs(vel) > 0.2) {
        combustivel -= 0.05;
    }

    if (combustivel <= 0) {

        combustivel = 0;

        vel = 0;

        pode_mover = false;

        aguardando_reboque = true;

        if (instance_exists(obj_hud)) {
            obj_hud.aguardando_reboque = true;
        }
    }


    // --- 5. ROTAÇÃO ---
    if (abs(vel) > 0.2) {

        var _old_angle = image_angle;

        var _dir_sinal = sign(vel);

        if (_left) {
            image_angle += turn_speed * _dir_sinal;
        }

        if (_right) {
            image_angle -= turn_speed * _dir_sinal;
        }

        if (place_meeting(x, y, obj_parede)) {
            image_angle = _old_angle;
        }
    }

    direction = image_angle;


    // --- 6. MOVIMENTO E COLISÕES pixel-a-pixel ---
    var _vx = lengthdir_x(vel, direction);
    var _vy = lengthdir_y(vel, direction);

    var _passos = max(1, ceil(abs(vel)));

    var _dx = _vx / _passos;
    var _dy = _vy / _passos;


    for (var _i = 0; _i < _passos; _i++) {

        if (place_meeting(x + _dx, y, obj_parede)) {

            vel *= -0.2;

            _dx = 0;
        }

        if (place_meeting(x, y + _dy, obj_parede)) {

            vel *= -0.2;

            _dy = 0;
        }

        if (_dx == 0 && _dy == 0) {
            break;
        }

        x += _dx;
        y += _dy;
    }


    // --- 7. SEGURANÇA ---
    if (place_meeting(x, y, obj_parede)) {

        x -= lengthdir_x(vel, direction);
        y -= lengthdir_y(vel, direction);

        vel = 0;
    }


    // =====================================================
    // VOLTAS
    // =====================================================
    if (place_meeting(x, y, obj_meta)) {

        if (!passou_meta) {
            passou_meta = true;
        }

    } else {

        passou_meta = false;
    }


    // =====================================================
    // PIT STOP
    // =====================================================

    if (vel < 0.8 && place_meeting(x, y, obj_pit)) {

        if (combustivel < combustivel_maximo) {
            combustivel += 1.5;
        }

        if (instance_exists(obj_hud) && obj_hud.moedas >= 50) {

            // Upgrade velocidade [Tecla 1]
            if (keyboard_check_pressed(ord("1"))) {

                obj_hud.moedas -= 50;

                max_speed += 0.5;
                max_speed_base = max_speed; // Atualiza a base para que os alarms reponham o novo valor correto comprado

                max_speed_atual = max_speed;
            }

            // Upgrade aceleração [Tecla 2]
            if (keyboard_check_pressed(ord("2"))) {

                obj_hud.moedas -= 50;

                accel += 0.05;
            }
        }
    }

} else {

    vel = 0;
}

speed = 0;

