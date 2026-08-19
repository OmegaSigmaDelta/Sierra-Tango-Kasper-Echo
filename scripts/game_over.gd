extends Control

@export var continue_button: Button
@export var leave: Button
@export var start: Button

func _ready():
	start.grab_focus()

func _on_leave_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://scenes/scenes/test_scene.tscn")
