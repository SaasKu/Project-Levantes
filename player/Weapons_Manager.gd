'''
	Make sure to remove print statements when not debugging.
	
	Print statements reduce performance a lot
'''


extends Node3D


@onready var Animation_Player = get_node("WeaponRig/AnimationPlayer")

signal hit(target)

var Current_Weapon = null

var Weapon_Stack = [] #Should be 2 weapons at most

var Weapon_Indicator: int = 0

var Other_Weapon: String

var Weapon_List = {}

var raycast_test = preload("res://Scenes/Assets/raycast_test.tscn")

@export var _weapon_resources: Array[Weapon_Resource]

@export var Starting_Weapons: Array[String]

enum {NULL,HITSCAN,PROJECTILE}

func _ready():
	Initialize(Starting_Weapons) #Enter the state machine

'''
	Don't handle checks in this function
'''
func _input(event):
	if event.is_action_pressed("Weapon_Switch"):
		Weapon_Indicator = !Weapon_Indicator
		exit(Weapon_Stack[Weapon_Indicator])
	elif event.is_action_pressed("Shoot"):
		fire_Wep()
	elif event.is_action_pressed("Reload"):
		reload()

func Initialize(_Starting_Weaps: Array):
	for weapon in _weapon_resources:
		Weapon_List[weapon.Wep_Name] = weapon
	
	for s_weps in _Starting_Weaps:
		Weapon_Stack.push_back(s_weps)
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	enter()
	
	
func enter():
	Animation_Player.queue(Current_Weapon.Equip_Ani)
	
	
func exit(_next_weapon: String):
	if _next_weapon != Current_Weapon.Wep_Name:
		if Animation_Player.get_current_animation() != Current_Weapon.Dequip_Ani:
			Animation_Player.play(Current_Weapon.Dequip_Ani)
			Other_Weapon = _next_weapon
			Weapon_Indicator = !Weapon_Indicator

'''
	There are no checks for if there's only one weapon in the stack
	The checks are handled in exits function
'''
func switch_Wep(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Other_Weapon = ""
	enter()
		
func fire_Wep():
	var f_mode = Current_Weapon.Fire_Mode
	match f_mode:
		"single" :
			var cur_anim = Animation_Player.get_current_animation()
			var anim_check = (cur_anim != Current_Weapon.Dequip_Ani) and (cur_anim != Current_Weapon.Equip_Ani)
			if Current_Weapon.Curr_Mag_Ammo != 0 and anim_check:
				_raycast()
				Animation_Player.play(Current_Weapon.Fire_Ani)
				$AudioStreamPlayer.play()
				Current_Weapon.Curr_Mag_Ammo -= 1
			elif Current_Weapon.Reserve_Ammo != 0 and anim_check:
				reload()
			# print("singlefire")
		"burst":
			var is_wait = Current_Weapon.Is_Waiting
			var is_rel = Current_Weapon.Is_Reloading
			var cur_mag_ammo = Current_Weapon.Curr_Mag_Ammo
			var burst_amount = Current_Weapon.Burst_Count
			
			var cur_anim = Animation_Player.get_current_animation()
			var ammo_checks = cur_mag_ammo != 0 and cur_mag_ammo >= burst_amount
			
			if ammo_checks:
				var checks = (cur_anim != Current_Weapon.Dequip_Ani and cur_anim != Current_Weapon.Equip_Ani and cur_anim != Current_Weapon.Reload_Ani and !is_wait and !is_rel)
				if !checks:
					pass
				elif checks:
					for i in range(burst_amount):
						if Current_Weapon.Is_Reloading:
							Current_Weapon.Is_Reloading = false
						#elif i == 2:
							#await Animation_Player.animation_finished
						Animation_Player.play(Current_Weapon.Fire_Ani)
						$AudioStreamPlayer.play()
						_raycast()
						print(str(Current_Weapon.Curr_Mag_Ammo) + "\n")
						Current_Weapon.Curr_Mag_Ammo -= 1
						await Animation_Player.animation_finished
						#if i == burst_amount-1:
							#await Animation_Player.animation_finished
					
					Current_Weapon.Is_Waiting = true
					Animation_Player.play(Current_Weapon.Wait_Ani)
					await Animation_Player.animation_finished
					Current_Weapon.Is_Waiting = false

					
					
						
					
			elif cur_mag_ammo != 0:
				for i in range(0, cur_mag_ammo):
					if i != 0:
						await Animation_Player.animation_finished
					Animation_Player.play(Current_Weapon.Fire_Ani)
					Current_Weapon.Curr_Mag_Ammo -= 1
			elif Current_Weapon.Reserve_Ammo != 0 and Current_Weapon.Curr_Mag_Ammo == 0:
				reload()
		"auto":
			if Current_Weapon.Curr_Mag_Ammo != 0:
				var cur_anim = Animation_Player.get_current_animation()
				var anim_checks = (cur_anim != Current_Weapon.Dequip_Ani and cur_anim != Current_Weapon.Equip_Ani)
				if anim_checks and Current_Weapon.Curr_Mag_Ammo != 0:
					while Input.is_action_pressed("Shoot") and Current_Weapon.Curr_Mag_Ammo != 0 and Animation_Player.get_current_animation() != Current_Weapon.Reload_Ani:
						Animation_Player.play(Current_Weapon.Fire_Ani)
						$AudioStreamPlayer.play()
						if $WeaponRig/smgModel/SMGRay.is_colliding():
							emit_signal("hit", $WeaponRig/smgModel/SMGRay.get_collider())
							print($WeaponRig/smgModel/SMGRay.get_collider())
						_raycast()
						Current_Weapon.Curr_Mag_Ammo -= 1
						await Animation_Player.animation_finished
						if Current_Weapon.Reserve_Ammo != 0 and Current_Weapon.Curr_Mag_Ammo == 0:
							reload()
				elif anim_checks and Current_Weapon.Curr_Mag_Ammo == 0 and Current_Weapon.Reserve_Ammo != 0:
					reload()


	
func reload():
	var r_ammo = Current_Weapon.Reserve_Ammo
	var c_mag_ammo = Current_Weapon.Curr_Mag_Ammo
	var max_mag_ammo = Current_Weapon.Max_Mag_Capacity
	
	var refill_amount = max_mag_ammo - c_mag_ammo
	if c_mag_ammo == max_mag_ammo:
		pass
	elif r_ammo >= refill_amount:
		var cur_anim = Animation_Player.get_current_animation()
		if ((cur_anim != Current_Weapon.Dequip_Ani) 
			and (cur_anim != Current_Weapon.Equip_Ani)
			and cur_anim != Current_Weapon.Reload_Ani
		):
			Animation_Player.play(Current_Weapon.Reload_Ani)
			Current_Weapon.Curr_Mag_Ammo += refill_amount
			Current_Weapon.Reserve_Ammo -= refill_amount
	else:
		var cur_anim = Animation_Player.get_current_animation()
		if ((cur_anim != Current_Weapon.Dequip_Ani) 
			and (cur_anim != Current_Weapon.Equip_Ani)
			and cur_anim != Current_Weapon.Reload_Ani
		):
			Animation_Player.play(Current_Weapon.Reload_Ani)
			Current_Weapon.Curr_Mag_Ammo += refill_amount
			Current_Weapon.Reserve_Ammo = 0

func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.Dequip_Ani:
		switch_Wep(Other_Weapon)

func _raycast() -> void:
	var camera = %Camera3D
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var endpoint = origin + camera.project_ray_normal(screen_center) * Current_Weapon.Projectile_Range
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var result = space_state.intersect_ray(query)
	if result:
		print(screen_center)
		_test_raycast(result.get("position"), origin-endpoint)

func _test_raycast(impact_position: Vector3, raycast_angle: Vector3) -> void:
	var instance = Raycast_test.new()
	instance.directionval = raycast_angle
	instance.impactpoint = impact_position
	get_tree().root.add_child(instance)
	instance.global_position = impact_position
	await get_tree().create_timer(1).timeout
	instance.queue_free()
	
#func update_hud():
	#
