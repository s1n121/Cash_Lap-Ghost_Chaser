// --- CORRIDA ---
voltas_atuais = 0;
pode_contar_volta = true;
corrida_comecou = false;
tempo_decorrido = 0;
tempo_melhor_volta = -1;
tempo_volta_atual = 0;
shake_intensidade = 0;
meta_pronta_para_primeira_volta = false;
moedas = 0;
passou_checkpoint = false;
tempo_minimo_volta = 15;

// --- REBOQUE ---
aguardando_reboque = false;
custo_reboque = 80;

// --- RECORDE ---
ini_open("recorde.ini");
recorde_global = ini_read_real("Scores", "melhor_tempo", -1);
ini_close();

// --- FANTASMA ---
lista_x_atual = ds_list_create();
lista_y_atual = ds_list_create();
lista_angle_atual = ds_list_create();
frame_atual = 0;
global.tem_fantasma = false;
global.fantasma_gravar_x = ds_list_create();
global.fantasma_gravar_y = ds_list_create();
global.fantasma_gravar_angle = ds_list_create();

// --- QUIZ ---
pergunta_ativa = false;
texto_exibir = "";
opcoes = ["", "", ""];
resposta_correta = 0;

// --- PERGUNTAS COM ACENTOS ATIVADOS ---
perguntas_lista = [
    ["O que é o Orçamento Familiar?", "Registo de ganhos e gastos", "Um plano de férias", "Um tipo de empréstimo", 1],
    ["O que é uma Necessidade?", "Comprar videojogos", "Alimentação e habitação", "Ir ao cinema", 2],
    ["O que significa Poupança?", "Gastar tudo hoje", "Guardar dinheiro para o futuro", "Pedir emprestado", 2],
    ["O que é um Desejo?", "Beber água", "Ter o telemóvel mais caro", "Ter uma casa", 2],
    ["O que são Rendimentos?", "Dinheiro que sai", "Dinheiro que entra", "Dívidas ao banco", 2],
    ["O que é o Fundo de Emergência?", "Dinheiro para festas", "Dinheiro para imprevistos", "Dinheiro para investir", 2],
    ["O que é a Inflação?", "Subida geral dos preços", "Descida dos preços", "Ganhar o Euromilhões", 1],
    ["Qual a vantagem de comparar preços?", "Gastar mais", "Poupar dinheiro", "Perder tempo", 2],
    ["O que é um Juro?", "Um bónus do governo", "O custo do dinheiro emprestado", "Um tipo de conta", 2],
    ["O que é o Multibanco?", "Uma conta poupança", "Um sistema de pagamentos", "Um presente do banco", 2],
    ["O que é um Crédito?", "Dinheiro oferecido", "Dinheiro emprestado", "Um prémio", 2],
    ["Comprar a prestações é...", "Mais barato", "Mais caro pelos juros", "Grátis", 2],
    ["O que é o IBAN?", "Identificação da conta", "Um código de jogo", "O nome do banco", 1],
    ["Quem deve fazer um orçamento?", "Apenas os ricos", "Todas as famílias", "Apenas os bancos", 2],
    ["Qual a regra de ouro da poupança?", "Gastar primeiro", "Pagar a si mesmo primeiro", "Não poupar", 2]
];

// --- SPAWN DE PERGUNTAS SEGURO ---
randomizar_perguntas = function(_quantidade) {
    var _obj_id = asset_get_index("obj_pergunta");
    
    if (_obj_id != -1) {
        with (_obj_id) {
            instance_destroy();
        }
    } else {
        show_debug_message("Erro: obj_pergunta não existe no projeto!");
        return;
    }
    
    array_shuffle_ext(perguntas_lista);
    var _lista_pontos = [];
    with (obj_spawn_ponto) array_push(_lista_pontos, id);
    array_shuffle_ext(_lista_pontos);
    var _limite = min(_quantidade, array_length(_lista_pontos));
    
    for (var i = 0; i < _limite; i++) {
        var _ponto = _lista_pontos[i];
        var _camada = layer_get_id("Instance_pontos_perguntas");
        if (_camada == -1) _camada = layer;
        
        var _inst = instance_create_layer(_ponto.x, _ponto.y, _camada, _obj_id);
        _inst.dados_pergunta = perguntas_lista[i % array_length(perguntas_lista)];
		// ADICIONA ESTA LINHA LOGO ABAIXO:
show_debug_message("SPAWNER: Criei uma pergunta na posição X: " + string(_ponto.x) + " Y: " + string(_ponto.y));
    }
}

// Dá 1 frame de descanso para o GameMaker carregar todos os pontos vermelhos na sala
alarm[1] = 1;