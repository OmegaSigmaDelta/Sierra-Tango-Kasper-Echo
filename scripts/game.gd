extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"


func _ready() -> void:
	MetSys.reset_state()
	MetSys.set_save_data()

	set_player($Ram)

	room_loaded.connect(init_room, CONNECT_DEFERRED)

	add_module("RoomTransitions.gd")


func init_room() -> void:
	var camera := $Ram/Camera2D
	var room := MetSys.get_current_room_instance()

	room.adjust_camera_limits(camera)

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

	if MetSys.last_player_position.x == Vector2i.MAX.x:
		MetSys.set_player_position($Ram.position)

	camera.global_position = $Ram.global_position
