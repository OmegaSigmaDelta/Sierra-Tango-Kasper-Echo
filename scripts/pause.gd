extends Control

@onready var resume_button: Button = $Panel/VBoxContainer/Resume
@onready var settings_button: Button = $Panel/VBoxContainer/Settings
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenu

@onready var pause_panel: Panel = $Panel
@onready var settings_menu: Control = $Settings


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_menu.process_mode = Node.PROCESS_MODE_ALWAYS

	settings_menu.hide()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			close_pause_menu()
		else:
			open_pause_menu()

		get_viewport().set_input_as_handled()
		return

	if not get_tree().paused:
		return

	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_DPAD_DOWN:
			move_selection(1)
			get_viewport().set_input_as_handled()

		elif event.button_index == JOY_BUTTON_DPAD_UP:
			move_selection(-1)
			get_viewport().set_input_as_handled()

		elif event.button_index == JOY_BUTTON_A:
			press_selected_button()
			get_viewport().set_input_as_handled()


func open_pause_menu() -> void:
	settings_menu.hide()
	pause_panel.show()
	show()
	get_tree().paused = true
	resume_button.grab_focus()


func close_pause_menu() -> void:
	get_tree().paused = false
	settings_menu.hide()
	pause_panel.show()
	hide()


func move_selection(direction: int) -> void:
	var buttons: Array[Button] = [
		resume_button,
		settings_button,
		main_menu_button
	]

	var current_index := -1

	for i in range(buttons.size()):
		if buttons[i].has_focus():
			current_index = i
			break

	if current_index == -1:
		current_index = 0
	else:
		current_index += direction

		if current_index < 0:
			current_index = buttons.size() - 1
		elif current_index >= buttons.size():
			current_index = 0

	buttons[current_index].grab_focus()


func press_selected_button() -> void:
	if resume_button.has_focus():
		_on_resume_pressed()
	elif settings_button.has_focus():
		_on_settings_pressed()
	elif main_menu_button.has_focus():
		_on_main_menu_pressed()


func _on_resume_pressed() -> void:
	close_pause_menu()


func _on_settings_pressed() -> void:
	pause_panel.hide()
	settings_menu.show()
	settings_menu.get_node("Panel/VBoxContainer/Master").grab_focus()


func _on_settings_back_pressed() -> void:
	settings_menu.hide()
	pause_panel.show()
	settings_button.grab_focus()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(
		"res://scenes/menus/main_menu.tscn"
	)
