extends Control

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/manager_scenes/game.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
