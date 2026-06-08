// --- 1. FUNDO ---
draw_sprite_stretched(spr_background_menu, 0, 0, 0, room_width, room_height);

draw_set_alpha(0.35);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1.0);

// --- 2. CONFIGURAÇÃO ---
var _x_alinhamento = room_width * 0.05;
var _menu_y_inicial = room_height * 0.28; // era 0.4 — sobe o menu

// --- 3. OPÇÕES DO MENU ---
draw_set_font(fnt_menuOpcoes);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

for (var i = 0; i < array_length(menu_opcoes); i++) {
    var _item_y = _menu_y_inicial + (i * 48);

    if (i == opcao_selecionada) {
        var _escala_pulsar = 1.1 + (sin(tempo_animacao * 2) * 0.05);
        draw_set_color(make_color_rgb(57, 255, 20));
        draw_text_transformed(_x_alinhamento, _item_y, "» " + menu_opcoes[i], _escala_pulsar, _escala_pulsar, 0);
    } else {
        draw_set_color(make_color_rgb(160, 180, 165));
        draw_text(_x_alinhamento, _item_y, "  " + menu_opcoes[i]);
    }
}

// --- 4. SEPARADOR ---
var _sep_y = _menu_y_inicial + (array_length(menu_opcoes) * 48) + 14;
draw_set_color(c_aqua);
draw_set_alpha(0.3);
draw_line(_x_alinhamento, _sep_y, room_width * 0.42, _sep_y);
draw_set_alpha(1);

// --- 5. REGRAS ---
draw_set_font(fnt_controlesEregras);
draw_set_valign(fa_top);

var _guia_y = _sep_y + 16;

draw_set_color(make_color_rgb(150, 220, 0));
draw_text(_x_alinhamento, _guia_y, "CONTROLO E REGRAS:");

var _linhas_guia = [
    "- SETAS / WASD  -  Conduzir o veículo",
    "- TECLA [E]     -  Chamar Reboque ($80, gratuito com seguro)",
    "- TECLA [1]     -  Pit: Trocar para Pneu Normal ($30)",
    "- TECLA [2]     -  Pit: Trocar para Pneu de Chuva ($50)",
    "- TECLA [3]     -  Pit: Contratar Seguro Automóvel ($100)",
    "",
    "COMO JOGAR:",
    "  Passa no Checkpoint antes de cruzar a Meta para a volta ser válida.",
    "  Se entrares no Pit, tens de completar o resto da volta até à Meta.",
    "  Essa passagem pela Meta não conta — só a volta seguinte é válida.",
    "  Responde aos Quizes para ganhar $10 de bónus por resposta certa.",
    "",
    "  CHUVA:  Pneus Chuva dão vantagem na pista molhada.",
    "  SECO:   Pneus Normais (Slick) têm desempenho máximo."
];

draw_set_color(c_white);
for (var j = 0; j < array_length(_linhas_guia); j++) {
    draw_text(_x_alinhamento, _guia_y + 22 + (j * 21), _linhas_guia[j]);
}

// --- 6. RESET ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);