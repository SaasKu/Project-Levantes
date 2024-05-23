extends Node3D

# Constants
const BULLET_SPEED = 10.0
const MAX_LIFETIME = 3.0
const INITIAL_OFFSET = 0.5  # Offset to avoid immediate collision
const BULLET_SCALE = Vector3(0.1, 0.1, 0.1)  # Scale of the bullet

# Variables
var lifetime = 0.0
var velocity = Vector3.ZERO

# Signals
signal hit_something

func _ready():
	# Create the MeshInstance3D child
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new() # Assign the mesh resource
	mesh_instance.scale = BULLET_SCALE  # Set the scale of the mesh

	# Create the RigidBody3D child
	var rigidbody = RigidBody3D.new()
	rigidbody.set_collision_layer(2)  # Ensure this layer does not collide with the player layer
	rigidbody.set_collision_mask(1)  # Ensure it can collide with appropriate targets
	add_child(rigidbody)
	rigidbody.add_child(mesh_instance)

	# Create the CollisionShape3D child
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.1  # Set the radius to match the scale
	collision_shape.shape = sphere_shape
	rigidbody.add_child(collision_shape)

	# Set the initial velocity
	rigidbody.linear_velocity = velocity

func launch(direction: Vector3, muzzle_position: Transform3D):
	# Apply initial offset to avoid immediate collision
	global_transform = muzzle_position.translated(direction * INITIAL_OFFSET)
	
	velocity = direction.normalized() * BULLET_SPEED
	# Set the initial velocity of the rigidbody
	$MeshInstance3D/RigidBody3D.linear_velocity = velocity

func _process(delta):
	# Increase the lifetime of the bullet
	lifetime += delta

	# Check if the bullet has exceeded its maximum lifetime
	if lifetime > MAX_LIFETIME:
		delete_self()

func _physics_process(delta):
	# Move the bullet and check for collisions
	var collision = move_and_collide(velocity * delta)
	if collision:
		emit_signal("hit_something")
		delete_self()

func move_and_collide(motion: Vector3):
	var collider = $MeshInstance3D/RigidBody3D.move_and_collide(motion)
	return collider

func delete_self():
	# Queue the bullet for deletion
	queue_free()


