extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"

@export_file("room_link") var starting_map: String


func _ready() -> void:
	MetSys.reset_state()
	MetSys.set_save_data()

	set_player($Ram)

	room_loaded.connect(init_room, CONNECT_DEFERRED)

	load_room(starting_map)

	add_module("RoomTransitions.gd")


func init_room() -> void:
	var camera := $Ram/Camera2D

	camera.global_position = $Ram.global_position

	if MetSys.last_player_position.x == Vector2i.MAX.x:
		MetSys.set_player_position($Ram.position)
