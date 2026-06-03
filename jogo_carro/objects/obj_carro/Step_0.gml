// --- 1. INPUTS ---
var _up    = keyboard_check(vk_up)    || keyboard_check(ord("W"));
var _down  = keyboard_check(vk_down)  || keyboard_check(ord("S"));
var _left  = keyboard_check(vk_left)  || keyboard_check(ord("A"));
var _right = keyboard_check(vk_right) || keyboard_check(ord("D"));

// --- 2. CHUVA (lê do hud) ---
if (instance_exists(obj_hud)) chuva_ativa = obj_hud.chuva_ativa;

// =====================================================
// MOVIMENTO E COMPORTAMENTO DOS PNEUS / QUIZ
// =====================================================
if (pode_mover && !em_pergunta && !aguardando_reboque) {

    max_speed_atual = max_speed;
    turn_speed = turn_speed_original;
    var _fator_aceleracao = 1.0;

    // --- VERIFICAÇÃO DE ESTADO ---
    if (falha_motor) {
        // [ERROU O QUIZ] Prioridade Absoluta: O carro fica extremamente lento e pesado
        max_speed_atual = max_speed * 0.25; // Reduz a velocidade para 25% da original
        turn_speed = turn_speed_original * 0.5; // Direção pesada
        _fator_aceleracao = 0.3;
        
        // Efeito visual de falha mecânica (Fumo Negro denso)
        if (object_exists(obj_fumo)) {
            repeat(2) {
                var _fumo_motor = instance_create_depth(x + irandom_range(-4,4), y + irandom_range(-4,4), depth - 2, obj_fumo);
                _fumo_motor.image_blend = c_dkgray; 
            }
        }
    } 
    else {
        // [CONDUÇÃO NORMAL] Aplica a física real e cruzada dos pneus
        if (chuva_ativa) {
            if (pneu_atual == "normal") {
                // Pneu Incorreto na Chuva: Perda de tração e derrapagem agressiva
                max_speed_atual = max_speed * 0.50;
                turn_speed = turn_speed_original * 0.6;
                _fator_aceleracao = 0.4; 
                
                if (abs(vel) > 1.0) {
                    slip_angle += ((_left ? 1 : -1) + sin(current_time * 0.05)) * 2.8;
                    slip_angle = clamp(slip_angle, -35, 35);
                }
            } else {
                // Pneu Correto na Chuva: Direção e estabilidade normais
                max_speed_atual = max_speed * 0.95;
                turn_speed = turn_speed_original;
                slip_angle = lerp(slip_angle, 0, 0.2);
            }
        } else {
            // PISTA SECA
            if (pneu_atual == "chuva") {
                // Pneu de Chuva no Seco: Sobreaquece, prende o carro e desgasta
                max_speed_atual = max_speed * 0.60; 
                turn_speed = turn_speed_original * 0.5; 
                _fator_aceleracao = 0.6;
                slip_angle = lerp(slip_angle, 0, 0.3);
                
                if (current_time mod 60 < 10 && object_exists(obj_fumo)) {
                    var _f = instance_create_depth(x, y, depth - 1, obj_fumo);
                    _f.image_blend = c_gray; // Fumo cinza de pneu a queimar
                }
            } else {
                // Pneu Correto no Seco: Desempenho Máximo e Perfeito
                slip_angle = lerp(slip_angle, 0, 0.25);
            }
        }
    }

    // --- ACELERAÇÃO ---
    if (_up && combustivel > 0) {
        vel = min(vel + (accel * _fator_aceleracao), max_speed_atual);
    } else if (_down) {
        vel = max(vel - accel, -2);
    } else {
        if (vel > 0) vel = max(0, vel - friction_power);
        if (vel < 0) vel = min(0, vel + friction_power);
    }

    // Se o carro for travado por uma velocidade máxima menor atual (ex: ao errar a pergunta)
    if (vel > max_speed_atual) vel = lerp(vel, max_speed_atual, 0.1);

    // --- COMBUSTÍVEL ---
    if (abs(vel) > 0.2) combustivel -= 0.05;

    if (combustivel <= 0) {
        combustivel = 0; vel = 0; pode_mover = false; aguardando_reboque = true;
        if (instance_exists(obj_hud)) obj_hud.aguardando_reboque = true;
    }

    // --- ROTAÇÃO ---
    if (abs(vel) > 0.2) {
        var _old_angle = image_angle;
        var _dir_sinal = sign(vel);
        if (_left)  image_angle += turn_speed * _dir_sinal;
        if (_right) image_angle -= turn_speed * _dir_sinal;
        if (place_meeting(x, y, obj_parede)) image_angle = _old_angle;
    }
    
    direction = image_angle + slip_angle;

    // --- SPRAY DE ÁGUA NA CHUVA (Apenas se NÃO estiver com falha no motor) ---
    if (chuva_ativa && abs(vel) > 1.2 && !falha_motor && object_exists(obj_fumo)) {
        var _f = instance_create_depth(x - lengthdir_x(8, image_angle), y - lengthdir_y(8, image_angle), depth - 1, obj_fumo);
        _f.image_blend = c_aqua;
    }

    // --- MOVIMENTO E COLISÕES PIXEL-A-PIXEL ---
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

    // --- PIT STOP ---
    if (vel < 0.8 && place_meeting(x, y, obj_pit)) {
        if (combustivel < combustivel_maximo) combustivel = min(combustivel + 1.5, combustivel_maximo);
        if (instance_exists(obj_hud) && !saiu_do_pit) {
            obj_hud.pode_contar_volta = false;
            obj_hud.passou_checkpoint = false;
            saiu_do_pit = true;
        }
    } else {
        saiu_do_pit = false;
    }
} else {
    vel = 0;
}

speed = 0;