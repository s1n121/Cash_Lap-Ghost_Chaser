// --- CONFIGURAÇÕES GERAIS ---
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// CORREÇÃO DOS ACENTOS: Ativa a tua fonte configurada com Latin-1 nas propriedades!
if (font_exists(fnt_perguntas)) {
    draw_set_font(fnt_perguntas);
} else {
    draw_set_font(-1); // Fallback de segurança se a fonte mudar de nome
}

// =====================================================
// CHUVA VISUAL PROGRAMÁTICA
// =====================================================
if (chuva_ativa || spr_chuva_alpha > 0) {
    var _a = spr_chuva_alpha;
    var _cor_vinheta = make_color_rgb(10, 30, 60);
    var _grad = 200;

    // Vinheta azul nas bordas
    draw_set_color(_cor_vinheta);
    for (var _i = 0; _i < _grad; _i++) {
        var _alpha_borda = _a * 0.55 * (1 - _i / _grad);
        draw_set_alpha(_alpha_borda);
        draw_line(_i, 0, _i, _gui_h);
        draw_line(_gui_w - _i, 0, _gui_w - _i, _gui_h);
        draw_set_alpha(_alpha_borda * 0.8);
        draw_line(0, _i, _gui_w, _i);
        draw_line(0, _gui_h - _i, _gui_w, _gui_h - _i);
    }

    // Gotas
    draw_set_color(make_color_rgb(180, 220, 255));
    for (var _i = 0; _i < 120; _i++) {
        var _gx = gotas_chuva[_i][0];
        var _gy = gotas_chuva[_i][1];
        var _len = gotas_chuva[_i][2];
        var _alpha_gota = _a * 0.55 + 0.1;
        draw_set_alpha(_alpha_gota);
        draw_line(_gx, _gy, _gx + _len * 0.3, _gy + _len);
    }

    draw_set_alpha(1);
}

// =====================================================
// PAINEL SUPERIOR ESQUERDO — INFO CORRIDA
// =====================================================
draw_set_color(c_black);
draw_set_alpha(0.55);
draw_roundrect_ext(10, 10, 280, 185, 8, 8, false); // Aumentado ligeiramente para caber o estado do seguro
draw_set_alpha(1);

draw_set_color(c_aqua);
draw_set_alpha(0.9);
draw_roundrect_ext(10, 10, 280, 26, 8, 8, false);
draw_set_alpha(1);
draw_set_color(c_black);
draw_text_transformed(22, 12, "CORRIDA", 0.65, 0.65, 0);

draw_set_color(c_white);
draw_text_transformed(22, 32, "TEMPO:  " + string_format(tempo_decorrido, 1, 2) + "s", 0.68, 0.68, 0);

var _txt_best = (tempo_melhor_volta == -1) ? "---" : string_format(tempo_melhor_volta, 1, 2) + "s";
draw_set_color((tempo_melhor_volta == -1) ? c_silver : c_aqua);
draw_text_transformed(22, 52, "MELHOR: " + _txt_best, 0.68, 0.68, 0);

if (voltas_atuais == 0) {
    draw_set_color(c_yellow);
    draw_text_transformed(22, 72, "VOLTA 0 — Arranca para começar!", 0.65, 0.65, 0);
} else {
    draw_set_color(c_white);
    draw_text_transformed(22, 72, "VOLTA " + string(voltas_atuais) + "  (" + string_format(tempo_volta_atual, 1, 2) + "s)", 0.68, 0.68, 0);
    if (passou_checkpoint) {
        draw_set_color(c_lime);
        draw_text_transformed(22, 92, "✓ CHECKPOINT OK", 0.65, 0.65, 0);
    } else {
        draw_set_color(c_orange);
        draw_text_transformed(22, 92, "✗ FALTA CHECKPOINT", 0.65, 0.65, 0);
    }
}

if (instance_exists(obj_carro)) {
    var _pct = ceil((obj_carro.combustivel / obj_carro.combustivel_maximo) * 100);
    var _cor_comb = c_lime;
    if (_pct < 50) _cor_comb = c_yellow;
    if (_pct < 20) _cor_comb = c_red;

    draw_set_color(c_dkgray);
    draw_roundrect_ext(22, 115, 268, 128, 4, 4, false);
    draw_set_color(_cor_comb);
    draw_roundrect_ext(22, 115, 22 + (246 * (_pct / 100)), 128, 4, 4, false);
    draw_set_color(c_white);
    draw_text_transformed(22, 130, "COMBUSTÍVEL  " + string(_pct) + "%", 0.63, 0.63, 0);

    var _txt_pneu = (obj_carro.pneu_atual == "chuva") ? "CHUVA" : "NORMAL";
    draw_set_color((obj_carro.pneu_atual == "chuva") ? c_aqua : c_silver);
    draw_text_transformed(22, 148, "PNEU: " + _txt_pneu, 0.63, 0.63, 0);
    
    // Mostra indicador visual do seguro ativo no HUD lateral
    draw_set_color(tem_seguro ? c_lime : c_gray);
    draw_text_transformed(22, 164, "SEGURO: " + (tem_seguro ? "ATIVADO" : "NÃO CONTRATADO"), 0.58, 0.58, 0);
}

// =====================================================
// CARTEIRA — CANTO SUPERIOR DIREITO
// =====================================================
draw_set_color(c_black);
draw_set_alpha(0.55);
draw_roundrect_ext(_gui_w - 200, 10, _gui_w - 10, 42, 8, 8, false);
draw_set_alpha(1);
draw_set_halign(fa_right);
draw_set_color((moedas < 0) ? c_red : c_lime);
draw_text_transformed(_gui_w - 20, 18, "$ " + string(moedas), 0.9, 0.9, 0);
draw_set_halign(fa_left);

// =====================================================
// AVISO DE CHUVA
// =====================================================
if (chuva_ativa) {
    var _pulse = 0.75 + 0.25 * sin(current_time * 0.006);
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_roundrect_ext(_gui_w/2 - 220, 52, _gui_w/2 + 220, 74, 6, 6, false);
    draw_set_alpha(_pulse);
    draw_set_color(c_aqua);
    draw_text_transformed(_gui_w/2, 56, "⚠  CHUVA  —  ALTERA OS PNEUS NO PIT STOP  ⚠", 0.68, 0.68, 0);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
}

// =====================================================
// ATUALIZADO: PIT STOP — LOJA EXPANDIDA (Grelha Dinâmica)
// =====================================================
if (instance_exists(obj_carro)) {
    var _no_pit = false;
    with (obj_carro) { if (place_meeting(x, y, obj_pit)) _no_pit = true; }

    if (_no_pit && obj_carro.vel < 0.8) {
        var _lx = _gui_w/2;
        var _ly = _gui_h - 260;
        var _pw = 350;
        var _ph = 210;

        draw_set_color(c_black);
        draw_set_alpha(0.88);
        draw_roundrect_ext(_lx - _pw, _ly, _lx + _pw, _ly + _ph, 10, 10, false);
        draw_set_alpha(1);

        draw_set_color(make_color_rgb(20, 60, 80));
        draw_roundrect_ext(_lx - _pw, _ly, _lx + _pw, _ly + 26, 10, 10, false);

        draw_set_halign(fa_center);
        draw_set_color(c_aqua);
        draw_text_transformed(_lx, _ly + 6, "PIT STOP  —  SALA DE COMANDO FINANCEIRO", 0.72, 0.72, 0);

        draw_set_color(c_white);
        draw_text_transformed(_lx, _ly + 32, "Saldo Atual: $" + string(moedas), 0.68, 0.68, 0);

        // [Botão 1] Motor
        var _tem1 = (moedas >= 50);
        draw_set_color(_tem1 ? c_yellow : c_dkgray);
        draw_set_alpha(_tem1 ? 1 : 0.45);
        draw_roundrect_ext(_lx - _pw + 15, _ly + 54, _lx - 15, _ly + 86, 6, 6, false);
        draw_set_color(_tem1 ? c_black : c_gray);
        draw_text_transformed(_lx - _pw/2, _ly + 62, "[1] +VELOCIDADE  $50", 0.62, 0.62, 0);

        // [Botão 2] Aceleração
        var _tem2 = (moedas >= 50);
        draw_set_color(_tem2 ? c_yellow : c_dkgray);
        draw_set_alpha(_tem2 ? 1 : 0.45);
        draw_roundrect_ext(_lx + 15, _ly + 54, _lx + _pw - 15, _ly + 86, 6, 6, false);
        draw_set_color(_tem2 ? c_black : c_gray);
        draw_text_transformed(_lx + _pw/2, _ly + 62, "[2] +ACELERAÇÃO  $50", 0.62, 0.62, 0);

        // [Botão 3] Pneu Normal ($30)
        var _is_normal = (obj_carro.pneu_atual == "normal");
        var _tem3 = (moedas >= 30 && !_is_normal);
        draw_set_color(_is_normal ? c_lime : (_tem3 ? c_white : c_dkgray));
        draw_set_alpha(_is_normal || _tem3 ? 1 : 0.45);
        draw_roundrect_ext(_lx - _pw + 15, _ly + 96, _lx - 15, _ly + 128, 6, 6, false);
        draw_set_color(c_black);
        draw_text_transformed(_lx - _pw/2, _ly + 104, _is_normal ? "✓ PNEU NORMAL" : "[3] PNEU NORMAL  $30", 0.58, 0.58, 0);

        // [Botão 4] Pneu Chuva ($50)
        var _is_chuva = (obj_carro.pneu_atual == "chuva");
        var _tem4 = (moedas >= 50 && !_is_chuva);
        draw_set_color(_is_chuva ? c_lime : (_tem4 ? c_aqua : c_dkgray));
        draw_set_alpha(_is_chuva || _tem4 ? 1 : 0.45);
        draw_roundrect_ext(_lx + 15, _ly + 96, _lx + _pw - 15, _ly + 128, 6, 6, false);
        draw_set_color(c_black);
        draw_text_transformed(_lx + _pw/2, _ly + 104, _is_chuva ? "✓ PNEU CHUVA" : "[4] PNEU CHUVA  $50", 0.58, 0.58, 0);

        // [Botão 5] Novo Seguro de Reboque ($120)
        var _tem5 = (moedas >= custo_seguro && !tem_seguro);
        draw_set_color(tem_seguro ? c_lime : (_tem5 ? make_color_rgb(255, 150, 50) : c_dkgray));
        draw_set_alpha(tem_seguro || _tem5 ? 1 : 0.45);
        draw_roundrect_ext(_lx - _pw + 15, _ly + 138, _lx + _pw - 15, _ly + 170, 6, 6, false);
        draw_set_color(c_black);
        draw_text_transformed(_lx, _ly + 146, tem_seguro ? "✓ SEGURO CONTRA FALTA DE COMBUSTÍVEL ATIVO" : "[5] CONTRATAR SEGURO DE VIAGEM  $120", 0.58, 0.58, 0);

        draw_set_alpha(1);
        draw_set_color(c_gray);
        draw_text_transformed(_lx, _ly + 184, "Gerencia o teu saldo: Trocar pneus evita acidentes e penalizações.", 0.55, 0.55, 0);
        
        draw_set_halign(fa_left);
    }
}

// =====================================================
// REBOQUE (Atualizado para refletir o Seguro)
// =====================================================
if (aguardando_reboque) {
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_set_alpha(0.85);
    draw_roundrect_ext(_gui_w/2 - 280, _gui_h/2 - 65, _gui_w/2 + 280, _gui_h/2 + 65, 10, 10, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_gui_w/2, _gui_h/2 - 48, "PANE SECA!", 1.1, 1.1, 0);
    draw_set_color(c_white);
    
    if (tem_seguro) {
        draw_set_color(c_lime);
        draw_text_transformed(_gui_w/2, _gui_h/2 - 10, "Prima [E] para ativar o Reboque Gratuito do Seguro ($0)", 0.75, 0.75, 0);
    } else {
        draw_text_transformed(_gui_w/2, _gui_h/2 - 10, "Prima [E] para chamar o reboque ($" + string(custo_reboque) + ")", 0.78, 0.78, 0);
        if (moedas < custo_reboque) {
            draw_set_color(c_orange);
            draw_text_transformed(_gui_w/2, _gui_h/2 + 22, "Sem saldo — será descontado o que tiver.", 0.68, 0.68, 0);
        }
    }
    draw_set_halign(fa_left);
}

// =====================================================
// QUIZ (Totalmente compatível com acentos)
// =====================================================
if (pergunta_ativa) {
    var _qx = 100;
    var _qy = _gui_h - 290;
    var _qw = _gui_w - 100;
    var _qh = _gui_h - 45;

    draw_set_color(c_black);
    draw_set_alpha(0.88);
    draw_roundrect_ext(_qx, _qy, _qw, _qh, 10, 10, false);
    draw_set_alpha(1);
    draw_set_color(c_aqua);
    draw_roundrect_ext(_qx, _qy, _qw, _qy + 24, 10, 10, false);

    draw_set_color(c_black);
    draw_text_transformed(_qx + 16, _qy + 6, "DESAFIO FINANCEIRO", 0.72, 0.72, 0);
    draw_set_color(c_white);
    draw_text_transformed(_qx + 16, _qy + 32, texto_exibir, 0.85, 0.85, 0);

    var _ops = [["A", opcoes[0]], ["B", opcoes[1]], ["C", opcoes[2]]];
    for (var _i = 0; _i < 3; _i++) {
        var _oy = _qy + 90 + _i * 52;
        draw_set_color(make_color_rgb(40, 80, 120));
        draw_set_alpha(0.7);
        draw_roundrect_ext(_qx + 16, _oy, _qw - 16, _oy + 38, 6, 6, false);
        draw_set_alpha(1);
        draw_set_color(c_aqua);
        draw_text_transformed(_qx + 28, _oy + 10, _ops[_i][0] + ")", 0.78, 0.78, 0);
        draw_set_color(c_white);
        draw_text_transformed(_qx + 60, _oy + 10, _ops[_i][1], 0.78, 0.78, 0);
    }
}

// =====================================================
// RESET FINAL
// =====================================================
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);