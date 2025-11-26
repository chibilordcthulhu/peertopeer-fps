extends Control

@onready var ammo_count_label: Label = $AmmoCount_Label
@onready var health_count_label: Label = $HealthCount_Label
@onready var is_dead_label: Label = $Dead

func _ready() -> void:
	if not is_multiplayer_authority(): return
	visible = true
	Global.update_hud.connect(_on_update_hud)


func _on_update_hud():
	if not is_multiplayer_authority(): return
	var player : CharacterBody3D = $".."
	
	#ammo count visibilty
	if player.current_weapon.type == Weapon.WeaponType.MELEE:
		ammo_count_label.visible = false
	else:
		ammo_count_label.visible = true
		
	#Set Ammo Label
	ammo_count_label.text = "%s / %s" % [player.current_bullets, player.ammo[player.current_weapon.ammo]]
	health_count_label.text = "%s" % [player.health]
	
	if player.is_dead == true:
		is_dead_label.visible = true
	else:
		is_dead_label.visible = false
	
