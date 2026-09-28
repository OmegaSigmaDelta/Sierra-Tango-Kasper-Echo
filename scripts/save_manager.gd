extends Node

const MetSysSaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")

const SAVE_PATH := "user://save.sav"

var data: Dictionary = {}


func save_game() -> void:
	var save := MetSysSaveManager.new()

	save.set_value("version", 1)
	save.set_value("player", get_player_data())
	save.set_value("location", get_location_data())

	save.save_as_binary(SAVE_PATH)


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var save := MetSysSaveManager.new()
	save.load_from_binary(SAVE_PATH)

	data = save.data

	return true


func get_player_data() -> Dictionary:
	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		push_error("SaveManager: Player not found.")
		return {}

	return player.get_save_data()


func get_location_data() -> Dictionary:
	var room := MetSys.get_current_room_instance()

	if room == null:
		return {
			"room": "",
			"entrance": ""
		}

	var nearest_entrance: Node2D = null
	var nearest_distance := INF

	for node in room.get_tree().get_nodes_in_group("save_entrance"):
		if not node.is_inside_tree():
			continue

		if node.owner != room.owner:
			continue

		var distance := node.global_position.distance_to(
			get_tree().get_first_node_in_group("player").global_position
		)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_entrance = node

	var entrance_id := ""

	if nearest_entrance != null:
		entrance_id = nearest_entrance.get_meta("entrance_id", "")

	return {
		"room": MetSys.get_current_room_id(),
		"entrance": entrance_id
	}
