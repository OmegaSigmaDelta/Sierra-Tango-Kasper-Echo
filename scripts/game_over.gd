extends Control

@export var continue_button: Button
@export var leave: Button
@export var start: Button

func _on_leave_pressed():
	SaveManager.change_scene_with_loading("res://scenes/menus/main_menu.tscn")


# Respawn at the last saved entrance. Without a save this starts a new game.
func _on_continue_button_pressed():
	SaveManager.load_on_start = SaveManager.has_save()
	SaveManager.change_scene_with_loading("res://scenes/manager_scenes/game.tscn")
