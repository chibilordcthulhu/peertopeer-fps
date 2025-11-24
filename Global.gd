extends Node


#decal
const BULLET_DECAL = preload("uid://47cjwgcndv43")
var max_decals : int = 10
var spawned_decals : Array

## Global Control
#References
var PlayerRef : CharacterBody3D
var WorldRef : Node3D

## UI Control
#References
#var PauseRef : Control

@warning_ignore("unused_signal")
signal update_hud


## UI
#func check_menus():
	#if PauseRef.is_open == true:
		#return true
	#else:
		#return false

#Quit
func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
