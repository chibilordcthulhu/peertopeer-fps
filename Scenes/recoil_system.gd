extends Node

@export var head_path: NodePath   # Path to your head/pitch node
@export var decay_speed := 12.0   # How fast recoil returns to normal

var head: Node3D
var recoil_x := 0.0
var recoil_y := 0.0

func _ready():
	head = get_node(head_path)

func apply_recoil(weapon):
	# Vertical recoil
	recoil_y += weapon.recoil_vertical
	# Horizontal recoil
	var h = randf_range(-weapon.recoil_horizontal, weapon.recoil_horizontal)
	recoil_x += h
	
func _physics_process(delta):
	# Apply accumulated recoil to the camera
	if recoil_x != 0.0 or recoil_y != 0.0:
		# Horizontal (yaw)
		get_parent().rotate_y(-recoil_x)
		# Vertical (pitch)
		head.rotate_x(recoil_y)
		head.rotation.x = clamp(
			head.rotation.x,-PI/3, PI/3, 
			)
			
		# Smooth return to normal
		recoil_x = lerp(recoil_x, 0.0, decay_speed * delta)
		recoil_y = lerp(recoil_y, 0.0, decay_speed * delta)
		
