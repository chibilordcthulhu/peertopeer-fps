extends CanvasLayer

@onready var weapon_node = $"../init_weapon"
var hud_current_weapon : String = "shotgun"
var hud_is_attacking = 2 
var hud_is_reloading = 2

func _ready():
	hud_current_weapon = weapon_node.current_weapon
	hud_is_attacking = weapon_node.is_attacking
	hud_is_reloading = weapon_node.is_reloading
	$WeaponSprite.animation_finished.connect(_on_WeaponSprite_animation_finished)
	$WeaponSprite.play(hud_current_weapon + "_idle")
	
func _process(_delta):
	hud_current_weapon = weapon_node.current_weapon
	hud_is_attacking = weapon_node.is_attacking
	hud_is_reloading = weapon_node.is_reloading
	
	if hud_is_attacking == 1:
		$WeaponSprite.play(hud_current_weapon + "_shoot")
		print ("pew")
		
	if hud_is_reloading == 1:
		$WeaponSprite.play(hud_current_weapon + "_reload")
		
func _on_WeaponSprite_animation_finished():
	$WeaponSprite.play(hud_current_weapon + "_idle")
