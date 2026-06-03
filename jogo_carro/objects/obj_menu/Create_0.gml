menu_opcoes = ["Jogar", "Sair"];
opcao_selecionada = 0;
tempo_animacao = 0;

// Inicia a música do menu em loop (repetir sempre) com prioridade alta
if (!audio_is_playing(snd_menuPrincipal)) {
    audio_play_sound(snd_menuPrincipal, 90, true);
}