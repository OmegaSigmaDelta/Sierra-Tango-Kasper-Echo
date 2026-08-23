extends Control

@onready var main_menu: Button = $Panel/VBoxContainer/MainMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			close_pause_menu()
		else:
			open_pause_menu()


func open_pause_menu() -> void:
	show()
	get_tree().paused = true


func close_pause_menu() -> void:
	get_tree().paused = false
	hide()


func _on_resume_pressed() -> void:
	close_pause_menu()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
