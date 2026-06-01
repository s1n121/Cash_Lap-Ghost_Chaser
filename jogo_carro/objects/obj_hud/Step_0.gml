var _volta_valida = (passou_checkpoint && tempo_volta_atual >= tempo_minimo_volta) || primeira_volta;

// --- 1. CRONÓMETRO ---
if (!corrida_comecou) {
    if (instance_exists(obj_carro) && obj_carro.vel > 0.1) {
        corrida_comecou = true;
    }
}

if (corrida_comecou && instance_exists(obj_carro)) {
    if (obj_carro.pode_mover) {
        tempo_decorrido += 1 / room_speed;
        tempo_volta_atual += 1 / room_speed;

        ds_list_add(lista_x_atual, obj_carro.x);
        ds_list_add(lista_y_atual, obj_carro.y);
        ds_list_add(lista_angle_atual, obj_carro.image_angle);

        if (global.tem_fantasma) {
            frame_atual += 1;
            if (frame_atual >= ds_list_size(global.fantasma_gravar_x)) {
                frame_atual = 0;
            }
        }
    }
}

// --- 2. REBOQUE (Com verificação de Seguro) ---
if (aguardando_reboque) {
    if (keyboard_check_pressed(ord("E"))) {
        
        if (tem_seguro) {
            // Se tem seguro, o reboque é totalmente grátis!
            show_debug_message("REBOQUE: Acionado gratuitamente através do Seguro!");
            // Nota: Podes optar por retirar o seguro após o uso (tem_seguro = false;) ou deixá-lo para a corrida toda.
        } else {
            // Se não tem seguro, cobramos a taxa normal ou deixamos a zero se for menor
            if (moedas >= custo_reboque) {
                moedas -= custo_reboque;
            } else {
                moedas = 0;
            }
            show_debug_message("REBOQUE: Cobrada taxa normal de $" + string(custo_reboque));
        }

        if (instance_exists(obj_carro) && instance_exists(obj_spawn_reboque)) {
            with (obj_carro) {
                x = obj_spawn_reboque.x;
                y = obj_spawn_reboque.y;
                vel = 0;
                speed = 0;
                vspeed = 0;
                hspeed = 0;
                slip_angle = 0;
                combustivel = combustivel_maximo;
                aguardando_reboque = false;
                pode_mover = true;
                image_blend = c_white;
            }
        }

        pode_contar_volta = false;
        passou_checkpoint = false;
        aguardando_reboque = false;
        show_debug_message("REBOQUE: volta invalidada, passa pela meta para recomeçar.");
    }
}

// --- 3. NOVO PIT STOP EXPANDIDO ---
if (instance_exists(obj_carro)) {
    var _no_pit = false;
    with(obj_carro) { if (place_meeting(x, y, obj_pit)) _no_pit = true; }

    if (_no_pit && obj_carro.vel < 0.8) {
        
        // [Opção 1] Upgrade de Motor ($50)
        if (keyboard_check_pressed(ord("1")) && moedas >= 50) {
            moedas -= 50;
            obj_carro.max_speed += 0.5;
            obj_carro.max_speed_base = obj_carro.max_speed;
            obj_carro.max_speed_atual = obj_carro.max_speed;
        }
        
        // [Opção 2] Upgrade de Aceleração ($50)
        if (keyboard_check_pressed(ord("2")) && moedas >= 50) {
            moedas -= 50;
            obj_carro.accel += 0.05;
        }
        
        // [Opção 3] Trocar/Voltar para PNEU NORMAL ($30)
        if (keyboard_check_pressed(ord("3")) && moedas >= 30 && obj_carro.pneu_atual != "normal") {
            moedas -= 30;
            obj_carro.pneu_atual = "normal";
            show_debug_message("PIT: Equipados Pneus Normais.");
        }
        
        // [Opção 4] Trocar para PNEU DE CHUVA ($50)
        if (keyboard_check_pressed(ord("4")) && moedas >= 50 && obj_carro.pneu_atual != "chuva") {
            moedas -= 50;
            obj_carro.pneu_atual = "chuva";
            show_debug_message("PIT: Equipados Pneus de Chuva.");
        }
        
        // [Opção 5] Comprar Seguro de Combustível ($120)
        if (keyboard_check_pressed(ord("5")) && moedas >= custo_seguro && !tem_seguro) {
            moedas -= custo_seguro;
            tem_seguro = true;
            show_debug_message("PIT: Seguro de reboque adquirido!");
        }
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
        if (_acertou) moedas += 20;

        with(obj_carro) {
            pode_mover = true;
            if (_acertou) {
                other.shake_intensidade = 6;
                max_speed_atual = max_speed * 1.4;
                vel = min(vel + 1.5, max_speed_atual);
                image_blend = c_aqua;
                alarm[0] = room_speed * 3;
            } else {
                max_speed_atual = max_speed * 0.4;
                vel = min(vel, max_speed_atual);
                image_blend = c_red;
                alarm[0] = room_speed * 2;
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

// --- 6. META (Sistema Anti-Burla) ---
if (instance_exists(obj_carro)) {
    var _colidiu_com_meta = false;
    with(obj_carro) {
        if (place_meeting(x, y, obj_meta)) _colidiu_com_meta = true;
    }

    if (!_colidiu_com_meta && !pode_contar_volta) {
        pode_contar_volta = true;
    }

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
            show_debug_message("VOLTA CONTADA! Checkpoint resetado.");

        } else {
            pode_contar_volta = false; 
            passou_checkpoint = false;
            show_debug_message("BURLA DETETADA: Ignorado e checkpoint retirado!");
        }
    }
}

// --- 7. SISTEMA DE CLIMA DINÂMICO E INTELIGENTE ---
if (!chuva_ativa) {
    chuva_timer -= 1;
    
    // Suaviza a saída da chuva se o alpha ainda estiver alto
    if (spr_chuva_alpha > 0) spr_chuva_alpha = max(spr_chuva_alpha - 0.01, 0);

    if (chuva_timer <= 0) {
        if (estado_clima == 0) {
            estado_clima = 1; // Transição: Sai da calmaria de 90s para o loop
        }
        chuva_ativa = true;
        // Duração aleatória proposta: 20 a 50 segundos
        chuva_duracao = irandom_range(room_speed * 20, room_speed * 50); 
        spr_chuva_alpha = 0;
        if (instance_exists(obj_carro)) obj_carro.chuva_ativa = true;
        show_debug_message("CHUVA: Começou a chover a sério!");
    }
} else {
    // Fade in das gotas
    spr_chuva_alpha = min(spr_chuva_alpha + 0.02, 0.7);

    chuva_duracao -= 1;
    if (chuva_duracao <= 0) {
        chuva_ativa = false;
        // Intervalo aleatório proposto entre chuvas: 40 a 90 segundos
        chuva_timer = irandom_range(room_speed * 40, room_speed * 90);
        if (instance_exists(obj_carro)) obj_carro.chuva_ativa = false;
        show_debug_message("CHUVA: O céu limpou. Pista a secar!");
    }
}

// --- 8. ANIMAR GOTAS ---
if (chuva_ativa || spr_chuva_alpha > 0) {
    for (var _i = 0; _i < 120; _i++) {
        gotas_chuva[_i][0] += gotas_chuva[_i][3] * 0.4; // deriva lateral
        gotas_chuva[_i][1] += gotas_chuva[_i][3] * 2.5; // cai para baixo

        if (gotas_chuva[_i][1] > 768) {
            gotas_chuva[_i][0] = irandom(1366);
            gotas_chuva[_i][1] = irandom_range(-40, 0);
        }
        if (gotas_chuva[_i][0] > 1366) {
            gotas_chuva[_i][0] = 0;
        }
    }
}