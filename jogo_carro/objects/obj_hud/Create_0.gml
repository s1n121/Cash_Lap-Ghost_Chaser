// --- CORRIDA ---
voltas_atuais = 0;
pode_contar_volta = true;
corrida_comecou = false;
tempo_decorrido = 0;
tempo_melhor_volta = -1;
tempo_volta_atual = 0;
shake_intensidade = 0;
meta_pronta_para_primeira_volta = false;
moedas = 99999;
passou_checkpoint = false;
tempo_minimo_volta = 15;
primeira_volta = true;

// --- GOTAS DE CHUVA ---
gotas_chuva = array_create(120);
for (var _i = 0; _i < 120; _i++) {
    gotas_chuva[_i] = [
        irandom(1366),  // x
        irandom(768),   // y
        4 + irandom(8), // comprimento
        2 + irandom(3)  // velocidade
    ];
}

// --- CLIMA REESTRUTURADO ---
chuva_ativa = false;
spr_chuva_alpha = 0;
chuva_duracao = 0;

// Estado 0 = Calmaria Inicial | Estado 1 = Ciclo Aleatório Ativo
estado_clima = 0; 
// Primeiros 90 segundos de jogo totalmente secos (90 * room_speed)
chuva_timer = room_speed * 90; 

// --- REBOQUE & SEGURO ATUALIZADOS ---
aguardando_reboque = false;
custo_reboque = 80;
tem_seguro = false;      // Controla se comprou o seguro
custo_seguro = 100;      // Reduzido para $100 conforme solicitado

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
    ["O que é uma Necessidade?", "Comprar videojogos", "Ir ao cinema", "Alimentação e habitação", 3],
    ["O que significa Poupança?", "Gastar tudo hoje", "Guardar dinheiro para o futuro", "Pedir emprestado", 2],
    ["O que é um Desejo?", "Ter o telemóvel mais caro", "Beber água", "Ter uma casa", 1],
    ["O que são Rendimentos?", "Dinheiro que sai", "Dinheiro que entra", "Dívidas ao banco", 2],
    ["O que é o Fundo de Emergência?", "Dinheiro para festas", "Dinheiro para investir","Dinheiro para imprevistos", 3],
    ["O que é a Inflação?", "Subida geral dos preços", "Descida dos preços", "Ganhar o Euromilhões", 1],
    ["Qual a vantagem de comparar preços?", "Gastar mais", "Poupar dinheiro", "Perder tempo", 2],
    ["O que é um Juro?","O custo do dinheiro emprestado", "Um bónus do governo", "Um tipo de conta", 1],
    ["O que é o Multibanco?", "Uma conta poupança", "Um sistema de pagamentos", "Um presente do banco", 2],
    ["O que é um Crédito?", "Dinheiro oferecido", "Dinheiro emprestado", "Um prémio", 2],
    ["Comprar a prestações é...", "Mais barato", "Mais caro pelos juros", "Grátis", 2],
    ["O que é o IBAN?", "Identificação da conta", "Um código de jogo", "O nome do banco", 1],
    ["Quem deve fazer um orçamento?", "Apenas os ricos", "Apenas os bancos", "Todas as famílias", 3],
    ["Qual a regra de ouro da poupança?", "Gastar primeiro", "Pagar a si mesmo primeiro", "Não poupar", 2]
];

randomizar_perguntas = function(_quantidade) {
    with (obj_pergunta) {
        instance_destroy();
    }
    
    array_shuffle_ext(perguntas_lista);
    
    var _lista_pontos = [];
    with (obj_spawn_ponto) {
        array_push(_lista_pontos, id);
    }
    array_shuffle_ext(_lista_pontos);
    
    var _limite = min(_quantidade, array_length(_lista_pontos));
    var _camada = layer_get_id("Instance_pontos_perguntas");
    
    for (var i = 0; i < _limite; i++) {
        var _ponto = _lista_pontos[i];
        var _inst = instance_create_layer(_ponto.x, _ponto.y, _camada, obj_pergunta);
        _inst.dados_pergunta = perguntas_lista[i mod array_length(perguntas_lista)];
        
        show_debug_message("SPAWNER: Pergunta criada em X=" + string(_ponto.x) + " Y=" + string(_ponto.y));
    }
}

alarm[1] = 1;