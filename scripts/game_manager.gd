extends Node

@export var player_scene: PackedScene

var players = {}


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	multiplayer.connected_to_server.connect(_on_connected_to_server)

	# If we are the server, spawn the host player.
	if multiplayer.is_server():
		spawn_player.rpc(multiplayer.get_unique_id())


func _on_peer_connected(peer_id):
	print("Player connected: ", peer_id)

	if multiplayer.is_server():
		spawn_player.rpc(peer_id)


func _on_peer_disconnected(peer_id):
	print("Player disconnected: ", peer_id)

	if players.has(peer_id):
		players[peer_id].queue_free()
		players.erase(peer_id)


func _on_connected_to_server():
	print("Connected to server")


@rpc("call_local", "reliable")
func spawn_player(peer_id):
	if players.has(peer_id):
		return

	var player = player_scene.instantiate()

	player.name = str(peer_id)

	add_child(player)

	player.set_multiplayer_authority(peer_id)

	players[peer_id] = player

	player.global_position = Vector2(
		300 + players.size() * 100,
		300
	)
