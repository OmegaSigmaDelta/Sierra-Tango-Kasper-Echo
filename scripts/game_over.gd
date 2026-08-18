extends Control

@export var continue_button: Button
@export var leave: Button



func _on_leave_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://scenes/test_scene.tscn")
