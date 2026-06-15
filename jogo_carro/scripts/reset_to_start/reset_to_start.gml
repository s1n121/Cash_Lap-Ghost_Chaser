function reset_to_start(){
/// reset_to_start
x = global.start_x;
y = global.start_y;
direction = global.start_direction;
image_angle = global.start_direction;
vel = 0;
hspeed = 0;
vspeed = 0;
speed = 0;
slip_angle = 0;
// ← NOVO: apaga checkpoint para a volta não contar
if (instance_exists(obj_hud)) {
    obj_hud.passou_checkpoint = false;
}
}