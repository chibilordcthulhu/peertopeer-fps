extends Node

@export var parent : CharacterBody3D
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_hud_anim = $"../Head/Camera3D/WeaponHUD"
@onready var recoil_system: Node = $"../Recoil System"


var current_weapon : Weapon


func player_ready():
	if not is_multiplayer_authority(): return
	if parent.is_in_group("Players"):
		weapon_hud_anim.reload.connect(player_reload)
		

@rpc("call_local")
func shoot():
	if not is_multiplayer_authority(): return
	current_weapon = parent.current_weapon
	
	if parent.can_attack == true and parent.current_bullets > 0:
		var valid_bullets : Array[Dictionary] = get_bullet_raycast()
		
		if current_weapon.type != Weapon.WeaponType.MELEE:
			parent.current_bullets -= 1
		
		#Cooldown
		parent.can_attack = false
		cooldown_timer.start(current_weapon.cooldown)
		#Sound Effect
		SoundManager.play_sfx(current_weapon.firing_sounds.pick_random(),parent)
		
		#Player Only
		if parent.is_in_group("Players"):
			recoil_system.apply_recoil(current_weapon)
			Global.update_hud.emit()
			weapon_hud_anim.play_attack_anim()
			
		#if any bullets hit, do all this
		if valid_bullets.is_empty() == false:
			for b in valid_bullets:
				#Damage
				if b.hit_target.is_in_group("Enemy"): #check if is enemy
					b.hit_target.rpc("change_health", current_weapon.damage * -1)        #change_health(current_weapon.damage * -1) # do something to enemy (hurt)
				
				#Spawn Decal
				var bullet = Global.BULLET_DECAL.instantiate()
				b.hit_target.add_child(bullet)
				bullet.global_transform.origin = b.collision_point
				
				#match decall direction to surface normal
				if b.collision_normal == Vector3(0, 1, 0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				elif b.collision_normal == Vector3(0, -1, 0):
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.RIGHT)
				else:
					bullet.look_at(b.collision_point + b.collision_normal, Vector3.DOWN)
					
				#add to decal count array
				Global.spawned_decals.append(bullet)
				
				#check decal ammount
				if Global.spawned_decals.size() > Global.max_decals:
					Global.spawned_decals[0].queue_free() #remove oldest decal
					Global.spawned_decals.remove_at(0) #removed freed decal from list
			
			
			
func get_bullet_raycast():
	if not is_multiplayer_authority(): return
	current_weapon = parent.current_weapon
	
	var bullet_raycast = parent.bullet_raycast
	var valid_bullets : Array[Dictionary]
	
	for b in current_weapon.bullet_ammount:
		#get spread 
		var spread_x : float = randf_range(current_weapon.spread * -1, current_weapon.spread)
		var spread_y : float = randf_range(current_weapon.spread * -1, current_weapon.spread)
		
		#set spread
		bullet_raycast.target_position = Vector3(spread_x, spread_y, -current_weapon.bullet_range)
		
		#get collided data
		bullet_raycast.force_raycast_update()
		var hit_target = bullet_raycast.get_collider()
		var collision_point = bullet_raycast.get_collision_point()
		var collision_normal = bullet_raycast.get_collision_normal()
		
		#if bullet hit object, get object data
		if hit_target != null:
			var valid_bullet : Dictionary = {
				"hit_target" : hit_target,
				"collision_point" : collision_point,
				"collision_normal" : collision_normal,
				}
				
			# add valid bullet data to array
			valid_bullets.append(valid_bullet)
			
	# send valid bullet data
	return valid_bullets
	
	
#reload
@rpc("call_local")
func reload():
	if not is_multiplayer_authority(): return
	current_weapon = parent.current_weapon
	
	if current_weapon.type != Weapon.WeaponType.MELEE:
		#if mag is missing bullets and player has bullets in inventory
		if parent.current_bullets < current_weapon.max_mag:
			parent.can_attack = false
			parent.is_reloading = true
			
			#player only
			if parent.is_in_group("Players"):
				if parent.ammo[current_weapon.ammo] > 0: #if player has ammo in inventory
					#Sound Effect
					SoundManager.play_sfx(current_weapon.reload_sound, parent)
					#play anim
					weapon_hud_anim.play_reload_anim()
					return
	
	
func player_reload():
	if not is_multiplayer_authority(): return
	current_weapon = parent.current_weapon
	
	#ammo var
	var ammo_amt : int = parent.ammo[current_weapon.ammo] #get player ammo ammount for required ammo
	var missing_ammo : int = current_weapon.max_mag - parent.current_bullets
	
	match ammo_amt >= missing_ammo: #check if player has enough ammo to fill mag
		true: #fill mag
			parent.current_bullets = current_weapon.max_mag
			parent.ammo[current_weapon.ammo] -= missing_ammo
		false: # partially fill mag
			parent.current_bullets += parent.ammo[current_weapon.ammo]
			parent.ammo[current_weapon.ammo] = 0
			
	#allow player to shoot again and update hud
	parent.can_attack = true
	parent.is_reloading = false
	Global.update_hud.emit()
	
	
	
	
func _on_cooldown_timer_timeout() -> void:
	if not is_multiplayer_authority(): return
	parent.can_attack = true
	
