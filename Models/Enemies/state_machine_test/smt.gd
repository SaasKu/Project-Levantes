extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D
@export var SPEED = 5.0
@onready var face_target_y = $f_t_y
@onready var face_target_x = $f_t_y/f_t_x
var curr_state = "idle"
var next_state = "idle"
var prev_state

var offset

func _ready():
	offset = add_rand_offset(2)
func _physics_process(delta):
	prev_state = curr_state
	curr_state = next_state
	
	match curr_state:
		"idle":
			idle()
		"chase":
			chase()
		"retreat":
			retreat()
	

func update_target_location(target_location):
	nav_agent.target_position = target_location
	
func add_rand_offset(offset_amount) -> Vector3:
	var offset = Vector3(randf() - offset_amount, 0, randf() - offset_amount).normalized() * offset_amount
	return offset

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	match curr_state:
		"idle":
			velocity = Vector3.ZERO
			move_and_slide()
		"chase":
			velocity = velocity.move_toward(safe_velocity+offset, 0.25)
			move_and_slide()
		"retreat":
			velocity = velocity.move_toward(safe_velocity+offset, 0.25)
			move_and_slide()
			

func idle():
	#print("idling")
	velocity = Vector3.ZERO
	move_and_slide()

func chase():
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(new_velocity)
	

	
func retreat():
	#print("retreating")
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(-new_velocity)



func _on_chase_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "chase"
		



func _on_chill_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "retreat" 
		



func _on_chase_body_exited(body):
	if body.is_in_group("Player"):
		next_state = "chase"
