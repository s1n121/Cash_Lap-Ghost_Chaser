// =======================================================
// PAUSA (ESC)
// =======================================================
if (keyboard_check_pressed(vk_escape)) {
    jogo_pausado = !jogo_pausado;
    pausa_opcao = 0;
}

if (jogo_pausado) {
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        pausa_opcao = max(0, pausa_opcao - 1);
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        pausa_opcao = min(1, pausa_opcao + 1);
    }
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        if (pausa_opcao == 0) {
            jogo_pausado = false;
        } else {
            room_goto(Room_menu);
        }
    }
    exit;
}

// =======================================================

var _volta_valida = (passou_checkpoint && tempo_volta_atual >= tempo_minimo_volta) || primeira_volta;

// Verifica se o carro está no pit (para pausar o timer)
var _em_pit = false;
if (instance_exists(obj_carro)) {
    with(obj_carro) { if (vel < 0.8 && place_meeting(x, y, obj_pit)) _em_pit = true; }
}

// --- 1. CRONÓMETRO (pausa no pit) ---
if (!corrida_comecou && instance_exists(obj_carro) && obj_carro.vel > 0.1) {
    corrida_comecou = true;
}

if (corrida_comecou && instance_exists(obj_carro) && obj_carro.pode_mover) {
    tempo_decorrido += 1 / room_speed;

    // O timer da volta pausa enquanto o carro está no pit
    if (!_em_pit) {
        tempo_volta_atual += 1 / room_speed;

        ds_list_add(lista_x_atual, obj_carro.x);
        ds_list_add(lista_y_atual, obj_carro.y);
        ds_list_add(lista_angle_atual, obj_carro.image_angle);

        if (global.tem_fantasma) {
            frame_atual += 1;
            if (frame_atual >= ds_list_size(global.fantasma_gravar_x)) frame_atual = 0;
        }
    }
}

// --- 2. REBOQUE ---
if (aguardando_reboque && keyboard_check_pressed(ord("E"))) {
    if (tem_seguro) {
        show_debug_message("REBOQUE: Seguro ativo — gratuito.");
    } else {
        moedas = max(0, moedas - custo_reboque);
    }
    if (instance_exists(obj_carro) && instance_exists(obj_spawn_reboque)) {
        with (obj_carro) {
            x = obj_spawn_reboque.x;
            y = obj_spawn_reboque.y;
            vel = 0; slip_angle = 0;
            combustivel = combustivel_maximo;
            aguardando_reboque = false;
            pode_mover = true;
            image_blend = c_white;
        }
    }
    pode_contar_volta = false;
    passou_checkpoint = false;
    aguardando_reboque = false;
}

// --- 3. LOJA PIT STOP ---
if (instance_exists(obj_carro) && _em_pit) {

    // [1] Pneu Normal ($30)
    if (keyboard_check_pressed(ord("1")) && moedas >= 30 && obj_carro.pneu_atual != "normal") {
        moedas -= 30;
        obj_carro.pneu_atual = "normal";
    }

    // [2] Pneu Chuva ($50)
    if (keyboard_check_pressed(ord("2")) && moedas >= 50 && obj_carro.pneu_atual != "chuva") {
        moedas -= 50;
        obj_carro.pneu_atual = "chuva";
    }

    // [3] Seguro ($100)
    if (keyboard_check_pressed(ord("3")) && moedas >= custo_seguro && !tem_seguro) {
        moedas -= custo_seguro;
        tem_seguro = true;
    }

    // [4] Upgrade Tanque ($60) — aumenta combustível máximo de 100 para 150
    if (keyboard_check_pressed(ord("4")) && moedas >= custo_upgrade_tanque && !upgrade_tanque) {
        moedas -= custo_upgrade_tanque;
        upgrade_tanque = true;
        obj_carro.combustivel_maximo = 150;
        obj_carro.combustivel = obj_carro.combustivel_maximo; // abastece logo
    }
}

// --- 4. QUIZ ---
if (pergunta_ativa) {
    var _escolha = -1;
    if (keyboard_check_pressed(ord("A"))) _escolha = 1;
    if (keyboard_check_pressed(ord("B"))) _escolha = 2;
    if (keyboard_check_pressed(ord("C"))) _escolha = 3;

    if (_escolha != -1) {
        var _acertou = (_escolha == resposta_correta);
        with(obj_carro) {
            pode_mover = true;
            if (_acertou) {
                other.moedas += 10;
                other.shake_intensidade = 5;
                vel = max_speed * 1.35;
                image_blend = c_aqua;
                falha_motor = false;
                alarm[0] = room_speed * 2.5;
            } else {
                vel = 0.5;
                falha_motor = true;
                image_blend = c_red;
                alarm[0] = room_speed * 4.5;
            }
        }
        pergunta_ativa = false;
    }
}

// --- 5. CAMERA SHAKE ---
if (shake_intensidade > 0) {
    camera_set_view_pos(view_camera[0], irandom_range(-shake_intensidade, shake_intensidade), irandom_range(-shake_intensidade, shake_intensidade));
    shake_intensidade -= 0.5;
} else {
    camera_set_view_pos(view_camera[0], 0, 0);
}

// --- 6. META ---
if (instance_exists(obj_carro)) {
    var _colidiu_com_meta = false;
    with(obj_carro) { if (place_meeting(x, y, obj_meta)) _colidiu_com_meta = true; }

    if (!_colidiu_com_meta && !pode_contar_volta) pode_contar_volta = true;

    if (_colidiu_com_meta && pode_contar_volta) {
        if (_volta_valida) {
            primeira_volta = false;
            if (ds_list_size(lista_x_atual) > 0) {
                if (tempo_melhor_volta == -1 || tempo_volta_atual < tempo_melhor_volta) {
                    tempo_melhor_volta = tempo_volta_atual;
                    ds_list_clear(global.fantasma_gravar_x);
                    ds_list_clear(global.fantasma_gravar_y);
                    ds_list_clear(global.fantasma_gravar_angle);
                    ds_list_copy(global.fantasma_gravar_x, lista_x_atual);
                    ds_list_copy(global.fantasma_gravar_y, lista_y_atual);
                    ds_list_copy(global.fantasma_gravar_angle, lista_angle_atual);
                    global.tem_fantasma = true;
                }
            }
            voltas_atuais += 1;
            ds_list_clear(lista_x_atual);
            ds_list_clear(lista_y_atual);
            ds_list_clear(lista_angle_atual);
            frame_atual = 0;
            tempo_volta_atual = 0;
            passou_checkpoint = false;
            pode_contar_volta = false;
            randomizar_perguntas(5);
        } else {
            pode_contar_volta = false;
            passou_checkpoint = false;
        }
    }
}

// --- 7. CLIMA DINÂMICO ---
if (!chuva_ativa) {
    chuva_timer -= 1;
    if (spr_chuva_alpha > 0) spr_chuva_alpha = max(spr_chuva_alpha - 0.01, 0);
    if (chuva_timer <= 0) {
        if (estado_clima == 0) estado_clima = 1;
        chuva_ativa = true;
        chuva_duracao = irandom_range(room_speed * 20, room_speed * 45);
        spr_chuva_alpha = 0;
        if (instance_exists(obj_carro)) obj_carro.chuva_ativa = true;
    }
} else {
    spr_chuva_alpha = min(spr_chuva_alpha + 0.02, 0.7);
    chuva_duracao -= 1;
    if (chuva_duracao <= 0) {
        chuva_ativa = false;
        chuva_timer = irandom_range(room_speed * 25, room_speed * 55);
        if (instance_exists(obj_carro)) obj_carro.chuva_ativa = false;
    }
}

// --- 8. ANIMAR GOTAS ---
if (chuva_ativa || spr_chuva_alpha > 0) {
    for (var _i = 0; _i < 120; _i++) {
        gotas_chuva[_i][0] += gotas_chuva[_i][3] * 0.4;
        gotas_chuva[_i][1] += gotas_chuva[_i][3] * 2.5;
        if (gotas_chuva[_i][1] > 768) {
            gotas_chuva[_i][0] = irandom(1366);
            gotas_chuva[_i][1] = irandom_range(-40, 0);
        }
        if (gotas_chuva[_i][0] > 1366) gotas_chuva[_i][0] = 0;
    }
}