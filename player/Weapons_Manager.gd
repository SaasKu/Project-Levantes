extends Node3D

@onready var Animation_Player = get_node("WeaponRig/AnimationPlayer")

var Current_Weapon = null

var Weapon_Stack = [] #Should be 2 weapons at most

var Weapon_Indicator = 0

var Other_Weapon: String

var Weapon_List = {}

@export var _weapon_resources: Array[Weapon_Resource]

@export var Starting_Weapons: Array[String]

func _ready():
	Initialize(Starting_Weapons) #Enter the state machine

func _input(event):
	if event.is_action_pressed("Weapon_Switch"):
		Weapon_Indicator = min(Weapon_Indicator+1, Weapon_Stack.size()-1)
		exit(Weapon_Stack[Weapon_Indicator])
func Initialize(_Starting_Weaps: Array):
	#Creates the dictionary that refers to our guns
	for weapon in _weapon_resources:
		Weapon_List[weapon.Wep_Name] = weapon
	
	for s in _Starting_Weaps:
		Weapon_Stack.push_back(s)
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	enter()
	
	
func enter():
	Animation_Player.queue(Current_Weapon.Equip_Ani)
	
	
func exit(_next_weapon: String):
	#In order to change weapons first call exit
	if _next_weapon != Current_Weapon.Wep_Name:
		if Animation_Player.get_current_animation() != Current_Weapon.Dequip_Ani:
			Animation_Player.play(Current_Weapon.Dequip_Ani)
			Other_Weapon = _next_weapon
func switch_Wep(weapon_name: String):
	var Weapon_Index = Weapon_List.find(weapon_name)
	if Weapon_Index != -1:
		Current_Weapon = Weapon_List[weapon_name]
		Other_Weapon = ""
		enter()



func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.Dequip_Ani:
		switch_Wep(Other_Weapon)

