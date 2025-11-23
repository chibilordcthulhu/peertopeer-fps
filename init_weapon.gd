@tool

extends Node

@export var WEAPON_TYPE : Weapons:
	set(value):
		WEAPON_TYPE = value
		if Engine.is_editor_hint():
			load_weapon()
			
@onready var current_weapon : String = "shotgun"
@onready var is_attacking = 2
@onready var is_reloading = 2
var current_ammo = 0
var time_since_last_shot = 0.0
var can_attack = 0.0


func _process(delta):
	time_since_last_shot += delta
	can_attack = time_since_last_shot >= (1.0 / WEAPON_TYPE.fire_rate)
	if current_ammo == 1:
		print(current_ammo)
	
func _unhandled_input(_event):
	if Input.is_action_pressed("weapon1"):
		WEAPON_TYPE = load("res://weapons/Shotgun/shotgun.tres")
		load_weapon()
	if Input.is_action_pressed("weapon2"):
		WEAPON_TYPE = load("res://weapons/AutoRifle/autorifle.tres")
		load_weapon()
	if Input.is_action_pressed("attack") and can_attack and current_ammo > 0:
		main_attack()
	else: is_attacking = 2
	
	if Input.is_action_pressed("reload") and current_ammo != WEAPON_TYPE.max_ammo:
		reload()
	else: is_reloading = 2
	
func load_weapon():
	current_weapon = WEAPON_TYPE.name
	current_ammo = WEAPON_TYPE.max_ammo
	
func main_attack()-> void:
	is_attacking = 1
	time_since_last_shot = 0.0
	if current_ammo > 0:
		current_ammo -=1
		
func reload():
	is_reloading = 1
	current_ammo = WEAPON_TYPE.max_ammo
	
	
	
