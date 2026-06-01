if (!instance_exists(obj_hud)) exit;
if (obj_hud.pergunta_ativa) exit;
if (is_undefined(dados_pergunta)) exit;

var _d = dados_pergunta;

obj_hud.pergunta_ativa   = true;
obj_hud.texto_exibir     = _d[0];
obj_hud.opcoes[0]        = _d[1];
obj_hud.opcoes[1]        = _d[2];
obj_hud.opcoes[2]        = _d[3];
obj_hud.resposta_correta = _d[4];

// Para o carro enquanto responde
with (obj_carro) {
    pode_mover = false;
    vel        = 0;
    speed      = 0;
}

instance_destroy();