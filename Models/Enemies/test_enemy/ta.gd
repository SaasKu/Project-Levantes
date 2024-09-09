extends Node3D


@onready var face_target_y = $f_t_y
@onready var face_target_x = $f_t_y/f_t_x
@onready var Animation_Player = get_node("AnimationPlayer")
var target : Node3D
var target_pos
var enemy

var health = 5
@onready var speed = face_target_y.follow_speed
@onready var non_flame_y = $f_t_y/f_t_y_model_group/non_flame_y
@onready var f_t_y_shield = $f_t_y/f_t_y_shield
@onready var non_face_x = $f_t_y/f_t_x/f_t_x_model_group/non_face_x
@onready var f_t_x_shield = $f_t_y/f_t_x/f_t_x_shield



func _ready():
	enemy = $CharacterBody3D
	pass
	

func _physics_process(delta):
	if target:
		target_pos = target.global_transform.origin
		face_target_y.face_point(target_pos, delta)
		face_target_x.face_point(target_pos, delta)
		if face_target_y.is_facing_target(target_pos) and face_target_x.is_facing_target(target_pos):
			show_angry()
			var velocity = position.direction_to(target.position) * speed
			self.position += velocity
		else:
			show_happy()
		 # Reset z-axis rotation
		var rot = rotation_degrees
		rot.z = 0
		rotation_degrees = rot
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
	if body.is_in_group("Player") or body == %Player:
		target = body
		print("IN")



func _on_area_3d_body_exited(body):
	if body.is_in_group("Player") or body == %Player:
		target = null
		print("OUT")
		show_happy()
		



func _on_weapons_manager_hit(tar):
	if tar == enemy:
		print("HITTTTT")
		$AudioStreamPlayer3D.play()
		non_flame_y.hide()
		non_face_x.hide()
		f_t_y_shield.show()
		f_t_x_shield.show()
		await get_tree().create_timer(.1).timeout
		non_flame_y.show()
		non_face_x.show()
		f_t_y_shield.hide()
		f_t_x_shield.hide()
		
		health -= 1
		if health == 0:
			Animation_Player.queue("explosion")
			await Animation_Player.animation_finished
			$".".queue_free()
	
	pass # Replace with function body.
