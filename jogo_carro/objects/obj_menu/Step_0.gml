tempo_animacao += 0.05;

if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
    opcao_selecionada -= 1;
    if (opcao_selecionada < 0) opcao_selecionada = array_length(menu_opcoes) - 1;
}

if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
    opcao_selecionada += 1;
    if (opcao_selecionada >= array_length(menu_opcoes)) opcao_selecionada = 0;
}

if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    switch(opcao_selecionada) {
        case 0:
			// 1. Para a música do menu antes de mudar de sala
if (audio_is_playing(snd_menuPrincipal)) {
    audio_stop_sound(snd_menuPrincipal);
}

// 2. Avança para a pista de corrida
room_goto(Room1);
            room_goto(Room1); 
            break;
        case 1:
            game_end(); 
            break;
    }
}