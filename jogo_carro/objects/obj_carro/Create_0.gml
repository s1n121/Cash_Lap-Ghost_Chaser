// --- Valores de Condução ---
max_speed = 4;
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

global.start_x = x;
global.start_y = y;
global.start_direction = direction;

// Upgrade de combustível (0 = base, 1 = +25, 2 = +50, 3 = +75)
fuel_upgrade_nivel = 0;
// Tabela de consumo por nível
fuel_consumo_base   = 0.05;  // nível 0 → 100 max
fuel_consumo_nivel1 = 0.04;  // nível 1 → 125 max
fuel_consumo_nivel2 = 0.03;  // nível 2 → 150 max
fuel_consumo_nivel3 = 0.02;  // nível 3 → 175 max

fuel_upgrade_nivel = 0;