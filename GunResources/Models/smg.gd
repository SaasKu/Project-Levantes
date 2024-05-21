class_name SMG
extends Gun

var debugLabel:Label3D
var numshots = 0
var muzzle_offset: Vector3
var model_offset: Vector3
func _init():
	pass

func _ready():
	debugLabel = Label3D.new()
	add_child(debugLabel)
	debugLabel.font_size = 50
	debugLabel.scale = Vector3(10,10,10)
	var smgScene = load("res://GunResources/Models/smg.gltf")
	model = smgScene.instantiate()
	add_child(model)
	model.scale = Vector3(0.04, 0.04, 0.04)
	model.transform.origin = Vector3(0.36, -0.14, -0.312)
	muzzle = MeshInstance3D.new()
	model.add_child(muzzle)
	muzzle.set_layer_mask_value(2,1)
	muzzle.mesh = BoxMesh.new()
	muzzle.position = Vector3(0, 0, -13.311)
	
	fire_rate = 0.3
	
	pass


func _process(_delta):
	debugLabel.text = "Shots: " + str(numshots)
	pass

func shoot():
	if muzzle == null:
		print("Muzzle node not found!")
		return

	var bullet_scene = load("res://GunResources/Bullet/Bullet.tscn")
	# Create a bullet instance
	var bullet:Node3D = bullet_scene.instantiate()
	
	# Set the bullet's position and direction
	bullet.global_transform = muzzle.global_transform
	
	# Add the bullet to the scene
	get_parent().get_parent().get_parent().get_parent().add_child(bullet)
	
	# Optionally, apply a force or velocity to the bullet
	#bullet.apply_impulse(Vector3.ZERO, muzzle.global_transform.basis.z * -1)
	numshots += 1
