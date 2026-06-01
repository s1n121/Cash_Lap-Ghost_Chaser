// --- 1. CONFIGURAÇÕES GERAIS ---
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _escala = 0.7;
draw_set_font(-1);

// --- CANTO SUPERIOR ESQUERDO ---
draw_set_color(c_black);
draw_set_alpha(0.6);
draw_rectangle(10, 10, 320, 150, false);
draw_set_alpha(1);
draw_set_color(c_white);

draw_text_transformed(20, 20, "TEMPO TOTAL: " + string_format(tempo_decorrido, 1, 2) + "s", _escala, _escala, 0);

var _txt_best = (tempo_melhor_volta == -1) ? "---" : string_format(tempo_melhor_volta, 1, 2) + "s";
draw_set_color((tempo_melhor_volta == -1) ? c_white : c_aqua);
draw_text_transformed(20, 40, "MELHOR VOLTA: " + _txt_best, _escala, _escala, 0);

draw_set_color(c_white);
if (voltas_atuais == 0) {
    draw_set_color(c_yellow);
    draw_text_transformed(20, 60, "VOLTA: 0 — Anda para começar!", _escala, _escala, 0);
} else {
    draw_set_color(c_white);
    draw_text_transformed(20, 60, "VOLTA: " + string(voltas_atuais) + " (" + string_format(tempo_volta_atual, 1, 2) + "s)", _escala, _escala, 0);
    if (passou_checkpoint) {
        draw_set_color(c_lime);
        draw_text_transformed(20, 80, "CHECKPOINT: OK!", _escala, _escala, 0);
    } else {
        draw_set_color(c_orange);
        draw_text_transformed(20, 80, "CHECKPOINT: FALTA PASSAR", _escala, _escala, 0);
    }
}

// Combustível e pneu
if (instance_exists(obj_carro)) {
    var _pct_comb = ceil((obj_carro.combustivel / obj_carro.combustivel_maximo) * 100);
    var _cor_comb = c_lime;
    if (_pct_comb < 50) _cor_comb = c_yellow;
    if (_pct_comb < 20) _cor_comb = c_red;
    draw_set_color(_cor_comb);
    draw_text_transformed(20, 100, "COMBUSTÍVEL: " + string(_pct_comb) + "%", _escala, _escala, 0);

    var _txt_pneu = (obj_carro.pneu_atual == "chuva") ? "CHUVA" : "NORMAL";
    draw_set_color((obj_carro.pneu_atual == "chuva") ? c_aqua : c_white);
    draw_text_transformed(20, 120, "PNEU ATUAL: " + _txt_pneu, _escala, _escala, 0);
}

// --- CANTO SUPERIOR DIREITO: DINHEIRO ---
draw_set_halign(fa_right);
draw_set_color((moedas < 0) ? c_red : c_lime);
draw_text_transformed(_gui_w - 20, 20, "CARTEIRA: $" + string(moedas), 0.9, 0.9, 0);
draw_set_halign(fa_left);

// --- PIT STOP LOJA ---
if (instance_exists(obj_carro)) {
    var _no_pit = false;
    with(obj_carro) { if (place_meeting(x, y, obj_pit)) _no_pit = true; }

    if (_no_pit && obj_carro.vel < 0.8) {
        draw_set_halign(fa_center);
        draw_set_color(c_black); draw_set_alpha(0.7);
        draw_rectangle(_gui_w/2 - 290, _gui_h - 100, _gui_w/2 + 290, _gui_h - 40, false);
        draw_set_alpha(1); draw_set_color(c_white);
        draw_text_transformed(_gui_w/2, _gui_h - 90, "--- PIT STOP: LOJA ---", 0.7, 0.7, 0);

        if (moedas >= 50) {
            draw_set_color(c_yellow);
            var _txt_loja = "[1] +VELOCIDADE ($50) | [2] +ACELERAÇÃO ($50)";
            if (obj_carro.pneu_atual == "normal") {
                _txt_loja += " | [3] PNEU CHUVA ($50)";
            } else {
                _txt_loja += " | [EQUIPADO: PNEU CHUVA]";
            }
            draw_text_transformed(_gui_w/2, _gui_h - 70, _txt_loja, 0.65, 0.65, 0);
        } else {
            draw_set_color(c_red);
            draw_text_transformed(_gui_w/2, _gui_h - 70, "DINHEIRO INSUFICIENTE PARA UPGRADES", 0.7, 0.7, 0);
        }
        draw_set_halign(fa_left);
    }
}

// --- REBOQUE ---
if (aguardando_reboque) {
    draw_set_halign(fa_center);
    draw_set_color(c_black); draw_set_alpha(0.8);
    draw_rectangle(_gui_w/2 - 300, _gui_h/2 - 50, _gui_w/2 + 300, _gui_h/2 + 50, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_gui_w/2, _gui_h/2 - 30, "PANE SECA!", 1, 1, 0);
    draw_set_color(c_white);
    draw_text_transformed(_gui_w/2, _gui_h/2, "Prima [E] para chamar o reboque ($" + string(custo_reboque) + ")", 0.8, 0.8, 0);
    if (moedas < custo_reboque) {
        draw_set_color(c_red);
        draw_text_transformed(_gui_w/2, _gui_h/2 + 25, "AVISO: Dinheiro insuficiente! Sera descontado o que tiver.", 0.7, 0.7, 0);
    }
    draw_set_halign(fa_left);
}

// --- QUIZ ---
if (pergunta_ativa) {
    draw_set_alpha(0.9);
    draw_set_color(c_black);
    draw_rectangle(100, _gui_h - 280, _gui_w - 100, _gui_h - 50, false);
    draw_set_alpha(1);
    draw_set_color(c_aqua);
    draw_rectangle(100, _gui_h - 280, _gui_w - 100, _gui_h - 50, true);

    draw_set_color(c_white);
    draw_text_transformed(120, _gui_h - 260, "DESAFIO FINANCEIRO:", 0.8, 0.8, 0);
    draw_text_transformed(120, _gui_h - 230, texto_exibir, 0.9, 0.9, 0);
    draw_set_color(c_silver);
    draw_text_transformed(140, _gui_h - 180, "A) " + opcoes[0], 0.8, 0.8, 0);
    draw_text_transformed(140, _gui_h - 150, "B) " + opcoes[1], 0.8, 0.8, 0);
    draw_text_transformed(140, _gui_h - 120, "C) " + opcoes[2], 0.8, 0.8, 0);
}

// --- RESET FINAL ---
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);