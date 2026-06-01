// --- 1. DESENHAR A IMAGEM DE FUNDO ---
draw_sprite_stretched(spr_background_menu, 0, 0, 0, room_width, room_height);

// Filtro escuro suave para o texto saltar à vista por cima do fundo
draw_set_alpha(0.4);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1.0);


// --- 2. TÍTULO PRINCIPAL (CASH LAP GHOST CHASER) ---
// NOTA: Se a tua imagem de fundo já tem o título desenhado, podes apagar esta secção
draw_set_font(fnt_titulo); 
draw_set_halign(fa_center);
draw_set_valign(fa_middle);


// --- 3. CONFIGURAÇÃO DA MARGEM ESQUERDA ---
var _x_alinhamento = room_width * 0.1;
var _menu_y_inicial = room_height * 0.4;


// --- 4. SECÇÃO: OPÇÕES (JOGAR / SAIR) ---
draw_set_font(fnt_menuOpcoes); 
draw_set_halign(fa_left); 
draw_set_valign(fa_middle);

for (var i = 0; i < array_length(menu_opcoes); i++) {
    var _item_y = _menu_y_inicial + (i * 50); 
    
    if (i == opcao_selecionada) {
        var _escala_pulsar = 1.1 + (sin(tempo_animacao * 2) * 0.05);
        
        // COR ALTERADA: Verde Neon Brilhante para destacar a seleção!
        draw_set_color(make_color_rgb(57, 255, 20)); 
        draw_text_transformed(_x_alinhamento, _item_y, "» " + menu_opcoes[i], _escala_pulsar, _escala_pulsar, 0);
    } else {
        // COR ALTERADA: Cinzento Claro Esverdeado para as opções apagadas
        draw_set_color(make_color_rgb(160, 180, 165)); 
        draw_text(_x_alinhamento, _item_y, "  " + menu_opcoes[i]);
    }
}


// --- 5. SECÇÃO: GUIA DE CONTROLOS E REGRAS ---
draw_set_font(fnt_controlesEregras); 
draw_set_valign(fa_top);

var _guia_y_inicial = _menu_y_inicial + (array_length(menu_opcoes) * 50) + 30; 

// COR ALTERADA: Verde Lima/Alface vibrante para o título das regras (combina com o fundo!)
draw_set_color(make_color_rgb(150, 220, 0)); 
draw_text(_x_alinhamento, _guia_y_inicial, "CONTROLO E REGRAS:");

// Lista de linhas das regras (Texto em Branco Puro para máxima leitura)
draw_set_color(c_white); 
var _linhas_guia = [
    "- SETAS / WASD -> Conduzir o veículo",
    "- TECLA [E]    -> Chamar Reboque (Custo: 80 moedas)",
    "- TECLA [1]/[2] -> Upgrades dentro do Pit Stop",
    "",
    "COMO JOGAR:",
    "  Passa no Checkpoint a meio da pista antes de cruzar",
    "  a Meta, ou a tua volta legítima não será contada!",
    "  Responde aos Quizes na pista para ganhar bónus.",
    "",
    "DICA: Fazer batota faz-te perder o progresso da volta!"
];

for (var j = 0; j < array_length(_linhas_guia); j++) {
    draw_text(_x_alinhamento, _guia_y_inicial + 25 + (j * 22), _linhas_guia[j]);
}


// --- 6. RESET FINAL DOS PADRÕES ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);