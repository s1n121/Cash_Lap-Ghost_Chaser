// --- Valores de Condução ---
max_speed = 5;
max_speed_base = max_speed;
falha_motor = false;
max_speed_atual = max_speed;
vel = 0;
accel = 0.15;
friction_power = 0.05;
turn_speed_original = 3.7;
turn_speed = turn_speed_original;
// --- Estados ---
em_pergunta = false;
pode_mover = true;
esta_derrapando = false;
// --- Combustível e Pneu ---
combustivel_maximo = 100;
combustivel = combustivel_maximo;
pneu_atual = "normal";
// --- Reboque ---
aguardando_reboque = false;
// --- Voltas ---
passou_meta = false;
passou_checkpoint = false;
// --- Chuva ---
chuva_ativa = false;
slip_angle = 0;
saiu_do_pit = false;