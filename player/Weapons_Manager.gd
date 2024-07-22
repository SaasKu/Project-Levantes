'''
	Make sure to remove print statements when not debugging.
	
	Print statements reduce performance a lot
'''


extends Node3D

@onready var Animation_Player = get_node("WeaponRig/AnimationPlayer")

var Current_Weapon = null

var Weapon_Stack = [] #Should be 2 weapons at most

var Weapon_Indicator: int = 0

var Other_Weapon: String

var Weapon_List = {}

@export var _weapon_resources: Array[Weapon_Resource]

@export var Starting_Weapons: Array[String]

func _ready():
	Initialize(Starting_Weapons) #Enter the state machine

'''
	Don't handle checks in this function
'''
func _input(event):
	if event.is_action_pressed("Weapon_Switch"):
		Weapon_Indicator = !Weapon_Indicator
		#print(Weapon_Indicator)
		exit(Weapon_Stack[Weapon_Indicator])
	elif event.is_action_pressed("Shoot"):
		fire_Wep()
	elif event.is_action_pressed("Reload"):
		reload()
func Initialize(_Starting_Weaps: Array):
	#Creates the dictionary that refers to our guns
	for weapon in _weapon_resources:
		Weapon_List[weapon.Wep_Name] = weapon
	
	for s_weps in _Starting_Weaps:
		Weapon_Stack.push_back(s_weps)
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	enter()
	
	
func enter():
	Animation_Player.queue(Current_Weapon.Equip_Ani)
	
	
func exit(_next_weapon: String):
	#print("exit function called")
	#print(len(Weapon_Stack))
	#In order to change weapons first call exit
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
		
# TODO: Remove print statements 
func fire_Wep():
	var f_mode = Current_Weapon.Fire_Mode
	#Acts as switch statement
	match f_mode:
		"single" :
			if Current_Weapon.Curr_Mag_Ammo != 0:
				var cur_anim = Animation_Player.get_current_animation()
				if (cur_anim != Current_Weapon.Dequip_Ani) and (cur_anim != Current_Weapon.Equip_Ani):
					Animation_Player.play(Current_Weapon.Fire_Ani)
				print("firing | singlefire")
			elif Current_Weapon.Reserve_Ammo != 0:
				reload()
			print("singlefire")
		"burst":
			var cur_mag_ammo = Current_Weapon.Curr_Mag_Ammo
			var burst_amount = Current_Weapon.Burst_Count
			if cur_mag_ammo != 0 and cur_mag_ammo >= burst_amount:
				var cur_anim = Animation_Player.get_current_animation()
				if (cur_anim != Current_Weapon.Dequip_Ani) and (cur_anim != Current_Weapon.Equip_Ani):
					for i in range(0, burst_amount):
						'''
							Burst Rifle code doesn't work
							Need a way to figure out when the animation finishes so it can play again for all 
							three rounds for the burst.
						'''
						if !Animation_Player.is_playing and Animation_Player.get_current_animation() == Current_Weapon.Fire_Ani:
							Animation_Player.play(Current_Weapon.Fire_Ani)
							print(i)
						
			elif cur_mag_ammo != 0:
				for i in range(0, cur_mag_ammo):
					Animation_Player.play(Current_Weapon.Fire_Ani)
			elif Current_Weapon.Reserve_Ammo != 0:
				reload()
			print("burstfire")
		"auto":
			if Current_Weapon.Curr_Mag_Ammo != 0:
				var cur_anim = Animation_Player.get_current_animation()
				if (cur_anim != Current_Weapon.Dequip_Ani) and (cur_anim != Current_Weapon.Equip_Ani):
					Animation_Player.play(Current_Weapon.Fire_Ani)
			print("auto")
	
func reload():
	var r_ammo = Current_Weapon.Reserve_Ammo
	var c_mag_ammo = Current_Weapon.Curr_Mag_Ammo
	var max_mag_ammo = Current_Weapon.Max_Mag_Capacity
	if c_mag_ammo != 0 and c_mag_ammo != max_mag_ammo:
		var cur_anim = Animation_Player.get_current_animation()
		if ((cur_anim != Current_Weapon.Dequip_Ani) 
			and (cur_anim != Current_Weapon.Equip_Ani)
			and cur_anim != Current_Weapon.Reload_Ani
		):
			Animation_Player.play(Current_Weapon.Reload_Ani)
		
	print("reloading")



func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.Dequip_Ani:
		switch_Wep(Other_Weapon)

