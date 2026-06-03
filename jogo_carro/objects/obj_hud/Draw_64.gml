// --- CONFIGURAÇÕES GERAIS DE RESOLUÇÃO ---
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// Garante uma fonte válida para evitar flutuações de tamanho no GameMaker
if (font_exists(fnt_perguntas)) {
    draw_set_font(fnt_perguntas);
} else {
    draw_set_font(-1);
}

// Definição de escala base adaptativa para evitar encolhimento do texto
var _scale_txt  = 0.85;
var _scale_sub  = 0.75;
var _scale_mini = 0.65;

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
draw_set_alpha(0.65); // Ligeiramente mais escuro para melhorar contraste
draw_roundrect_ext(10, 10, 290, 205, 8, 8, false); // Aumentado espaço para não espremer
draw_set_alpha(1);

draw_set_color(c_aqua);
draw_set_alpha(0.9);
draw_roundrect_ext(10, 10, 290, 32, 8, 8, false);
draw_set_alpha(1);
draw_set_color(c_black);
draw_text_transformed(22, 14, "CORRIDA", _scale_mini, _scale_mini, 0);

draw_set_color(c_white);
draw_text_transformed(22, 40, "TEMPO:  " + string_format(tempo_decorrido, 1, 2) + "s", _scale_sub, _scale_sub, 0);

var _txt_best = (tempo_melhor_volta == -1) ? "---" : string_format(tempo_melhor_volta, 1, 2) + "s";
draw_set_color((tempo_melhor_volta == -1) ? c_silver : c_aqua);
draw_text_transformed(22, 62, "MELHOR: " + _txt_best, _scale_sub, _scale_sub, 0);

if (voltas_atuais == 0) {
    draw_set_color(c_yellow);
    draw_text_transformed(22, 84, "VOLTA 0 — Arranca para começar!", _scale_mini, _scale_mini, 0);
} else {
    draw_set_color(c_white);
    draw_text_transformed(22, 84, "VOLTA " + string(voltas_atuais) + "  (" + string_format(tempo_volta_atual, 1, 2) + "s)", _scale_sub, _scale_sub, 0);
    if (passou_checkpoint) {
        draw_set_color(c_lime);
        draw_text_transformed(22, 106, "✓ CHECKPOINT OK", _scale_mini, _scale_mini, 0);
    } else {
        draw_set_color(c_orange);
        draw_text_transformed(22, 106, "✗ FALTA CHECKPOINT", _scale_mini, _scale_mini, 0);
    }
}

if (instance_exists(obj_carro)) {
    var _pct = ceil((obj_carro.combustivel / obj_carro.combustivel_maximo) * 100);
    var _cor_comb = c_lime;
    if (_pct < 50) _cor_comb = c_yellow;
    if (_pct < 20) _cor_comb = c_red;

    draw_set_color(c_dkgray);
    draw_roundrect_ext(22, 130, 278, 144, 4, 4, false);
    draw_set_color(_cor_comb);
    draw_roundrect_ext(22, 130, 22 + (256 * (_pct / 100)), 144, 4, 4, false);
    
    draw_set_color(c_white);
    draw_text_transformed(22, 150, "COMBUSTÍVEL  " + string(_pct) + "%", _scale_mini, _scale_mini, 0);

    var _txt_pneu = (obj_carro.pneu_atual == "chuva") ? "CHUVA" : "NORMAL";
    draw_set_color((obj_carro.pneu_atual == "chuva") ? c_aqua : c_silver);
    draw_text_transformed(22, 168, "PNEU: " + _txt_pneu, _scale_mini, _scale_mini, 0);
    
    draw_set_color(tem_seguro ? c_lime : c_gray);
    draw_text_transformed(22, 186, "SEGURO: " + (tem_seguro ? "ATIVADO" : "NÃO CONTRATADO"), _scale_mini, _scale_mini, 0);
}

// =====================================================
// CARTEIRA — CANTO SUPERIOR DIREITO
// =====================================================
draw_set_color(c_black);
draw_set_alpha(0.55);
draw_roundrect_ext(_gui_w - 220, 10, _gui_w - 10, 48, 8, 8, false);
draw_set_alpha(1);
draw_set_halign(fa_right);
draw_set_color((moedas < 0) ? c_red : c_lime);
draw_text_transformed(_gui_w - 25, 16, "$ " + string(moedas), 0.95, 0.95, 0);
draw_set_halign(fa_left);

// =====================================================
// AVISO DE CHUVA
// =====================================================
if (chuva_ativa) {
    var _pulse = 0.75 + 0.25 * sin(current_time * 0.006);
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_roundrect_ext(_gui_w/2 - 240, 52, _gui_w/2 + 240, 78, 6, 6, false);
    draw_set_alpha(_pulse);
    draw_set_color(c_aqua);
    draw_text_transformed(_gui_w/2, 57, "⚠  CHUVA  —  ALTERA OS PNEUS NO PIT STOP  ⚠", _scale_sub, _scale_sub, 0);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
}

// =====================================================
// PIT STOP — CENTRAL DE LOGÍSTICA REESTRUTURADA [1], [2], [3]
// =====================================================
if (instance_exists(obj_carro)) {
    var _no_pit = false;
    with (obj_carro) { if (place_meeting(x, y, obj_pit)) _no_pit = true; }

    if (_no_pit && obj_carro.vel < 0.8) {
        var _lx = _gui_w/2;
        var _ly = _gui_h - 250; 
        var _pw = 380; // Alargado ligeiramente para comportar o texto perfeitamente
        var _ph = 190; 

        // Fundo do painel
        draw_set_color(c_black);
        draw_set_alpha(0.94);
        draw_roundrect_ext(_lx - _pw, _ly, _lx + _pw, _ly + _ph, 10, 10, false);
        draw_set_alpha(1);

        // Cabeçalho
        draw_set_color(make_color_rgb(15, 45, 65));
        draw_roundrect_ext(_lx - _pw, _ly, _lx + _pw, _ly + 32, 10, 10, false);

        draw_set_halign(fa_center);
        draw_set_color(c_aqua);
        draw_text_transformed(_lx, _ly + 8, "PIT STOP  —  SALA DE COMANDO LOGÍSTICO", _scale_sub, _scale_sub, 0);

        draw_set_color(c_white);
        draw_text_transformed(_lx, _ly + 38, "Saldo Atual Disponível: $" + string(moedas), _scale_sub, _scale_sub, 0);

        // --- [OPÇÃO 1] Pneu Normal ($30) ---
        var _is_normal = (obj_carro.pneu_atual == "normal");
        var _tem1 = (moedas >= 30 && !_is_normal);
        draw_set_color(_is_normal ? c_lime : (_tem1 ? c_white : c_dkgray));
        draw_set_alpha(_is_normal || _tem1 ? 1 : 0.5);
        draw_roundrect_ext(_lx - _pw + 20, _ly + 65, _lx - 15, _ly + 100, 6, 6, false);
        draw_set_color(c_black);
        draw_text_transformed(_lx - (_pw/2) - 5, _ly + 74, _is_normal ? "✓ PNEU SLICK ATIVO" : "[1] PNEU NORMAL  $30", _scale_sub, _scale_sub, 0);

        // --- [OPÇÃO 2] Pneu Chuva ($50) ---
        var _is_chuva = (obj_carro.pneu_atual == "chuva");
        var _tem2 = (moedas >= 50 && !_is_chuva);
        draw_set_color(_is_chuva ? c_lime : (_tem2 ? c_aqua : c_dkgray));
        draw_set_alpha(_is_chuva || _tem2 ? 1 : 0.5);
        draw_roundrect_ext(_lx + 15, _ly + 65, _lx + _pw - 20, _ly + 100, 6, 6, false);
        draw_set_color(c_black);
        draw_text_transformed(_lx + (_pw/2) + 5, _ly + 74, _is_chuva ? "✓ PNEU CHUVA ATIVO" : "[2] PNEU CHUVA  $50", _scale_sub, _scale_sub, 0);

        // --- [OPÇÃO 3] SEGURO AUTOMÓVEL ($100) ---
        var _tem3 = (moedas >= custo_seguro && !tem_seguro);
        draw_set_color(tem_seguro ? c_lime : (_tem3 ? make_color_rgb(255, 130, 40) : c_dkgray));
        draw_set_alpha(tem_seguro || _tem3 ? 1 : 0.5);
        draw_roundrect_ext(_lx - _pw + 20, _ly + 115, _lx + _pw - 20, _ly + 150, 6, 6, false);
        draw_set_color(c_black);
        var _str_seguro = tem_seguro ? "✓ APÓLICE AUTOMÓVEL ATIVA: REBOQUES COBERTOS ($0)" : "[3] CONTRATAR APÓLICE DE SEGURO AUTOMÓVEL  $100";
        draw_text_transformed(_lx, _ly + 124, _str_seguro, _scale_sub, _scale_sub, 0);

        // Rodapé Informativo
        draw_set_alpha(1);
        draw_set_color(c_gray);
        draw_text_transformed(_lx, _ly + 168, "A escolha correta de pneus previne acidentes e a perda total de tração.", _scale_mini, _scale_mini, 0);
        
        draw_set_halign(fa_left);
    }
}

// =====================================================
// REBOQUE
// =====================================================
if (aguardando_reboque) {
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_set_alpha(0.88);
    draw_roundrect_ext(_gui_w/2 - 300, _gui_h/2 - 70, _gui_w/2 + 300, _gui_h/2 + 70, 10, 10, false);
    draw_set_alpha(1);
    draw_set_color(c_red);
    draw_text_transformed(_gui_w/2, _gui_h/2 - 45, "PANE SECA!", 1.1, 1.1, 0);
    draw_set_color(c_white);
    
    if (tem_seguro) {
        draw_set_color(c_lime);
        draw_text_transformed(_gui_w/2, _gui_h/2 - 5, "Prima [E] para ativar o Reboque Gratuito do Seguro ($0)", _scale_txt, _scale_txt, 0);
    } else {
        draw_text_transformed(_gui_w/2, _gui_h/2 - 5, "Prima [E] para chamar o reboque ($" + string(custo_reboque) + ")", _scale_txt, _scale_txt, 0);
        if (moedas < custo_reboque) {
            draw_set_color(c_orange);
            draw_text_transformed(_gui_w/2, _gui_h/2 + 26, "Sem saldo — será descontado o valor remanescente.", _scale_sub, _scale_sub, 0);
        }
    }
    draw_set_halign(fa_left);
}

// =====================================================
// QUIZ ATUALIZADO (ALERTA DE FALHA NO MOTOR)
// =====================================================
if (pergunta_ativa) {
    var _qx = 80;
    var _qy = _gui_h - 310;
    var _qw = _gui_w - 80;
    var _qh = _gui_h - 40;

    draw_set_color(c_black);
    draw_set_alpha(0.90);
    draw_roundrect_ext(_qx, _qy, _qw, _qh, 10, 10, false);
    draw_set_alpha(1);
    
    draw_set_color(c_aqua);
    draw_roundrect_ext(_qx, _qy, _qw, _qy + 28, 10, 10, false);

    draw_set_color(c_black);
    draw_text_transformed(_qx + 16, _qy + 6, "DESAFIO FINANCEIRO — SE ERRAR O MOTOR FALHA!", _scale_sub, _scale_sub, 0);
    
    draw_set_color(c_white);
    draw_text_transformed(_qx + 16, _qy + 38, texto_exibir, _scale_txt, _scale_txt, 0);

    var _ops = [["A", opcoes[0]], ["B", opcoes[1]], ["C", opcoes[2]]];
    for (var _i = 0; _i < 3; _i++) {
        var _oy = _qy + 95 + _i * 54;
        draw_set_color(make_color_rgb(40, 80, 120));
        draw_set_alpha(0.75);
        draw_roundrect_ext(_qx + 16, _oy, _qw - 16, _oy + 42, 6, 6, false);
        draw_set_alpha(1);
        
        draw_set_color(c_aqua);
        draw_text_transformed(_qx + 28, _oy + 12, _ops[_i][0] + ")", _scale_txt, _scale_txt, 0);
        draw_set_color(c_white);
        draw_text_transformed(_qx + 65, _oy + 12, _ops[_i][1], _scale_txt, _scale_txt, 0);
    }
}

// =====================================================
// RESET FINAL DE CONTEXTO GRAPHICO
// =====================================================
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);