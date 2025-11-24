extends CharacterBody3D


#Player Nodes
@onready var camera : Camera3D = $Head/Camera3D
@onready var weaponHUD : CanvasLayer = $Head/Camera3D/WeaponHUD

#System Nodes
@onready var weapon_system: Node = $WeaponSystem

#Raycast
@onready var bullet_raycast: RayCast3D = $Head/Camera3D/Bullet_RayCast3

#Guns
var current_weapon : Weapon = SHOTGUN
var can_attack : bool = true
var is_reloading : bool = false
var current_bullets : int = current_weapon.max_mag

const AUTORIFLE = preload("uid://fccsorg7n1ch")
const AXE = preload("uid://kxeplm5otxd2")
const SHOTGUN = preload("uid://c7hd4n6uvbrqw")

var ammo : Dictionary = {
	"melee" : 1,
	"shotgun" : 200,
	"autorifle" : 200,
}


#movement var
const SPEED = 10.0
const JUMP_VELOCITY = 10.0
	
	
#On ready
func _ready():
	#capture mouse to window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#Update and Connect Player UI
	Global.update_hud.emit()
	#call weapon system ready
	weapon_system.player_ready()
	
#camera look
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if  event.is_action_pressed("reload"):
		weapon_system.reload()
		
	if event.is_action_pressed("weapon1") and is_reloading == false:
		switch_weapon(SHOTGUN)
	if event.is_action_pressed("weapon2") and is_reloading == false:
		switch_weapon(AUTORIFLE)
	
	
#movement
func _physics_process(delta: float) -> void:
	
	#Weapon
	#Semi-Automatic
	if Input.is_action_just_pressed("attack") and current_weapon.automatic == false:
		weapon_system.shoot()
	#Automatic
	if Input.is_action_pressed("attack") and current_weapon.automatic != false:
		print(current_weapon)
		weapon_system.shoot()
	
	
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#call walking animation
		weaponHUD.play_walking_anim()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


#Player Actions
func switch_weapon(new_weapon : Weapon):
	if new_weapon == current_weapon:
		return #do nothing
		
	#add bullets back to ammo count
	ammo[current_weapon.ammo] += current_bullets
	current_bullets = 0
	
	#switch gun resource
	current_weapon = new_weapon
	
	#call weapon sprite change
	weaponHUD.on_weapon_switch()
	Global.update_hud.emit()
		
	pass
