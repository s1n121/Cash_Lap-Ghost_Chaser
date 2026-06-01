// --- 1. INPUTS ---
var _up    = keyboard_check(vk_up)    || keyboard_check(ord("W"));
var _down  = keyboard_check(vk_down)  || keyboard_check(ord("S"));
var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));

// --- 2. CHUVA (lê do hud) ---
if (instance_exists(obj_hud)) chuva_ativa = obj_hud.chuva_ativa;

// =====================================================
// MOVIMENTO
// =====================================================
if (pode_mover && !em_pergunta && !aguardando_reboque) {

    max_speed_atual = max_speed;
    turn_speed = turn_speed_original;

    // --- PENALIDADE DE CHUVA ---
    if (chuva_ativa && pneu_atual == "normal") {
        max_speed_atual = max_speed * 0.65;
        turn_speed = turn_speed_original * 0.7;
    }

    // --- ACELERAÇÃO ---
    if (_up && combustivel > 0) {
        vel = min(vel + accel, max_speed_atual);
    } else if (_down) {
        vel = max(vel - accel, -2);
    } else {
        if (vel > 0) vel = max(0, vel - friction_power);
        if (vel < 0) vel = min(0, vel + friction_power);
    }

    // --- COMBUSTÍVEL ---
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

    // --- ROTAÇÃO ---
    if (abs(vel) > 0.2) {
        var _old_angle = image_angle;
        var _dir_sinal = sign(vel);
        if (_left)  image_angle += turn_speed * _dir_sinal;
        if (_right) image_angle -= turn_speed * _dir_sinal;
        if (place_meeting(x, y, obj_parede)) image_angle = _old_angle;
    }
    direction = image_angle;

    // --- DERRAPAGEM NA CHUVA ---
if (chuva_ativa && pneu_atual == "normal" && abs(vel) > 1.5) {
    var _fator_vel = clamp(abs(vel) / max_speed_atual, 0, 1);
    var _input_lateral = ((_left ? 1 : 0) - (_right ? 1 : 0)) * sign(vel);
    slip_angle += _input_lateral * 1.8 * _fator_vel;
    slip_angle = lerp(slip_angle, 0, 0.12);
    slip_angle = clamp(slip_angle, -15, 15);
    direction = image_angle + slip_angle;

    // Fumo de derrapagem a cada 8 frames
    if (current_time mod 120 < 16 && object_exists(obj_fumo)) {
        var _f = instance_create_depth(x, y, depth - 1, obj_fumo);
        _f.image_blend = c_aqua; // sinaliza chuva
    }
} else {
    slip_angle = lerp(slip_angle, 0, 0.25);
    direction = image_angle + slip_angle;
}

    // --- MOVIMENTO PIXEL-A-PIXEL ---
    var _vx = lengthdir_x(vel, direction);
    var _vy = lengthdir_y(vel, direction);
    var _passos = max(1, ceil(abs(vel)));
    var _dx = _vx / _passos;
    var _dy = _vy / _passos;

    for (var _i = 0; _i < _passos; _i++) {
        if (place_meeting(x + _dx, y, obj_parede)) { vel *= -0.2; _dx = 0; slip_angle = 0; }
        if (place_meeting(x, y + _dy, obj_parede)) { vel *= -0.2; _dy = 0; slip_angle = 0; }
        if (_dx == 0 && _dy == 0) break;
        x += _dx;
        y += _dy;
    }

    // --- SEGURANÇA CONTRA PAREDES ---
    if (place_meeting(x, y, obj_parede)) {
        x -= lengthdir_x(vel, direction);
        y -= lengthdir_y(vel, direction);
        vel = 0;
        slip_angle = 0;
    }

    // --- META ---
    if (place_meeting(x, y, obj_meta)) {
        if (!passou_meta) passou_meta = true;
    } else {
        passou_meta = false;
    }

    // --- PIT STOP ---
    if (vel < 0.8 && place_meeting(x, y, obj_pit)) {

        if (combustivel < combustivel_maximo) {
            combustivel = min(combustivel + 1.5, combustivel_maximo);
        }

        // Invalida a volta atual — tem de passar pela meta de novo
        if (instance_exists(obj_hud) && !saiu_do_pit) {
            obj_hud.pode_contar_volta = false;
            obj_hud.passou_checkpoint = false;
            saiu_do_pit = true;
            show_debug_message("PIT: volta invalidada, passa pela meta para recomeçar.");
        }

        if (instance_exists(obj_hud)) {
            if (keyboard_check_pressed(ord("1")) && obj_hud.moedas >= 50) {
                obj_hud.moedas -= 50;
                max_speed += 0.5;
                max_speed_base = max_speed;
                max_speed_atual = max_speed;
            }
            if (keyboard_check_pressed(ord("2")) && obj_hud.moedas >= 50) {
                obj_hud.moedas -= 50;
                accel += 0.05;
            }
            if (keyboard_check_pressed(ord("3")) && obj_hud.moedas >= 50 && pneu_atual == "normal") {
                obj_hud.moedas -= 50;
                pneu_atual = "chuva";
            }
        }
    } else {
        saiu_do_pit = false;
    }

} else {
    vel = 0;
}

// --- SPRAY DE ÁGUA NA CHUVA ---
if (chuva_ativa && abs(vel) > 1.5 && object_exists(obj_fumo)) {
    repeat (3) {
        var _f = instance_create_depth(
            x - lengthdir_x(10, image_angle) + irandom_range(-4, 4),
            y - lengthdir_y(10, image_angle) + irandom_range(-4, 4),
            depth - 1, obj_fumo
        );
    }
}

speed = 0;