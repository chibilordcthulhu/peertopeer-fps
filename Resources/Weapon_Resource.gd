extends Resource
class_name Weapon

enum WeaponType {
	MELEE,
	SHOTGUN,
	AUTORIFLE,
}

@export var type : WeaponType
@export var ammo : String
@export var sprite : Texture2DArray
@export var cooldown : float = 0.2 #time in seconds
@export var automatic : bool = false

@export_category("Sounds")
@export var firing_sounds : Array[AudioStream]
@export var reload_sound : AudioStream
@export var dry_fire_sound : AudioStream = preload("res://Sound Effects/Guns/shot_dry.wav")

@export_category("Bullet Stats")
@export var damage : int
@export var spread : float
@export var max_mag : int
@export var bullet_ammount : int = 1
@export var bullet_range : int = 40
