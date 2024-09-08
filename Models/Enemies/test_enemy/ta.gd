extends Node3D


@onready var face_target_y = $f_t_y
@onready var face_target_x = $f_t_y/f_t_x
var target : Node3D
var target_pos
func _ready():
	pass
	

func _physics_process(delta):
	if target:
		target_pos = target.global_transform.origin
		face_target_y.face_point(target_pos, delta)
		face_target_x.face_point(target_pos, delta)

		if face_target_y.is_facing_target(target_pos) and face_target_x.is_facing_target(target_pos):
			show_angry()
		else:
			show_happy()
	#else:
		#print(target)
func show_angry():
	$f_t_y/f_t_x/f_t_x_model_group/Angry_Face.show()
	$f_t_y/f_t_y_model_group/Angry_Flame.show()
	$f_t_y/f_t_x/f_t_x_model_group/Mellow_Face.hide()
	$f_t_y/f_t_y_model_group/Mellow_Flame.hide()
	

func show_happy():
	$f_t_y/f_t_x/f_t_x_model_group/Angry_Face.hide()
	$f_t_y/f_t_y_model_group/Angry_Flame.hide()
	$f_t_y/f_t_x/f_t_x_model_group/Mellow_Face.show()
	$f_t_y/f_t_y_model_group/Mellow_Flame.show()



func _on_area_3d_body_entered(body):
	if body == %Player:
		target = body
		print("IN")



func _on_area_3d_body_exited(body):
	target = null
	print("OUT")
	show_happy()
