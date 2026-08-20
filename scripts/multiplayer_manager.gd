extends Node

const PORT := 7000
const MAX_PLAYERS := 4


func host_game():
	var peer = ENetMultiplayerPeer.new()

	var error = peer.create_server(PORT, MAX_PLAYERS)

	if error != OK:
		print("Could not create server: ", error)
		return

	multiplayer.multiplayer_peer = peer

	print("Hosting game on port ", PORT)


func join_game(ip_address: String):
	var peer = ENetMultiplayerPeer.new()

	var error = peer.create_client(ip_address, PORT)

	if error != OK:
		print("Could not connect: ", error)
		return

	multiplayer.multiplayer_peer = peer

	print("Connecting to ", ip_address)


func stop_game():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
