extends "res://Gun.gd"
@onready var model = $Head/Camera3D/smgModel
@onready var muzzle = $Head/Camera3D/smgModel/MuzzlePos


func _ready():
	bullet_scene = preload("res://GunResources/Bullet/Bullet.tscn")
	pass



func _process(delta):
	pass

func shoot():
	# Create a bullet instance
	var bullet = bullet_scene.instance()
	
	# Set the bullet's position and direction
	bullet.global_transform.origin = muzzle.global_transform.origin
	bullet.global_transform.basis = muzzle.global_transform.basis
	
	# Add the bullet to the scene
	get_parent().add_child(bullet)
	
	# Optionally, apply a force or velocity to the bullet
	bullet.apply_impulse(Vector3.ZERO, muzzle.global_transform.basis.z * -1)
