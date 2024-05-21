extends Node3D

# Constants
const BULLET_SPEED = 10.0
const MAX_LIFETIME = 3.0

# Variables
var lifetime = 0.0

func _ready():
	# Create the MeshInstance3D child
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new() # Assign the mesh resource
	
	
	# Create the RigidBody3D child
	var rigidbody = RigidBody3D.new()
	rigidbody.set_collision_layer(1)
	rigidbody.set_collision_mask(1)
	add_child(rigidbody)
	rigidbody.add_child(mesh_instance)
	# Create the CollisionShape3D child
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = SphereShape3D.new() # Set the collision shape (sphere in this case)
	rigidbody.add_child(collision_shape)
	
	# Set the collision layer and mask
	
	
	# Begin moving the bullet forward
	rigidbody.linear_velocity = transform.basis.z * BULLET_SPEED

func _process(delta):
	# Increase the lifetime of the bullet
	lifetime += delta
	
	# Check if the bullet has exceeded its maximum lifetime
	if lifetime > MAX_LIFETIME:
		delete_self()

func _on_Bullet_body_entered(body):
	# Emit signal indicating collision with another body
	emit_signal("collision_detected", body)

func delete_self():
	# Queue the bullet for deletion
	queue_free()

