extends CanvasLayer

@export var player: CharacterBody3D

var is_reloading : bool = false
var is_attacking : bool = false

signal reload


func _ready():
	if not is_multiplayer_authority(): return
	visible = true
	var equiped_weapon = str(player.current_weapon.type)
	$WeaponSprite.animation_finished.connect(_on_WeaponSprite_animation_finished)
	$WeaponSprite.play(equiped_weapon + "_idle")
	
func _process(_delta):
	pass
	
func play_walking_anim():
	if not is_multiplayer_authority(): return
	if is_reloading == false and is_attacking == false:
		var equiped_weapon = str(player.current_weapon.type)
		$WeaponSprite.play(equiped_weapon + "_walk")
	
	
func play_attack_anim():
	if not is_multiplayer_authority(): return
	var equiped_weapon = str(player.current_weapon.type)
	$WeaponSprite.play(equiped_weapon + "_attack")
	is_attacking = true
	
func play_reload_anim():
	if not is_multiplayer_authority(): return
	var equiped_weapon = str(player.current_weapon.type)
	$WeaponSprite.play(equiped_weapon + "_reload")
	is_reloading = true
	
func on_weapon_switch():
	if not is_multiplayer_authority(): return
	var equiped_weapon = str(player.current_weapon.type)
	$WeaponSprite.play(equiped_weapon + "_idle")
	
	
	
	
func _on_WeaponSprite_animation_finished():
	if not is_multiplayer_authority(): return
	var equiped_weapon = str(player.current_weapon.type)
	
	if $WeaponSprite.animation == equiped_weapon + "_reload":
		is_reloading = false
		reload.emit()
		$WeaponSprite.play(equiped_weapon + "_idle")
		
	if $WeaponSprite.animation == equiped_weapon + "_attack":
		is_attacking = false
		$WeaponSprite.play(equiped_weapon + "_idle")
		
	else:
		$WeaponSprite.play(equiped_weapon + "_idle")
	
	
	
