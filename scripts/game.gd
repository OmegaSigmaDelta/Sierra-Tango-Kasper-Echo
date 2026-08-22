extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"

@export_file("room_link") var starting_map: String


func _ready() -> void:
	MetSys.reset_state()
	MetSys.set_save_data()

	set_player($Ram)
	$Ram.z_index = 100

	room_loaded.connect(init_room, CONNECT_DEFERRED)

	if starting_map.is_empty():
		push_error("Starting Map is empty! Assign a .room_link file in the Game node Inspector.")
		return

	add_module("RoomTransitions.gd")

	load_room(starting_map)


func init_room() -> void:
	var camera: Camera2D = $Ram/Camera2D
	var room := MetSys.get_current_room_instance()

	if room == null:
		push_error("MetSys failed to load the current room.")
		return

	# Apply the room's camera limits
	room.adjust_camera_limits(camera)

	# If this is the first room and there is no saved player position,
	# let MetSys determine the player's position from the current map cell.
	if MetSys.last_player_position.x == Vector2i.MAX.x:
		MetSys.set_player_position($Ram.position)

	# Keep the camera centered on Ram
	camera.global_position = $Ram.global_position

	print("ROOM LOADED: ", room)
	print("ROOM SIZE: ", room.get_size())
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
