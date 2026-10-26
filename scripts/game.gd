extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"

@export_file("room_link") var starting_map: String

# How far from the room edge Ram is placed when spawning at an entrance,
# so he doesn't immediately walk back into the neighbouring room.
const ENTRANCE_EDGE_MARGIN := 32.0

var spawn_entrance := ""
var room_loads := 0


func _ready() -> void:
	MetSys.reset_state()

	var loaded_save := false

	if SaveManager.load_on_start:
		loaded_save = SaveManager.load_game()

	SaveManager.load_on_start = false

	if not loaded_save:
		SaveManager.start_new_game()
		MetSys.set_save_data()

	set_player($Ram)
	$Ram.z_index = 100

	room_loaded.connect(init_room, CONNECT_DEFERRED)

	if starting_map.is_empty():
		push_error("Starting Map is empty! Assign a .room_link file in the Game node Inspector.")
		return

	var first_room := starting_map

	if loaded_save:
		SaveManager.load_player_data()

		var location: Dictionary = SaveManager.get_saved_location()
		var saved_room := str(location.get("room", ""))

		if not saved_room.is_empty() and ResourceLoader.exists(saved_room):
			first_room = saved_room
			spawn_entrance = str(location.get("entrance", ""))
		else:
			push_warning("Saved room is missing, starting from the beginning.")

	load_room(first_room)

	add_module("RoomTransitions.gd")


func _unhandled_input(event: InputEvent) -> void:
	# Manual save (action "save") and reload from the save (action "load")
	if event.is_action_pressed("save"):
		SaveManager.save_game()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("load"):
		if SaveManager.has_save():
			SaveManager.load_on_start = true
			get_tree().paused = false
			SaveManager.change_scene_with_loading(scene_file_path)

		get_viewport().set_input_as_handled()


func init_room() -> void:
	var camera: Camera2D = $Ram/Camera2D
	var room := MetSys.get_current_room_instance()

	if room == null:
		push_error("MetSys failed to load the current room.")
		return

	# Apply the room's camera limits
	room.adjust_camera_limits(camera)

	room_loads += 1
	var is_first_load := room_loads == 1

	if is_first_load:
		# Loaded from a save: put Ram at the entrance he last came through.
		# New game: stay at the scene's default position (no entrance yet).
		if not place_ram_at_entrance(room, spawn_entrance):
			spawn_entrance = ""

		SaveManager.current_entrance = spawn_entrance
	else:
		# Ram walked into a new room: remember where he entered and autosave
		SaveManager.update_current_entrance()
		SaveManager.save_game()

	# If this is the first room and there is no saved player position,
	# let MetSys determine the player's position from the current map cell.
	if MetSys.last_player_position.x == Vector2i.MAX.x:
		MetSys.set_player_position($Ram.position)

	# Keep the camera centered on Ram
	camera.global_position = $Ram.global_position
	camera.reset_smoothing()

	print("ROOM LOADED: ", room)
	print("ROOM SIZE: ", room.get_size())
	print("ENTRANCE: ", SaveManager.current_entrance)
	print(
		"CAMERA LIMITS: ",
		camera.limit_left,
		", ",
		camera.limit_top,
		", ",
		camera.limit_right,
		", ",
		camera.limit_bottom
	)


# Returns false if there is no such entrance in the room.
func place_ram_at_entrance(room: Node, entrance_id: String) -> bool:
	var entrance := SaveManager.find_entrance(room, entrance_id)

	if entrance == null:
		return false

	var size: Vector2 = room.call("get_size")
	var target: Vector2 = entrance.global_position

	# Entrances sit on the room border; step a bit inside
	target.x = clampf(
		target.x,
		ENTRANCE_EDGE_MARGIN,
		size.x - ENTRANCE_EDGE_MARGIN
	)

	$Ram.global_position = target
	$Ram.velocity = Vector2.ZERO

	# Tell MetSys where Ram is now (same room, so this can't trigger a room change)
	MetSys.set_player_position($Ram.position)

	return true
