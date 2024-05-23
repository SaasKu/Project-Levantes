class_name SMG
extends Gun

var debugLabel:Label3D
var numshots = 0
var muzzle_offset: Vector3
var model_offset: Vector3
@onready var camera = get_parent()

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
	#muzzle.mesh = BoxMesh.new()
	muzzle.position = Vector3(2, 2, -2)
	
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
	get_parent().get_parent().get_parent().get_parent().add_child(bullet)
	# Set the bullet's position and direction
	bullet.global_transform.origin = muzzle.global_transform.origin
	var viewport_size = get_viewport().size
	var ray_origin = camera.project_ray_origin(Vector2(viewport_size.x / 2, viewport_size.y / 2))
	var ray_direction = camera.project_ray_normal(Vector2(viewport_size.x / 2, viewport_size.y / 2))
	var ray_length = 1000  # Arbitrary large value

	# Cast the ray and get the collision point
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_direction
	
	var collision = space_state.intersect_ray(params)

	var target_position: Vector3
	if collision.has("position"):
		target_position = collision.position
	else:
		# If there's no collision, use a point far away in the direction of the ray
		target_position = ray_origin + ray_direction * ray_length
	
	var direction = (target_position - muzzle.global_transform.origin).normalized()
	# Launch the bullet with the direction and muzzle position
	bullet.launch(direction, muzzle.global_transform)
		
	# Add the bullet to the scene
		
		
	numshots += 1
	
	# Optionally, apply a force or velocity to the bullet
	#bullet.apply_impulse(Vector3.ZERO, muzzle.global_transform.basis.z * -1)
	numshots += 1
