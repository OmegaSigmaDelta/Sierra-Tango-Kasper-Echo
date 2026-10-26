extends Node

const MetSysSaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")

const SAVE_PATH := "user://save.sav"
const SAVE_VERSION := 1

# Entrance markers inside a room are Marker2D nodes whose name starts with this
# (or that are in the "save_entrance" group). Their id is the "entrance_id"
# metadata, or the node name if the metadata is missing.
const ENTRANCE_NAME_PREFIX := "Entrance"
const ENTRANCE_GROUP := "save_entrance"

var data: Dictionary = {}

# Id of the last entrance Ram came through. Empty = the room's default spawn.
var current_entrance := ""

# Set by menus: true = Game should load the save, false = start a new game.
var load_on_start := false


const LOADING_MIN_TIME := 0.1   # seconds the loading screen stays at least
const LOADING_FADE_TIME := 0.3

var is_loading := false


# Scene change behind a loading screen. The screen is shown for at least
# LOADING_MIN_TIME even if the scene is ready instantly ("fake" loading).
func change_scene_with_loading(path: String) -> void:
	if is_loading:
		return

	is_loading = true

	var overlay := ColorRect.new()
	overlay.color = Color(0.03, 0.03, 0.05)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.modulate.a = 0.0

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	var label := Label.new()
	label.text = "Загрузка..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)

	#var bar := ProgressBar.new()
	#bar.custom_minimum_size = Vector2(320, 14)
	#bar.show_percentage = false
	#bar.min_value = 0.0
	#bar.max_value = 100.0
	#box.add_child(bar)

	var layer := CanvasLayer.new()
	layer.layer = 200
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	layer.add_child(overlay)
	get_tree().root.add_child(layer)

	# Fade in
	var fade_in := overlay.create_tween()
	fade_in.tween_property(overlay, "modulate:a", 1.0, LOADING_FADE_TIME)
	await fade_in.finished

	var started := Time.get_ticks_msec()
	var packed: PackedScene = null
	var failed := false

	if ResourceLoader.load_threaded_request(path) != OK:
		failed = true

	while not failed:
		await get_tree().process_frame

		var elapsed := (Time.get_ticks_msec() - started) / 1000.0
		var t := clampf(elapsed / LOADING_MIN_TIME, 0.0, 1.0)
		var status := ResourceLoader.load_threaded_get_status(path)

		if status == ResourceLoader.THREAD_LOAD_FAILED \
		or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			failed = true
			break

		# Ease-out fill, never claims 100% before it is really done
		#bar.value = (1.0 - pow(1.0 - t, 2.0)) * 95.0

		if status == ResourceLoader.THREAD_LOAD_LOADED and t >= 1.0:
			packed = ResourceLoader.load_threaded_get(path) as PackedScene
			break

	#bar.value = 100.0
	get_tree().paused = false

	if packed != null:
		get_tree().change_scene_to_packed(packed)
	else:
		get_tree().change_scene_to_file(path)

	# Let the new scene finish its _ready before revealing it
	await get_tree().process_frame
	await get_tree().process_frame

	var fade_out := overlay.create_tween()
	fade_out.tween_property(overlay, "modulate:a", 0.0, LOADING_FADE_TIME)
	await fade_out.finished

	layer.queue_free()
	is_loading = false


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func start_new_game() -> void:
	data = {}
	current_entrance = ""


func save_game() -> void:
	var player_data := get_player_data()

	# Don't overwrite a good save with an empty one
	if player_data.is_empty():
		return

	var location := get_location_data()

	if str(location.get("room", "")).is_empty():
		return

	var save := MetSysSaveManager.new()

	save.set_value("version", SAVE_VERSION)
	save.set_value("player", player_data)
	save.set_value("location", location)

	save.save_as_binary(SAVE_PATH)


func load_game() -> bool:
	if not has_save():
		return false

	var save := MetSysSaveManager.new()

	# Also feeds the MetSys part of the data (discovered map cells) to MetSys
	save.load_from_binary(SAVE_PATH)

	if save.data.is_empty():
		return false

	data = save.data
	current_entrance = str(get_saved_location().get("entrance", ""))

	return true


func get_saved_location() -> Dictionary:
	return data.get("location", {})


func get_player() -> Node2D:
	# Ram's child nodes are in the "player" group too, so pick the real one
	for node in get_tree().get_nodes_in_group("player"):
		if node.has_method("get_save_data"):
			return node as Node2D

	return null


func get_player_data() -> Dictionary:
	var player := get_player()

	if player == null:
		push_error("SaveManager: Player not found.")
		return {}

	return player.get_save_data()


func load_player_data() -> void:
	var player := get_player()

	if player == null:
		push_error("SaveManager: Player not found.")
		return

	var player_data: Dictionary = data.get("player", {})

	if player_data.is_empty():
		return

	player.load_save_data(player_data)


func get_location_data() -> Dictionary:
	return {
		"room": MetSys.get_current_room_id(),
		"entrance": current_entrance
	}


# ---------------------------------------------------------------------------
# Entrances
# ---------------------------------------------------------------------------

func get_room_entrances(room: Node) -> Array[Node2D]:
	var result: Array[Node2D] = []

	if room == null:
		return result

	# RoomInstance sits directly under the room scene's root
	var room_root := room.get_parent()

	if room_root == null:
		return result

	for child in room_root.get_children():
		if not child is Marker2D:
			continue

		if child.name.begins_with(ENTRANCE_NAME_PREFIX) or child.is_in_group(ENTRANCE_GROUP):
			result.append(child as Node2D)

	return result


func get_entrance_id(entrance: Node) -> String:
	return str(entrance.get_meta("entrance_id", entrance.name))


func find_entrance(room: Node, entrance_id: String) -> Node2D:
	if entrance_id.is_empty():
		return null

	for entrance in get_room_entrances(room):
		if get_entrance_id(entrance) == entrance_id:
			return entrance

	return null


# Remembers which entrance Ram just came through (the one closest to him).
# Call it right after a room was loaded and Ram was placed in it.
func update_current_entrance() -> void:
	var player := get_player()
	var room := MetSys.get_current_room_instance()

	if player == null or room == null:
		return

	var nearest_entrance: Node2D = null
	var nearest_distance := INF

	for entrance in get_room_entrances(room):
		var distance := entrance.global_position.distance_to(player.global_position)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_entrance = entrance

	if nearest_entrance != null:
		current_entrance = get_entrance_id(nearest_entrance)
	else:
		current_entrance = ""
