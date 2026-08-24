extends Control

@onready var resume_button: Button = $Panel/VBoxContainer/Resume
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenu


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS

	hide()


func _input(event: InputEvent) -> void:

	# Pause / unpause
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			close_pause_menu()
		else:
			open_pause_menu()

		get_viewport().set_input_as_handled()
		return


	# Only handle gamepad navigation while paused
	if not get_tree().paused:
		return


	# Gamepad navigation
	if event is InputEventJoypadButton:
		if event.pressed:
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
	show()
	get_tree().paused = true


func close_pause_menu() -> void:
	get_tree().paused = false
	hide()


func move_selection(direction: int) -> void:
	var buttons: Array[Button] = [
		resume_button,
		main_menu_button
	]

	var current_index: int = -1

	for i: int in range(buttons.size()):
		if buttons[i].has_focus():
			current_index = i
			break

	# If nothing is selected, start at the first button.
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
		resume_button.pressed.emit()

	elif main_menu_button.has_focus():
		main_menu_button.pressed.emit()


func _on_resume_pressed() -> void:
	close_pause_menu()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(
		"res://scenes/menus/main_menu.tscn"
	)
