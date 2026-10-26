extends Control


@onready var buttons: VBoxContainer = $Buttons
@onready var start_button: Button = $Buttons/Start
@onready var settings_button: Button = $Buttons/Settings
@onready var exit_button: Button = $Buttons/Exit
@onready var settings_menu: Control = $SettingsMenu

var continue_button: Button


func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	process_mode = Node.PROCESS_MODE_ALWAYS
	settings_menu.process_mode = Node.PROCESS_MODE_ALWAYS

	settings_menu.hide()
	buttons.show()

	setup_continue_button()

	if continue_button != null:
		continue_button.grab_focus()
	else:
		start_button.grab_focus()


# "Продолжить" appears above "Играть" only when a save file exists
func setup_continue_button() -> void:
	if not SaveManager.has_save():
		return

	continue_button = start_button.duplicate()
	continue_button.name = "Continue"
	continue_button.text = "Продолжить"

	buttons.add_child(continue_button)
	buttons.move_child(continue_button, 0)

	continue_button.pressed.connect(_on_continue_pressed)

	# Focus order (keyboard / gamepad): Continue sits between Exit and Start
	continue_button.focus_neighbor_top = continue_button.get_path_to(exit_button)
	continue_button.focus_neighbor_bottom = continue_button.get_path_to(start_button)
	start_button.focus_neighbor_top = start_button.get_path_to(continue_button)
	exit_button.focus_neighbor_bottom = exit_button.get_path_to(continue_button)


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

	var menu_buttons: Array[Button] = []

	if continue_button != null:
		menu_buttons.append(continue_button)

	menu_buttons.append(start_button)
	menu_buttons.append(settings_button)
	menu_buttons.append(exit_button)

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

	if continue_button != null and continue_button.has_focus():
		_on_continue_pressed()

	elif start_button.has_focus():
		_on_play_pressed()

	elif settings_button.has_focus():
		_on_settings_pressed()

	elif exit_button.has_focus():
		_on_exit_pressed()


func _on_play_pressed() -> void:
	# New game (the old save is overwritten at the first autosave)
	SaveManager.load_on_start = false

	SaveManager.change_scene_with_loading(
		"res://scenes/manager_scenes/game.tscn"
	)


func _on_continue_pressed() -> void:
	SaveManager.load_on_start = true

	SaveManager.change_scene_with_loading(
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

	if continue_button != null:
		continue_button.grab_focus()
	else:
		start_button.grab_focus()


func _on_exit_pressed() -> void:
	get_tree().quit()
