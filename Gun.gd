# Gun.gd
class_name Gun
extends Node3D

	# Properties that all guns should have
@export var fire_rate: float = 0.5  # Time between shots in seconds
var bullet_scene: PackedScene  # The scene for the bullets
@export var muzzle_position: Vector3  
var model: Node3D
var muzzle:Node3D
# A flag to check if the gun can fire
var can_fire: bool = true
var last_shot_time: float = 0.0

func _init():
	pass

func _ready():
	pass

# Method to be called to attempt shooting
func trigger_shoot():
	if can_fire and _can_shoot():
		shoot()
		last_shot_time = Time.get_ticks_msec() / 1000.0

# Abstract method for shooting, to be implemented by subclasses
func shoot():
	pass

# Method to determine if the gun can shoot based on fire rate
func _can_shoot() -> bool:
	return Time.get_ticks_msec() / 1000.0 - last_shot_time >= fire_rate

# Optional method for reloading, can be overridden by subclasses
func reload():
	pass

# Optional method for aiming, can be overridden by subclasses
func aim():
	pass

# Optional method for stopping shooting (e.g., for burst fire)
func stop_shoot():
	pass
func getModel() -> Node3D:
	return self.model

func getMuzzle() -> Node3D:
	return self.model

