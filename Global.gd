extends Node

# SERVER
const PORT: int = 9999
var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
const Player = preload("res://Scenes/player.tscn")

# MAIN MENU UI
@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

# decal example (kept from your original)
const BULLET_DECAL = preload("uid://47cjwgcndv43")
var max_decals : int = 10
var spawned_decals : Array = []

# Globals / refs (if you use them elsewhere)
var PlayerRef : CharacterBody3D
var WorldRef : Node3D

signal update_hud

func _ready():
	# nothing auto-spawned here — wait for host/join button
	pass

# --- Input / Quit ---
func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

# --- HOSTING ---
func _on_host_button_pressed() -> void:
	#main_menu.hide()

	# create server and assign to multiplayer API
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer

	# always connect the signals so logic runs regardless of who hosts
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# setup UPNP (best-effort)
	await get_tree().create_timer(0.5).timeout
	upnp_setup()
	# the host must spawn its own player as well
	if multiplayer.is_server():
		main_menu.hide()
		_on_peer_connected(multiplayer.get_unique_id())
		
# --- JOINING ---
func _on_join_button_pressed() -> void:
	main_menu.hide()

	# create client connection and assign to multiplayer API
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer

	# connect signals (clients still connect so we can respond to disconnections, etc.)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# optionally show "connecting..." UI here

# --- CONNECTION HANDLERS ---
func _on_peer_connected(peer_id: int) -> void:
	# Only the server is allowed to instantiate player nodes for everyone.
	# Clients do nothing here (they will receive the nodes via replication).
	if not multiplayer.is_server():
		# we're a client: do not instantiate players locally
		print("Connected: ", peer_id, " (client side — waiting for server to spawn player)")
		return

	# Server spawns the player and assigns authority to the peer
	var player = Player.instantiate()
	player.name = str(peer_id)
	# Add to the scene tree with RPC replication enabled (true)
	add_child(player)

	print("Spawned player for peer:", peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	# Find player's node by its name and free it (on all peers the removal will propagate)
	var node_name = str(peer_id)
	var player = get_node_or_null(node_name)
	if player:
		player.queue_free()
		print("Removed player:", peer_id)
	else:
		print("Peer disconnected but no node found for:", peer_id)

# --- UPNP (best-effort, non-fatal) ---
func upnp_setup() -> void:
	var upnp = UPNP.new()

	var discover_result = upnp.discover()
	print("UPNP discover result:", discover_result)
	if discover_result != UPNP.UPNP_RESULT_SUCCESS:
		printerr("UPNP DISCOVER FAILED! CODE: %s" % discover_result)
		return

	var gateway = upnp.get_gateway()
	if not gateway or not gateway.is_valid_gateway():
		printerr("UPNP INVALID GATEWAY!")
		return

	var map_result = upnp.add_port_mapping(PORT)
	print("UPNP add port mapping result:", map_result)
	if map_result != UPNP.UPNP_RESULT_SUCCESS:
		printerr("UPNP PORT MAPPING FAILED! CODE: %s" % map_result)
		return

	var ext = upnp.query_external_address()
	print("UPNP success. External address: %s" % [ext])

# --- Utility: optional clean shutdown / leave match ---
func leave_session() -> void:
	# remove peer, free nodes, etc.
	# if you want to stop hosting or disconnect as client:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	# optionally clear players
	for child in get_children():
		if child is CharacterBody3D and child.name.is_valid_filename():
			child.queue_free()
	# show menu etc.
	main_menu.show()
