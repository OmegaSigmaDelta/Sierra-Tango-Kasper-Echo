extends Control


@onready var buttons: VBoxContainer = $Buttons
@onready var start_button: Button = $Buttons/Start
@onready var settings_button: Button = $Buttons/Settings
@onready var exit_button: Button = $Buttons/Exit
@onready var settings_menu: Control = $SettingsMenu


func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	process_mode = Node.PROCESS_MODE_ALWAYS
	settings_menu.process_mode = Node.PROCESS_MODE_ALWAYS

	settings_menu.hide()
	buttons.show()

	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
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


func move_selection(direction: int) -> void:
	if not buttons.visible:
		return

	var menu_buttons: Array[Button] = [
		start_button,
		settings_button,
		exit_button
	]

	var current_index := -1

	for i in range(menu_buttons.size()):
		if menu_buttons[i].has_focus():
			current_index = i
			break

	if current_index == -1:
		current_index = 0
	else:
		current_index += direction

	if current_index < 0:
		current_index = menu_buttons.size() - 1
	elif current_index >= menu_buttons.size():
		current_index = 0

	menu_buttons[current_index].grab_focus()


func press_selected_button() -> void:
	if not buttons.visible:
		return

	if start_button.has_focus():
		_on_play_pressed()

	elif settings_button.has_focus():
		_on_settings_pressed()

	elif exit_button.has_focus():
		_on_exit_pressed()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(
		"res://scenes/manager_scenes/game.tscn"
	)


func _on_settings_pressed() -> void:
	buttons.hide()
	settings_menu.show()

	settings_menu.get_node(
		"Panel/VBoxContainer/Master"
	).grab_focus()


func _on_settings_back_pressed() -> void:
	settings_menu.hide()
	buttons.show()

	start_button.grab_focus()


func _on_exit_pressed() -> void:
	get_tree().quit()
