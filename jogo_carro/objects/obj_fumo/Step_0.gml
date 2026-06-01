vida -= 0.08;
if (vida <= 0) { instance_destroy(); exit; }
x += vel_x;
y += vel_y;
vel_y += 0.12; // gravidade
vel_x = lerp(vel_x, 0, 0.06);