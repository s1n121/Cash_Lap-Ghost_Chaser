var _volta_valida = (passou_checkpoint && tempo_volta_atual >= tempo_minimo_volta) || primeira_volta;

// --- 1. CRONÓMETRO ---
if (!corrida_comecou && instance_exists(obj_carro) && obj_carro.vel > 0.1) {
    corrida_comecou = true;
}

if (corrida_comecou && instance_exists(obj_carro) && obj_carro.pode_mover) {
    tempo_decorrido += 1 / room_speed;
    tempo_volta_atual += 1 / room_speed;

    ds_list_add(lista_x_atual, obj_carro.x);
    ds_list_add(lista_y_atual, obj_carro.y);
    ds_list_add(lista_angle_atual, obj_carro.image_angle);

    if (global.tem_fantasma) {
        frame_atual += 1;
        if (frame_atual >= ds_list_size(global.fantasma_gravar_x)) frame_atual = 0;
    }
}

// --- 2. REBOQUE ---
if (aguardando_reboque && keyboard_check_pressed(ord("E"))) {
    if (tem_seguro) {
        show_debug_message("REBOQUE: Acionado gratuitamente através do Seguro!");
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

// --- 3. LOJA ATUALIZADA (OPÇÕES 1, 2 e 3) ---
if (instance_exists(obj_carro)) {
    var _no_pit = false;
    with(obj_carro) { if (place_meeting(x, y, obj_pit)) _no_pit = true; }

    if (_no_pit && obj_carro.vel < 0.8) {
        
        // [Opção 1] Mudar para Pneu Normal ($30)
        if (keyboard_check_pressed(ord("1")) && moedas >= 30 && obj_carro.pneu_atual != "normal") {
            moedas -= 30;
            obj_carro.pneu_atual = "normal";
        }
        
        // [Opção 2] Mudar para Pneu de Chuva ($50)
        if (keyboard_check_pressed(ord("2")) && moedas >= 50 && obj_carro.pneu_atual != "chuva") {
            moedas -= 50;
            obj_carro.pneu_atual = "chuva";
        }
        
        // [Opção 3] Comprar Seguro Automóvel ($100)
        if (keyboard_check_pressed(ord("3")) && moedas >= custo_seguro && !tem_seguro) {
            moedas -= custo_seguro;
            tem_seguro = true;
        }
    }
}

// --- 4. QUIZ ATUALIZADO (CONSEQUÊNCIAS REAIS) ---
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
                // ACERTOU: Dá um bónus de dinheiro e um turbo de velocidade instantâneo!
                other.moedas += 10;
                other.shake_intensidade = 5;
                vel = max_speed * 1.35; // Impulso imediato
                image_blend = c_aqua;   // Brilho azul de velocidade
                falha_motor = false;
                alarm[0] = room_speed * 2.5; // O bónus visual dura 2.5 segundos
            } else {
                // ERROU: Ativa a falha mecânica gravíssima (Carro lento e fumo negro)
                vel = 0.5;              // Corta o embalo atual do carro na hora
                falha_motor = true;     // Ativa o estado lento gerido no Step do carro
                image_blend = c_red;    // Carro fica vermelho (Alerta de Motor)
                alarm[0] = room_speed * 4.5; // Fica quebrado por 4.5 segundos
            }
        }
        pergunta_ativa = false;
    }
}

// --- 5. CAMERA SHAKE & META ---
if (shake_intensidade > 0) {
    camera_set_view_pos(view_camera[0], irandom_range(-shake_intensidade, shake_intensidade), irandom_range(-shake_intensidade, shake_intensidade));
    shake_intensidade -= 0.5;
} else {
    camera_set_view_pos(view_camera[0], 0, 0);
}

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
                    ds_list_clear(global.fantasma_gravar_x); ds_list_clear(global.fantasma_gravar_y); ds_list_clear(global.fantasma_gravar_angle);
                    ds_list_copy(global.fantasma_gravar_x, lista_x_atual); ds_list_copy(global.fantasma_gravar_y, lista_y_atual); ds_list_copy(global.fantasma_gravar_angle, lista_angle_atual);
                    global.tem_fantasma = true;
                }
            }
            voltas_atuais += 1;
            ds_list_clear(lista_x_atual); ds_list_clear(lista_y_atual); ds_list_clear(lista_angle_atual);
            frame_atual = 0; tempo_volta_atual = 0; passou_checkpoint = false; pode_contar_volta = false;
            randomizar_perguntas(5);
        } else {
            pode_contar_volta = false; passou_checkpoint = false;
        }
    }
}

// --- 6. CLIMA DINÂMICO ---
if (!chuva_ativa) {
    chuva_timer -= 1;
    if (spr_chuva_alpha > 0) spr_chuva_alpha = max(spr_chuva_alpha - 0.01, 0);
    if (chuva_timer <= 0) {
        if (estado_clima == 0) estado_clima = 1;
        chuva_ativa = true;
        chuva_duracao = irandom_range(room_speed * 20, room_speed * 50);
        spr_chuva_alpha = 0;
        if (instance_exists(obj_carro)) obj_carro.chuva_ativa = true;
    }
} else {
    spr_chuva_alpha = min(spr_chuva_alpha + 0.02, 0.7);
    chuva_duracao -= 1;
    if (chuva_duracao <= 0) {
        chuva_ativa = false;
        chuva_timer = irandom_range(room_speed * 40, room_speed * 90);
        if (instance_exists(obj_carro)) obj_carro.chuva_ativa = false;
    }
}

// --- 7. ANIMAR GOTAS ---
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