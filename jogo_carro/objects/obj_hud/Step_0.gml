// --- 1. CRONÓMETRO (só começa quando o carro se move) ---
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

// --- 2. REBOQUE (Com ponto de Spawn customizado) ---
if (aguardando_reboque) {
    if (keyboard_check_pressed(ord("E"))) {
        if (moedas >= custo_reboque) {
            moedas -= custo_reboque;
        } else {
            moedas = 0;
        }
        
        // Verifica se o carro e o novo ponto de spawn existem na Room
        if (instance_exists(obj_carro) && instance_exists(obj_spawn_reboque)) {
            with (obj_carro) {
                // Move o carro exatamente para as coordenadas do objeto de spawn
                x = obj_spawn_reboque.x;
                y = obj_spawn_reboque.y;
                
                // Imobiliza o carro por completo
                vel = 0;
                speed = 0;
                vspeed = 0;
                hspeed = 0;
                
                // Restaura o estado do jogo
                combustivel = combustivel_maximo;
                pode_mover = true;
            }
        }
        // Desativa o reboque no HUD
        aguardando_reboque = false;
    }
}

// --- 3. PIT STOP ---
if (instance_exists(obj_carro)) {
    var _no_pit = false;
    with(obj_carro) { if (place_meeting(x, y, obj_pit)) _no_pit = true; }

    if (_no_pit && obj_carro.vel < 0.8) {
        if (moedas >= 50) {
            if (keyboard_check_pressed(ord("1"))) {
                moedas -= 50;
                obj_carro.max_speed += 0.5;
                obj_carro.max_speed_atual = obj_carro.max_speed;
            }
            if (keyboard_check_pressed(ord("2"))) {
                moedas -= 50;
                obj_carro.accel += 0.05;
            }
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

// --- 6. META (Sistema Físico Anti-Burla) ---
if (instance_exists(obj_carro)) {
    
    // Verifica se o carro está fisicamente a tocar no objeto obj_meta
    var _colidiu_com_meta = false;
    with(obj_carro) {
        if (place_meeting(x, y, obj_meta)) _colidiu_com_meta = true;
    }

    // Se o carro saiu de perto da meta, libertamos a tranca
    if (!_colidiu_com_meta && !pode_contar_volta) {
        pode_contar_volta = true;
    }

    // Só processa se o carro estiver a tocar na meta E a meta não estiver trancada
    if (_colidiu_com_meta && pode_contar_volta) {
        
        // SE PASSOU NO CHECKPOINT E JÁ DECORREU O TEMPO MÍNIMO
        if (passou_checkpoint == true && tempo_volta_atual >= tempo_minimo_volta) {

            // [O teu código do fantasma fica aqui igual]
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

            // CONTABILIZAR VOLTA
            voltas_atuais += 1;
            
            // LIMPAR LISTAS
            ds_list_clear(lista_x_atual);
            ds_list_clear(lista_y_atual);
            ds_list_clear(lista_angle_atual);
            frame_atual = 0;
            
            // RESET ABSOLUTO DOS CRONÓMETROS E VALIDAÇÕES
            tempo_volta_atual = 0;      // OBRIGATORIAMENTE zero aqui
            passou_checkpoint = false;  // Fica FALSO. Tem de ir ao checkpoint outra vez!
            pode_contar_volta = false;  // Tranca a meta para não repetir no próximo frame
            
            randomizar_perguntas(5);
            show_debug_message("VOLTA CONTADA! Checkpoint resetado.");

        } else {
            // Se ele tocou na meta mas não cumpriu os requisitos (Burla)
            pode_contar_volta = false; 
            passou_checkpoint = false; // Castigo: perde o checkpoint se tentar burlar
            show_debug_message("BURLA DETETADA: Ignorado e checkpoint retirado!");
        }
    }
}