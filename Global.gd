extends Node

#SERVER
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
const Player = preload("res://Scenes/player.tscn")

#main menu
@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

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

#on host press
func _on_host_button_pressed():
	main_menu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	
	upnp_setup()
	
#on join press
func _on_join_button_pressed():
		main_menu.hide()
		
		enet_peer.create_client(address_entry.text, PORT)
		multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP DISCOVER FAILED! ERROR %s" % discover_result)
		
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP INVALID GATEWAY!")
		
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP PORT MAPPING FAILED! ERROR %s" % map_result)
		
	print("Sucess! Join Address: %s" % upnp.query_external_address())
	
